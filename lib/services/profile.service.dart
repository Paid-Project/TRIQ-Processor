import 'dart:convert';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/core/models/widgets/invite_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/api.service.dart';

import '../core/storage/storage.dart';

class ProfileService {
  final apiService = locator<ApiService>();

  // Global ProfileModel stored in memory
  ProfileModel? _globalProfileModel;
  InviteModel? _inviteData;
  // Track if profile has been initialized
  bool _isInitialized = false;

  String chatLanguage = "en";

  // Getter for global profile model
  ProfileModel? get globalProfileModel => _globalProfileModel;

  // Check if profile is initialized
  bool get isInitialized => _isInitialized;
  InviteModel? get inviteData => _inviteData;
  // Initialize profile data - always fetch from API
  Future<void> initializeProfile() async {
    // Only initialize once

    chatLanguage =  getChatSelectedLanguage();
    if (_isInitialized) {
      AppLogger.info('Profile already initialized, skipping...');
      return;
    }

    // Always fetch from API (no local storage)
    await _fetchFromAPI();

    // Mark as initialized
    _isInitialized = true;
    AppLogger.info('Profile initialization completed');
  }
  Future<void> getInvitePeopleAPI() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.links);
      print("response:-$response");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Parse profile data
        InviteModel invitePeople;
        invitePeople = InviteModel.fromJson(responseData);

        // if((profile.profile?.chatLanguage ?? "").isNotEmpty) {
        //   saveSelectedChatLanguage(profile.profile?.chatLanguage ?? "en");
        // }

        _inviteData = invitePeople;
        AppLogger.info('Profile fetched from API');
      } else {
        AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error fetching profile from API: $e');
    }
  }
  // Fetch profile data from API
  Future<void> _fetchFromAPI() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.getProfile);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Parse profile data
        ProfileModel profile;
        AppLogger.info('Profile fetched from API :${responseData['completionPercentage']}');
        profile = ProfileModel.fromJson(responseData);

        if((profile.profile?.chatLanguage ?? "").isNotEmpty) {
          saveSelectedChatLanguage(profile.profile?.chatLanguage ?? "en");
        }

        _globalProfileModel = profile;

      } else {
        AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error fetching profile from API: $e');
    }
  }

  // Update profile data
  Future<void> updateProfileData(Map<String, dynamic> updateData) async {
    try {
      AppLogger.info('ProfileService: Sending update data to API: $updateData');

      final response = await apiService.put(
        url: ApiEndpoints.updateProfile,
        data: updateData,
      );

      AppLogger.info(
        'ProfileService: API response status: ${response.statusCode}',
      );
      AppLogger.info('ProfileService: API response data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        AppLogger.info('ProfileService: Parsed response data: $responseData');

        // Update global profile model with new data
        if (_globalProfileModel != null) {
          // Handle the case where user is a string ID instead of nested object
          // Map<String, dynamic> profileData = Map.from(responseData);
          //
          // // If user is a string ID, preserve the existing user object
          // if (responseData['user'] is String) {
          //   profileData['user'] = _globalProfileModel!.profile?.user?.toJson() ?? {};
          // }
          //
          // final updatedProfile = ProfileModel.fromJson(profileData);
          // _globalProfileModel = updatedProfile;
          _fetchFromAPI();
          AppLogger.info('ProfileService: Profile updated');
        }
      } else {
        AppLogger.error('Failed to update profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
    }
  }

  // Refresh profile data from API
  Future<void> refreshProfile() async {
    try {
      AppLogger.info('ProfileService: Refreshing profile data from API...');

      final response = await apiService.get(url: ApiEndpoints.getProfile);

      AppLogger.info(
        'ProfileService: API response status: ${response.statusCode}',
      );
      AppLogger.info('ProfileService: API response data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('ProfileService: Invalid response format');
          return;
        }

        // Parse the profile data from the response
        ProfileModel profile;
        profile = ProfileModel.fromJson(responseData);

        if((profile.profile?.chatLanguage ?? "").isNotEmpty) {
          saveSelectedChatLanguage(profile.profile?.chatLanguage ?? "en");
        }

        // Update global profile model
        _fetchFromAPI();
        AppLogger.info('ProfileService: Profile refreshed successfully');
      } else {
        AppLogger.error(
          'ProfileService: Failed to refresh profile: ${response.statusMessage}',
        );
      }
    } catch (e) {
      AppLogger.error('ProfileService: Error refreshing profile: $e');
    }
  }

  // Clear profile data (for logout)
  Future<void> clearProfileData() async {
    try {
      _globalProfileModel = null;
      _isInitialized = false; // Reset initialization flag
      AppLogger.info('Profile data cleared');
    } catch (e) {
      AppLogger.error('Error clearing profile data: $e');
    }
  }
}
