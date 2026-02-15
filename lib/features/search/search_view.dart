import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../resources/app_resources/app_resources.dart';
import 'search_vm.dart';

class SearchViewAttributes {
  SearchViewAttributes({
    required this.title,
    required this.apiEndPoint,
    required this.onSelect,
  });

  final String title;
  final String apiEndPoint;
  final Function(dynamic) onSelect;
}

class SearchView extends StatelessWidget {
  const SearchView({super.key, required this.attributes});

  final SearchViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(),
      onViewModelReady: (SearchViewModel model) => model.init(attributes),
      disposeViewModel: false,
      builder: (BuildContext context, SearchViewModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(title: Text('Search '+attributes.title[0].toUpperCase()+attributes.title.substring(1))),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSizes.h20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.v30),
                  ),
                  child: TextField(
                    controller: model.searchController,
                    onChanged: model.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Type something to search...',
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
                    : model.searchResults.isEmpty
                    ? _buildEmptyState(context)
                    : _buildSearchResultsList(context, model),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsList(BuildContext context, SearchViewModel model) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
      itemCount: model.searchResults.length,
      itemBuilder: (context, index) {
        final result = model.searchResults[index];
        return _buildSearchResultCard(context, result, model);
      },
    );
  }

  Widget _buildSearchResultCard(BuildContext context, Organization result, SearchViewModel model) {
    return GestureDetector(
      onTap: () => attributes.onSelect(result.id),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.h10),
        padding: EdgeInsets.all(AppSizes.w15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v12),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.w50,
              height: AppSizes.w50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  result.name.isNotEmpty ? result.name[0].toUpperCase() : '',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.v22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.w15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.h4),
                  Text(
                    result.email,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.h4),
                  Row(
                    children: [
                      Text(
                        result.phone,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: AppSizes.w10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.w8,
                          vertical: AppSizes.h4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                        ),
                        child: Text(
                          result.organizationType,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontSize: AppSizes.v10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
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
              Icons.business_outlined,
              size: AppSizes.v60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            'No ${attributes.title.toLowerCase()}s found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            'Try searching with a different keyword',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}