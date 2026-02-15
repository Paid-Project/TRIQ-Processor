import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:manager/services/language.service.dart';

import '../../resources/app_resources/app_resources.dart';
import '../../resources/multimedia_resources/resources.dart';


Future<void> showCustomAddMenuDialog({
  required BuildContext context,
  required String dialogTitle,
   Alignment alignment=Alignment.center,
  required List<CustomMenuItem> menuItems,
  int itemLenth=3
})
{
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Dialog ka UI yahan banega
      return _AddMenuDialogContent(
        dialogTitle: dialogTitle,
        menuItems: menuItems,
        animation: animation,
        alignment: alignment,
          itemLenth:itemLenth
      );
    },
  );
}

// Dialog ka internal UI widget
class _AddMenuDialogContent extends StatelessWidget {
  final String dialogTitle;
  final Alignment alignment;
  final List<CustomMenuItem> menuItems;
  final Animation<double> animation;
  final int itemLenth;
  const _AddMenuDialogContent({
    required this.dialogTitle,
    required this.menuItems,
    required this.animation,
    required this.alignment,
     this.itemLenth=3,
  });


  static List<CustomMenuItem> defaultItem =[
    CustomMenuItem(icon: AppImages.camera, title: "scan_from_camera_gallery".lang, iconColor: AppColors.colorFFB141, onTap: (){}),
    CustomMenuItem(icon: AppImages.phone, title: "search_by_phone_number_email".lang, iconColor: AppColors.color41C293, onTap: (){}),
    CustomMenuItem(icon: AppImages.addCircle, title: "create_new".lang, iconColor: AppColors.color0ABAB5, onTap: (){}),
  ];
  @override
  Widget build(BuildContext context) {
    // ScaleTransition animation ke liye
    final scaleAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    return GestureDetector(
      // Dialog ke bahar tap karne par use band karne ke liye
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: alignment,
          children: [
            if (alignment == Alignment.center)
            ScaleTransition(
              scale: scaleAnimation,
              alignment: alignment,
              child: child(),
            ),
            if (alignment == Alignment.bottomRight)
      Positioned(
      bottom: 120,
      right: 16,
      child: Transform.scale(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)).value,
          child:  child()))
          ],
        ),
      ),
    );
  }

  Widget child(){
    return Container(
      width: Get.width*0.85,
      // height: (Get.height * 0.1266)*itemLenth+10,
      decoration: BoxDecoration(
        color: Colors.white, // AppColors.white
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // AppColors.black.withValues(alpha: 0.1)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog ka Title
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 4),
            child: Text(
              dialogTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),

          // Menu items ki list ko dynamically generate karna
          ListView.separated(
            itemCount: menuItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildMenuOption(
                context: context,
                icon: item.icon ?? defaultItem[index].icon??'',
                title: item.title ?? defaultItem[index].title??'',
                subtitle: item.subtitle??'',
                iconColor: item.iconColor??defaultItem[index].iconColor,
                onTap: item.onTap,
              );
            },
            separatorBuilder: (context, index) {
              // Har item ke beech me Divider
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE0E0E0)), // AppColors.lightGrey
              );
            },
          ),
        ],
      ),
    );
  }
}

// Yeh aapka original helper method hai, thode changes ke saath
Widget _buildMenuOption({
  required BuildContext context,
  required String icon,
  required String title,
  String? subtitle,
  Color? iconColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pop(); // Option par tap karte hi dialog band ho jayega
      onTap(); // Aur fir diya gaya function execute hoga
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Image.asset(icon, width: 24, height: 24, color: iconColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333), // AppColors.textPrimary
                  ),
                ),
                if (subtitle != '') ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle??'',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF828282), // AppColors.textSecondary
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomMenuItem {
  final String? icon;
  final String? title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  CustomMenuItem({
     this.icon,
     this.title,
    this.subtitle,
     this.iconColor,
    required this.onTap,
  });
}