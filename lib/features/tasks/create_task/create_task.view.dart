import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/features/tasks/create_task/create_task.vm.dart';
import 'package:manager/features/tasks/create_task/widgets/add_media_widget.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common/custom_dropdown.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:stacked/stacked.dart';

class AssignTaskScreen extends StackedView<CreateTaskViewModel> {
  const AssignTaskScreen({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      CreateTaskViewModel viewModel,
      Widget? child,
      ) {

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(LanguageService.get('assignNewTask')),
        // Gradient (jaisa pichhli screen me tha)
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primaryDark],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              stops: const [0.08, 1],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // (const hata diya)
        padding: EdgeInsets.all(AppSizes.h16),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Assign To Section ---
              viewModel.isDropdownLoading?SizedBox():
              _FormSection(
                label: LanguageService.get('assignTo'),
                child: CustomDropdownFormField<Employee>(
                  hintText: LanguageService.get('selectEmployee'),
                  items:viewModel.employees.map((Employee type) {
                    return DropdownMenuItem<Employee>(
                      value:type,
                      child: Text(
                        type.name??'',
                        style: TextStyle(color: AppColors.black),
                      ),
                    );
                  }).toList(),
                  label: '',
                  onChanged: viewModel.onEmployeeSelected,
                  validator: (value) =>
                  value == null ? 'Please assign to an employee' : null,
                ),
              ),
              // --- Title Section ---
              _FormSection(
                label: LanguageService.get('title'),
                child: CommonTextField(
                  controller: viewModel.titleController,
                  placeholder: LanguageService.get('title'),
                  validator: (value) =>
                  value!.isEmpty ? 'Field cannot be empty' : null,
                ),
              ),
              AppGaps.h20,

              // --- Description Section ---
              _FormSection(
                label: LanguageService.get('description'),
                child: CommonTextField(
                  controller: viewModel.descriptionController,
                  placeholder: LanguageService.get('writeHere'),
                  maxLines: 4,
                  validator: (value) =>
                  value!.isEmpty ? 'Field cannot be empty' : null,
                ),
              ),
              AppGaps.h20,

              // --- Upload Media Section ---
              AddMediaWidget(
                onTap: viewModel.pickMedia,
              ),

              // Picked files list
              if (viewModel.pickedFiles.isNotEmpty)
                _buildPickedFilesList(viewModel),

              AppGaps.h24,

              // --- Time Line Section ---
              Text(
                LanguageService.get('timeLineOfTask'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppGaps.h12,
              _FormSection(
                label: LanguageService.get('startingDateTime'),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: viewModel.startDateController,
                        placeholder: 'YYYY/MM/DD',
                        readOnly: true,
                        onTap: () => viewModel.selectStartDate(context),
                        suffixIcon:
                        Icon(Icons.calendar_today_outlined, size: 20),
                        validator: (value) =>
                        value!.isEmpty ? 'Select date' : null,
                      ),
                    ),
                    AppGaps.w12,
                    Expanded(
                      child: CommonTextField(

                        controller: viewModel.startTimeController,
                        placeholder: 'HH:MM',
                        readOnly: true,
                        onTap: () => viewModel.selectStartTime(context),
                        suffixIcon: Icon(Icons.access_time, size: 20),
                        validator: (value) =>
                        value!.isEmpty ? 'Select time' : null,
                      ),
                    ),
                  ],
                ),
              ),
              AppGaps.h20,
              _FormSection(
                label: LanguageService.get('endingDateTime'),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: viewModel.endDateController,
                        placeholder: 'YYYY/MM/DD',
                        readOnly: true,
                        onTap: () => viewModel.selectEndDate(context),
                        suffixIcon:
                        Icon(Icons.calendar_today_outlined, size: 20),
                        validator: (value) =>
                        value!.isEmpty ? 'Select date' : null,
                      ),
                    ),
                    AppGaps.w12,
                    Expanded(
                      child: CommonTextField(
                        controller: viewModel.endTimeController,
                        placeholder: 'HH:MM',
                        readOnly: true,
                        onTap: () => viewModel.selectEndTime(context),
                        suffixIcon: Icon(Icons.access_time, size: 20),
                        validator: (value) =>
                        value!.isEmpty ? 'Select time' : null,
                      ),
                    ),
                  ],
                ),
              ),
              AppGaps.h20,

              // --- Priority Section ---
              _FormSection(
                label: LanguageService.get('priority'),
                child: CustomDropdownFormField<String>(
                  hintText: LanguageService.get('selectPriority'),
                  items: viewModel.priorities.map((String type) {
                    return DropdownMenuItem<String>(
                      value:type,
                      child: Text(
                        type,
                        style: TextStyle(color: AppColors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: viewModel.onPrioritySelected,
                  label: '',
                  validator: (value) =>
                  value == null ? 'Please select priority' : null,
                ),
              ),
              AppGaps.h20,

              // --- Web URL Section ---
              _FormSection(
                label: LanguageService.get('webUrlOptional'),
                child: CommonTextField(
                  controller: viewModel.webUrlController,
                  placeholder: 'Url',
                  // (Validation nahi hai, optional hai)
                ),
              ),
              AppGaps.h20,



            ],
          ),
        ),
      ),
      // --- Bottom Create Task Button ---
      bottomNavigationBar: Container(

        height: 85,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGrey,
              spreadRadius: 0,
              blurRadius: 10,
            )
          ]
        ),
        padding: EdgeInsets.all(AppSizes.h16),
        child: CommonElevatedButton(
          label: LanguageService.get('createTask'),
          isLoading: viewModel.isBusy,
          borderRadius: AppSizes.h45,

          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          onPressed: viewModel.createTask,
        ),
      ),
    );
  }
  @override
  void onViewModelReady(CreateTaskViewModel viewModel) {
    viewModel.onModelReady();
  }
  @override
  CreateTaskViewModel viewModelBuilder(BuildContext context) =>
      CreateTaskViewModel();


  // Pick ki hui files ki horizontal list
  Widget _buildPickedFilesList(CreateTaskViewModel viewModel) {
    return Container(
      height: AppSizes.h100,
      margin: EdgeInsets.only(top: AppSizes.h16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.pickedFiles.length,
        itemBuilder: (context, index) {
          final file = viewModel.pickedFiles[index];
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: AppSizes.h100,
                height: AppSizes.h100,
                margin: EdgeInsets.only(right: AppSizes.w8),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppSizes.h8),
                  image: file.path.contains('.jpg') || file.path.contains('.png')
                      ? DecorationImage(
                      image: FileImage(file), fit: BoxFit.cover)
                      : null,
                ),
                child: !(file.path.contains('.jpg') || file.path.contains('.png'))
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.h8),
                    child: Text(
                      file.path.split('/').last,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                    : null,
              ),
              // Remove button
              InkWell(
                onTap: () => viewModel.removeFile(index),
                child: Container(
                  margin: EdgeInsets.all(AppSizes.h4),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: AppSizes.h16,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

/// Local helper widget (jaisa reference code me tha)
class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormSection({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textGrey),
        ),
        AppGaps.h8,
        child,
      ],
    );
  }
}