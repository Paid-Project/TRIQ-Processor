import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/task.dart'; // Naya Task Model
import 'package:manager/routes/routes.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/task.service.dart'; // Nayi Task Service
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class TaskListViewModel extends ReactiveViewModel {
  final _taskService = locator<TaskService>();
  final _navigationService = locator<NavigationService>();

  // --- UI STATE ---
  int _selectedTaskTypeIndex = 0;
  int get selectedTaskTypeIndex => _selectedTaskTypeIndex;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  final searchController = TextEditingController();
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  final List priortyTags = ["all", "low", "medium", "high", "completed", "pending"];

  final List<String> _filterOptions = [
    LanguageService.get('all'), // index 0
    LanguageService.get('low'), // index 1
    LanguageService.get('medium'), // index 2
    LanguageService.get('high'), // index 3
    LanguageService.get('completed'), // index 4
    LanguageService.get('pending'), // index 5
  ];
  List<String> get filterOptions => _filterOptions;

  // --- DATA STATE ---
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  // --- GETTERS ---
  // UI filter index ko API string me convert karna
  String get _currentStatusFilter {
    switch (_selectedFilterIndex) {
      case 1:
        return 'low';
      case 2:
        return 'medium';
      case 3:
        return 'high';
      case 4:
        return 'completed'; // API ke hisaab se
      case 5:
        return 'pending'; // API ke hisaab se
      default:
        return 'all';
    }
  }

  // UI tab index ko API string me convert karna
  String get _currentTabFilter {
    return _selectedTaskTypeIndex == 0 ? 'mytask' : 'assignedtask';
  }


  void init() {
    fetchInitialTasks();
  }

  Future<void> fetchInitialTasks({bool showLoading = true}) async {
    _currentPage = 1;
    _hasMoreData = true;

    if (showLoading) setBusy(true);

    final response = await _taskService.getTasks(
      page: _currentPage,
      tab: _currentTabFilter,
      status: _currentStatusFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (response != null && response.success) {
      _tasks = response.tasks;
      _totalPages = response.totalPages;
      _hasMoreData = response.currentPage < response.totalPages;
    } else {
      _tasks = []; // Error ya data na milne par list khaali karein
    }

    if (showLoading) setBusy(false);
    notifyListeners();
  }

  Future<void> loadMoreTasks() async {
    if (isBusy || !_hasMoreData) return;

    _currentPage++;

    // Yahan setBusy(true) nahi karenge, taaki list ke neeche loader dikha sakein
    // Abhi ke liye, hum bas aur data fetch karenge

    final response = await _taskService.getTasks(
      page: _currentPage,
      tab: _currentTabFilter,
      status: _currentStatusFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (response != null && response.success) {
      _tasks.addAll(response.tasks); // Naye data ko list me add karein
      _hasMoreData = response.currentPage < response.totalPages;
    } else {
      _hasMoreData = false;
    }

    notifyListeners();
  }

  void onTaskTypeChanged(int index) {
    _selectedTaskTypeIndex = index;
    fetchInitialTasks(); // Naye tab ke liye data fetch karein
  }

  void onFilterSelected(int index) {
    _selectedFilterIndex = index;
    fetchInitialTasks(); // Naye filter ke liye data fetch karein
  }

  void onSearchPressed() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      searchController.clear();
      _searchQuery = '';
      fetchInitialTasks(); // Search cancel karne par data refresh karein
    }
    notifyListeners();
  }

  void onSearchSubmitted(String query) {
    _searchQuery = query.trim();
    fetchInitialTasks(); // Search query ke saath data fetch karein
  }
  
  void onSearchChanged(String query) {
    _searchQuery = query.trim();
    // Real-time search ke liye debounce implement kar sakte hain
    // Abhi ke liye simple implementation
    fetchInitialTasks();
  }

  void navigateToCreateTask() {
     _navigationService.navigateTo(Routes.createTask);
    print('Navigating to Create Task');
  }

  void navigateBack() {
    _navigationService.back();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}