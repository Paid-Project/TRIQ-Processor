import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'machine_card/machine_card.dart';
import 'machines_list.vm.dart';

class MachinesListViewAttributes {
  final String processorId;
  final String organizationId;
  final String title;
  final bool showAddButton;
  final bool showFilterButton;

  const MachinesListViewAttributes({
    this.processorId = '',
    this.organizationId = '',
    required this.title,
    this.showAddButton = true,
    this.showFilterButton = true,
  });

  // Factory constructor for creating an instance from a JSON map
  factory MachinesListViewAttributes.fromJson(Map<String, String> json) {
    return MachinesListViewAttributes(
      processorId: json['processorId'] ?? '',
      organizationId: json['organizationId'] ?? '',
      title: json['title'] ?? '',
      showAddButton: bool.parse(json['showAddButton'] ?? 'true'),
      showFilterButton: bool.parse(json['showFilterButton'] ?? 'true'),
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, String> toJson() {
    return {
      'processorId': processorId ?? '',
      'organizationId': organizationId ?? '',
      'title': title ?? '',
      'showAddButton': showAddButton.toString(),
      'showFilterButton': showFilterButton.toString(),
    };
  }

  // Optional: Override equality for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MachinesListViewAttributes &&
        other.processorId == processorId &&
        other.organizationId == organizationId &&
        other.title == title &&
        other.showAddButton == showAddButton &&
        other.showFilterButton == showFilterButton;
  }

  // Optional: Generate hashCode when overriding equality
  @override
  int get hashCode {
    return processorId.hashCode ^ organizationId.hashCode ^ title.hashCode ^ showAddButton.hashCode ^ showFilterButton.hashCode;
  }
}

class MachinesListView extends StatefulWidget {
  final MachinesListViewAttributes attributes;

  const MachinesListView({super.key, MachinesListViewAttributes? attributes})
    : attributes = attributes ?? const MachinesListViewAttributes(title: 'Machines Inventory');

  @override
  State<MachinesListView> createState() => _MachinesListViewState();
}

class _MachinesListViewState extends State<MachinesListView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachinesListViewModel>.reactive(
      viewModelBuilder: () => MachinesListViewModel(),
      onViewModelReady: (MachinesListViewModel model) => model.init(widget.attributes),
      disposeViewModel: false,
      builder: (BuildContext context, MachinesListViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: Container(
            color: AppColors.scaffoldBackground,
            child: SafeArea(
              child: Column(
                children: [
                  SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => model.init(widget.attributes),
                      color: AppColors.primary,
                      backgroundColor: AppColors.white,
                      child: model.isLoading ? _buildLoadingShimmer() : _buildMainContent(context, model),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton:
              widget.attributes.showAddButton && getUser().organizationType == OrganizationType.manufacturer
                  ? FloatingActionButton(
                    onPressed:
                        () =>
                            widget.attributes.processorId.isEmpty && widget.attributes.organizationId.isEmpty
                                ? model.onAddMachineTap(context)
                                : model.onAssignMachineTap(widget.attributes.processorId ?? widget.attributes.organizationId),
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.add, color: AppColors.white),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, MachinesListViewModel model) {
    return CustomScrollView(
      slivers: [
        // Organization details header if available
        if (widget.attributes.organizationId.isNotEmpty || widget.attributes.processorId.isNotEmpty)
          SliverToBoxAdapter(
            child: ExpandableOrganizationHeader(
              details: model.manufacturer ?? model.processor ?? User(),
              isManufacturer: model.isManufacturer,
              model: model,
            ),
          ),

        // Machines list or empty state
        if (model.machines.isEmpty)
          if (widget.attributes.organizationId.isNotEmpty || widget.attributes.processorId.isNotEmpty)
            SliverFillRemaining(child: _buildAssignMachine(context, model))
          else
            SliverFillRemaining(child: _buildEmptyState(context, model))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final machine = model.machines[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h8),
                child: MachineCard(
                  attributes: MachineCardAttributes(
                    machine: machine,
                    onMachineTap: model.onMachineTap,
                    isMyMachine: model.initialOrganizationId.isEmpty && model.initialProcessorId.isEmpty,
                  ),
                ),
              );
            }, childCount: model.machines.length),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MachinesListViewModel model) {
    return AppBar(
      elevation: 0,
      title: Text(
        LanguageService.get("all_models"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
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
      actions: [
        IconButton(onPressed: _toggleSearch, icon: Icon(_isSearchVisible ? Icons.close : Icons.search, color: AppColors.white)),
        if (widget.attributes.showFilterButton)
          IconButton(icon: Icon(Icons.filter_list, color: AppColors.white), onPressed: () => _showFilterSheet(context, model)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, MachinesListViewModel model) {
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
          model.applyFilters();
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_machines"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
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
                      model.applyFilters();
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
        return MachineCardShimmer();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, MachinesListViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(Icons.precision_manufacturing_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.7)),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            LanguageService.get("no_machines_found"),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSizes.h8),
          if (getUser().organizationType == OrganizationType.manufacturer)
            Column(
              children: [
                Text(
                  LanguageService.get("no_machine_assigned"),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSizes.h30),
                if (getUser().organizationType == OrganizationType.manufacturer)
                  ElevatedButton.icon(
                    onPressed: () => model.onAddMachineTap(context),
                    icon: Icon(Icons.add, color: AppColors.white),
                    label: Text(LanguageService.get("add_machine"), style: TextStyle(color: AppColors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w24, vertical: AppSizes.h12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAssignMachine(BuildContext context, MachinesListViewModel model) {
    final organizationDetails = model.manufacturer ?? model.processor;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(Icons.precision_manufacturing_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.7)),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            LanguageService.get("no_machine_found"),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSizes.h8),
          if (getUser().organizationType == OrganizationType.manufacturer)
            Column(
              children: [
                Text(
                  LanguageService.get("no_machine_assigned"),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSizes.h30),
                if (getUser().organizationType == OrganizationType.manufacturer)
                  ElevatedButton.icon(
                    onPressed: () => model.onAssignMachineTap(organizationDetails?.id ?? ''),
                    icon: Icon(Icons.add, color: AppColors.white),
                    label: Text(LanguageService.get("assign_machine"), style: TextStyle(color: AppColors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w24, vertical: AppSizes.h12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, MachinesListViewModel model) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.v24)),
                boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.w24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterHeader(context),
                      SizedBox(height: AppSizes.h20),
                      _buildStatusFilter(context, model, setState),
                      SizedBox(height: AppSizes.h20),
                      _buildDepartmentFilter(context, model, setState),
                      SizedBox(height: AppSizes.h24),
                      _buildFilterActions(context, model),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LanguageService.get("filter"),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(icon: Icon(Icons.close, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context, MachinesListViewModel model, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
            SizedBox(width: AppSizes.w8),
            Text(LanguageService.get("status"), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: AppSizes.h12),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.v12), border: Border.all(color: AppColors.lightGrey)),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
              border: InputBorder.none,
            ),
            value: model.selectedStatus,
            hint: Text(LanguageService.get("all_statuses")),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            dropdownColor: AppColors.white,
            items:
                model.statusOptions.map((String status) {
                  return DropdownMenuItem<String>(value: status, child: Text(status));
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                model.updateStatusFilter(newValue);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentFilter(BuildContext context, MachinesListViewModel model, StateSetter setState) {
    // Verify at least "All" is in the departments list
    if (model.departments.isEmpty) {
      model.departments = ['All'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business, color: AppColors.primary, size: 20),
            SizedBox(width: AppSizes.w8),
            Text(LanguageService.get("department"), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: AppSizes.h12),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.v12), border: Border.all(color: AppColors.lightGrey)),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
              border: InputBorder.none,
            ),
            value: model.selectedDepartment,
            hint: Text(LanguageService.get("all_departments")),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            dropdownColor: AppColors.white,
            items:
                model.departments.map((String department) {
                  return DropdownMenuItem<String>(value: department, child: Text(department));
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                model.updateDepartmentFilter(newValue);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterActions(BuildContext context, MachinesListViewModel model) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              model.resetFilters();
              Navigator.pop(context);
              model.loadMachines();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
            ),
            child: Text(LanguageService.get("reset"), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(width: AppSizes.w16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              model.loadMachines();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
            ),
            child: Text(LanguageService.get("apply"), style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class ExpandableOrganizationHeader extends StatefulWidget {
  final User details;
  final bool isManufacturer;
  final MachinesListViewModel model;

  const ExpandableOrganizationHeader({super.key, required this.details, required this.isManufacturer, required this.model});

  @override
  _ExpandableOrganizationHeaderState createState() => _ExpandableOrganizationHeaderState();
}

class _ExpandableOrganizationHeaderState extends State<ExpandableOrganizationHeader> {
  bool _isExpanded = false;

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h6),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.v20, color: AppColors.primary.withOpacity(0.7)),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                Text(
                  value ?? 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    final address = widget.details?.address;
    if (address == null) return SizedBox.shrink();

    final addressText = [
      address.addressLine1,
      address.addressLine2,
      '${address.city}, ${address.state}',
      '${address.country} - ${address.pinCode}',
    ].where((line) => line != null && line.trim().isNotEmpty).join('\n');

    return Padding(
      padding: EdgeInsets.only(top: AppSizes.h12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary.withOpacity(0.7), size: AppSizes.v20),
              SizedBox(width: AppSizes.w8),
              Text(LanguageService.get("address"), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: AppSizes.h8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.w12),
            decoration: BoxDecoration(color: AppColors.lightGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(AppSizes.v10)),
            child: Text(addressText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: AppSizes.w60,
      height: AppSizes.w60,
      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppSizes.v12)),
      child: Icon(Icons.business, size: AppSizes.w30, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final organizationType = widget.isManufacturer ? LanguageService.get("manufacturer") : LanguageService.get("processor");
    final industry = details?.industry;

    return Container(
      margin: EdgeInsets.all(AppSizes.w20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section (Always Visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppSizes.v16),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.w16),
              child: Row(
                children: [
                  // Logo or Placeholder
                  if (details.logo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                      child: CachedNetworkImage(
                        imageUrl: details.logo!,
                        width: AppSizes.w60,
                        height: AppSizes.w60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildLogoPlaceholder(),
                        errorWidget: (context, error, stackTrace) => _buildLogoPlaceholder(),
                      ),
                    )
                  else
                    _buildLogoPlaceholder(),

                  SizedBox(width: AppSizes.w16),

                  // Organization Name and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(organizationType, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            if (industry != null) ...[
                              Text(' • ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                              Text(
                                industry,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Icon
                  Container(
                    padding: EdgeInsets.all(AppSizes.v8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.primary, size: AppSizes.v24),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Details Section
          if (_isExpanded) ...[
            Divider(color: AppColors.lightGrey),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First column of details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(context, Icons.person, LanguageService.get("contact_person"), details.yourName),
                            _buildDetailRow(context, Icons.work, LanguageService.get("designation"), details.designation),
                            _buildDetailRow(context, Icons.email, LanguageService.get("email"), details.email),
                            _buildDetailRow(context, Icons.phone, LanguageService.get("phone"), details.phone),
                            if (details.language != null) _buildDetailRow(context, Icons.language, LanguageService.get("language"), details.language),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Address section if available
                  if (details.address != null) _buildAddressSection(context),
                  if (getUser().organizationType == OrganizationType.manufacturer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => widget.model.removeProcessor(processorId: details.id ?? ''),
                          icon: Icon(Icons.delete, color: AppColors.white),
                          label: Text(LanguageService.get("remove"), style: TextStyle(color: AppColors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.w12, vertical: AppSizes.h10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
