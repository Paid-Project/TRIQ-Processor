import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/home/machine_overview/machine_overview.vm.dart';
import 'package:manager/core/models/machine_overview_model.dart';

class MachineOverviewView extends StatefulWidget {
  final bool refreshOnInit;

  const MachineOverviewView({super.key, this.refreshOnInit = false});

  @override
  State<MachineOverviewView> createState() => _MachineOverviewViewState();
}

class _MachineOverviewViewState extends State<MachineOverviewView> with TickerProviderStateMixin {
  final _navigationService = locator<NavigationService>();
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

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
      _clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineOverviewViewModel>.reactive(
      viewModelBuilder: () => MachineOverviewViewModel()..init(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, viewModel) : const SizedBox.shrink()),
                  Expanded(
                    child:
                        viewModel.isLoading
                            ? RefreshIndicator(
                              onRefresh: viewModel.refreshMachines,
                              backgroundColor: AppColors.white,
                              child: SingleChildScrollView(child: _buildShimmerList()),
                            )
                            : RefreshIndicator(
                              backgroundColor: AppColors.white,
                              onRefresh: viewModel.refreshMachines,
                              child: SingleChildScrollView(child: _buildMachineList(context, viewModel)),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
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
      leading: IconButton(icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white), onPressed: () => Get.back()),
      titleSpacing: 0,
      title: Text('machine_overview'.lang, style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: Image.asset(AppImages.search, width: 24, height: 24, color: AppColors.white), onPressed: _toggleSearch)],
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(AppImages.empty, width: 160, height: 160),

          Text(
            LanguageService.get('no_machines_linked'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          AppGaps.h12,
          Text(
            LanguageService.get('no_machines_linked_description'),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          AppGaps.h24,
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '💡 ',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      LanguageService.get('what_you_can_do'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                AppGaps.h16,
                _buildInfoItem(LanguageService.get('contact_manufacturer')),
                AppGaps.h12,
                _buildInfoItem("Once added, you'll be able to: View machine details"),
                AppGaps.h12,
                _buildInfoItem("Track warranty & service"),
                AppGaps.h12,
                _buildInfoItem("Raise support tickets"),
                AppGaps.h12,
                _buildInfoItem("Monitor installation progress"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
        ),
        AppGaps.w8,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, MachineOverviewViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_machines'.lang,
          prefixIcon: Padding(padding: const EdgeInsets.all(16), child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.gray)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _clearSearch();
                      viewModel.clearSearch();
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
        ),
        onTapOutside: (event) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        onChanged: viewModel.onSearchChanged,
      ),
    );
  }

  Widget _buildMachineList(BuildContext context, MachineOverviewViewModel viewModel) {

    if (viewModel.hasError) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.textGrey),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage,
                style: TextStyle(color: AppColors.textGrey, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: viewModel.refreshMachines, child: Text('retry'.lang)),
            ],
          ),
        ),
      );
    }



    if (viewModel.filteredMachines.isEmpty) {
      // 🔥 IMPORTANT LOGIC
      if (viewModel.isSearching) {
        return Center(
          child: Text("No Data Found"),
        );
      } else {
        return _buildEmptyState(context);
      }
    }
    return Column(children: viewModel.filteredMachines.map((machine) => _buildMachineCard(context, machine, viewModel)).toList());
  }

  Widget _buildMachineCard(BuildContext context, MachineOverviewList machine, MachineOverviewViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () async {
          final result = await _navigationService.navigateTo(Routes.machineOverviewDetails, arguments: machine);

          if (result == true) {
            viewModel.refreshMachines();
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: AppColors.colorF0F2FC, borderRadius: BorderRadius.circular(16)),
              child: Text(
                machine.machineType?.substring(0, 2).toUpperCase() ?? 'NA',
                style: TextStyle(color: AppColors.colorBlue, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${machine.modelNumber?.toUpperCase() ?? 'N/A'} - ${machine.machineName?.toUpperCase() ?? 'Unknown Machine'}",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if(machine.remark!=''&& machine.remark!=null)
                  Row(
                    children: [
                      Text("${"add_on".lang}: ", style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.bold)),

                      Expanded(child: Text(machine.remark ?? 'N/A', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final result = await _navigationService.navigateTo(Routes.machineOverviewDetails, arguments: machine);

                if (result == true) {
                  viewModel.refreshMachines();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                ),
                child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 60, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(children: List.generate(6, (index) => _buildMachineCardShimmer())),
    );
  }
}
