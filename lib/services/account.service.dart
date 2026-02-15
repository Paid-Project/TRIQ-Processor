import 'package:hive/hive.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

import '../core/models/hive/user/saved_account.dart';
import '../core/models/hive/user/user.dart';
import '../core/utils/app_logger.dart';

class AccountManagerService {
  static const String _savedAccountsBoxName = 'saved_accounts';

  // Singleton pattern
  static AccountManagerService? _instance;
  static AccountManagerService get instance {
    _instance ??= AccountManagerService._internal();
    return _instance!;
  }

  AccountManagerService._internal();
  List<SavedAccount> getSavedAccounts() {
    try {
      final dynamic rawData = Hive.box(
        AppStrings.triqBox,
      ).get(_savedAccountsBoxName);

      if (rawData == null) {
        AppLogger.info('No saved accounts found in Hive');
        return [];
      }

      // Handle the case where rawData might be List<dynamic>
      List<SavedAccount> accounts;
      if (rawData is List) {
        accounts = rawData.cast<SavedAccount>();
      } else {
        AppLogger.warning(
          'Unexpected data type in saved accounts: ${rawData.runtimeType}',
        );
        return [];
      }

      AppLogger.info('Retrieved ${accounts.length} accounts from Hive');

      for (var account in accounts) {
        AppLogger.info('Account: ${account.toJson()}');
      }

      accounts.sort((a, b) => b.lastLogin.compareTo(a.lastLogin));
      return accounts;
    } catch (e) {
      AppLogger.error('Failed to get saved accounts: $e');
      return [];
    }
  }

  Future<void> updateLastLogin(String email) async {
    try {
      final List<SavedAccount> retrieved = getSavedAccounts().toList();
      final account =
          retrieved.where((element) => element.email == email).toList();
      if (account.isNotEmpty) {
        final updatedAccount = account.first.copyWith(
          lastLogin: DateTime.now(),
        );
        retrieved.removeWhere((e) => e.email == email);
        retrieved.add(updatedAccount);
        await Hive.box(
          AppStrings.triqBox,
        ).put(_savedAccountsBoxName, retrieved);
        AppLogger.info('Updated last login for: $email');
      } else {
        AppLogger.warning('Account not found for email: $email');
      }
    } catch (e) {
      AppLogger.error('Failed to update last login: $e');
    }
  }

  Future<void> removeSavedAccount(String email) async {
    try {
      final List<SavedAccount> retrieved = getSavedAccounts().toList();
      retrieved.removeWhere((e) => e.email == email);
      await Hive.box(AppStrings.triqBox).put(_savedAccountsBoxName, retrieved);
      AppLogger.info('Removed saved account: $email');
    } catch (e) {
      AppLogger.error('Failed to remove saved account: $e');
    }
  }

  Future<void> saveCurrentUser(User user) async {
    {
      if (user.email == null || user.email!.isEmpty) {
        AppLogger.warning('Cannot save user account: email is null or empty');
        return;
      }

      final savedAccount = SavedAccount(
        email: user.email!,
        name: user.name ?? user.fullName ?? user.yourName ?? '',
        lastLogin: DateTime.now(),
      );

      final List<SavedAccount> retrievedAccounts = getSavedAccounts().toList();
      if (retrievedAccounts.where((e) => e.email == user.email).isNotEmpty) {
        AppLogger.highlight("Already Saved");
        return;
      }
      retrievedAccounts.add(savedAccount);
      try {
        await Hive.box(
          AppStrings.triqBox,
        ).put(_savedAccountsBoxName, retrievedAccounts);
        AppLogger.info('Successfully saved account to Hive');

        // Verify it was saved
        final List<SavedAccount> retrieved = getSavedAccounts().toList();
        AppLogger.info('Verification - Retrieved account: ${retrieved}');

        // Log all accounts in box
        AppLogger.info('All accounts in box: ${retrieved.length}');
        for (var account in retrieved) {
          AppLogger.info('Account: ${account.toJson()}');
        }
      } catch (e) {
        AppLogger.error('Failed to save account to Hive: $e');
      }
    }
  }

  // Debug method to check box status
  void debugBoxStatus() {
    AppLogger.info('=== AccountManagerService Debug ===');

    if (getSavedAccounts().isNotEmpty) {
      AppLogger.info('SavedAccountsBox length: ${getSavedAccounts().length}');
      AppLogger.info('SavedAccountsBox keys: ${getSavedAccounts()}');
    }
    AppLogger.info('=== End Debug ===');
  }
}
