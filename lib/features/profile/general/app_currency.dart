import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';

import '../../../services/language.service.dart';
import '../my_wallet/controller/currencyController.dart';

class AppCurrencyView extends StatefulWidget {
  const AppCurrencyView({super.key});

  @override
  State<AppCurrencyView> createState() => _AppCurrencyViewState();
}

class _AppCurrencyViewState extends State<AppCurrencyView> with SingleTickerProviderStateMixin {
  final controller = Get.put(CurrencyController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildSaveButton(context),
      body: Column(children: [_buildSearchBar(context), Expanded(child: _buildLanguageList(context))]),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "app_currency");
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: CommonTextField(
        controller: _searchController,
        placeholder: LanguageService.get('search_currency'),
        onChanged: (value) {
          controller.updateSearch(value);
        },
        prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(AppImages.search, height: 17, width: 17, color: AppColors.black)),
        suffixIcon:
        _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: AppColors.gray),
          onPressed: () {
            _searchController.clear();
            controller.updateSearch('');
          },
        )
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(height: 20, color: AppColors.textGrey.withValues(alpha: 0.1));
        },
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 16),
        itemCount: controller.filteredLanguages.length,
        itemBuilder: (_, index) {
          final lang = controller.filteredLanguages[index];

          return InkWell(
            onTap: () => controller.selectLanguage(lang),
            child: Row(
              children: [
                // Flag container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.softGray.withOpacity(0.1)),
                  child: Center(child: Text(lang.flag, style: TextStyle(fontSize: 24))),
                ),
                SizedBox(width: 10),
                // Language info
                Expanded(child: Text(lang.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
                // Radio button
                StreamBuilder<Object>(
                  stream: controller.selectedLanguageCode.stream,
                  builder: (context, snapshot) {
                    final isSelected = controller.selectedLanguageCode.value == lang.code;

                    return Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? AppColors.primaryLight : AppColors.textGrey.withValues(alpha: 0.1), width: 1.5),
                        color: AppColors.white,
                      ),
                      child: Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppColors.primaryLight : AppColors.transparent),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: Obx(
            () => CommonElevatedButton(
          height: 48,
          label: controller.isLoading.value ? 'Saving...' : LanguageService.get('save_changes'),
          onPressed:
          controller.isLoading.value
              ? null
              : () async {
            await controller.saveLanguage();
            // App will restart automatically, no need to navigate back
          },
          backgroundColor: AppColors.primaryDark,
          textColor: AppColors.white,
          borderRadius: 45,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
