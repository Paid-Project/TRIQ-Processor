import 'package:get/get.dart';
import 'package:stacked/stacked.dart';

class DuePaymentViewModel extends ReactiveViewModel {
  // final DuePaymentsController _controller = Get.find<DuePaymentsController>();

  @override
  // List<ReactiveServiceMixin> get reactiveServices => [_controller];

  @override
  void onDataChanged() {
    notifyListeners();
  }

  // List<PaymentModel> get payments => _controller.payments;

  // bool get isLoading => _controller.isLoading;

  void refreshPayments() {
    // _controller.fetchPayments();
  }
}