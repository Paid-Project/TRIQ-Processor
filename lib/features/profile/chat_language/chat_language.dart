// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manager/resources/app_resources/app_maps.dart';
// import 'package:manager/resources/app_resources/app_resources.dart';
// import 'package:stacked/stacked.dart';
// import '../../../core/models/hive/user/user.dart';
// import '../../../core/storage/storage.dart';
// import '../../../services/language.service.dart';
// import '../create_or_edit_org/create_or_edit_org.vm.dart';
// import '../create_or_edit_org/update_employee_profile.vm.dart';
//
// class ChatLanguage extends StatefulWidget {
//   const ChatLanguage({super.key});
//
//   @override
//   State<ChatLanguage> createState() => _ChatLanguageState();
// }
//
// class _ChatLanguageState extends State<ChatLanguage> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Check user role to determine which ViewModel to use
//     final bool isSuperAdmin = getUser().userRole == UserRole.superAdmin;
//
//     if (isSuperAdmin) {
//       return ViewModelBuilder<UpdateOrganizationViewModel>.reactive(
//         viewModelBuilder: () => UpdateOrganizationViewModel(),
//         onViewModelReady: (UpdateOrganizationViewModel model) => model.init(null),
//         disposeViewModel: false,
//         builder: (BuildContext context, UpdateOrganizationViewModel model, Widget? child) {
//           return _buildScaffold(
//             context: context,
//             preferredLanguage: model.preferredLanguage(),
//             isBusy: model.isBusy,
//             onLanguageChanged: (val) => model.updateLanguage(val ?? 'English'),
//             onSave: () async {
//               await model.onSave();
//               if (mounted) {
//                 Get.back();
//               }
//             },
//           );
//         },
//       );
//     } else {
//       return ViewModelBuilder<EmployeeProfileViewModel>.reactive(
//         viewModelBuilder: () => EmployeeProfileViewModel(),
//         onViewModelReady: (EmployeeProfileViewModel model) => model.init(null),
//         disposeViewModel: false,
//         builder: (BuildContext context, EmployeeProfileViewModel model, Widget? child) {
//           return _buildScaffold(
//             context: context,
//             preferredLanguage: model.preferredLanguages(),
//             isBusy: model.isBusy,
//             onLanguageChanged: (val) => model.updateLanguage(val ?? 'English'),
//             onSave: () async {
//               await model.onSave();
//               if (mounted) {
//                 Get.back();
//               }
//             },
//           );
//         },
//       );
//     }
//   }
//
//   Widget _buildScaffold({
//     required BuildContext context,
//     required String? preferredLanguage,
//     required bool isBusy,
//     required void Function(String?) onLanguageChanged,
//     required VoidCallback onSave,
//   }) {
//     return Scaffold(
//       appBar: _buildAppBar(context, _scrollController),
//       body: SafeArea(
//         child: ListView(
//           controller: _scrollController,
//           padding: const EdgeInsets.all(20),
//           children: [
//             const SizedBox(height: 12),
//             Text(
//               LanguageService.get("choose_preferred_chat_language"),
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             _buildDropdownFormField(
//               context: context,
//               value: preferredLanguage,
//               label: LanguageService.get("chat_language"),
//               items: AppMaps.languageMap.keys.toList(),
//               onChanged: onLanguageChanged,
//               validator: (value) => value == null ? LanguageService.get("please_select_language") : null,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: isBusy ? null : onSave,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child:
//                   isBusy
//                       ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
//                       )
//                       : Text(LanguageService.get("save"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(BuildContext context, ScrollController scrollController) {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(kToolbarHeight),
//       child: AnimatedBuilder(
//         animation: scrollController,
//         builder: (context, child) {
//           double opacity = (scrollController.hasClients ? (scrollController.offset / (MediaQuery.of(context).size.height / 5)) : 0.0).clamp(
//             0.05,
//             1.0,
//           ); // Always visible AppBar
//
//           return AppBar(
//             elevation: opacity * 2,
//             backgroundColor: AppColors.primary,
//             surfaceTintColor: Colors.transparent,
//             title: Text(
//               LanguageService.get("chat_language"),
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
//             ),
//             iconTheme: const IconThemeData(color: Colors.white),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildDropdownFormField({
//     required BuildContext context,
//     required String? value,
//     required String label,
//     required List<String> items,
//     required void Function(String?) onChanged,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(AppSizes.v14),
//         border: Border(left: BorderSide(color: AppColors.primary, width: AppSizes.w4)),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide(color: AppColors.lightGray)),
//           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide(color: AppColors.lightGray)),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(AppSizes.v12),
//             borderSide: BorderSide(color: AppColors.primary, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         dropdownColor: AppColors.white,
//         style: Theme.of(context).textTheme.bodyLarge,
//         items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
//         onChanged: onChanged,
//         validator: validator,
//       ),
//     );
//   }
// }
