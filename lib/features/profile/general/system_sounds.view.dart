import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX ko dialogs ke liye rakha gaya hai
import 'package:manager/features/profile/general/system_sounds.vm.dart'; // ViewModel import
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart'; // Save button ke liye
import 'package:stacked/stacked.dart'; // Stacked import

// `StatelessWidget` ko `StackedView<SystemSoundsViewModel>` se badlein
class SystemSoundsView extends StackedView<SystemSoundsViewModel> {
  const SystemSoundsView({super.key});

  @override
  Widget builder(
      BuildContext context,
      SystemSoundsViewModel model, // ViewModel yahan milta hai
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: AppColors.cultured,
      appBar: _buildAppBar(context, model),
      body: model.busy(SystemSoundsViewModel.kInitBusyKey) // Page loader
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : _buildContent(context, model),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.cultured,
        child: CommonElevatedButton(
          isLoading: model.busy(SystemSoundsViewModel.kSaveBusyKey),
          onPressed: model.saveSettings,
          label: LanguageService.get("save"), // l10n se "Save" lein
        ),
      ),

    );
  }

  // ViewModel ko initialize karein
  @override
  SystemSoundsViewModel viewModelBuilder(BuildContext context) =>
      SystemSoundsViewModel();

  @override
  void onViewModelReady(SystemSoundsViewModel model) {
    model.init(); // Data load karne ke liye init() call karein
  }
  // --- End ViewModel Setup ---

  PreferredSizeWidget _buildAppBar(
      BuildContext context, SystemSoundsViewModel model) {
    // GradientAppBar aapke code se
    return GradientAppBar(titleKey: "system_sound", titleSpacing: 0);
  }

  Widget _buildContent(BuildContext context, SystemSoundsViewModel model) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSizes.v10,
        // Button ke liye extra padding
        bottom: AppSizes.v10 + 90,
      ),
      child: Column(
        children: [
          _buildSoundCategory(
            context: context,
            model: model,
            title: LanguageService.get("ticket_notification"),
            type: 'ticket_notification', // Type key
          ),
          // _buildSoundCategory(
          //   context: context,
          //   model: model,
          //   title: LanguageService.get("voice_call"),
          //   type: 'voice_call', // Type key
          // ),
          // _buildSoundCategory(
          //   context: context,
          //   model: model,
          //   title: LanguageService.get("video_call"),
          //   type: 'video_call', // Type key
          // ),
          _buildSoundCategory(
            context: context,
            model: model,
            title: LanguageService.get("alert_sound"),
            type: 'alert', // Type key
          ),
          _buildSoundCategory(
            context: context,
            model: model,
            title: LanguageService.get("chat"),
            type: 'chat', // Type key
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCategory({
    required BuildContext context,
    required SystemSoundsViewModel model,
    required String title,
    required String type, // Type key pass karein
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8,horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          InkWell(
            // Dialog kholne ke liye type pass karein
            onTap: () => _showSoundSelectionDialog(context, model, type, title),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySuperLight.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textGrey.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LanguageService.get("sound"),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    // currentSound ko ViewModel se lein
                    model.getSoundNameForType(type),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.gunmetal, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoundSelectionDialog(
      BuildContext context,
      SystemSoundsViewModel model, // Model pass karein
      String type, // Type pass karein
      String category,
      ) {
    // Sound list ko ViewModel se lein
    final sounds = model.availableSounds.map((s) {
      if (s.isEmpty || s == 'default') return 'Default';
      return s[0].toUpperCase() + s.substring(1); // Capitalize
    }).toList();

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
                    Image.asset(AppImages.systemSound, width: 24, height: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
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
              // Sound List
              StatefulBuilder(
                  builder: (context,set) {
                    return Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(16),
                        itemCount: sounds.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.gray.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final sound = sounds[index];
                          // Check karein ki yeh sound selected hai ya nahi
                          final bool isSelected =
                              model.getSoundNameForType(type) == sound;

                          return ListTile(
                            leading: Icon(
                              Icons.music_note,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: Text(
                              sound,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: isSelected // Dynamic check
                                ? Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 20,
                            )
                                : null,
                            onTap: () {

                              set((){});
                              model.updateSound(type, sound.toLowerCase(),);

                            },
                          );
                        },
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}