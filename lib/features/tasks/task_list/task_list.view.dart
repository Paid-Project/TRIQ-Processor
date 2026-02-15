
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:manager/features/tasks/task_list/task_list.vm.dart';
import 'package:manager/features/tasks/widgets/task_card.dart'; // Updated Task Card
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../widgets/task_list_shimmer.dart';

class TaskListView extends StackedView<TaskListViewModel> {
  const TaskListView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      TaskListViewModel viewModel,
      Widget? child,
      ) {

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context, viewModel),
      body: _buildTaskList(context, viewModel),
      floatingActionButton: viewModel.selectedTaskTypeIndex == 1 ? _buildAssignTaskFab(viewModel) : null,
    );
  }

  @override
  TaskListViewModel viewModelBuilder(BuildContext context) => TaskListViewModel();
  @override
  void onViewModelReady(TaskListViewModel model) {
    model.init();
  }

  AppBar _buildAppBar(BuildContext context, TaskListViewModel viewModel) {
    const appBarColor = AppColors.primaryDark;
    const toggleContainerColor = AppColors.primary;

    return AppBar(
      // Aapka Gradient
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

      toolbarHeight: AppSizes.h70,

      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: viewModel.navigateBack,
      ),
      title:Container(
        height: AppSizes.h38,
        decoration: BoxDecoration(
          color: toggleContainerColor,
          borderRadius: BorderRadius.circular(AppSizes.h20),
        ),
        child: Row(
          children: [
            _buildTaskTypeToggle(viewModel, 0, LanguageService.get('myTask')),
            _buildTaskTypeToggle(
                viewModel, 1, LanguageService.get('assignedTask')),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            viewModel.isSearching ? Icons.close : Icons.search,
            color: AppColors.white,
            size: AppSizes.h28,
          ),
          onPressed: viewModel.onSearchPressed,
        ),
      ],
      bottom: viewModel.isSearching
          ? _buildSearchBar(context, viewModel)
          : _buildFilterChips(context, viewModel),
    );
  }
  PreferredSizeWidget _buildSearchBar(BuildContext context, TaskListViewModel viewModel) {
    return PreferredSize(
      preferredSize:  Size.fromHeight(AppSizes.h40),
      child: Container(
        color: AppColors.white,
        padding:  EdgeInsets.symmetric(
            horizontal: AppSizes.w16, vertical: AppSizes.h8),
        child: TextField(
          controller: viewModel.searchController,
          autofocus: true,
          onChanged: viewModel.onSearchChanged,
          onSubmitted: viewModel.onSearchSubmitted,
          decoration: InputDecoration(
            hintText: LanguageService.get('searchTasks'),
            prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.scaffoldBackground,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.h25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildFilterChips(BuildContext context, TaskListViewModel viewModel) {
    return PreferredSize(

        preferredSize:  Size.fromHeight(AppSizes.h40),
        child: Container(
          color: AppColors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:  EdgeInsets.symmetric(
                horizontal: AppSizes.w12, vertical: AppSizes.h10),
            child: Row(
              children: List.generate(viewModel.filterOptions.length, (index) {
                final bool isSelected = viewModel.selectedFilterIndex == index;
                return Padding(
                  padding:  EdgeInsets.symmetric(horizontal: AppSizes.w4),
                  child: GestureDetector(
                    onTap: () => viewModel.onFilterSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:  EdgeInsets.symmetric(horizontal: AppSizes.w10, vertical: AppSizes.h5),
                      decoration: BoxDecoration(
                        color: isSelected ? _getPriorityTagColor(viewModel.priortyTags[index]): AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.h7),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.transparent
                              : _getPriorityTagColor(viewModel.filterOptions[index]),
                        ),
                      ),
                      child: Text(
                        viewModel.filterOptions[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ));
    }
  Widget _buildTaskTypeToggle(
      TaskListViewModel viewModel, int index, String text) {
    final bool isSelected = viewModel.selectedTaskTypeIndex == index;
    const toggleContainerColor = AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.onTaskTypeChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : toggleContainerColor,
            borderRadius: BorderRadius.circular(AppSizes.h20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? toggleContainerColor : AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignTaskFab(TaskListViewModel viewModel) {
    return FloatingActionButton.extended(
      onPressed: viewModel.navigateToCreateTask,
      label: Text(LanguageService.get('assignNewTask'),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add),
      highlightElevation: AppSizes.h5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
      ),

      backgroundColor: AppColors.primary,
    );
  }

  /// Builds the main list of task cards
  Widget _buildTaskList(BuildContext context, TaskListViewModel viewModel) {
    if (viewModel.isBusy) {
      // Shimmer loading dikhayein
      // TODO: Naya shimmer widget banana padega jo naye task card se match kare
      return const TaskListShimmer();
    }

    if (viewModel.tasks.isEmpty) {
      return Center(
        child: Text(
          LanguageService.get('noTasksFound'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // Pagination ke liye
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels >
                notification.metrics.maxScrollExtent * 0.8) {
          viewModel.loadMoreTasks(); // Naya data load karo
        }
        return true;
      },
      child: ListView.builder(
        padding:  EdgeInsets.fromLTRB(AppSizes.w16, AppSizes.h16, AppSizes.w16, AppSizes.h80),
        itemCount: viewModel.tasks.length,
        itemBuilder: (context, index) {
          final task = viewModel.tasks[index];
          return TaskCardWidget(
            task: task,
            viewModel:viewModel,
            onTap: () {},
          );
        },
      ),
    );
  }
  Color _getPriorityTagColor(String status) {
    switch (status) {
      case 'low':
        return AppColors.softGreen;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.red;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.yellow;
      default:
        return AppColors.grey;
    }
  }
}


