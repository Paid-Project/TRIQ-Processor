import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'employee_role_cards.vm.dart';

class RoleEmployeeListView extends StatelessWidget {
  const RoleEmployeeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RoleEmployeeListViewModel>.reactive(
      viewModelBuilder: () => RoleEmployeeListViewModel(),
      onViewModelReady: (RoleEmployeeListViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          RoleEmployeeListViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          appBar: _buildAppBar(context),
          floatingActionButton: _buildFloatingActionButton(model),
          body: Container(
            color: AppColors.scaffoldBackground,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.w20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDepartmentList(context, model),
                  _buildCreateButton(context, model),
                  SizedBox(height: AppSizes.h55),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildFloatingActionButton(RoleEmployeeListViewModel model) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SizedBox(
        width: 200,
        height: 46,
        child: FloatingActionButton.extended(
          onPressed: () => model.showScanQrOptions(),
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: Icon(Icons.add, color: AppColors.white, size: 20),
          label: Text(
            LanguageService.get("assign_new_departments"),
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        LanguageService.get("all_departments"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDepartmentList(BuildContext context, RoleEmployeeListViewModel model) {
    final departments = model.availableDepartments;
    return Column(
      children: departments.map((department) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.h12),
          child: _buildDepartmentCard(context, model, department),
        );
      }).toList(),
    );
  }

  Widget _buildDepartmentCard(
      BuildContext context,
      RoleEmployeeListViewModel model,
      Department department,
      ) {
    final departmentInfo = model.getDepartmentInfo(department);
    return
      InkWell(
        onTap: () => model.navigateToDepartment(department),
        borderRadius: BorderRadius.circular(AppSizes.v16),
        child: Container(
          padding: EdgeInsets.all(AppSizes.w10),
          decoration: BoxDecoration(
            color: departmentInfo.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.v16),
            border: Border(
              left: BorderSide(
                color: departmentInfo.primaryColor,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Department Icon
              Container(
                padding: EdgeInsets.all(AppSizes.w18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.v40),
                ),
                child: Icon(
                  departmentInfo.icon,
                  color: departmentInfo.primaryColor,
                  size: 28,
                ),
              ),

              SizedBox(width: AppSizes.w16),

              // Department Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departmentInfo.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.h4),
                    if (departmentInfo.isFunctional)
                      FutureBuilder<int>(
                        future: model.getDepartmentEmployeeCount(department),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data} ${snapshot.data == 1 ? LanguageService.get('employee') : LanguageService.get('employees')}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textGrey.withValues(alpha: 0.8),
                              ),
                            );
                          }
                          return Text(
                            LanguageService.get('loading'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGrey.withValues(alpha: 0.8),
                            ),
                          );
                        },
                      )
                    else
                      Text(
                        LanguageService.get('coming_soon'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              // Arrow Icon
              if (departmentInfo.isFunctional)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  size: 24,
                ),
            ],
          ),
        ),
      );
  }

  Widget _buildCreateButton(BuildContext context, RoleEmployeeListViewModel model) {
    return
      InkWell(
        onTap: () {

        },
        borderRadius: BorderRadius.circular(AppSizes.v16),
        child: Container(
          padding: EdgeInsets.all(AppSizes.w20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v16),
            border: Border(
              left: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 4,
              ),
              right: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              top: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.w12),
                decoration: BoxDecoration(
                  color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.v30),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSizes.w16),
              Text(
                LanguageService.get('create_new_departments'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
  }
}