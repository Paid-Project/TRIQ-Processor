// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:stacked/stacked.dart';
//
// import '../../../../core/models/employee.dart';
// import '../../../../resources/app_resources/app_resources.dart';
// import '../add_machine.vm.dart';
//
// class EmployeeMultiSelectDropdown extends ViewModelWidget<AddMachineViewModel> {
//   const EmployeeMultiSelectDropdown({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, AddMachineViewModel viewModel) {
//     // Filter out null IDs to prevent errors
//     final validEmployees = viewModel.allEmployees
//         .where((employee) => employee.id != null && employee.name != null)
//         .toList();
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizes.h16),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(AppSizes.v14),
//           border: Border(
//             left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
//           ),
//         ),
//         child: DropdownButtonFormField2<Employee>(
//           isExpanded: true,
//           value: null,
//           // dropdownStyleOverride: DropdownStyleOverride(
//           //   maxHeight: 300,
//           //   decoration: BoxDecoration(
//           //     borderRadius: BorderRadius.circular(AppSizes.v14),
//           //   ),
//           // ),
//           dropdownSearchData: DropdownSearchData(
//             searchController: TextEditingController(),
//             searchInnerWidgetHeight: AppSizes.h70,
//             searchInnerWidget: Container(
//               color: Colors.white,
//               padding: const EdgeInsets.all(8.0),
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   hintText: 'Search employees...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 controller: viewModel.employeeSearchController,
//                 onChanged: (value) {
//                   viewModel.filterEmployees(value);
//                 },
//               ),
//             ),
//             searchMatchFn: (employee, searchValue) {
//               return (employee.value?.name ?? '')
//                   .toLowerCase()
//                   .contains(searchValue.toLowerCase());
//             },
//           ),
//           buttonStyleData: ButtonStyleData(
//             decoration: BoxDecoration(
//               color: Colors.white
//             ),
//             padding: EdgeInsets.only(right: 8),
//           ),
//           items: validEmployees.map((employee) {
//             return DropdownMenuItem<Employee>(
//               value: employee,
//               enabled: false,
//               child: StatefulBuilder(
//                 builder: (context, menuSetState) {
//                   final isSelected = viewModel.selectedEmployees.contains(employee);
//                   return InkWell(
//                     onTap: () {
//                       viewModel.toggleEmployeeSelection(employee);
//                       menuSetState(() {});
//                     },
//                     child: Container(
//                       height: double.infinity,
//                       color: Colors.white,
//                       child: Row(
//                         children: [
//                           Checkbox(
//                             value: isSelected,
//                             onChanged: (_) {
//                               viewModel.toggleEmployeeSelection(employee);
//                               menuSetState(() {});
//                             },
//                             activeColor: AppColors.white,
//                             side: BorderSide(width: 2, color: AppColors.primary), // Make border more visible
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4.0), // Slightly rounded corners
//                             ),
//                           ),
//                           // Checkbox(
//                           //   value: isSelected,
//                           //   onChanged: (_) {
//                           //     viewModel.toggleEmployeeSelection(employee);
//                           //     menuSetState(() {});
//                           //   },
//                           // ),
//                           Expanded(
//                             child: Text(
//                               employee.name ?? 'Unnamed Employee',
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//           onChanged: (_) {},
//           selectedItemBuilder: (context) {
//             return validEmployees.map<Widget>((employee) {
//               return Container(); // This is intentionally left empty
//             }).toList();
//           },
//           hint: Text(
//             'Select Responsible Employees',
//             style: TextStyle(fontSize: 14, color: AppColors.gray),
//           ),
//           customButton: viewModel.selectedEmployees.isEmpty
//               ? null
//               : Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: viewModel.selectedEmployees.map((employee) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       employee.name ?? 'Unnamed Employee',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 12,
//                       ),
//                     ),
//                     SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: () => viewModel.toggleEmployeeSelection(employee),
//                       child: Icon(
//                         Icons.close,
//                         size: 16,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }