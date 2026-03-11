import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../model/chat_message_model.dart';

class ChatAudioMessageBubble extends StatefulWidget {
  const ChatAudioMessageBubble({
    super.key,
    required this.messageId,
    required this.attachment,
    required this.isSentByMe,
  });

  final String messageId;
  final Attachment attachment;
  final bool isSentByMe;

  @override
  State<ChatAudioMessageBubble> createState() =>
      _ChatAudioMessageBubbleState();
}

class _ChatAudioMessageBubbleState extends State<ChatAudioMessageBubble> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  bool _isLoading = false;
  String? _errorText;

  bool get _isPlaying => _playerState == PlayerState.playing;

  String get _audioUrl {
    final url = widget.attachment.url;
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  Duration get _resolvedDuration {
    if (_duration > Duration.zero) {
      return _duration;
    }
    if (widget.attachment.durationInSeconds != null) {
      return Duration(seconds: widget.attachment.durationInSeconds!);
    }
    return Duration.zero;
  }

  double get _progress {
    final total = _resolvedDuration.inMilliseconds;
    if (total == 0) {
      return 0;
    }
    final value = _position.inMilliseconds / total;
    return value.clamp(0.0, 1.0).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
        if (state == PlayerState.stopped) {
          _position = Duration.zero;
        }
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });

    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      _ChatAudioPlaybackCoordinator.instance.clear(widget.messageId);
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completionSubscription?.cancel();
    _ChatAudioPlaybackCoordinator.instance.clear(widget.messageId);
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      setState(() {
        _errorText = null;
      });

      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      await _ChatAudioPlaybackCoordinator.instance.activate(
        widget.messageId,
        () async {
          await _audioPlayer.stop();
          if (!mounted) return;
          setState(() {
            _position = Duration.zero;
          });
        },
      );

      setState(() {
        _isLoading = true;
      });

      if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(UrlSource(_audioUrl));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Unable to play audio';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isSentByMe ? AppColors.white : AppColors.primaryDark;
    final trackColor = widget.isSentByMe
        ? AppColors.white.withValues(alpha: 0.28)
        : AppColors.primary.withValues(alpha: 0.12);
    final labelColor = widget.isSentByMe ? AppColors.white : AppColors.textPrimary;
    final secondaryColor = widget.isSentByMe
        ? AppColors.white.withValues(alpha: 0.8)
        : AppColors.textSecondary;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isSentByMe
            ? AppColors.white.withValues(alpha: 0.12)
            : AppColors.primaryDark.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSentByMe
              ? AppColors.white.withValues(alpha: 0.16)
              : AppColors.primaryDark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayback,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isSentByMe
                        ? AppColors.white.withValues(alpha: 0.18)
                        : AppColors.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice message',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: _progress,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        backgroundColor: trackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(_resolvedDuration),
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorText!,
              style: TextStyle(
                color: widget.isSentByMe
                    ? AppColors.white.withValues(alpha: 0.85)
                    : AppColors.error,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ChatAudioPlaybackCoordinator {
  _ChatAudioPlaybackCoordinator._();

  static final _ChatAudioPlaybackCoordinator instance =
      _ChatAudioPlaybackCoordinator._();

  String? _activeMessageId;
  Future<void> Function()? _stopActive;

  Future<void> activate(
    String messageId,
    Future<void> Function() stopActive,
  ) async {
    if (_activeMessageId != null &&
        _activeMessageId != messageId &&
        _stopActive != null) {
      await _stopActive!.call();
    }

    _activeMessageId = messageId;
    _stopActive = stopActive;
  }

  void clear(String messageId) {
    if (_activeMessageId == messageId) {
      _activeMessageId = null;
      _stopActive = null;
    }
  }
}
