import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../core/locator.dart';

class ProcessorsSearchViewModel extends ReactiveViewModel {
  final navigationService = locator<NavigationService>();

  final TextEditingController searchController = TextEditingController();

  bool _searching = false;
  bool get searching => _searching;

  void init() {
    // Initialize the view model
  }

  void onSearchChanged(String value) {
    // Handle search functionality here
    if (value.isEmpty) {
      _searching = false;
    } else {
      _searching = true;
      // Implement search logic
      // This is a placeholder to show loading state briefly
      Future.delayed(Duration(milliseconds: 500), () {
        _searching = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}