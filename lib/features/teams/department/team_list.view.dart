import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:manager/core/models/department.model.dart'; // Import model
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/teams/department/team_list.vm.dart'; // Import VM
import 'package:manager/features/teams/department_hierarchy.view.dart';
import 'package:manager/features/teams/widgets/create_new_department_dialog.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common/select_user_option_diealog.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/dialogs/animated_floting_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart'; // Import stacked


class TeamListView extends StackedView<TeamListVM> {
  TeamListView({super.key});


  static final Map<String, Map<String, dynamic>> departmentListUiIcon = {
    "sale": {"path": AppImages.team_sale, "color": Color(0xff6CCA9B)},
    "service": {"path": AppImages.team_service, "color": Color(0xffED75E3)},
    "product": {"path": AppImages.team_product, "color": Color(0xffD28591)},
    "finance": {"path": AppImages.team_finance, "color": Color(0xffB7BE79)},
    "hr": {"path": AppImages.team_hr, "color": Color(0xffF3B33E)},
    "account": {"path": AppImages.team_account, "color": Color(0xffB7BE79)},
    "default": {"path": AppImages.team_default, "color": Color(0xff849ddd)},
  };

  // 3. Add builder method
  @override
  Widget builder(BuildContext context, TeamListVM viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: GradientAppBar(title: 'my_team'.lang),
      floatingActionButton: ExpandableFloatingActionButton(
        distance: 90.0,
        startAngle: 60.0,
        spaceBetween: 50.0,
        children: [
          FabActionItem(
            label: 'add_new_employee'.lang,
            onPressed: () {
              showCustomAddMenuDialog(context: context, dialogTitle: 'add_new_employee'.lang, menuItems: [
                CustomMenuItem(onTap: (){
                  viewModel.onScanFromCamera(context);
                }),
                CustomMenuItem(onTap: (){
                  viewModel.onSearchByPhone(context);
                }),
                CustomMenuItem(onTap: (){
                  viewModel.onAddNewEmployee(context);
                },subtitle: 'Create a New Employee'),
              ]);
            },
            backgroundColor: AppColors.primary,
          ),
          FabActionItem(
            label: 'create_new_departments'.lang,
            onPressed: () {
              // 4. Pass viewModel to the dialog
              showCreateDepartmentDialog(context, viewModel);
            },
            backgroundColor: AppColors.primaryLight,
          ),
        ],
      ),
      body:viewModel.isBusy
          ? Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withValues(alpha: 0.4),
          highlightColor: AppColors.white,
          period: const Duration(milliseconds: 1500),
          child: ListView.separated(
            padding: EdgeInsets.all(AppSizes.w10),
              itemBuilder: (context, index) {
            return  Container(color: AppColors.white,     height: Get.height * 0.12,
              width: Get.width);
          }, separatorBuilder: (BuildContext context, int index) { return SizedBox(height: AppSizes.h15); }, itemCount: 10,)) // Jab busy ho, to sirf loader dikhega
          : Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppSizes.w15, vertical: AppSizes.w15),
        decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(10)),
        child: viewModel.departments.isEmpty
            ? Center(child: Text('no_departments_found'.lang))
            : ListView.builder(
          padding: EdgeInsets.all(AppSizes.w10),
          itemCount: viewModel.departments.length,
          itemBuilder: (context, index) {
            final department = viewModel.departments[index];
            return getDepartmentCard(department,context,viewModel);
          },
        ),
      ),
    );
  }

  /// Builds a visually appealing card for a department.
  // 8. Update parameter to use DepartmentModel
  Widget getDepartmentCard(DepartmentModel department,BuildContext context,TeamListVM viewModel) {
    String keyToUse = 'default';
    for (var key in TeamListView.departmentListUiIcon.keys) {
      // 9. Use department.name
      if (department.name.toLowerCase().contains(key)) {
        keyToUse = key;
        break;
      }
    }
    final Map<String, dynamic> uiData =
    TeamListView.departmentListUiIcon[keyToUse]!;
    final String path = uiData['path'];
    final Color color = uiData['color'];

    return InkWell(
      onTap: () async {

          _onDepartmentTap(context, department, viewModel);

      },
      child: Container(
        height: Get.height * 0.12,
        width: Get.width,
        margin: EdgeInsets.only(bottom: AppSizes.h15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.w13),
          border: Border(left: BorderSide(color: color, width: 5)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.w15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.h15),
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child:
                // keyToUse == 'default'
                //     ? Image.asset('${AppImages.team_default}',
                //     width: Get.width * 0.1)
                //     :
                SvgPicture.asset(
                  path,
                  width: Get.width * 0.07,
                ),
              ),
              SizedBox(width: AppSizes.w15),
              Expanded(
                child: Text(
                  department.name, // 10. Use department.name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.h16,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _onDepartmentTap(BuildContext context, DepartmentModel dept,TeamListVM viewModel) async {
    final navigator = Navigator.of(context);
    // Show loading dialog
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (dialogContext) => WillPopScope(
    //     onWillPop: () async => false,
    //     child: Center(
    //       child: Card(
    //         child: Padding(
    //           padding: EdgeInsets.all(20),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               CircularProgressIndicator(),
    //               SizedBox(height: 16),
    //               Text('Loading'),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    // Fetch hierarchy
    final success = await viewModel.fetchDepartmentHierarchy(dept.id!);

    // Close loading dialog
   // if (context.mounted) Navigator.pop(context);

    AppLogger.info(viewModel.hierarchy.length.toString()+" ${context.mounted}");
    // Navigate to hierarchy screen
    if (success && viewModel.hierarchy.isNotEmpty) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => HierarchyScreen(
            departmentName: dept.name ?? 'Hierarchy',
            viewModel: viewModel,
          ),
        ),
      );
    }
  }
  // 11. Add viewModelBuilder
  @override
  TeamListVM viewModelBuilder(BuildContext context) => TeamListVM();

  // 12. Add onViewModelReady
  @override
  void onViewModelReady(TeamListVM viewModel) {
    viewModel.onModelReady();
  }
}