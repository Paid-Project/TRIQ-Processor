import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/language.service.dart';
import 'login.vm.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      onViewModelReady: (LoginViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, LoginViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Container(
            color: AppColors.white,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (model.showOtpLogin ||
                            model.showForgotPassword ||
                            model.showOtpField)
                          _buildBackButton(context, model)
                        else
                          SizedBox(height: AppSizes.h45),
                        _buildHeaderSection(context, model),
                        SizedBox(height: AppSizes.h5),
                        _buildMainContent(context, model),
                        _buildSignUpPrompt(context, model),
                        // if (!model.showForgotPassword &&
                        //     !model.showOtpLogin &&
                        //     (model.loginMode == LoginMode.email || model.loginMode == LoginMode.phone) &&
                        //     !model.showOtpField)
                        //   _buildSocialLoginSection(context, model),
                        if (!model.showForgotPassword &&
                            !model.showOtpLogin &&
                            (model.loginMode == LoginMode.email ||
                                model.loginMode == LoginMode.phone) &&
                            !model.showOtpField) ...[
                          // _buildSignUpPrompt(context, model),
                          _buildTermsAndConditionsCheckbox(context),
                          SizedBox(height: AppSizes.h20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton(BuildContext context, LoginViewModel model) {
    return Align(
      alignment: Alignment.topLeft,
      child: InkWell(
        onTap: () {
          if (model.showForgotPassword) {
            model.toggleForgotPassword();
          } else if (model.showOtpLogin) {
            model.toggleOtpLogin();
          } else if (model.showOtpField) {
            model.setLoginMode(LoginMode.email);
          }
        },
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(top: 12), // Add margin for proper spacing
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light grey background
            shape: BoxShape.circle, // Makes it circular
          ),
          child: Image.asset(
            AppImages.back,
            height: 20,
            width: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, LoginViewModel model) {
    if (model.showForgotPassword) {
      return _buildForgotPasswordSection(context, model);
    } else if (model.showOtpField) {
      return _buildOtpVerificationSection(context, model);
    } else if (model.showOtpLogin) {
      return _buildOtpLoginSection(context, model);
    } else {
      return _buildLoginForm(context, model);
    }
  }

  Widget _buildHeaderSection(BuildContext context, LoginViewModel model) {
    String headerText = LanguageService.get('welcome_to_triq');
    if (model.showForgotPassword) {
      switch (model.forgotPasswordStep) {
        case ForgotPasswordStep.contact:
          headerText = LanguageService.get('forgot_password');
          break;
        case ForgotPasswordStep.otp:
          headerText = LanguageService.get('verify_otp');
          break;
        case ForgotPasswordStep.newPassword:
          headerText = LanguageService.get('create_new_password');
          break;
      }
    } else if (model.showOtpLogin) {
      headerText = LanguageService.get('otp_login');
    } else if (model.showOtpField) {
      headerText = LanguageService.get('verify_otp');
    }

    return Column(
      children: [
        SizedBox(width: double.infinity, child: _buildStateIllustration(model)),
        SizedBox(height: 10),
        if (model.showForgotPassword) ...[SizedBox(height: 50)],
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            headerText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateIllustration(LoginViewModel model) {
    // Return different illustrations based on current state
    if (model.showForgotPassword) {
      switch (model.forgotPasswordStep) {
        case ForgotPasswordStep.contact:
          return _buildForgotPasswordIllustration();
        case ForgotPasswordStep.otp:
          return _buildOtpIllustration();
        case ForgotPasswordStep.newPassword:
          return _buildNewPasswordIllustration();
      }
    } else if (model.showOtpField) {
      return _buildOtpIllustration();
    } else {
      return _buildLoginIllustration();
    }
  }

  Widget _buildLoginIllustration() {
    return Image.asset('assets/images/auth1.png', height: 200, width: 200);
  }

  Widget _buildForgotPasswordIllustration() {
    return Image.asset('assets/images/auth5.png', height: 150, width: 150);
  }

  Widget _buildOtpIllustration() {
    return Image.asset('assets/images/auth4.png', height: 200, width: 200);
  }

  Widget _buildNewPasswordIllustration() {
    return Image.asset('assets/images/auth6.png', height: 200, width: 200);
  }

  Widget _buildLoginForm(BuildContext context, LoginViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h10),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.v45),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => model.setLoginMode(LoginMode.phone),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
                      decoration: BoxDecoration(
                        color:
                            model.loginMode == LoginMode.phone
                                ? AppColors.primary
                                : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.v45),
                          bottomLeft: Radius.circular(AppSizes.v45),
                        ),
                      ),
                      child: Text(
                        LanguageService.get('login_with_phone'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              model.loginMode == LoginMode.phone
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => model.setLoginMode(LoginMode.email),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
                      decoration: BoxDecoration(
                        color:
                            model.loginMode == LoginMode.email
                                ? AppColors.primary
                                : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppSizes.v45),
                          bottomRight: Radius.circular(AppSizes.v45),
                        ),
                      ),
                      child: Text(
                        LanguageService.get('login_with_email'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              model.loginMode == LoginMode.email
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.h15),
          Form(
            key: model.formKey,
            child: Column(
              children: [
                if (model.loginMode == LoginMode.phone) ...[
                  SizedBox(
                    height: 65,
                    child: IntlPhoneField(
                      controller: model.phoneController,
                      pickerDialogStyle: PickerDialogStyle(
                        backgroundColor: AppColors.white,
                        countryCodeStyle: TextStyle(color: AppColors.black),
                        countryNameStyle: TextStyle(color: AppColors.black),
                      ),
                      decoration: InputDecoration(
                        labelText: LanguageService.get('phone_number'),
                        labelStyle: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        model.updatePhoneNumber(phone);
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return LanguageService.get(
                            'please_enter_phone_number',
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ] else ...[
                  _buildTextFormField(
                    context,
                    controller: model.emailController,
                    label: LanguageService.get('email_address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {

                      if (value == null || value.isEmpty) {
                        return 'Please Enter Mail';
                      }

                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );

                      if (!emailRegex.hasMatch(value)) {
                        return 'Please Enter Valid Email';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.h5),
                ],

                // Password Field - only show if not in OTP mode
                if (!model.showOtpField) ...[
                  SizedBox(height: AppSizes.h8),
                  _buildTextFormField(
                    context,
                    controller: model.passwordController,
                    label: LanguageService.get('password'),
                    obscureText: model.obscurePassword,
                    validator:
                        (value) =>
                            value?.isEmpty == true
                                ? LanguageService.get('please_enter_password')
                                : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        model.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.gray,
                      ),
                      onPressed: model.togglePassword,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: AppSizes.h20),

          // Show options only if not in OTP field mode
          if (!model.showOtpField) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: AppSizes.h5),
                GestureDetector(
                  onTap: model.toggleOtpWithLogin,
                  child: Text(
                    LanguageService.get('login_with_otp'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: model.toggleForgotPassword,
                    child: Text(
                      LanguageService.get('forgot_password'),
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h20),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.v45),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: model.isBusy ? null : model.onSubmitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, AppSizes.h40),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                // Remove default elevation since we're using custom shadow
                shadowColor: Colors.transparent,
                // Remove default shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v45),
                ),
              ),
              child:
                  model.isBusy
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        model.showOtpField
                            ? LanguageService.get('verify_otp')
                            : (model.loginMode == LoginMode.phone &&
                                !model.showOtpField)
                            ? LanguageService.get('login')
                            : LanguageService.get('login'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationSection(
    BuildContext context,
    LoginViewModel model,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h20),
      child: Column(
        children: [
          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: Get.width / 7.5,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.v8),
                ),
                child: TextFormField(
                  controller: model.otpDigitControllers[index],
                  focusNode: model.otpFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  onChanged: (value) => model.onOtpDigitChanged(index, value),
                ),
              );
            }),
          ),

          SizedBox(height: AppSizes.h20),

          // Resend OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text(
              //   model.canResendOtp
              //       ? LanguageService.get('dont_receive_otp')
              //       : "${LanguageService.get('resend_in')} ${model.resendTimer}s",
              //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              // ),
              if (model.canResendOtp)
                GestureDetector(
                  onTap: () {
                    model.isOTPWithLogin
                        ? model.sendOtpWithLogin(skipValidation: true)
                        : model.sendPasswordResetOtp();
                  },
                  child: Text(
                    LanguageService.get('resend_otp'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppSizes.h30),

          // Verify Button
          ElevatedButton(
            onPressed:
                model.isBusy
                    ? null
                    : (model.isOTPWithLogin == true
                        ? model.verifyOtpWithLogin
                        : model.verifyOtp),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, AppSizes.h40),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v45),
              ),
            ),
            child:
                model.isBusy
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      LanguageService.get('verify_otp'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordSection(
    BuildContext context,
    LoginViewModel model,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h20),
      child: Form(
        key: model.forgotPasswordFormKey,
        child: Column(
          children: [
            if (model.forgotPasswordStep == ForgotPasswordStep.contact) ...[
              // Mode Toggle for Forgot Password
              // Container(
              //   margin: EdgeInsets.only(bottom: AppSizes.h20),
              //   decoration: BoxDecoration(
              //     color: AppColors.lightGrey.withValues(alpha: 0.3),
              //     borderRadius: BorderRadius.circular(AppSizes.v45),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () => model.setForgotPasswordMode(LoginMode.phone),
              //           child: Container(
              //             padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
              //             decoration: BoxDecoration(
              //               color: model.forgotPasswordMode == LoginMode.phone ? AppColors.primary : Colors.transparent,
              //               borderRadius: BorderRadius.only(
              //                 topLeft: Radius.circular(AppSizes.v45),
              //                 bottomLeft: Radius.circular(AppSizes.v45),
              //               ),
              //             ),
              //             child: Text(
              //               LanguageService.get('phone_number'),
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 color:
              //                     model.forgotPasswordMode == LoginMode.phone
              //                         ? AppColors.white
              //                         : AppColors.textSecondary,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () => model.setForgotPasswordMode(LoginMode.email),
              //           child: Container(
              //             padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
              //             decoration: BoxDecoration(
              //               color: model.forgotPasswordMode == LoginMode.email ? AppColors.primary : Colors.transparent,
              //               borderRadius: BorderRadius.only(
              //                 topRight: Radius.circular(AppSizes.v45),
              //                 bottomRight: Radius.circular(AppSizes.v45),
              //               ),
              //             ),
              //             child: Text(
              //               LanguageService.get('email_address'),
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 color:
              //                     model.forgotPasswordMode == LoginMode.email
              //                         ? AppColors.white
              //                         : AppColors.textSecondary,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // Contact input based on selected mode
              if (model.forgotPasswordMode == LoginMode.phone) ...[
                SizedBox(
                  height: 65,
                  child: IntlPhoneField(
                    controller: model.forgotPhoneController,
                    pickerDialogStyle: PickerDialogStyle(
                      backgroundColor: AppColors.white,
                      countryCodeStyle: TextStyle(color: AppColors.black),
                      countryNameStyle: TextStyle(color: AppColors.black),
                    ),
                    decoration: InputDecoration(
                      labelText: LanguageService.get('phone_number'),
                      labelStyle: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      model.updateForgotPhoneNumber(phone);
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return LanguageService.get('please_enter_phone_number');
                      }
                      return null;
                    },
                  ),
                ),
              ] else ...[
                _buildTextFormField(
                  context,
                  controller: model.forgotEmailController,
                  label: LanguageService.get('email_address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return 'Please Enter Mail';
                    }

                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );

                    if (!emailRegex.hasMatch(value)) {
                      return 'Please Enter Valid Email';
                    }

                    return null;
                  },
                  prefixIcon: Icons.email_outlined,
                ),
              ],

              SizedBox(height: AppSizes.h20),
              ElevatedButton(
                onPressed:
                    model.isBusyForgotPassword
                        ? null
                        : model.sendPasswordResetOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.h20),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v45),
                  ),
                ),
                child:
                    model.isBusyForgotPassword
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          LanguageService.get('send_otp'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ] else if (model.forgotPasswordStep ==
                ForgotPasswordStep.newPassword) ...[
              // New Password Fields
              _buildTextFormField(
                context,
                controller: model.newPasswordController,
                label: LanguageService.get('new_password'),
                obscureText: model.obscureNewPassword,
                validator: (value) {
                  if (value?.isEmpty == true)
                    return LanguageService.get('please_enter_new_password');
                  if (value!.length < 6)
                    return LanguageService.get(
                      'password_must_be_at_least_6_characters',
                    );
                  return null;
                },
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    model.obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray,
                  ),
                  onPressed: model.toggleNewPassword,
                ),
              ),
              SizedBox(height: AppSizes.h16),
              _buildTextFormField(
                context,
                controller: model.confirmPasswordController,
                label: LanguageService.get('confirm_password'),
                obscureText: model.obscureConfirmPassword,
                validator: (value) {
                  if (value?.isEmpty == true)
                    return LanguageService.get('please_confirm_password');
                  if (value != model.newPasswordController.text) {
                    return LanguageService.get('passwords_do_not_match');
                  }
                  return null;
                },

                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    model.obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray,
                  ),
                  onPressed: model.toggleConfirmPassword,
                ),
              ),
              SizedBox(height: AppSizes.h30),
              ElevatedButton(
                onPressed:
                    model.isBusyForgotPassword ? null : model.resetPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.h50),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                  ),
                ),
                child:
                    model.isBusyForgotPassword
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          LanguageService.get('create_password'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtpLoginSection(BuildContext context, LoginViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h20),
      child: Form(
        key: model.forgotPasswordFormKey,
        child: Column(
          children: [
            if (model.forgotPasswordStep == ForgotPasswordStep.contact) ...[
              // Mode Toggle for Forgot Password
              Container(
                margin: EdgeInsets.only(bottom: AppSizes.h20),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.v45),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => model.setForgotPasswordMode(LoginMode.phone),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
                          decoration: BoxDecoration(
                            color:
                                model.forgotPasswordMode == LoginMode.phone
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSizes.v45),
                              bottomLeft: Radius.circular(AppSizes.v45),
                            ),
                          ),
                          child: Text(
                            LanguageService.get('phone_number'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  model.forgotPasswordMode == LoginMode.phone
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => model.setForgotPasswordMode(LoginMode.email),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
                          decoration: BoxDecoration(
                            color:
                                model.forgotPasswordMode == LoginMode.email
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(AppSizes.v45),
                              bottomRight: Radius.circular(AppSizes.v45),
                            ),
                          ),
                          child: Text(
                            LanguageService.get('email_address'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  model.forgotPasswordMode == LoginMode.email
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contact input based on selected mode
              if (model.forgotPasswordMode == LoginMode.phone) ...[
                SizedBox(
                  height: 65,
                  child: IntlPhoneField(
                    controller: model.forgotPhoneController,
                    pickerDialogStyle: PickerDialogStyle(
                      backgroundColor: AppColors.white,
                      countryCodeStyle: TextStyle(color: AppColors.black),
                      countryNameStyle: TextStyle(color: AppColors.black),
                    ),
                    decoration: InputDecoration(
                      labelText: LanguageService.get('phone_number'),
                      labelStyle: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onCountryChanged: (country) {
                      model.countryCode = country.dialCode.toString();
                    },
                    onChanged: (phone) {
                      model.updateForgotPhoneNumber(phone);
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return LanguageService.get('please_enter_phone_number');
                      }
                      return null;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap:() {
                      if (model.showForgotPassword) {
                        model.toggleForgotPassword();
                      } else if (model.showOtpLogin) {
                        model.toggleOtpLogin();
                      } else if (model.showOtpField) {
                        model.setLoginMode(LoginMode.email);
                      }
                    },
                    child: Text(
                      LanguageService.get('login_with_password'),
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _buildTextFormField(
                  context,
                  controller: model.forgotEmailController,
                  label: LanguageService.get('email_address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return 'Please Enter Mail';
                    }

                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );

                    if (!emailRegex.hasMatch(value)) {
                      return 'Please Enter Valid Email';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap:() {
                      if (model.showForgotPassword) {
                        model.toggleForgotPassword();
                      } else if (model.showOtpLogin) {
                        model.toggleOtpLogin();
                      } else if (model.showOtpField) {
                        model.setLoginMode(LoginMode.email);
                      }
                    },
                    child: Text(
                      LanguageService.get('login_with_password'),
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: AppSizes.h20),
              ElevatedButton(
                onPressed:
                    model.isBusyForgotPassword
                        ? null
                        : (model.isOTPWithLogin == true
                            ? model.sendOtpWithLogin
                            : model.sendPasswordResetOtp),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.h40),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v45),
                  ),
                ),
                child:
                    model.isBusyForgotPassword
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          LanguageService.get('send_otp'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ] else if (model.forgotPasswordStep ==
                ForgotPasswordStep.newPassword) ...[
              // New Password Fields
              _buildTextFormField(
                context,
                controller: model.newPasswordController,
                label: LanguageService.get('new_password'),
                obscureText: model.obscureNewPassword,
                validator: (value) {
                  if (value?.isEmpty == true)
                    return LanguageService.get('please_enter_new_password');
                  if (value!.length < 6)
                    return LanguageService.get(
                      'password_must_be_at_least_6_characters',
                    );
                  return null;
                },
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    model.obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray,
                  ),
                  onPressed: model.toggleNewPassword,
                ),
              ),
              SizedBox(height: AppSizes.h16),
              _buildTextFormField(
                context,
                controller: model.confirmPasswordController,
                label: LanguageService.get('confirm_password'),
                obscureText: model.obscureConfirmPassword,
                validator: (value) {
                  if (value?.isEmpty == true)
                    return LanguageService.get('please_confirm_password');
                  if (value != model.newPasswordController.text) {
                    return LanguageService.get('passwords_do_not_match');
                  }
                  return null;
                },
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    model.obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray,
                  ),
                  onPressed: model.toggleConfirmPassword,
                ),
              ),
              SizedBox(height: AppSizes.h30),
              ElevatedButton(
                onPressed:
                    model.isBusyForgotPassword ? null : model.resetPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.h40),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v45),
                  ),
                ),
                child:
                    model.isBusyForgotPassword
                        ? CircularProgressIndicator(color: AppColors.white)
                        : Text(
                          LanguageService.get('create_password'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(BuildContext context, LoginViewModel model) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.h10),
          child: Row(
            children: [
              Expanded(child: Divider(color: AppColors.lightGrey)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w16),
                child: Text(
                  LanguageService.get('or'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.lightGrey)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSocialLoginButton(
              context,
              onTap: model.signInWithGoogle,
              iconPath: AppImages.google,
              title: LanguageService.get('google'),
            ),
            // _buildSocialLoginButton(
            //   context,
            //   onTap: model.signInWithFacebook,
            //   iconPath: AppImages.facebook,
            //   title: LanguageService.get('facebook'),
            // ),
            _buildSocialLoginButton(
              context,
              onTap: () {},
              iconPath: AppImages.microsoft,
              title: LanguageService.get('apple'),
              icon: Icons.apple,
            ),
            _buildSocialLoginButton(
              context,
              onTap: () {},
              iconPath: AppImages.linkedin,
              title: LanguageService.get('linkedin'),
            ),
            _buildSocialLoginButton(
              context,
              onTap: () {},
              iconPath: AppImages.wechat,
              title: LanguageService.get('wechat'),
              iconColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt(BuildContext context, LoginViewModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h10),
      child: GestureDetector(
        onTap: model.navigateToRegister,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: LanguageService.get('dont_have_account'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: " ${LanguageService.get('sign_up')}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Could not launch $url: $e');
      // Optionally show error to the user
    }
  }

  Widget _buildTermsAndConditionsCheckbox(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "${LanguageService.get('i_agree_to_the')} ",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: LanguageService.get('terms_of_service'),
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            _openUrl(
                              'https://www.freeprivacypolicy.com/live/38ff3e0d-37fd-440f-a2a0-a92c7c14fc89',
                            );
                          },
                  ),
                  TextSpan(text: "${LanguageService.get('and')} "),
                  TextSpan(
                    text: LanguageService.get('privacy_policy'),
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            _openUrl(
                              'https://www.freeprivacypolicy.com/live/4fbd2c88-6839-4292-9a10-8c331bd89deb',
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
            ),
          ),
          filled: !enabled,
          fillColor:
              enabled ? null : AppColors.lightGrey.withValues(alpha: 0.1),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w12,
            vertical: AppSizes.h12,
          ),
        ),
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildSocialLoginButton(
    BuildContext context, {
    required VoidCallback onTap,
    String? iconPath,
    required String title,
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppSizes.v12),
          color: AppColors.white,
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(
                    icon,
                    size: 32,
                    color: iconColor ?? AppColors.textPrimary,
                  )
                  : iconPath != null
                  ? SvgPicture.asset(iconPath, height: 28, width: 28)
                  : Icon(Icons.login, size: 24, color: AppColors.primary),
        ),
      ),
    );
  }
}
