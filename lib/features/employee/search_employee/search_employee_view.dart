import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/features/employee/add_employee/add_employee.view.dart';
import 'package:manager/features/employee/search_employee/search_employee_vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../routes/routes.dart';


class SearchEmploeeView extends StatefulWidget {
  const SearchEmploeeView({super.key});

  @override
  State<SearchEmploeeView> createState() => _SearchEmploeeViewState();
}

class _SearchEmploeeViewState extends State<SearchEmploeeView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {}

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchEmploeeViewModel>.reactive(
      viewModelBuilder: () => SearchEmploeeViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: _buildAppBar(context),

          body: Column(
            children: [
              Container(
                color: AppColors.scaffoldBackground,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: _buildSearchTextField(context, model),
              ),

              Expanded(
                child: Container(
                  color: AppColors.scaffoldBackground,
                  child: _buildSearchContent(model),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
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
      title: Text(
        LanguageService.get('search_by_phone_number_email'),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildSearchTextField(
      BuildContext context,
      SearchEmploeeViewModel model,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              AppImages.search,
              width: 20,
              height: 20,
              color: AppColors.black,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: model.performSearch,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
              onTapOutside: (event) {
                _searchFocusNode.unfocus();
              },
              decoration: const InputDecoration(
                hintText: 'Search employee by name, phone, or email...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 16,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                model.clearSearch();
                model.cancelSearch();
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.close, color: AppColors.black, size: 20),
              ),
            ),
          if (model.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Image.asset(
        AppImages.earthSearch,
        width: 280,
        height: 280,
        color: AppColors.gray,
      ),
    );
  }

  Widget _buildSearchContent(SearchEmploeeViewModel model) {
    if (model.isLoading) {
      return Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withValues(alpha: 0.4),
          highlightColor: AppColors.white,
          period: const Duration(milliseconds: 1500),

          child:ListView.separated(
        padding: EdgeInsets.all(AppSizes.w10),
        itemBuilder: (context, index) {
          return  Container(color: AppColors.white,     height: Get.height * 0.08,
              width: Get.width);
        }, separatorBuilder: (BuildContext context, int index) { return SizedBox(height: AppSizes.h15); }, itemCount: 10,));
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          model.errorMessage!,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (model.searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: model.searchResults.length + 1,
      separatorBuilder:
          (context, index) =>
      index == 0
          ? SizedBox()
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: const Divider(color: AppColors.lightGrey, height: 1),
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(height: 10);
        }
        final result = model.searchResults[index - 1];
        return Container(
          color: AppColors.white,
          padding: EdgeInsets.all(10),
          child: _buildSearchResultItem(result, model),
        );
      },
    );
  }

  Widget _buildSearchResultItem(
      Employee result,
      SearchEmploeeViewModel model,
      ) {
    return InkWell(
      onTap: () async {
        final _navigationService = locator<NavigationService>();
        await _navigationService.navigateTo(
          Routes.addEmployee,
          arguments: AddEmployeeViewAttributes(
            id: result.id,
            hasReadOnly: false,
            isPartialAdd: true,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorF0F2FC,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bluebackground,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.bluebackground,
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.h5),
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child:  Image.asset('${AppImages.team_default}',fit: BoxFit.contain,)

                      ),
                    ),
                  ),
                ),
                if (result.flag != null)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: SvgPicture.network(result.flag?.prefixWithBaseUrl??'', width: 17, height: 17),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Text(
            result.name ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
