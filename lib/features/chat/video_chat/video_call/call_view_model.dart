import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:manager/api_endpoints.dart';

import 'package:manager/core/locator.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/socket_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../../../core/models/hive/user/user.dart';
import '../../../../core/storage/storage.dart';

class CallParticipant with ChangeNotifier {
  final Participant participant;
  final ApiService apiService = locator.get<ApiService>();

  VideoTrack? videoTrack;
  bool isMuted;

  CallParticipant({
    required this.participant,
    this.videoTrack,
    this.isMuted = true,
  });

  void setVideoTrack(VideoTrack? track) {
    videoTrack = track;
    notifyListeners();
  }

  void setMuted(bool muted) {
    isMuted = muted;
    notifyListeners();
  }
}

class CallViewModel with ChangeNotifier {
  final SocketService _socketService = SocketService();
  final _chatService = locator<ChatService>();

  String _roomName = 'flutter-group-call-demo';
  String roomToken = 'flutter-group-call-demo';
  Room? get room => _room;
  User userData = getUser();
  Room? _room;
  String get roomId => _room?.name ?? '';
  EventsListener<RoomEvent>? _listener;

  bool _isConnecting = false;
  bool _isVoice = false;
  bool get isVoice => _isVoice;
  bool get isConnecting => _isConnecting;

  List<CallParticipant> _participants = [];
  List<CallParticipant> get participants => _participants;

  bool _shouldPop = false;
  bool get shouldPop => _shouldPop;

  bool _hasOtherJoined = false;

  CallParticipant? get mainParticipant {
    if (_participants.isEmpty) return null;
    return _participants.firstWhere(
          (p) => p.participant != _room?.localParticipant,
      orElse: () => _participants.first,
    );
  }

  List<CallParticipant> get otherParticipants {
    if (_participants.isEmpty) return [];
    final mainP = mainParticipant;
    return _participants.where((p) => p != mainP).toList();
  }

  bool _isMicOn = true;
  bool get isMicOn => _isMicOn;

  bool _isVideoOn = true;
  bool get isVideoOn => _isVideoOn;

  // Speaker mode for voice call
  bool _isSpeakerOn = false;
  bool get isSpeakerOn => _isSpeakerOn;

  Timer? _callDurationTimer;
  int _callDurationSeconds = 0;

  Future<void> initCall({
    required String roomName,
    required String token,
    required bool isVoice,
  }) async {
    _roomName = roomName;
    roomToken = token;
    _isVoice = isVoice;

    // Voice call mein video default off
    if (_isVoice) {
      _isVideoOn = false;
    }

    await _requestPermissions();
    await _connectToRoom();
  }

  Future<void> _requestPermissions() async {
    if (_isVoice) {
      // Voice call ke liye sirf microphone permission
      await Permission.microphone.request();
    } else {
      // Video call ke liye camera + microphone
      await [Permission.camera, Permission.microphone].request();
    }
  }

  String get callDuration {
    final duration = Duration(seconds: _callDurationSeconds);
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _connectToRoom() async {
    _isConnecting = true;
    notifyListeners();

    try {
      final authToken = roomToken;

      // Voice call ke liye different room options
      final roomOptions = _isVoice
          ? const RoomOptions(
        adaptiveStream: false,
        dynacast: false,
        defaultAudioPublishOptions: AudioPublishOptions(
          dtx: true, // Discontinuous transmission for voice
        ),
      )
          : const RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
      );

      _room = Room();
      _listener = _room!.createListener();

      await _room!.connect(
        ApiEndpoints.livekit_endpoint,
        authToken,
        roomOptions: roomOptions,
      );

      if (_isVoice) {
        // Voice call: Sirf microphone enable karo
        await _room!.localParticipant?.setMicrophoneEnabled(true);
        // Camera explicitly disable
        await _room!.localParticipant?.setCameraEnabled(false);
      } else {
        // Video call: Camera + Microphone dono enable
        await _room!.localParticipant?.setCameraEnabled(true);
        await _room!.localParticipant?.setMicrophoneEnabled(true);
      }

      _setupListeners();
      _setupSocketListeners();
      _updateParticipants();
      _startCallTimer();

    } catch (e) {
      print('Could not connect to room: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _setupListeners() {
    _listener!
      ..on<RoomDisconnectedEvent>((event) {
        print("Disconnected from room: ${event.reason}");
        disconnect();
      })
      ..on<ParticipantEvent>((event) => _updateParticipants())
      ..on<ParticipantConnectedEvent>((event) {
        print("Participant Connected: ${event.participant.identity}");
        _updateParticipants();
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        print("Participant Disconnected: ${event.participant.identity}");
        _updateParticipants();
      })
      ..on<TrackSubscribedEvent>((event) => _updateParticipants())
      ..on<TrackUnsubscribedEvent>((event) => _updateParticipants())
      ..on<LocalTrackPublishedEvent>((event) => _updateParticipants())
      ..on<TrackMutedEvent>((event) => _updateParticipants())
      ..on<TrackUnmutedEvent>((event) => _updateParticipants());
  }

  void _setupSocketListeners() {
    print("Setting up socket listeners for call events...");
    _socketService.on('call-ended', _handleRemoteCallEnd);
  }

  void _handleRemoteCallEnd(dynamic data) {
    print("Socket event: 'call-ended' received. Terminating call.");
    _socketService.off('call-ended');
    _shouldPop = true;
    disconnect();
  }

  void _updateParticipants() {
    final allParticipants = <Participant>[];
    if (_room?.localParticipant != null) {
      allParticipants.add(_room!.localParticipant!);
    }
    allParticipants.addAll(_room!.remoteParticipants.values);

    _participants = allParticipants.map((p) {
      final audioPub = p.audioTrackPublications.firstOrNull;

      if (_isVoice) {
        // Voice call: Video track null
        return CallParticipant(
          participant: p,
          videoTrack: null,
          isMuted: audioPub?.muted ?? true,
        );
      } else {
        // Video call: Video track include karo
        final videoPub = p.videoTrackPublications.firstOrNull;
        return CallParticipant(
          participant: p,
          videoTrack: videoPub?.track as VideoTrack?,
          isMuted: audioPub?.muted ?? true,
        );
      }
    }).toList();

    _participants.sort((a, b) {
      if (a.participant == _room?.localParticipant) return 1;
      if (b.participant == _room?.localParticipant) return -1;
      return (a.participant.joinedAt!).compareTo(b.participant.joinedAt!);
    });

    // Handle auto-exit logic
    if (_participants.length > 1) {
      _hasOtherJoined = true;
    }

    if (_hasOtherJoined && _participants.length <= 1 && !_shouldPop && !_isConnecting) {
      print("Auto-exiting: Room participant count dropped to 1 after someone had joined.");
      endCall();
      return;
    }

    notifyListeners();
  }

  void toggleMic() {
    if (_room?.localParticipant == null) return;
    _isMicOn = !_isMicOn;
    _room!.localParticipant!.setMicrophoneEnabled(_isMicOn);
    notifyListeners();
  }

  void toggleVideo() {
    // Voice call mein video toggle disable
    if (_isVoice) return;

    if (_room?.localParticipant == null) return;
    _isVideoOn = !_isVideoOn;
    _room!.localParticipant!.setCameraEnabled(_isVideoOn);
    notifyListeners();
  }

  // Speaker toggle for voice call
  void toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    try {
      await Hardware.instance.setSpeakerphoneOn(_isSpeakerOn);
    } catch (e) {
      print('Error toggling speaker: $e');
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    print("Disconnecting from room...");
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    await _room?.disconnect();
    _room = null;
    notifyListeners();
  }

  Future<void> endCall() async {
    print("User initiated End Call. Emitting event and disconnecting...");
    _socketService.off('call-ended'); // Prevent handling the event we might trigger
    _socketService.emit('call-event', {'eventType': 'call-end'});
    _shouldPop = true;
    await disconnect();
  }

  void _startCallTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    print("Disposing CallViewModel");
    _socketService.off('call-ended');
    _callDurationTimer?.cancel();
    _listener?.dispose();
    _room?.dispose();
    super.dispose();
  }
}

@immutable
class TokenResponse {
  final String serverUrl;
  final String participantToken;

  const TokenResponse({
    required this.serverUrl,
    required this.participantToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      serverUrl: json['serverUrl'] as String,
      participantToken: json['participantToken'] as String,
    );
  }
}