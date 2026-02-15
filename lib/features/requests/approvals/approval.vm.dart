import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../routes/routes.dart';

class ApprovalViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();

  get navigateToCreateOrEditOrgView => null;

  void init() {}

  void navigateToLeave() async {
    await _navigationService.navigateTo(Routes.approval);
  }

}
