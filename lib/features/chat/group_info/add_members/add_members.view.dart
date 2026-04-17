import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:stacked/stacked.dart';

import 'add_members.vm.dart';

class AddMembersScreen extends StatefulWidget {
  final String? roomId;
  const AddMembersScreen({super.key, this.roomId});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMembersViewModel>.reactive(
      viewModelBuilder: () => AddMembersViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final employees = model.filteredEmployees;
        final Widget content;

        if (model.isBusy) {
          content = const Center(child: CircularProgressIndicator());
        } else if (model.loadError != null) {
          content = Center(
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
          );
        } else if (employees.isEmpty) {
          content = const Center(
            child: Text(
              'No employees found',
              style: TextStyle(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
          content = ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _EmployeeTile(employee: employee, model: model);
            },
          );
        }

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
                  child: content,
                ),
              ),
              if (!model.isBusy && model.loadError == null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: CommonElevatedButton(
                      label:
                          model.selectedMemberIds.isEmpty
                          ? 'Select members'
                          : 'Add ${model.selectedMemberIds.length} member${model.selectedMemberIds.length > 1 ? 's' : ''}',
                      width: double.infinity,
                      height: 48,
                      backgroundColor: AppColors.primary,
                      isLoading: model.isSubmitting,
                      onPressed:
                          widget.roomId == null ||
                              model.selectedMemberIds.isEmpty ||
                              model.isSubmitting
                          ? null
                          : () => model.addMember(
                            widget.roomId ?? "",
                            model.selectedMemberIds,
                          ),
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
  const _EmployeeTile({required this.employee, required this.model});
  final AddMembersViewModel model;

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final title = model.getEmployeeLabel(employee);
    final subtitleParts = [
      if ((employee.designation?.name ?? '').trim().isNotEmpty)
        employee.designation!.name!.trim(),
      if ((employee.department?.name ?? '').trim().isNotEmpty)
        employee.department!.name!.trim(),
      if ((employee.email ?? '').trim().isNotEmpty) employee.email!.trim(),
      if ((employee.phone ?? '').trim().isNotEmpty) employee.phone!.trim(),
    ];
    final memberId = model.getMemberId(employee);
    final isSelectable = memberId != null;
    final isSelected = model.isSelected(employee);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSelectable ? () => model.toggleMemberSelection(employee) : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.24)
                  : AppColors.textGrey.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.softGray,
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' | '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (!isSelectable) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'User ID not available',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SelectionRadio(
                  isSelected: isSelected,
                  isEnabled: isSelectable,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionRadio extends StatelessWidget {
  const _SelectionRadio({required this.isSelected, required this.isEnabled});

  final bool isSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : AppColors.textGrey.withValues(alpha: isEnabled ? 0.45 : 0.2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.transparent,
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
    actions: const [SizedBox(width: 25)],
  );
}
