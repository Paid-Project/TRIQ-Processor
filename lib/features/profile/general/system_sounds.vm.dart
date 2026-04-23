import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/sound_settings.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SystemSoundsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _soundSettingsService = locator<SoundSettingsService>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const String kInitBusyKey = 'initialising';
  static const String kSaveBusyKey = 'saving';

  // Sabhi available sounds ki list
  final List<String> availableSounds = [
    'bamboo',
    'bell',
    'chime',
    'ding',
    'notification',
    'pop',
    'ring',
    'tone',
    'whistle',
  ];

  // --- MODIFICATION: `chat` type ko default map mein add karein ---
  Map<String, String> _selectedSounds = {
    'ticket_notification': 'bell|',
    'voice_call': 'bell|',
    'video_call': 'bell|',
    'alert': 'bell|',
    'chat': 'bell|',
  };

  Map<String, String> get selectedSounds => _selectedSounds;

  void init() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await runBusyFuture(
      _soundSettingsService.getSoundSettings(),
      busyObject: kInitBusyKey,
    );

    if (result.isNotEmpty && result.containsKey('data')) {
      // API se aaye data ko lein
      List apiSounds = result['data'];



      // Default map par API values ko update (overwrite) karein
      apiSounds.forEach((sound) {
        String type=sound['type']??'';
        String soundName=sound['soundName']??'bell';
        String id=sound['_id']??'';

        if (_selectedSounds.containsKey(type)) {
          _selectedSounds[type] = soundName+'|'+id;
        }
      });

      notifyListeners();
    } else {

    }
  }

  // Is method mein koi change nahi
  void updateSound(String type, String soundName) {
    String id=selectedSounds[type]!.split('|')[1];
    _selectedSounds[type] = soundName+'|'+id;
    notifyListeners();
    playSound(soundName);
  }

  // Is method mein koi change nahi
  void playSound(String soundName) async {
    if (soundName == 'default') return;
    try {
      await _audioPlayer.play(AssetSource('sound/${soundName.toLowerCase()}.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  // Is method mein koi change nahi (yeh ab 5 items bhejega)
  void saveSettings() async {
    List<Map<String, String>> notificationSoundPayload = [];
    log("1111111@: $notificationSoundPayload");
    // `_selectedSounds` map se list banayein (ab isme 5 items honge)
    AppLogger.info('API Sounds: $_selectedSounds');
    _selectedSounds.forEach((type, sound) {
      String name=sound.split('|')[0];
      String id=sound.split('|')[1];

      notificationSoundPayload.add({'type': type, 'sound': name,'id':id});
    });
    log("1111111#: $notificationSoundPayload");
    final result = await runBusyFuture(
      _soundSettingsService.updateSoundSettings(notificationSoundPayload),
      busyObject: kSaveBusyKey,
    );


    if (result.isNotEmpty && result.containsKey('success') && result['success']) {

      _navigationService.back();
    } else {
    }
  }

  // Is method mein koi change nahi
  String getSoundNameForType(String type) {
    String soundWithId = _selectedSounds[type] ?? 'default';
    String sound = soundWithId.split('|')[0];
    if (sound.isEmpty || sound == 'default') return 'Default';
    return sound[0].toUpperCase() + sound.substring(1);
  }
}