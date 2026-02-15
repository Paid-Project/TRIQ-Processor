import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart'; // Import stacked
import '../../employee/add_employee/add_employee.vm.dart'; // Import stacked

void showCreateCustomRoleDialog(BuildContext context, AddEmployeeViewModel viewModel) {
  showDialog(
    context: context,
    // 2. Prevent closing dialog while API is calling
    barrierDismissible: !viewModel.busy('dialog'),
    builder: (BuildContext context) {
      // 3. Use ViewModelBuilder to make dialog reactive
      return ViewModelBuilder<AddEmployeeViewModel>.reactive(
        viewModelBuilder: () => viewModel,
        disposeViewModel: false,
        builder: (context, viewModel, child) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'create_new_role'.lang,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                        InkWell(
                          // 4. Disable close button when busy
                          onTap: viewModel.busy('dialog')
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, size: 24.0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // TextField
                    TextField(
                      controller: viewModel.designationNameController,
                      enabled: !viewModel.busy('dialog'),
                      decoration: InputDecoration(
                        hintText: 'Name (eg. CEO)'.lang,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            // 7. Disable button when busy
                            onPressed: viewModel.busy('dialog')
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'cancel'.lang,
                              style:
                              TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CommonElevatedButton(
                            isLoading: viewModel.busy('dialog'),
                            onPressed: viewModel.createNewDesignation,
                            label: 'create'.lang,
                            backgroundColor: AppColors.primary,
                            borderRadius: 30.0,

                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

