// import 'package:flutter/material.dart';
// import 'package:manager/resources/app_resources/app_resources.dart';
// import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
//
//
// class LoaderDialogAttributes {
//   final Future<dynamic> Function()? task;
//   final List<Future<dynamic> Function()>? tasks;
//   final String? message;
//
//   LoaderDialogAttributes({this.task, this.tasks, this.message})
//       : assert(
//   (task != null && tasks == null) || (task == null && tasks != null),
//   'Either provide a single task or multiple tasks, not both or none',
//   );
// }
//
// class LoaderDialog extends StatelessWidget {
//   const LoaderDialog({
//     super.key,
//     required this.request,
//     required this.completer,
//   });
//
//   final DialogRequest<LoaderDialogAttributes> request;
//   final Function(DialogResponse) completer;
//
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<LoaderDialogViewModel>.reactive(
//       viewModelBuilder: () => LoaderDialogViewModel(),
//       onViewModelReady: (LoaderDialogViewModel model) => model.init(
//         request: request,
//         completer: completer,
//         context: context,
//       ),
//       builder: (
//           BuildContext context,
//           LoaderDialogViewModel viewModel,
//           Widget? child,
//           ) {
//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Column(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.4),
//                   ),
//                   alignment: Alignment.center,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const CircularProgressIndicator(color: Colors.white),
//                         if (viewModel.message != null) ...[
//                           const SizedBox(height: 12),
//                           Text(
//                             viewModel.message!,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class LoaderDialogViewModel extends ReactiveViewModel {
//   String? _message;
//   String? get message => _message;
//
//   void init({
//     required DialogRequest<LoaderDialogAttributes> request,
//     required Function(DialogResponse) completer,
//     required BuildContext context,
//   }) async {
//     _message = request.data?.message;
//
//     await executeTask(request: request, completer: completer, context: context);
//   }
//
//   Future<void> executeTask({
//     required DialogRequest<LoaderDialogAttributes> request,
//     required Function(DialogResponse) completer,
//     required BuildContext context,
//   }) async {
//     final navigator = Navigator.of(context);
//     final singleTask = request.data?.task;
//     final multipleTasks = request.data?.tasks;
//
//     if (singleTask == null && multipleTasks == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         navigator.pop(
//           DialogResponse(confirmed: false, data: 'No task(s) provided'),
//         );
//       });
//       return;
//     }
//
//     try {
//       if (singleTask != null) {
//         final result = await singleTask();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           navigator.pop(DialogResponse(confirmed: true, data: result));
//         });
//       } else if (multipleTasks != null) {
//         final futures = multipleTasks.map((task) => task()).toList();
//         final results = await Future.wait(futures);
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           navigator.pop(DialogResponse(confirmed: true, data: results));
//         });
//       }
//     } catch (e) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         navigator.pop(DialogResponse(confirmed: false, data: e.toString()));
//       });
//     }
//   }
//
// }