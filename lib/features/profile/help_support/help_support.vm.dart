import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart' as stacked;
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class HelpAndSupportViewModel extends BaseViewModel {
  final _dialogService = locator<stacked.DialogService>();
  final _apiService = locator<ApiService>();

  Future<void> submitProblemReport(String title, String description) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          final apiResponse = await _apiService.post(url: ApiEndpoints.reportProblem, data: {"title": title, "description": description});

          if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
            AppLogger.info('Problem report sent successfully');
            Fluttertoast.showToast(msg: apiResponse.data['msg'] ?? "Problem report sent successfully", backgroundColor: Colors.green);
            return {'success': true, 'message': LanguageService.get("problem_report_sent_successfully")};
          }
        },
      ),
    );
  }

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info.triqinnovations@gmail.com',
      query: 'subject=${Uri.encodeComponent('Support Request')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication, // 🔥 IMPORTANT
        );
      } else {
        // ✅ Fallback when no email app
        await Clipboard.setData(
          ClipboardData(text: 'info.triqinnovations@gmail.com'),
        );

        Get.snackbar(
          LanguageService.get("email_copied"),
          LanguageService.get("email_address_copied_to_clipboard"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryLight,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        LanguageService.get("error"),
        LanguageService.get("could_not_open_email_client"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redBack,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> launchWhatsApp() async {
    // You can replace this with your actual WhatsApp number
    const String phoneNumber = '+919625858082'; // Replace with actual number
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          LanguageService.get("error"),
          LanguageService.get("whatsapp_not_installed"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.redBack,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        LanguageService.get("error"),
        LanguageService.get("could_not_open_whatsapp"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redBack,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> _fallbackToEmail(String title, String description) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info.triqinnovations@gmail.com',
      query: 'subject=${Uri.encodeComponent('Problem Report: $title')}&body=${Uri.encodeComponent('Title: $title\n\nDescription:\n$description')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Copy report to clipboard
        final reportText = 'Title: $title\n\nDescription:\n$description';
        await Clipboard.setData(ClipboardData(text: reportText));
        Get.snackbar(
          LanguageService.get("report_copied"),
          LanguageService.get("problem_report_copied_to_clipboard"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryLight,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      // Silent error handling for fallback
    }
  }
}
