import 'package:flutter/material.dart';
import 'package:manager/features/organization/employees_list/widgets/employee_card.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'employee_list.vm.dart';

class EmployeeListViewAttributes {
  final String role;

  EmployeeListViewAttributes({
    required this.role,
  });

  factory EmployeeListViewAttributes.fromJson(Map<String, String> json) {
    return EmployeeListViewAttributes(
      role: json['role'] ?? '',
    );
  }

  Map<String, String> toJson() {
    return {
      'role': role,
    };
  }
}

class EmployeesListView extends StatefulWidget {
  const EmployeesListView({super.key, required this.attributes});
  final EmployeeListViewAttributes attributes;

  @override
  State<EmployeesListView> createState() => _EmployeesListViewState();
}

class _EmployeesListViewState extends State<EmployeesListView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
    return ViewModelBuilder<EmployeesListViewModel>.reactive(
      viewModelBuilder: () => EmployeesListViewModel(),
      onViewModelReady: (EmployeesListViewModel model) => model.init(widget.attributes),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          EmployeesListViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildAppBar(context, model),
          floatingActionButton: FloatingActionButton(
            onPressed: model.showScanQrOptions,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, color: AppColors.white),
          ),
          body: Column(
            children: [
              // Animated search bar
              SlideTransition(
                position: _slideAnimation,
                child: _isSearchVisible
                    ? _buildSearchBar(context, model)
                    : const SizedBox.shrink(),
              ),
              // _buildRoleFilters(context, model),
              Expanded(child: _buildEmployeesList(context, model)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      EmployeesListViewModel model,
      ) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        'Your Team',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearchVisible ? Icons.close : Icons.search,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, EmployeesListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.searchQuery = value;
        },
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
          suffixIcon: _searchController.text.isNotEmpty
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

  Widget _buildEmployeesList(
      BuildContext context,
      EmployeesListViewModel model,
      ) {
    if (model.isBusy) {
      return _buildLoadingState();
    }

    if (model.filteredEmployees.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: () async => model.refreshEmployees(),
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w20,
          vertical: AppSizes.h12,
        ),
        itemCount: model.filteredEmployees.length,
        itemBuilder: (context, index) {
          final employee = model.filteredEmployees[index];
          return EmployeeCard(
            attributes: EmployeeCardAttributes(
              onTap: () => model.onEmployeeTap(employee),
              leadingImageUrl:
              'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
              title: employee.name ?? 'Unknown Employee',
              status: employee.role ?? employee.employmentStatus ?? 'Active',
              trailingImageUrl:
              'https://img.freepik.com/free-vector/round-flag-india_23-2147813736.jpg',
              employee: employee,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return EmployeeCardShimmer();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, EmployeesListViewModel model) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.v24),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_outlined,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: AppSizes.h20),
            Text(
              'No employees found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.h8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.w40),
              child: Text(
                model.searchQuery.isNotEmpty || model.selectedRole != 'all'
                    ? 'Try changing your search or filters'
                    : 'Add employees to your team',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSizes.h30),
            if (model.searchQuery.isEmpty && model.selectedRole == 'all')
              ElevatedButton.icon(
                onPressed: model.showScanQrOptions,
                icon: Icon(Icons.add, color: AppColors.white),
                label: Text(
                  'Add Employee',
                  style: TextStyle(color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w24,
                    vertical: AppSizes.h12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}