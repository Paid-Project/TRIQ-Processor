import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/features/stage/stage.vm.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/ticket_resolve/ticket_resolve.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../resources/app_resources/app_resources.dart';

class StageViewAttributes {
  StageViewAttributes({required this.selectedBottomNavIndex});

  final int selectedBottomNavIndex;
}

class StageView extends StatelessWidget {
  const StageView({super.key, required this.attributes});

  final StageViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StageViewModel>.reactive(
      viewModelBuilder: () => StageViewModel(),
      onViewModelReady: (StageViewModel model) => model.init(attributes),
      disposeViewModel: false,
      builder: (BuildContext context, StageViewModel model, Widget? child) {
        return WillPopScope(
          onWillPop: () => model.handleBackPress(context),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.transparent,
                body: model.bottomNavItems[model.selectedBottomNavIndex],
                bottomNavigationBar: _buildCustomBottomNavBar(model, context),
              ),
              if (model.isCloseTicketDialogOpen)
                Container(color: AppColors.black.withValues(alpha: 0.3)),
              if (model.isCloseTicketDialogOpen)
                TicketResolveDialog(
                  request: DialogRequest<TicketResolveDialogAttributes>(
                    data: TicketResolveDialogAttributes(
                      ticketId: model.requestedTicketId,
                      onResolvePressed: (ticketId) {
                        model.resolveTicket(ticketId);
                      },
                      onRejectPressed: (ticketId) {
                        model.rejectTicket(ticketId);
                      },
                      closeDialog: () {
                        model.closeDialog();
                      },
                    ),
                  ),
                  completer: (_) {},
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomBottomNavBar(StageViewModel model, BuildContext context) {
    return SafeArea(
      child: Container(
        height: AppSizes.v80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.v30),
            bottomRight: Radius.circular(AppSizes.v30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          currentIndex: model.selectedBottomNavIndex,
          onTap: model.updateSelectedBottomNavIndex,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.primary,
          elevation: 10,
          unselectedLabelStyle: TextStyle(
            fontSize: AppSizes.v10,
            color: AppColors.textGrey,
          ),
          selectedLabelStyle: TextStyle(
            fontSize: AppSizes.v10,
            color: AppColors.primary,
          ),
          items: [
            _buildBottomNavItem(
              context,
              imagePath: AppImages.homeInactive,
              activeImagePath: AppImages.homeActive,
              label: LanguageService.get("home"),
              isSelected: model.selectedBottomNavIndex == 0,
            ),
            _buildBottomNavItem(
              context,
              imagePath: AppImages.ticketInactive,
              activeImagePath: AppImages.ticketActive,
              label: LanguageService.get("tickets"),
              isSelected: model.selectedBottomNavIndex == 1,
            ),
            _buildBottomNavItem(
              context,
              imagePath: AppImages.conversationInactive,
              activeImagePath: AppImages.conversationActive,
              label: LanguageService.get("chat"),
              isSelected: model.selectedBottomNavIndex == 2,
            ),
            _buildBottomNavItem(
              context,
              imagePath: AppImages.contactBookInactive,
              activeImagePath: AppImages.contactBookActive,
              label: LanguageService.get("contacts"),
              isSelected: model.selectedBottomNavIndex == 3,
            ),
            _buildBottomNavItem(
              context,
              imagePath: AppImages.userInactive,
              activeImagePath: AppImages.userActive,
              label: LanguageService.get("profile"),
              isSelected: model.selectedBottomNavIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
    BuildContext context, {
    required String imagePath,
    required String activeImagePath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      activeIcon: SizedBox(
        height: AppSizes.v32,
        child: Image.asset(
          activeImagePath,
          height: AppSizes.v24,
          width: AppSizes.v24,
          color: isSelected ? AppColors.primary : AppColors.gray,
        ),
      ),
      icon: SizedBox(
        height: AppSizes.v32,
        child: Image.asset(
          imagePath,
          height: AppSizes.v24,
          width: AppSizes.v24,
          color: isSelected ? AppColors.primary : AppColors.gray,
        ),
      ),
      label: label,
    );
  }
}
