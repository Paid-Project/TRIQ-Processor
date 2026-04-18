import 'dart:async';
import 'dart:math' as math;

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';
import 'package:manager/widgets/dialogs/select_maintenance_type/select_maintenance_type_dialog.view.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';

import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/ticket_model.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/common/info_column.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import 'tickets_list.vm.dart';

class TicketsListView extends StatefulWidget {
  const TicketsListView({super.key});

  @override
  State<TicketsListView> createState() => _TicketsListViewState();
}

class _TicketsListViewState extends State<TicketsListView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  AnimationController? _fabAnimationController;
  Animation<double>? _expandAnimation;
  bool _isSearchVisible = false;
  bool _fabOpen = false;
  final Set<String> _expiredTicketIds = {}; // Track which tickets have already triggered refresh

  // Dynamic border radius for segmented control
  BorderRadius _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));

  @override
  void initState() {
    super.initState();

    // Initialize search animation controller
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // FAB animation controller will be initialized lazily when needed
  }

  void _initializeFabAnimation() {
    if (_fabAnimationController == null) {
      _fabAnimationController = AnimationController(value: _fabOpen ? 1.0 : 0.0, duration: const Duration(milliseconds: 250), vsync: this);
      _expandAnimation = CurvedAnimation(curve: Curves.fastOutSlowIn, reverseCurve: Curves.easeOutQuad, parent: _fabAnimationController!);
    }
  }

  void _clearExpiredTicketIds() {
    _expiredTicketIds.clear();
  }

  Future<void> _refreshTickets(TicketsListViewModel model) async {
    _clearExpiredTicketIds();
    await model.loadTickets(forceRefresh: true);
  }

  @override
  void dispose() {
    // Dispose animation controllers first
    _animationController.dispose();
    _fabAnimationController?.dispose();

    // Dispose text controllers
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _toggleSearch() {
    if (mounted) {
      setState(() {
        _isSearchVisible = !_isSearchVisible;
      });

      if (_isSearchVisible) {
        _animationController.forward();
        // Focus the search field after animation starts
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    }
  }

  void _toggleFab() {
    if (mounted) {
      _initializeFabAnimation();
      if (_fabAnimationController!.isAnimating == false) {
        setState(() {
          _fabOpen = !_fabOpen;
        });
        if (_fabOpen) {
          _fabAnimationController!.forward();
        } else {
          _fabAnimationController!.reverse();
        }
      }
    }
  }

  Future<void> _onOnlineSupportPressed(TicketsListViewModel model) async {
    _toggleFab();
    if (model.machineSupplierData.isEmpty) {
      final _dialogService = locator<DialogService>();
      await _dialogService.showCustomDialog(variant: DialogType.loader, data: LoaderDialogAttributes(task: () => model.loadMachines()));
    }

    if (model.machineSupplierData.isEmpty) {
      return;
    }

    Get.dialog(
      CreateTicketDialogWidget(
        machineSupplierData: model.machineSupplierData,
        attributes: CreateTicketDialogAttributes(
          onSubmit: (problem, errorCode, additionalNotes, attachments, machineId, organizationId) async {
            print('Problem: $problem');
            print('Error Code: $errorCode');
            print('Additional Notes: $additionalNotes');
            print('Attachments: ${attachments.length} files');
            await model.navigateToReviewTicket(
              problem: problem,
              errorCode: "#$errorCode",
              additionalNotes: additionalNotes,
              attachments: attachments,
              machineId: machineId.toLowerCase(),
              organizationId: organizationId,
              isFromSiteVisit: false,

            );
          },
          onCancel: () {
            print('Ticket creation cancelled');
          },
        ),
      ),
    );
  }

  Future<void> _onSiteVisitPressed(TicketsListViewModel model) async {
    _toggleFab();

    if (model.machineSupplierData.isEmpty) {
      final _dialogService = locator<DialogService>();
      await _dialogService.showCustomDialog(variant: DialogType.loader, data: LoaderDialogAttributes(task: () => model.loadMachines()));
    }

    if (model.machineSupplierData.isEmpty) {
      return;
    }

    Get.dialog(
      SelectMaintenanceTypeDialog(
        machineSupplierData: model.machineSupplierData,
        isWarrantyActive: true, // You can modify this based on your logic
        attributes: SelectMaintenanceTypeDialogAttributes(
          onSubmit: (String maintenanceType, String organizationId, String machineId) async {
            await model.navigateToReviewTicket(
              maintenanceType: maintenanceType,
              isFromSiteVisit: true,
              organizationId: organizationId,
              machineId: machineId.toLowerCase(),

            );
          },
          onCancel: () {
            // Handle cancel action if needed
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketsListViewModel>.reactive(
      viewModelBuilder: () => locator<TicketsListViewModel>(),
       onViewModelReady: (TicketsListViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, TicketsListViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildAppBar(context, model),
          body: Container(
            color: AppColors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Animated search bar
                  SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
                  // Tab Bar
                  Container(
                    color: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
                    child: CustomSlidingSegmentedControl<int>(
                      height: 40,
                      innerPadding: EdgeInsets.zero,
                      initialValue: model.selectedTabIndex,
                      decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(AppSizes.v45)),
                      padding: AppSizes.v4,

                      isStretch: true,
                      children: {
                        0: Text(
                          LanguageService.get("active_tickets"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: model.selectedTabIndex == 0 ? AppColors.white : AppColors.black,
                          ),
                        ),
                        1: Text(
                          LanguageService.get("resolved_tickets"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: model.selectedTabIndex == 1 ? AppColors.white : AppColors.black,
                          ),
                        ),
                      },
                      fromMax: true,
                      thumbDecoration: BoxDecoration(borderRadius: _dynamicBorder, color: AppColors.primary),
                      onValueChanged: (int value) {
                        // Update the current tab index in the view model
                        model.selectedTabIndex = value;

                        // Update dynamic border radius based on selected segment
                        setState(() {
                          switch (value) {
                            case 0:
                              _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));
                              break;
                            case 1:
                              _dynamicBorder = BorderRadius.only(topRight: Radius.circular(AppSizes.v45), bottomRight: Radius.circular(AppSizes.v45));
                              break;
                          }
                        });
                      },
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: IndexedStack(
                        index: model.selectedTabIndex,
                        children: [
                          // Active Tickets Tab
                          RefreshIndicator(
                            onRefresh: () async => _refreshTickets(model),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child:
                                model.isLoading && model.activeTickets.isEmpty
                                    ? _buildLoadingShimmer()
                                    : model.activeTickets.isEmpty
                                    ? _buildEmptyState(context, model, isActive: true)
                                    : _buildTicketsListWithPagination(context, model, model.activeTickets, isActive: true),
                          ),

                          // Resolved Tickets Tab
                          RefreshIndicator(
                            onRefresh: () async => _refreshTickets(model),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child:
                                model.isLoading && model.resolvedTickets.isEmpty
                                    ? _buildLoadingShimmer()
                                    : model.resolvedTickets.isEmpty
                                    ? _buildEmptyState(context, model, isActive: false)
                                    : _buildTicketsListWithPagination(context, model, model.resolvedTickets, isActive: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: model.selectedTabIndex == 0 ? _buildExpandableFloatingActionButton(model) : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TicketsListViewModel model) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
      ),
      leading: IconButton(onPressed: () => model.navigateToHome(), icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white)),
      title: Text(
        LanguageService.get("tickets_summary"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        InkWell(onTap: _toggleSearch, child: Image.asset(AppImages.search, width: 21, height: 21, color: AppColors.white)),
        SizedBox(width: 20),
        InkWell(onTap: () => model.loadTickets(forceRefresh: true), child: Image.asset(AppImages.refresh, width: 21, height: 21, color: AppColors.white)),
        SizedBox(width: AppSizes.w8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TicketsListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.searchQuery = value;
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_tickets"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Padding(padding: EdgeInsets.all(12), child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.primary)),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                      model.searchQuery = '';
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h20),
      itemCount: 5, // Number of shimmer items to show
      itemBuilder: (context, index) {
        return TicketCardShimmer();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TicketsListViewModel model, {required bool isActive}) {
    String mainText = isActive ? LanguageService.get('no_active_tickets_found') : LanguageService.get('no_feedback_yet');
    String subText = isActive ? LanguageService.get('create_a_ticket_to_get_support') : LanguageService.get('all_your_resolved_tickets_will_appear_here');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(
              isActive ? Icons.support_agent_outlined : Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(mainText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: AppSizes.h8),
          if (isActive) SizedBox() else Text(subText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTicketsListWithPagination(BuildContext context, TicketsListViewModel model, List<TicketList> tickets, {required bool isActive}) {
    final tabIndex = isActive ? 0 : 1;
    final hasMoreTickets = isActive ? model.hasMoreActive : model.hasMoreResolved;
    final isCurrentTab = model.selectedTabIndex == tabIndex;
    final isLoadingMore = model.isLoadingMore && isCurrentTab;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (isCurrentTab && !isLoadingMore && hasMoreTickets && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          // User has scrolled near the bottom (within 200 pixels), load more tickets
          model.loadMoreTickets();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
        itemCount: tickets.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tickets.length) {
            return _buildLoadingIndicator(context, model);
          }
          final ticket = tickets[index];
          return _buildTicketCard(context, ticket, model);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, TicketsListViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h16),
      child: Center(
        child: Padding(padding: EdgeInsets.all(AppSizes.v16), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketList ticket, TicketsListViewModel model) {
    final pendingDuration = ticket.status?.toLowerCase() =="resolved"?_calculatePendingDuration(ticket.resolvedAt):_calculatePendingDuration(ticket.createdAt);
    // final pendingDuration = _calculatePendingDuration(ticket);

    return GestureDetector(
      onTap: () {
        //TODO:  don't remove
        // if (ticket.paymentStatus == 'paid') {
         model.currentOpenTicketId= ticket.id??'';
        model.currentOpenTicketStatus.value= ticket.status??'';
        model.navigateToTicketDetails(ticketId: ticket.id ?? '');
        // } else {
        //   model.navigateToReviewTicketWithId(ticketId: ticket.id ?? '');
        // }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.h10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.v10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCountryFlag(context, ticket),
                  SizedBox(width: AppSizes.w10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticket.organisation?.fullName?.toString().capitalizeWords  ?? '-',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (ticket.status == "On Hold") _buildCountdownTimer(ticket, model),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColorFromString(ticket.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSizes.v8),
                                  ),
                                  child: Text(
                                    ticket.status ?? '-',
                                    style: TextStyle(color: _getStatusColorFromString(ticket.status), fontSize: AppSizes.v12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (ticket.createdAt != null) ...[
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text('${ticket.status?.toLowerCase() =="resolved"? LanguageService.get("Resolved In"):LanguageService.get("pending_since")} : ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                              Text(pendingDuration, style: TextStyle(fontSize: 11, color: AppColors.black))
                                    // Text("${ticket.resolvedAt??0} hours ${ticket.resolutionDurationMinutes??0} min", style: TextStyle(fontSize: 11, color: AppColors.black)),
                                  ],
                                ),
                              ),
                              Text("#"+(ticket.ticketNumber ?? '-'), style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              Divider(),
              AppGaps.h8,

              Row(
                children: [
                  Expanded(
                    child: InfoColumn(label: LanguageService.get("created_date"), value: _formatTicketDate(ticket.createdAt!.toIso8601String())),
                  ),
                  if (ticket.errorCode != null && ticket.errorCode != "") ...[
                    Expanded(
                      child: InfoColumn(
                        label: LanguageService.get("error_code"),
                        value: ticket.errorCode == null || ticket.errorCode == "" ? "-" : ticket.errorCode ?? '-',
                      ),
                    ),
                  ],
                  Expanded(
                    child: InfoColumn(
                      label: LanguageService.get("warranty_status"),
                      value: ticket.warrantyStatus ?? "-",
                      valueColor: ticket.warrantyStatus == 'In warranty' ? AppColors.success : AppColors.redBack,
                      valueFontWeight: FontWeight.w600,
                      valueFontSize: 10,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (ticket.errorCode == null || ticket.errorCode == "") ...[Expanded(child: SizedBox())],
                ],
              ),
              AppGaps.h8,

              Divider(),
              AppGaps.h8,
              if ((ticket.problem != null && ticket.problem!.isNotEmpty) || (ticket.notes != null && ticket.notes!.isNotEmpty))
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                          children: [
                            TextSpan(
                              text: "${LanguageService.get("problem_description")}: ",
                              style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ticket.problem ?? ticket.notes ?? "-", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if ((ticket.problem != null && ticket.problem!.isNotEmpty) || (ticket.notes != null && ticket.notes!.isNotEmpty)) AppGaps.h8,
              if ((ticket.problem != null && ticket.problem!.isNotEmpty) || (ticket.notes != null && ticket.notes!.isNotEmpty)) Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (ticket.status != "Resolved") ...[
                    ElevatedButton(
                      onPressed:
                          (ticket.IsShowChatOption == true && ticket.status?.toLowerCase() != "waiting for accept")
                              ? () {
                            model.currentOpenTicketId= ticket.id??'';
                                _openChat(ticket, model);
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (ticket.IsShowChatOption == true && ticket.status?.toLowerCase() != "waiting for accept") ? AppColors.primary : AppColors.gray,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(60, 30),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      child: Text(LanguageService.get("chat_now"), style: TextStyle(fontSize: 12)),
                    ),
                    Spacer(),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        model.currentOpenTicketId = ticket.id ?? '';
                        _openChat(ticket, model);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(60, 30),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      child: Text(LanguageService.get("see_chat_record"), style: TextStyle(fontSize: 12)),
                    ),
                    Spacer(),
                  ],
                  if(ticket.status != "Resolved")...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.softGray,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                      ),
                      child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                    ),
                  ]


                ],
              ),
              Row(
                children: [
                  if (ticket.status == "Resolved") ...[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                        ),
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                            children: [
                              TextSpan(
                                text: "${LanguageService.get("engineer_remarks")}: ",
                                style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ticket.engineerRemark ?? "-", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.softGray,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                      ),
                      child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                    ),
                  ],


                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag(BuildContext context, TicketList ticket) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v16)),
          alignment: Alignment.center,
          child: Text(
            ticket.processor?.fullName?.substring(0, 2).toUpperCase() ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: ClipRRect(borderRadius: BorderRadius.circular(2), child: SvgPicture.network((ticket.flag??'').prefixWithBaseUrl, width: 17, height: 17, fit: BoxFit.cover)),
        ),
      ],
    );
  }

  String _calculatePendingDuration( DateTime? tickets) {
    // if (ticket.createdAt == null) return LanguageService.get('unknown');

    try {
      final createdAt = tickets ?? DateTime.now();
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ${difference.inHours % 24}h';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return '${difference.inMinutes} ${LanguageService.get("mins")}';
      }
    } catch (e) {
      return LanguageService.get('unknown');
    }
  }

  String _formatTicketDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat('MMM dd,yyyy HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColorFromString(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'on hold':
        return Colors.red;
      case 'waiting for accept':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildExpandableFloatingActionButton(TicketsListViewModel model) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [_buildTapToCloseFab(), ..._buildExpandingActionButtons(model), _buildTapToOpenFab()],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_fabOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(!_fabOpen ? 0.7 : 1.0, !_fabOpen ? 0.7 : 1.0, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: !_fabOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "tickets_close_fab",
            onPressed: _toggleFab,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.close_rounded),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons(TicketsListViewModel model) {
    final children = <Widget>[];
    final count = 2; // Online Support and Site Visit
    final step = 40.0 / (count - 1);
    final buttons = [
      _ActionButton(onPressed: () => _onSiteVisitPressed(model), label: 'site_visit'.lang, backgroundColor: AppColors.primaryLight),
      _ActionButton(onPressed: () => _onOnlineSupportPressed(model), label: 'online_support'.lang, backgroundColor: AppColors.primary),
    ];

    // Initialize FAB animation if not already done
    _initializeFabAnimation();

    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
      children.add(_ExpandingActionButton(directionInDegrees: angleInDegrees, maxDistance: 90, progress: _expandAnimation!, child: buttons[i]));
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _fabOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_fabOpen ? 0.7 : 1.0, _fabOpen ? 0.7 : 1.0, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _fabOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "tickets_open_fab",
            onPressed: _toggleFab,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  _openChat(TicketList ticket, TicketsListViewModel model) async {
    if (ticket.chatRoom?.id == null) {
      Fluttertoast.showToast(msg: "Chat room not found");
      return;
    }
    final ticketNumber = ticket.ticketNumber ?? 'Unknown';
    final chatWithName = ticket.organisation?.fullName?.toString().capitalizeWords  ?? 'Customer';
    final ticketStatus = ticket.status ?? '';
    final contactInitials = chatWithName.isNotEmpty ? chatWithName.substring(0, 1).toUpperCase() : 'U';
    final roomId = ticket.chatRoom?.id ?? '';

    // Navigate to chat screen and wait for result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatView(
              contactName: chatWithName,
              contactNumber: ticketNumber,
              contactInitials: contactInitials,
              updatedAt: ticket.status?.toLowerCase() =="resolved"? ticket.createdAt?.formatReadableDate():ticket.createdAt?.formatReadableDate(),
              roomId: roomId,
              ticketStatus: ticketStatus,
              ticketId: ticket.id,
              flag: ticket.flag,
            ),
      ),
    );

    // If ticket was resolved, refresh the tickets list
    if (result == true) {
      await model.loadTickets(forceRefresh: true);
    }
  }

  Widget _buildCountdownTimer(TicketList ticket, TicketsListViewModel model) {
    print("residyul:- ${ticket.rescheduleUpdateTime}");
    if (ticket.rescheduleUpdateTime == null) {
      return Text('-', style: TextStyle(color: _getStatusColorFromString(ticket.status), fontSize: AppSizes.v12));
    }

    return StreamBuilder<DateTime>(
      stream: Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final rescheduleTime = ticket.rescheduleUpdateTime!;

        if (now.isAfter(rescheduleTime)) {
          // Trigger background refresh when timer expires (only once per ticket)
          final ticketId = ticket.id ?? '';
          if (ticketId.isNotEmpty && !_expiredTicketIds.contains(ticketId)) {
            _expiredTicketIds.add(ticketId);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              model.loadTickets(forceRefresh: true);
            });
          }
          return Text('Expired', style: TextStyle(color: AppColors.error, fontSize: AppSizes.v12));
        }

        final difference = rescheduleTime.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        String timeString;
        if (hours > 0) {
          timeString = '${hours}h ${minutes}m ${seconds}s';
        } else if (minutes > 0) {
          timeString = '${minutes}m ${seconds}s';
        } else {
          timeString = '${seconds}s';
        }

        return Text(
          timeString,
          style: TextStyle(color: _getStatusColorFromString(ticket.status), fontSize: AppSizes.v12, fontWeight: FontWeight.w500),
        );
      },
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({required this.directionInDegrees, required this.maxDistance, required this.progress, required this.child});

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(directionInDegrees * (math.pi / 180.0), progress.value * maxDistance);
        return Positioned(
          right: -10 + offset.dx,
          bottom: 6 + offset.dy,
          child: Transform.rotate(angle: (1.0 - progress.value) * math.pi / 2, child: child!),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({this.onPressed, required this.label, required this.backgroundColor});

  final VoidCallback? onPressed;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// Shimmer loading state for the ticket card
class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.v10),
        child: Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withValues(alpha: 0.3),
          highlightColor: AppColors.lightGrey.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header section with avatar and name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar shimmer
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppSizes.v16)),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppSizes.w10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppSizes.v8)),
                              child: Container(
                                height: 12,
                                width: 60,
                                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    height: 12,
                                    width: 80,
                                    decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    height: 12,
                                    width: 60,
                                    decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGrey),
              AppGaps.h8,

              // Info columns section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildShimmerInfoColumn(), _buildShimmerInfoColumn(), _buildShimmerInfoColumn()],
              ),
              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGrey),
              AppGaps.h8,

              // Problem description section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 2),
                        Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGrey),

              // Action buttons section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 30, width: 80, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6))),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 10, width: 60, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
        SizedBox(height: 4),
        Container(height: 10, width: 40, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
      ],
    );
  }
}
