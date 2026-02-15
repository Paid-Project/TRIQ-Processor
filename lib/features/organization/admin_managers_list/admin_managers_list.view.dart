import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import 'admin_managers_list.vm.dart';

class AdminManagersListView extends StatefulWidget {
  const AdminManagersListView({super.key});

  @override
  State<AdminManagersListView> createState() => _AdminManagersListViewState();
}

class _AdminManagersListViewState extends State<AdminManagersListView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AdminManagersListViewModel>.reactive(
      viewModelBuilder: () => AdminManagersListViewModel(),
      onViewModelReady: (AdminManagersListViewModel model) => model.init(this),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        AdminManagersListViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: RichText(
              text: TextSpan(
                text: "People ",
                style: Theme.of(context).textTheme.displayMedium,
                children: [
                  TextSpan(
                    text: "in Organization",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
            child: Column(
              children: [
                TabBar(
                  controller: model.tabController,
                  tabs: [Tab(text: 'Admins'), Tab(text: 'Managers')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: model.tabController,
                    children: [
                      ListView.builder(
                        itemCount: 10,
                        padding: EdgeInsets.only(
                          bottom: 2 * kBottomNavigationBarHeight,
                        ),
                        itemBuilder: (context, index) {
                          return _buildExpandableTile(
                            model.expandedAdminTileIndex,
                            index,
                            model.expandAdminTile,
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: 10,
                        padding: EdgeInsets.only(
                          bottom: 2 * kBottomNavigationBarHeight,
                        ),
                        itemBuilder: (context, index) {
                          return _buildExpandableTile(
                            model.expandedManagerTileIndex,
                            index,
                            model.expandManagerTile,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableTile(
    int? expandedIndex,
    int index,
    Function(int) onTap,
  ) {
    bool isExpanded = index == expandedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.v14),
          border: Border(
            left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
          ),
          color: AppColors.scaffoldBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 3,
            ),
          ],
        ),
        margin:
            EdgeInsets.only(top: AppSizes.h10) +
            EdgeInsets.symmetric(horizontal: AppSizes.w4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "#Member No. ${index + 1}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.gray,
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  isExpanded
                      ? Container(
                        padding: EdgeInsets.all(16),
                        child: Text("Details for Member No. ${index + 1}"),
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
