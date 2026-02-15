import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:manager/features/profile/general/applang.view.dart';
import 'package:manager/features/profile/general/system_sounds.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';

import '../my_wallet/controller/languageController.dart';
import 'app_currency.dart';

class GeneralSettingView extends StatelessWidget {
  GeneralSettingView({super.key});

  final controller = Get.put(LanguageController());

  void showTranslationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        child: ValueListenableBuilder(
            valueListenable: controller.selectedChatLanguage,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close_rounded),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.progressBlue.withValues(alpha: 0.1),
                      ),
                      child: Image.asset(AppImages.translate),
                    ),
                    SizedBox(height: 10),
                    Text(
                      LanguageService.get("chat_translation"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const AppLanguageView(chatLanguage: true));

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primarySuperLight.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.textGrey.withValues(alpha: 0.1),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                LanguageService.get('translate_text_to'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              controller.selectedChatLanguage.value.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.gunmetal,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      LanguageService.get(
                        'after_it_is_enabled_text_in_chats_will_be_translated_into_the_selected_language',
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: AppColors.primarySuperLight.withValues(alpha: 0.04),
                    //     borderRadius: BorderRadius.circular(13),
                    //     border: Border.all(
                    //       color: AppColors.textGrey.withValues(alpha: 0.1),
                    //     ),
                    //   ),
                    //   padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Text(
                    //           LanguageService.get(
                    //             'auto_translate_messages_received_in_chat',
                    //           ),
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.w500,
                    //             color: AppColors.black,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       ),
                    //       Switch(
                    //         value: true,
                    //         onChanged: (value) {},
                    //         activeColor: AppColors.primary,
                    //         inactiveThumbColor: AppColors.gray,
                    //         inactiveTrackColor: AppColors.violetBlue.withValues(
                    //           alpha: 0.1,
                    //         ),
                    //         trackOutlineColor: WidgetStateProperty.all(
                    //           Colors.transparent,
                    //         ),
                    //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //         splashRadius: 0,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //
                    // const SizedBox(height: 10),
                    //
                    // Text(
                    //   LanguageService.get(
                    //     'after_it_is_enabled_text_in_chats_will_be_translated_into_the_selected_language',
                    //   ),
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w400,
                    //     color: AppColors.textGrey,
                    //     fontSize: 10,
                    //   ),
                    // ),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(color: AppColors.white, child: _buildContent(context)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
      ),

      title: Text(
        LanguageService.get("general"),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    );
    //   },
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.v10, bottom: AppSizes.v10),
        child: Column(
          children: [
            _buildMenuItem(
              imagePath: AppImages.appLanguage,
              title: LanguageService.get("app_language"),
              iconColor: AppColors.bluebackground,
              onTap: () {
                Get.to(
                      () => AppLanguageView(),
                ); // Navigate to app language settings
              },
              animationDelay: 200.ms,
            ),
            _buildDivider(),
            _buildMenuItem(
              imagePath: AppImages.chatLanguage,
              title: LanguageService.get("chat_language"),
              iconColor: AppColors.greenbackground,
              onTap: () {
                showTranslationDialog(context); // Show translation dialog
              },
              animationDelay: 300.ms,
            ),
            _buildDivider(),
            // _buildMenuItem(
            //   imagePath: AppImages.currency,
            //   title: LanguageService.get("currency"),
            //   iconColor: AppColors.violetBlue,
            //   onTap: () {
            //     Get.to(
            //           () => AppCurrencyView(),
            //     );
            //     // _showCurrencySelectionDialog(context);
            //   },
            //   animationDelay: 400.ms,
            // ),
            _buildDivider(),
            _buildMenuItem(
              imagePath: AppImages.systemSound,
              title: LanguageService.get("system_sound"),
              iconColor: AppColors.redbackground,
              onTap: () {
                Get.to(() => SystemSoundsView());
              },
              animationDelay: 500.ms,
            ),
            _buildDivider(),
            // _buildMenuItem(
            //   imagePath: AppImages.appearance,
            //   title: LanguageService.get("appearance"),
            //   iconColor: AppColors.backgroundlightgreen,
            //   onTap: () {
            //     // Navigate to appearance settings
            //   },
            //   hasToggle: true,
            //   animationDelay: 600.ms,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    String? imagePath,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    required Duration animationDelay,
    bool hasToggle = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath!,
                  width: 24,
                  height: 24,
                  color: iconColor,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            if (hasToggle)
              _buildThemeToggle()
            else
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySuperLight.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.textGrey.withValues(alpha: 0.1),
                  ),
                ),
                child: Image.asset(
                  AppImages.arrowRight,
                  width: 16,
                  height: 16,
                  color: AppColors.textGrey,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: animationDelay);
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFEEEEEE),
    );
  }

  Widget _buildThemeToggle() {
    bool isDarkMode = true; // Default to Dark (you can manage this with state)

    return SizedBox(
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            LanguageService.get('light'),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 8),
          FlutterSwitch(
            width: 50.0,
            height: 25.0,
            valueFontSize: 0.0,
            toggleSize: 20.0,
            value: isDarkMode,
            borderRadius: 30.0,

            padding: 2.0,
            activeColor: AppColors.violetBlue.withValues(alpha: 0.1),
            inactiveColor: AppColors.lightGrey.withValues(alpha: 0.3),
            activeIcon: Icon(Icons.dark_mode, color: Colors.black, size: 16),
            inactiveIcon: Icon(Icons.light_mode, color: Colors.black, size: 16),
            onToggle: (value) {},
          ),
          SizedBox(width: 8),
          Text(
            LanguageService.get('dark'),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencySelectionDialog(BuildContext context) {
    final currencies = [
      {'code': 'USD', 'flag': '🇺🇸', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'INR', 'flag': '🇮🇳', 'name': 'Indian Rupee', 'symbol': '₹'},
      {'code': 'CNY', 'flag': '🇨🇳', 'name': 'Chinese Yuan', 'symbol': '¥'},
      {'code': 'EUR', 'flag': '🇪🇺', 'name': 'Euro', 'symbol': '€'},
      {'code': 'JPY', 'flag': '🇯🇵', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'SAR', 'flag': '🇸🇦', 'name': 'Saudi Riyal', 'symbol': '﷼'},
      {'code': 'RUB', 'flag': '🇷🇺', 'name': 'Russian Ruble', 'symbol': '₽'},
      {
        'code': 'BDT',
        'flag': '🇧🇩',
        'name': 'Bangladeshi Taka',
        'symbol': '৳',
      },
      {'code': 'TRY', 'flag': '🇹🇷', 'name': 'Turkish Lira', 'symbol': '₺'},
      {
        'code': 'KRW',
        'flag': '🇰🇷',
        'name': 'South Korean Won',
        'symbol': '₩',
      },
      {'code': 'VND', 'flag': '🇻🇳', 'name': 'Vietnamese Dong', 'symbol': '₫'},
      {'code': 'THB', 'flag': '🇹🇭', 'name': 'Thai Baht', 'symbol': '฿'},
      {'code': 'PLN', 'flag': '🇵🇱', 'name': 'Polish Zloty', 'symbol': 'zł'},
      {
        'code': 'IDR',
        'flag': '🇮🇩',
        'name': 'Indonesian Rupiah',
        'symbol': 'Rp',
      },
      {
        'code': 'UAH',
        'flag': '🇺🇦',
        'name': 'Ukrainian Hryvnia',
        'symbol': '₴',
      },
    ];

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(AppImages.currency, width: 24, height: 24),
                    SizedBox(width: 12),
                    Text(
                      LanguageService.get("select_currency"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Currency List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  itemCount: currencies.length,
                  separatorBuilder:
                      (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.gray.withValues(alpha: 0.2),
                  ),
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    return ListTile(
                      leading: Text(
                        currency['flag']!,
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        currency['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${currency['code']!} (${currency['symbol']!})',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        // Handle currency selection
                        _onCurrencySelected(currency['code']!);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCurrencySelected(String currencyCode) {
    // Handle currency selection
    // You can save the selected currency to storage or state management
    Get.snackbar(
      LanguageService.get("currency_selected"),
      '${LanguageService.get("selected_currency")}: $currencyCode',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryLight,
      colorText: AppColors.white,
    );
  }
}
