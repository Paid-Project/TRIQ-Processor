// lib/widgets/dialogs/success_dialog.dart

import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';


enum DialogType {
  loader,
  success
}


class SuccessDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SuccessDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Green Check Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: Colors.green.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              request.title ?? 'Employee Created Successfully!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              request.description ??
                  'Please ask your employee to log in using registered mobile number.\n\nAn OTP will be sent for verification during their first login.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Dialog ko band karke 'confirmed' response bhejein
                  completer(DialogResponse(confirmed: true));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}