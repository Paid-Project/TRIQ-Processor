import 'package:stacked/stacked.dart';

class StageService with ListenableServiceMixin {
  ReactiveValue<bool> isCloseTicketDialogOpen = ReactiveValue(false);

  ReactiveValue<String?> requestedTicketId = ReactiveValue(null);

  ReactiveValue<int> selectedBottomNavIndex = ReactiveValue(0);

  setCloseTicketDialogOpen(bool val, String? ticketId) {
    isCloseTicketDialogOpen.value = val;
    if (ticketId != null) {
      requestedTicketId.value = ticketId;
    }
    notifyListeners();
  }

  updateSelectedBottomNavIndex(int index) {
    selectedBottomNavIndex.value = index;
    notifyListeners();
  }
}
