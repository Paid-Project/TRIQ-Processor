import 'package:flutter/material.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:manager/features/auth/login/login.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:stacked/stacked.dart';
import '../core/locator.dart';
import '../features/language/language_selection_view.dart';
import '../features/tickets/tickets_list/tickets_list.vm.dart';
import '../routes/routes.dart';

class AppViewModel extends ReactiveViewModel {
  final _ticketsListViewModel = locator<TicketsListViewModel>();
  void init() {
    if (getUser().token?.isNotEmpty == true) {
      _ticketsListViewModel.init();
    }
    // _ticketsListViewModel.init();
    ScreenUtil.instance.init();
  }

  Widget homeNavigation() {
    if (isFirstTimeUser()) {
      return LanguageSelectionView();
    }

    if (getUser().token?.isNotEmpty == true) {
      return StageView(
        attributes: StageViewAttributes(selectedBottomNavIndex: 0),
      );
    }
    return LoginView();
  }

  String getInitialRoute() {
    return Routes.root;
  }

  bool isFirstTimeUser() {
    return !hasLanguageBeenSelected();
  }

  bool hasLanguageBeenSelected() {
    try {
      return getLanguageSelectionFlag();
    } catch (e) {
      return false;
    }
  }

  void markLanguageAsSelected() {
    saveLanguageSelectionFlag();
  }
}
