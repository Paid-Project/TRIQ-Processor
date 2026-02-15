import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/api_response.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/core/utils/app_logger.dart';

class SoundSettingsService {
  final _api = locator<ApiService>();

  /// **Get Sound Settings**
  /// Fetches the user's current sound settings from the server.
  Future<Map<String, dynamic>> getSoundSettings() async {
    // --- REAL IMPLEMENTATION (GET) ---
    try {
      // Aapke curl ke hisab se, yeh POST request hai
      final response = await _api.get(url: ApiEndpoints.soundSettingsGet);

      // Check karein ki API call successful tha aur status 1 hai
      if (response.statusCode == 200 && response.data['status'] == 1) {
        // Response list ko Map<String, String> mein convert karein
        Map<String, String> settingsMap = {};
        List<dynamic> settingsList = response.data['data'];

        for (var item in settingsList) {
          if (item['type'] != null && item['soundName'] != null) {
            settingsMap[item['type']] = item['soundName'];
          }
        }

        return {
          "success": true,
          "message": 'Sound settings Get successfully',
          "statusCode": 200,
          "data": settingsList,
        };
      }
      return {
        "success": false,
        "message": 'Sound settings Get Erorr',
        "statusCode": 400,
      };
    } catch (e) {
      AppLogger.error('Failed to get sound settings');
      return {
        "success": false,
        "message": 'Sound settings Get Erorr',
        "statusCode": 400,
      };
    }
  }

  /// **Update Sound Settings**
  /// Posts the new sound settings to the server.
  Future<Map<String, dynamic>> updateSoundSettings(
    List<Map<String, String>> sounds, // VM se 5 types ki list
  ) async {
    try {
      List<Future> apiCalls = [];

      for (var soundSetting in sounds) {
        final type = soundSetting['type']!;
        final soundName = soundSetting['sound']!;
        final id = soundSetting['id'] ?? '';

        final channelId = 'triq_sound_${type}';

        apiCalls.add(
          _api.put(
            url: ApiEndpoints.soundSettingsUpdate + "/$id",

            data: {
              'type': type,
              'soundName': soundName,
              'channelId': channelId,
            },
          ),
        );
      }

      final results = await Future.wait(apiCalls);

      bool allSuccess = results.every((res) => res.data['status'] == 1);

      if (allSuccess) {
        return {
          "success": true,
          "message": 'Sound settings Update successfully',
          "statusCode": 200,
        };
      } else {
        return {
          "success": false,
          "message": 'Sound settings Update Erorr',
          "statusCode": 400,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": 'Sound settings Update Erorr',
        "statusCode": 400,
      };
    }
  }
}
