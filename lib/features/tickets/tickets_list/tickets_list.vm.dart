import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/configs.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/socket_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../api_endpoints.dart';
import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/models/machine_supplier_model.dart';
import '../../../core/models/pending_ticket_data.dart';
import '../../../core/models/ticket_model.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/api.service.dart';
import '../../../services/machine_supplier.service.dart';
import '../../../services/ticket.service.dart';
import '../../../services/stage.service.dart';

class TicketsListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();
  final _stageService = locator<StageService>();
  final _apiService = locator<ApiService>();
  final SocketService _socketService = SocketService();
  bool _isSocketInitialized = false;
  // Search query
  String _searchQuery = '';

  // Tab state
  final ReactiveValue<int> _selectedTabIndex = ReactiveValue<int>(0);
  bool _isSubmitting = false;
  String  currentOpenTicketId = "";

  int get selectedTabIndex => _selectedTabIndex.value;

  set selectedTabIndex(int value) {
    _selectedTabIndex.value = value;
    _loadTicketsForCurrentTab();
    notifyListeners();
  }

  // Pagination state
  final ReactiveValue<int> _activePage = ReactiveValue<int>(1);
  final ReactiveValue<int> _resolvedPage = ReactiveValue<int>(1);
  final ReactiveValue<bool> _hasMoreActive = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _hasMoreResolved = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _isLoadingMore = ReactiveValue<bool>(false);

  int get activePage => _activePage.value;

  int get resolvedPage => _resolvedPage.value;

  bool get hasMoreActive => _hasMoreActive.value;

  bool get hasMoreResolved => _hasMoreResolved.value;

  bool get isLoadingMore => _isLoadingMore.value;
  final currentOpenTicketStatus = ValueNotifier<String>("");

  // Reactive values
  final ReactiveValue<List<TicketList>> _activeTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<List<TicketList>> _resolvedTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  // Filtered tickets for search
  final ReactiveValue<List<TicketList>> _filteredActiveTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<List<TicketList>> _filteredResolvedTickets = ReactiveValue<List<TicketList>>([]);

  List<TicketList> get activeTickets => _filteredActiveTickets.value;

  List<TicketList> get resolvedTickets => _filteredResolvedTickets.value;
  User userData = getUser();

  bool get isLoading => _isLoading.value;

  // Search query
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    _applySearchFilters();
    notifyListeners();
  }

  void init() {
    if (!_isSocketInitialized) {
      initializeSocket();
    }
    // Defer initial load to next frame to avoid "markNeedsBuild called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTicketsForCurrentTab(forceRefresh: true);
    });
  }
  Future<void> initializeSocket() async {
    if (_isSocketInitialized) return;
    _isSocketInitialized = true;

    _socketService.initializeSocket(
      serverUrl: '${Configurations().url}/',
      queryParams: {},
      extraHeaders: {'Authorization': "${userData.token}"},
      onDisconnected: () {
        _socketService.off('ticketStatusUpdated');
      },
      onConnected: () {
        _socketService.emit('join', userData.id);
        _socketService.on('ticketStatusUpdated', (data) {
          _handleTicketUpdate(data);
        });
      },
    );
  }

  Future<void>_handleTicketUpdate(data) async {
    await _reloadActivePages();
    log("ValueListenableBuilder rebuilt with status ===> ${data}");
    print("SOCKET UPDATE HASHCODE: ${this.hashCode}");
    if (data is Map) {
      currentOpenTicketStatus.value = data['status']?.toString() ?? currentOpenTicketStatus.value;
    }
    notifyListeners();
  }

  Future<void> _reloadActivePages() async {
    final targetPage = _activePage.value;

    _activePage.value = 1;
    _hasMoreActive.value = true;

    for (var page = 1; page <= targetPage; page++) {
      final didLoadPage = await loadActiveTickets();
      if (!didLoadPage || !_hasMoreActive.value) {
        break;
      }

      if (page < targetPage) {
        _activePage.value = page + 1;
      }
    }
  }

  Future<void> _loadTicketsForCurrentTab({bool forceRefresh = false}) async {

    if (forceRefresh) {
      // Reset pagination when force refreshing
      _activePage.value = 1;
      _resolvedPage.value = 1;
      _hasMoreActive.value = true;
      _hasMoreResolved.value = true;
      _activeTickets.value = [];
      _resolvedTickets.value = [];
    }

    if (selectedTabIndex == 0) {
      await loadActiveTickets();
    } else {
      await _loadResolvedTickets();
    }
    notifyListeners();
  }

  Future<bool> loadActiveTickets() async {
    if (_isLoading.value) return false;

    final shouldShowPageLoader = _activePage.value == 1 && _activeTickets.value.isEmpty;
    if (shouldShowPageLoader) {
      _isLoading.value = true;
      notifyListeners();
    }

    var didLoadSuccessfully = false;

    try {
      // Load tickets with status "Active" and "In Progress"
      final activeResult = await _ticketService.getTicketsByStatus(
        status: 'Active',
        page: _activePage.value,
        limit: 5,
        forceRefresh: _activePage.value == 1,
      );

      List<TicketList> combinedTickets = [];

      activeResult.fold(
        (failure) {
          print('Error loading active tickets: ${failure.message}');
        },
        (paginatedResponse) {
          didLoadSuccessfully = true;
          combinedTickets.addAll(paginatedResponse.data ?? []);
        },
      );

      if (_activePage.value == 1) {
        _activeTickets.value = combinedTickets;
      } else {
        _activeTickets.value = [..._activeTickets.value, ...combinedTickets];
      }

      // Check if we have more tickets from either status
      bool hasMoreActive = false;

      activeResult.fold((failure) {}, (paginatedResponse) {
        hasMoreActive = _activePage.value < (paginatedResponse.pages ?? 1);
      });
      _hasMoreActive.value = hasMoreActive;
    } catch (e) {
      print('Exception loading active tickets: $e');
      if (_activePage.value == 1) {
        _activeTickets.value = [];
      }
    }

    // Update filtered tickets after loading
    _applySearchFilters();
    if (shouldShowPageLoader) {
      _isLoading.value = false;
    }
    notifyListeners();
    return didLoadSuccessfully;
  }

  Future<bool> _loadResolvedTickets() async {
    if (_isLoading.value) return false;

    final shouldShowPageLoader = _resolvedPage.value == 1 && _resolvedTickets.value.isEmpty;
    if (shouldShowPageLoader) {
      _isLoading.value = true;
      notifyListeners();
    }

    var didLoadSuccessfully = false;

    try {
      // Load tickets with status "Resolved" and "Rejected"
      final resolvedResult = await _ticketService.getTicketsByStatus(
        status: 'Resolved',
        page: _resolvedPage.value,
        limit: 5,
        forceRefresh: _resolvedPage.value == 1,

      );

      List<TicketList> combinedTickets = [];

      resolvedResult.fold(
        (failure) {
          print('Error loading resolved tickets: ${failure.message}');
        },
        (paginatedResponse) {
          didLoadSuccessfully = true;
          combinedTickets.addAll(paginatedResponse.data ?? []);
        },
      );

      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = combinedTickets;
      } else {
        _resolvedTickets.value = [..._resolvedTickets.value, ...combinedTickets];
      }

      // Check if we have more tickets from either status
      bool hasMoreResolved = false;

      resolvedResult.fold((failure) {}, (paginatedResponse) {
        hasMoreResolved = _resolvedPage.value < (paginatedResponse.pages ?? 1);
      });

      _hasMoreResolved.value = hasMoreResolved;
    } catch (e) {
      print('Exception loading resolved tickets: $e');
      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = [];
      }
    }

    // Update filtered tickets after loading
    _applySearchFilters();
    if (shouldShowPageLoader) {
      _isLoading.value = false;
    }
    notifyListeners();
    return didLoadSuccessfully;
  }

  Future<void> loadMoreTickets() async {
    if (_isLoadingMore.value || !hasMoreTickets) return;

    _isLoadingMore.value = true;
    notifyListeners();

    try {
      if (selectedTabIndex == 0) {
        final previousPage = _activePage.value;
        _activePage.value++;
        final didLoadPage = await loadActiveTickets();
        if (!didLoadPage) {
          _activePage.value = previousPage;
        }
      } else {
        final previousPage = _resolvedPage.value;
        _resolvedPage.value++;
        final didLoadPage = await _loadResolvedTickets();
        if (!didLoadPage) {
          _resolvedPage.value = previousPage;
        }
      }
    } finally {
      _isLoadingMore.value = false;
      notifyListeners();
    }
  }

  Future<void> loadTickets({bool forceRefresh = false}) async {
    await _loadTicketsForCurrentTab(forceRefresh: forceRefresh);
  }

  void _applySearchFilters() {
    if (_searchQuery.isEmpty) {
      _filteredActiveTickets.value = _activeTickets.value;
      _filteredResolvedTickets.value = _resolvedTickets.value;
    } else {
      // Filter tickets based on search query
      final query = _searchQuery.toLowerCase();

      _filteredActiveTickets.value =
          _activeTickets.value.where((ticket) {
            return _matchesSearchQuery(ticket, query);
          }).toList();

      _filteredResolvedTickets.value =
          _resolvedTickets.value.where((ticket) {
            return _matchesSearchQuery(ticket, query);
          }).toList();
    }
    notifyListeners();
  }

  bool _matchesSearchQuery(TicketList ticket, String query) {
    final fullName = ticket.processor?.fullName?.toLowerCase() ?? '';
    final ticketNum = ticket.ticketNumber?.toLowerCase() ?? '';

    return fullName.contains(query)||ticketNum.contains(query);
  }

  void resetFilters() {
    _searchQuery = '';
    _filteredActiveTickets.value = _activeTickets.value;
    _filteredResolvedTickets.value = _resolvedTickets.value;
    notifyListeners();
  }

  void navigateToTicketDetails({required String ticketId}) async {
    await _navigationService.navigateTo(Routes.ticketDetails, arguments: ticketId);
  }

  void navigateToReviewTicketWithId({required String ticketId}) async {
    await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
  }

  void navigateToHome() {
    _stageService.updateSelectedBottomNavIndex(0); // Home tab is at index 0
  }

  // Getter for current tickets based on selected tab
  List<TicketList> get currentTickets {
    return selectedTabIndex == 0 ? activeTickets : resolvedTickets;
  }

  // Getter for has more tickets based on selected tab
  bool get hasMoreTickets {
    return selectedTabIndex == 0 ? hasMoreActive : hasMoreResolved;
  }

  List<MachineSupplier> machineSupplierData = [];

  Future<void> loadMachines() async {
    try {
      final MachineSupplierService _machineSupplierService = locator<MachineSupplierService>();

      final result = await _machineSupplierService.getMachineSupplier();

      result.fold(
        (failure) {
          Fluttertoast.showToast(msg: "Failed to load machines. Please try again", backgroundColor: Colors.red);
        },
        (machineSupplierModel) {
          machineSupplierData = machineSupplierModel.data ?? [];
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load machines. Please try again", backgroundColor: Colors.red);
    }
  }
  PendingTicketData? _pendingTicketData;
  bool get isPendingTicket => _pendingTicketData != null;
  Future<void> continueToPay() async {
    // If this is a pending ticket, submit it first
    if (_pendingTicketData != null) {
      await _submitPendingTicket();
    } else {
      // Navigate back and refresh tickets list
      // _navigationService.back();

      // Refresh the tickets list in TicketsListViewModel singleton
      final ticketsListViewModel = locator<TicketsListViewModel>();
      await ticketsListViewModel.loadTickets(forceRefresh: true);
    }
  }
  Future<void> _submitPendingTicket() async {
    if (_pendingTicketData == null) return;
    if (_isSubmitting) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = _pendingTicketData!;

      if (data.isFromSiteVisit) {
        // Site Visit ticket
        final formData = dio.FormData();
        formData.fields.addAll([
          MapEntry('ticketType', data.maintenanceType!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('problem', ""),
          MapEntry('errorCode', ""),
          MapEntry('notes', ""),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Offline"),
        ]);

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          AppLogger.info('Site visit ticket created successfully: $ticketId');

          Fluttertoast.showToast(
            msg: response.data["message"] ?? 'Site visit ticket created successfully!',
            backgroundColor: Colors.green,
          );

          // Navigate back and refresh
          _navigationService.back();
          final ticketsListViewModel = locator<TicketsListViewModel>();
          await ticketsListViewModel.loadTickets(forceRefresh: true);
        } else {
          AppLogger.error('Failed to create site visit ticket');
          Fluttertoast.showToast(
            msg: 'Failed to create ticket',
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Online Support ticket
        final formData = dio.FormData();

        formData.fields.addAll([
          MapEntry('problem', data.problem!),
          MapEntry('errorCode', data.errorCode!),
          MapEntry('notes', data.additionalNotes!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('ticketType', "Full Machine Service"),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Online"),
        ]);

        for (var i = 0; i < data.attachments!.length; i++) {
          final file = data.attachments![i];
          final extension = file.path.split('.').last.toLowerCase();
          final contentType = extension == 'png'
              ? http_parser.MediaType('image', 'png')
              : http_parser.MediaType('image', 'jpeg');
          formData.files.add(
            MapEntry(
              'ticketImages',
              await dio.MultipartFile.fromFile(
                file.path,
                filename: 'ticket_image_$i.$extension',
                contentType: contentType,
              ),
            ),
          );
        }

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          AppLogger.info('Ticket created successfully: $ticketId');

          Fluttertoast.showToast(
            msg: response.data["message"] ?? 'Ticket created successfully!',
            backgroundColor: Colors.green,
          );

          // Navigate back and refresh
          _navigationService.back();
          final ticketsListViewModel = locator<TicketsListViewModel>();
          await ticketsListViewModel.loadTickets(forceRefresh: true);
        } else {
          AppLogger.error('Failed to create ticket');
          Fluttertoast.showToast(
            msg: 'Failed to create ticket',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error submitting ticket: $e');
      // Fluttertoast.showToast(
      //   msg: 'Error creating ticket: ${e.toString()}',
      //   backgroundColor: Colors.red,
      // );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> navigateToReviewTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
    String? machineId,
    String? organizationId,
  }) async {
    if (machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(msg: 'Machine ID not found', backgroundColor: Colors.red);
      return;
    }

    if (organizationId == null) {
      AppLogger.error('Organization ID is null');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    // Create pending ticket data
    final pendingTicketData = PendingTicketData(
      problem: problem,
      errorCode: errorCode,
      additionalNotes: additionalNotes,
      attachments: attachments,
      maintenanceType: maintenanceType,
      isFromSiteVisit: isFromSiteVisit,
      machineId: machineId,
      organizationId: organizationId,
    );

    // Navigate to ReviewTicket with pending data
    await _navigationService.navigateTo(
      Routes.reviewTicket,
      arguments: pendingTicketData,
    );
  }

  Future<void> createTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
    String? machineId,
    String? organizationId,
  }) async {
    if (machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(msg: 'Machine ID not found', backgroundColor: Colors.red);
      return;
    }

    if (organizationId == null) {
      AppLogger.error('Organization ID is null');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    if (isFromSiteVisit) {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('ticketType', maintenanceType!),
        MapEntry('machineId', machineId),
        MapEntry('organisationId', organizationId),
        MapEntry('problem', ""),
        MapEntry('errorCode', ""),
        MapEntry('notes', ""),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Offline"),
      ]);

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        final ticketId = response.data['ticket']['_id'];

        AppLogger.info('Site visit ticket created successfully: ${response.data['ticket']['_id']}');

        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);

        Fluttertoast.showToast(msg: response.data["message"] ?? 'Site visit ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create site visit ticket');
      }
    } else {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('problem', problem!),
        MapEntry('errorCode', errorCode!),
        MapEntry('notes', additionalNotes!),
        MapEntry('machineId', machineId),
        MapEntry('organisationId', organizationId),
        MapEntry('ticketType', "Full Machine Service"),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Online"),
      ]);

      for (var i = 0; i < attachments!.length; i++) {
        final file = attachments[i];
        final extension = file.path.split('.').last.toLowerCase();
        final contentType = extension == 'png' ? DioMediaType('image', 'png') : DioMediaType('image', 'jpeg');
        formData.files.add(
          MapEntry('ticketImages', await MultipartFile.fromFile(file.path, filename: 'ticket_image_$i.$extension', contentType: contentType)),
        );
      }

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        final ticketId = response.data['ticket']['_id'];

        AppLogger.info('Ticket created successfully: ${response.data['ticket']['_id']}');
        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create ticket');
      }
    }
  }
}
