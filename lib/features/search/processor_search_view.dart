import 'package:flutter/material.dart';
import 'package:manager/features/search/processor_search_vm.dart';
import 'package:stacked/stacked.dart';

import '../../resources/app_resources/app_resources.dart';

class ProcessorsSearchView extends StatelessWidget {
  const ProcessorsSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProcessorsSearchViewModel>.reactive(
      viewModelBuilder: () => ProcessorsSearchViewModel(),
      onViewModelReady: (ProcessorsSearchViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          ProcessorsSearchViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Your Customers'),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSizes.h20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(AppSizes.v30),
                  ),
                  child: TextField(
                    controller: model.searchController,
                    onChanged: model.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppSizes.h16,
                        horizontal: AppSizes.w20,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: model.searching
                    ? Center(child: CircularProgressIndicator())
                    : _buildEmptyState(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.w120,
            height: AppSizes.h120,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: AppSizes.v60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            'No processors found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            'Add processor to your network',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}