import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';

class ScanQrViewModel extends ReactiveViewModel{
  final _navigationService = locator<NavigationService>();

  init(){}

  executeOnScanQr(Function(dynamic) onScanQr,data)async{
    if(isBusy)return;
    _navigationService.back();
    setBusy(true);
    await onScanQr.call(data);
    setBusy(false);
  }
}