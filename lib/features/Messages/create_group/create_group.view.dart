import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/employee.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'create_group.vm.dart';

class CreateGroupChatViewAttributes {
  final List<Employee>? preselectedEmployees;
  CreateGroupChatViewAttributes({this.preselectedEmployees});
}

class CreateGroupChat extends StatelessWidget {
  const CreateGroupChat({super.key, this.attributes});

  final CreateGroupChatViewAttributes? attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateGroupChatViewModel>.reactive(
      viewModelBuilder: () => CreateGroupChatViewModel(),
      onViewModelReady: (CreateGroupChatViewModel model) => model.init(attributes?.preselectedEmployees),
      disposeViewModel: false,
      builder: (BuildContext context, CreateGroupChatViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: Color(0xFFF5F5FA),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              LanguageService.get("create_group_chat"),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Group name input
              Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: model.groupNameController,
                    decoration: InputDecoration(
                      hintText: LanguageService.get("group_name"),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: model.searchController,
                    onChanged: model.searchUsers,
                    decoration: InputDecoration(
                      hintText: LanguageService.get("search_by_name_or_id"),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              // Employee List
              Expanded(
                child: model.isBusy
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : model.filteredEmployees.isEmpty
                    ? Center(child: Text(LanguageService.get("no_employees_found")))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: model.filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = model.filteredEmployees[index];
                    final isSelected = model.isEmployeeSelected(employee);
                    final role = employee.role?.toLowerCase() ?? "employee";
                    final roleColor = role == "manager" ? Colors.blue : Colors.teal;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => model.toggleEmployeeSelection(employee),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Blue accent line
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.secondary : AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 16),

                              // Avatar with first letter of name
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.secondary.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                      color: isSelected ? AppColors.secondary : Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: (employee.name?.isNotEmpty ?? false)
                                      ? Text(
                                    employee.name![0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.secondary : AppColors.primary,
                                    ),
                                  )
                                      : Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),

                              // Name and Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      employee.name ?? LanguageService.get("unknown"),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: isSelected ? AppColors.secondary : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      employee.email ?? "",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isSelected ? AppColors.secondary : roleColor)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: isSelected ? AppColors.secondary : roleColor,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            role.capitalize(),
                                            style: TextStyle(
                                              color: isSelected ? AppColors.secondary : roleColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Chevron or checkbox indicator
                              isSelected
                                  ? Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                                  : Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: model.selectedEmployees.isNotEmpty ? () => model.createGroupChat() : null,
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    model.selectedEmployees.isNotEmpty
                        ? "${LanguageService.get("create_group")} (${model.selectedEmployees.length})"
                        : LanguageService.get("select_employees"),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}