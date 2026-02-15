import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manager/features/profile/my_wallet/duepay.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

class DuePayView extends StatelessWidget {
  const DuePayView({super.key});

  @override
  Widget build(BuildContext context) {
       return ViewModelBuilder<DuePaymentViewModel>.reactive(
      viewModelBuilder: () => DuePaymentViewModel(),
      // onViewModelReady: (DuePaymentViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, DuePaymentViewModel model, Widget? child) {
        final ScrollController scrollController = ScrollController();

        return Scaffold(
          // extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),

          body: Stack(
            children: [
              
             
              _buildList(context, model),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    // return PreferredSize(
  

       return  AppBar(
             flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.appbarVarient, 
          AppColors.primaryVariant,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    ),
  ),
            // backgroundColor: AppColors.primary,//withValues(alpha: opacity),
            // surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: AppColors.white),
            ),
          
            title: Text(
             LanguageService.get("Due Payments"),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.white),

            actions: [
              IconButton(
                onPressed: () {
               //   model.navigateToQRView();
                },
                icon: Icon(Icons.search, color: Colors.white),
              ),
         
            ],
          );
      //   },
      // ),
    // );
  }

  Widget _buildList(BuildContext context,DuePaymentViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: 10, // Replace with model.payments.length
        itemBuilder: (context, index) {
          // Replace with your payment item widget
          return Column(
            children: [
              _buildHeaderBackground(context, model),
                 SizedBox(height: AppSizes.h8),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lightGrey,
              indent: AppSizes.w20,
              endIndent: AppSizes.w20,
            ),
            SizedBox(height: AppSizes.h8),
            ],
          );
        },
      ),
    );

  }

Widget _buildHeaderBackground(BuildContext context, DuePaymentViewModel model) {
    return Stack(
      children: [
  
        // Profile content
        Center(
          child: ListTile(
         
        leading:      Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // CachedNetworkImage for organization logo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightGrey,
                          // blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    width: AppSizes.w60,
                    height: AppSizes.h60,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            // model.user.logoUrl ??
                            'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
                        width: AppSizes.w120,
                        height: AppSizes.h120,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: AppColors.lightGrey,
                              child: Icon(
                                Icons.business,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: AppColors.lightGrey,
                              child: Icon(
                                Icons.business,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                      ),
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
    
                  // Replace IconButton with this new implementation
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        print(
                          LanguageService.get("edit_button_tapped")
                        ); // Debug print
                        // model.navigateToCreateOrEditOrgView();
                      },
                      child: Center(
                        child: CachedNetworkImage(imageUrl:
                        // model.flag.url??
                         "https://img.icons8.com/ios-filled/50/ffffff/colouredflag--v1.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.flag, color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: AppSizes.h16),
           title:    Text(
                // model.organization?.name ??
                    // model.user.name ??
                    'User Name',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  // fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 500.ms),
              // SizedBox(height: AppSizes.h4),
          subtitle:     Text(
                // model.payment.date ?? 
                '2025 Jun 20',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
         trailing: Text(
          // model.payment.amount.toString(),
          "\$30.00",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
         ),
          ),
        ),
      ],
    );
  }

}

