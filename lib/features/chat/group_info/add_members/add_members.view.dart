import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:stacked/stacked.dart';

import 'add_members.vm.dart';

class AddMembersScreen extends StatelessWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMembersViewModel>.reactive(
      viewModelBuilder: () => AddMembersViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F6F8),
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.textGrey.withValues(alpha: 0.12),
                    ),
                  ),
                  child: TextField(
                    controller: model.searchController,
                    onChanged: model.searchEmployees,
                    decoration: const InputDecoration(
                      hintText: 'Search members',
                      prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: model.isBusy
                      ? const Center(child: CircularProgressIndicator())
                      : model.loadError != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  model.loadError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : model.filteredEmployees.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No employees found',
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: model.filteredEmployees.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final employee =
                                        model.filteredEmployees[index];
                                    return _EmployeeTile(employee: employee , model: model,);
                                  },
                                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile( {required this.employee,required this.model});
 final AddMembersViewModel model;

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if ((employee.designation?.name ?? '').trim().isNotEmpty)
        employee.designation!.name!.trim(),
      if ((employee.phone ?? '').trim().isNotEmpty) employee.phone!.trim(),
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.softGray,
        child: Text(
          (employee.displayName.isNotEmpty
                  ? employee.displayName[0]
                  : 'U')
              .toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        employee.displayName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitleParts.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitleParts.join(' | '),
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ),
      trailing: GestureDetector(
        onTap: () {
          model.addMember(employee.id!);
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context) {
  return GradientAppBar(
    leading: IconButton(
      icon: Image.asset(
        AppImages.back,
        width: 24,
        height: 24,
        color: AppColors.white,
      ),
      onPressed: () => Navigator.of(context).pop(),
    ),
    titleWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [


        const Text(
          'Add Members',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    ),
    titleSpacing: 0,
    actions: const [
      SizedBox(width: 25),
    ],
  );
}
