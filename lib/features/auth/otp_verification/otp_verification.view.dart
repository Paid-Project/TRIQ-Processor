import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import '../../../widgets/common_elevated_button.dart';
import 'otp_verification.vm.dart';

class OtpVerificationViewAttributes {
  final bool isOrganization;
  final String email;

  // Registration data for processor registration flow
  final String? fullName;
  final String? phone;
  final String? countryCode;
  final String? password;
  final String? organizationType;
  final String? otherDescription;
  final String? language;

  OtpVerificationViewAttributes({
    required this.isOrganization,
    required this.email,
    this.fullName,
    this.phone,
    this.countryCode,
    this.password,
    this.organizationType,
    this.otherDescription,
    this.language,
  });
}

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key, required this.attributes});

  final OtpVerificationViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<OtpVerificationViewModel>.reactive(
      viewModelBuilder: () => OtpVerificationViewModel(),
      onViewModelReady: (OtpVerificationViewModel model) => model.init(attributes),
      builder: (BuildContext context, OtpVerificationViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight - MediaQuery.of(context).padding.vertical - kToolbarHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSizes.h12),
                        Row(
                          // This moves items to the top
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildBackButton(context), SizedBox(width: 60), _buildIllustrationSection(context)],
                        ),
                        _buildHeaderSection(context),

                        // OTP Verification Form
                        _buildOtpVerificationForm(context, model),

                        _buildVerifyButton(context, model),

                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // bottomNavigationBar: _buildVerifyButton(context, model),
        );
      },
    );
  }

  Widget _buildIllustrationSection(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.only(top: AppSizes.h2, bottom: AppSizes.h30),
      child: Center(child: Image.asset('assets/images/auth4.png', fit: BoxFit.contain)),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.get('verify_your_otp'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 20),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            'We have sent OTP to your registered mobile number or email.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationForm(BuildContext context, OtpVerificationViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinFieldAutoFill(
            controller: model.otpController,
            cursor: Cursor(enabled: true, color: AppColors.primary, width: AppSizes.w2, height: AppSizes.h30),
            currentCode: model.otpController.text.length == 6 ? model.otpController.text : null,
            codeLength: 6,
            decoration: BoxLooseDecoration(
              strokeColorBuilder: FixedColorBuilder(AppColors.lightGrey),
              bgColorBuilder: FixedColorBuilder(Colors.transparent),
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              radius: Radius.circular(8),
              strokeWidth: 1,
            ),
          ),
          SizedBox(height: AppSizes.h25),
          _buildResendOtpPrompt(context, model),
        ],
      ),
    );
  }

  Widget _buildResendOtpPrompt(BuildContext context, OtpVerificationViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(LanguageService.get('didnt_receive_code'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: model.canResend ? model.resendOtp : null,
          child: ValueListenableBuilder<int>(
            valueListenable: model.timerNotifier,
            builder: (context, countdown, child) {
              return Text(
                model.canResend ? LanguageService.get('resend_otp') : 'Resend OTP in ${countdown}s',
                style: TextStyle(
                  color: model.canResend ? AppColors.primary : AppColors.textSecondary,
                  decoration: model.canResend ? TextDecoration.underline : TextDecoration.none,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context, OtpVerificationViewModel model) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: CommonElevatedButton(
        label: LanguageService.get('verify_otp'),
        onPressed: model.isBusy ? null : model.verifyPhone,
        backgroundColor: AppColors.primary,
        textColor: AppColors.white,
        borderRadius: 45,
        width: double.infinity,
        height: AppSizes.h55,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        padding: EdgeInsets.symmetric(vertical: 13),
      ),
    );
  }
}

Widget _buildBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: Container(
      margin: EdgeInsets.only(top: 5), // Add margin for proper spacing
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        shape: BoxShape.circle, // Makes it circular
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
        // Adjust padding for better circle appearance
      ),
    ),
  );
}
