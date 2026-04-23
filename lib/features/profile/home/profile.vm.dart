import 'package:flutter/material.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/routes/routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart' as hive_user;
import '../../../core/storage/storage.dart';
import '../../../services/auth.service.dart';
import '../../../services/profile.service.dart';
import '../../../services/account.service.dart';
import '../../../core/utils/app_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _profileService = locator<ProfileService>();

  final _user = ReactiveValue(getUser());
  hive_user.User get user => _user.value;

  final _profile = ReactiveValue<ProfileModel?>(null);
  ProfileModel? get profile => _profile.value;

  final _isLoading = ReactiveValue<bool>(false);
  bool get isLoading => _isLoading.value;

  String get inviteLink =>
      _profileService.inviteData?.data?.processorUrl ?? '';
  void init() {
     _profileService.refreshProfile();
     refreshInvite();
     loadProfileData();
  }
  Future<void> refreshInvite() async {
    _profileService.getInvitePeopleAPI();
  }

  Future<void> loadProfileData() async {
    _isLoading.value = true;
    notifyListeners();

    try {
      // Get profile data from ProfileService (no API call)
      final profile = _profileService.globalProfileModel;
      if (profile != null) {
        _profile.value = profile;
        AppLogger.info('Profile data loaded from ProfileService ${_profile.value?.completionPercentage??"nocode"}');
      } else {
        AppLogger.warning('No profile data available in ProfileService');
      }
    } catch (e) {
      AppLogger.error('Error loading profile data: $e');
      Fluttertoast.showToast(
        msg: 'Error loading profile data: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading.value = false;
      notifyListeners();
    }
  }

  void navigateToQRView() async {
    await _navigationService.navigateTo(Routes.qr);
  }

  void navigateToCreateOrEditOrgView() async {
    await _navigationService.navigateTo(Routes.updateOrg);
    
    // Refresh profile data when returning from organization page
    await _profileService.refreshProfile();
    await loadProfileData();
  }
  Future<void> openWhatsApp() async {
    final link = _profileService.inviteData?.data?.processorUrl ?? '';
    if (link.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invite link not available',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    final String message =
        "Hi 👋\n\nPlease download our app using this link:\n$link";

    final Uri url = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  void shareDriveLink() {
    final link = _profileService.inviteData?.data?.processorUrl ?? '';
    if (link.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invite link not available',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    Share.share(
      "Hi 👋\n\nPlease download our app using this link:\n\n$link",
      subject: "Invite - Download App",
    );
  }
  Future<void> shareViaEmail() async {
    final link = _profileService.inviteData?.data?.processorUrl ?? '';

    if (link.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invite link not available',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '', // yaha specific email bhi de sakte ho
      queryParameters: {
        'subject': 'Invite - Download App',
        'body': "Hi 👋\n\nPlease download our app using this link:\n\n$link",
      },
    );

    await launchUrl(emailUri);
  }
  void navigateToLoginView() async {
    hive_user.User currentUser = getUser();

    if (currentUser.email != null) {
      await AccountManagerService.instance.saveCurrentUser(currentUser);
    }

    String? fcmToken = getUser().fcmToken;
    _authService.logout(fcmToken);
  }

  Future<bool> deleteAccount(String password) async {
    print("Stap 1");
    try {
      setBusy(true);

      // Step 1: Verify password first
      AppLogger.info('Checking password before account deletion');
      final passwordCheckResult = await _authService.checkPassword(password: password);


      bool isPasswordValid = false;
      passwordCheckResult.fold(
        (failure) {
          AppLogger.error('Password check failed: ${failure.message}');
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          isPasswordValid = false;
        },
        (success) async {
          // // Always clear local data and redirect to login

          AppLogger.info('User permanently deleted with cleanup');
          isPasswordValid = true;
        },
      );
      
      // If password is invalid, return false and don't proceed
      if (!isPasswordValid) {
        setBusy(false);
        return false;
      }
      
      // Step 2: If password is valid, proceed with account deletion
      hive_user.User currentUser = getUser();

      if (currentUser.email != null) {
        await AccountManagerService.instance.saveCurrentUser(currentUser);
      }

      AppLogger.info('Proceeding with account deletion for user: ${currentUser.id}');
      final deleteResult = await _authService.deleteAccount(id: currentUser.id ?? '');


      bool isDeleted = false;
      deleteResult.fold(
        (failure) {

          AppLogger.error('Account deletion failed: ${failure.message}');
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          isDeleted = false;
        },
        (success) async {
          AppLogger.info('Account deleted successfully');
          await clearHive();
          await _navigationService.clearStackAndShow(Routes.login);
          Fluttertoast.showToast(
            msg: 'Account deleted successfully',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
          isDeleted = true;
        },
      );
      
      setBusy(false);
      return isDeleted;
    } catch (e) {
      AppLogger.error('Error during account deletion: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      setBusy(false);
      return false;
    }
  }

  void navigateToGeneralSetting() async {

    await _navigationService.navigateTo(Routes.generalSetting);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
