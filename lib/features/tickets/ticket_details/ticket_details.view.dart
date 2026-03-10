import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/core/models/ticket_details_model.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/configs.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import 'ticket_details.vm.dart';

class TicketDetailsView extends StatelessWidget {
  final String? ticketId;
  final bool isEmbedded;
  TicketDetailsView({super.key, this.ticketId,  this.isEmbedded = false});

  bool isInitScreenDone=false;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketDetailsViewModel>.reactive(
      viewModelBuilder: () => TicketDetailsViewModel(),
      onViewModelReady: (TicketDetailsViewModel model) => model.init(ticketId: ticketId),
      disposeViewModel: false,
      builder: (BuildContext context, TicketDetailsViewModel model, Widget? child) {
        if (isEmbedded) {
          return Column(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: _buildBody(context, model)),
              if (!model.isLoading) _buildBottomActionBar(context, model),
            ],
          );
        }
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: _buildBody(context, model),
          bottomNavigationBar: model.isLoading ? null : _buildBottomActionBar(context, model),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TicketDetailsViewModel model) {


    if (model.isLoading) {
      return _buildShimmerLoading();
    }

    if (model.hasError) {
      return _buildErrorState(context, model);
    }

    if (model.ticketDetails == null) {
      return _buildEmptyState();
    }
    if(isInitScreenDone==false){
       WidgetsBinding.instance.addPostFrameCallback((c){
        if(model.ticketDetails?.ticketDetails?.status=='Resolved'){
          if(model.ticketDetails?.ticketDetails?.isFirstTimeServiceDone??true){
            _showRatingDialog(context, model);
          }
        }
      });
      isInitScreenDone=true;
    }

    return Container(
      color: AppColors.snowDrift,
      height:isEmbedded ? null : double.maxFinite,
      child: SingleChildScrollView(
        physics: isEmbedded ? const ClampingScrollPhysics() : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfoCard(context, model),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildTicketDetailsCard(context, model),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildProblemDescriptionCard(context, model),
                  SizedBox(height: 16),
                  _buildMediaCard(context, model),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildWarrantyInfoCard(context, model),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                ],
              ),
            ),
            if (getUser().primaryRole == UserRole.organization && model.ticketDetails?.ticketDetails?.status?.toLowerCase() != "resolved")
              if (getUser().primaryRole != UserRole.organization) ...{
                //Padding(padding: EdgeInsets.all(15), child: _buildPaymentCard(context, model)),
              } else ...{
                Form(
                  key: model.formKey,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: AbsorbPointer(
                      absorbing: model.ticketDetails?.ticketDetails?.status == "On Hold",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LanguageService.get('reschedule'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 16),
                          _buildDropdownFormField(
                            context,
                            value: null,
                            label: LanguageService.get('select_time'),
                            items: [
                              {"value": "10", "display": LanguageService.get('10_Minute')},
                              {"value": "20", "display": LanguageService.get('20_Minute')},
                              {"value": "30", "display": LanguageService.get('30_Minute')},
                              {"value": "40", "display": LanguageService.get('40_Minute')},
                              {"value": "50", "display": LanguageService.get('50_Minute')},
                              {"value": "60", "display": LanguageService.get('60_Minute')},
                            ],
                            onChanged: (value) {
                              model.rescheduleTime = value ?? "";
                              model.formKey.currentState?.validate();
                            },
                            validator: (value) {
                              return value == null ? LanguageService.get('please_select_time') : null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              },
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFormField(
    BuildContext context, {
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.white,
      style: Theme.of(context).textTheme.bodyLarge,
      items:
          items.map((Map<String, String> item) {
            return DropdownMenuItem<String>(
              value: item['value'], // English value for backend
              child: Text(item['display']!), // Translated text for display
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.snowDrift,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerCustomerInfoCard(),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildShimmerTicketDetailsCard(),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildShimmerProblemDescriptionCard(),
                  SizedBox(height: 16),
                  _buildShimmerMediaCard(),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  _buildShimmerWarrantyInfoCard(),
                  Divider(height: 26, color: AppColors.textGrey.withValues(alpha: 0.1)),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(15), child: _buildShimmerPaymentCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TicketDetailsViewModel model) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.redBack),
            SizedBox(height: 16),
            Text(
              LanguageService.get('error_loading_ticket_details'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              model.errorMessage ?? LanguageService.get('unknown_error_occurred'),
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => model.refreshTicketDetails(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(LanguageService.get('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              LanguageService.get('no_ticket_details_found'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              LanguageService.get('ticket_details_could_not_be_loaded'),
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, TicketDetailsViewModel model) {
    final pricingDetails = model.ticketDetails?.pricingDetails;
    final ticketDetails = model.ticketDetails?.ticketDetails;

    final totalCost = pricingDetails?.cost ?? 0;
    final currency = pricingDetails?.currency ?? 'USD';
    final paymentStatus = ticketDetails?.paymentStatus ?? 'unknown';
    final supportMode = pricingDetails?.supportMode ?? 'Unknown';
    final ticketType = pricingDetails?.ticketType ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(AppImages.payment, width: 20, height: 20, color: AppColors.primarySuperLight),
                    SizedBox(width: 8),
                    Text(LanguageService.get('payment'), style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LanguageService.get('total_payment'), style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      model.formatCurrency(totalCost, currency),
                      style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageService.get('payment_status'),
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: paymentStatus.toLowerCase() == 'paid' ? AppColors.color41C293 : AppColors.crimsonRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageService.get('support_mode'),
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    Text(supportMode, style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageService.get('ticket_type'),
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    Text(ticketType, style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 0, color: AppColors.textGrey.withValues(alpha: 0.1)),
          Row(
            children: [
              SizedBox(width: 13),
              Expanded(
                child: Text(
                  LanguageService.get('get_tax_invoice'),
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement tax invoice functionality
                },
                icon: Transform.rotate(angle: math.pi, child: Image.asset(AppImages.back, height: 22, width: 22)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TicketDetailsViewModel model) {
    final ticketNumber = model.ticketDetails?.ticketDetails?.ticketNumber ?? '#Loading...';
    final status = model.ticketDetails?.ticketDetails?.status ?? 'Loading...';

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
      title: Text(ticketNumber, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
      actions: [
        SizedBox(
          height: 23,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved" ? AppColors.success : AppColors.white,
              padding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
            ),
            onPressed: () {},
            child: Text(
              model.getStatusColor(status),
              style: TextStyle(
                color: _getStatusColorFromString(model.ticketDetails?.ticketDetails?.status),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved")...[
          SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.white, size: 20),
            menuPadding: EdgeInsets.zero,
            offset: Offset(-10, 40),
            onSelected: (String value) {
              if (value == 'report') {
                _showReportDialog(context, model);
              } else if (value == 'rating') {
                _showRatingDialog(context, model);
              }
            },
            itemBuilder:
                (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Text(
                  LanguageService.get('report'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ),
                  // PopupMenuItem<String>(
                  //   value: 'rating',
                  //   child: Text(
                  //     LanguageService.get('rating'),
                  //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  //   ),
                  // ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.white,
            shadowColor: AppColors.black.withValues(alpha: 0.1),
            elevation: 8,
          ),
        ]
      ],
    );
  }

  void _showReportDialog(BuildContext context, TicketDetailsViewModel model) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
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

              // Header
              Text(LanguageService.get("report_problem"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 20),

              // Form with validation
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Title Field

                    CommonTextField(
                      controller: titleController,
                      placeholder: LanguageService.get("title"),
                      validator: CommonValidators.required(LanguageService.get("title_required")),
                    ),
                    SizedBox(height: 16),

                    // Description Field
                    CommonTextField(
                      controller: descriptionController,
                      placeholder: LanguageService.get("write_here"),
                      maxLines: 4,
                      validator: CommonValidators.required(LanguageService.get("description_required")),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: CommonElevatedButton(
                  label: LanguageService.get("submit"),
                  onPressed: () {
                    // Validate the form
                    if (formKey.currentState!.validate()) {
                      // Form is valid, submit the report
                      Get.back();
                      model.submitProblemReport(titleController.text.trim(), descriptionController.text.trim());
                    }
                    // If validation fails, CommonTextField will show error messages
                  },
                  backgroundColor: AppColors.primaryDark,
                  textColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  borderRadius: 23,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, TicketDetailsViewModel model) {
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
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

              // Header
              Text(LanguageService.get("feedback_and_ratings"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 20),

              // Form with validation
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStarRating(),
                    SizedBox(height: 16),
                    CommonTextField(
                      controller: feedbackController,
                      placeholder: LanguageService.get("write_feedback_here"),
                      maxLines: 4,
                      validator: CommonValidators.required(LanguageService.get("description_required")),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: CommonElevatedButton(
                  label: LanguageService.get("submit"),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Get.back();
                      model.submitRating(rating.value, feedbackController.text.trim());
                    }
                  },
                  backgroundColor: AppColors.primaryDark,
                  textColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  borderRadius: 23,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ValueNotifier<int> rating = ValueNotifier(5);

  Widget buildStarRating({
    double size = 34,
    double spacing = 4,
  })
  {
    return ValueListenableBuilder(
      valueListenable: rating,
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              final isFilled = index < rating.value;
              return GestureDetector(
                onTap: () {
                  rating.value = index + 1;
                },
                child: Padding(
                  padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
                  child: Container(
                    width: size,
                    height: size,
                    color: Colors.white,
                    padding: const EdgeInsets.all(2),
                    child: SvgPicture.asset(
                      isFilled
                          ? 'assets/svg/star_filled.svg'
                          : 'assets/svg/star_empty.svg',
                      width: size - 4,
                      height: size - 4,
                      colorFilter: isFilled
                          ? null
                          : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }
    );
  }


  Widget _buildCustomerInfoCard(BuildContext context, TicketDetailsViewModel model) {
    final orgDetails = model.ticketDetails?.processorDetails;
    final ticketDetails = model.ticketDetails?.ticketDetails;
    final config = locator<Configurations>();

    final customerName = orgDetails?.fullName ?? 'Unknown Customer';

    final flagUrl =orgDetails!.flag!.prefixWithBaseUrl;
    print("flagUrl:-${flagUrl}");
    final supportType = ticketDetails?.type ?? 'Unknown';
    final createdAt = ticketDetails?.createdAt;
print("status:- ${ model.ticketDetails?.ticketDetails?.status?.toLowerCase()}");


// Calculate time since creation
    String pendingText = 'Loading...';

    // if (createdAt != null) {
    //   final now = DateTime.now();
    //   final difference = now.difference(createdAt);
    //
    //   final hours = difference.inHours;
    //   final minutes = difference.inMinutes % 60;
    //
    //   if (model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved") {
    //     pendingText = 'Resolved In: ${ model.ticketDetails?.ticketDetails?.resolvedAt??0}h ${ model.ticketDetails?.ticketDetails?.resolutionDurationMinutes??0}m';
    //   } else {
    //     pendingText = 'Pending Since: ${hours}h ${minutes}m';
    //   }
    // }
     pendingText =model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved" ? _calculatePendingDuration(model.ticketDetails?.ticketDetails?.resolvedAt) :_calculatePendingDuration(createdAt);
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.lavenderMist, borderRadius: BorderRadius.circular(14)),
              padding: EdgeInsets.all(16),
              child: Text(
                customerName.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: AppColors.colorBlue, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: ClipRRect(borderRadius: BorderRadius.circular(2), child: AppImages.getSvgFlag(flagUrl, width: 14, height: 14)),
            ),
            // Positioned(
            //   bottom: -4,
            //   right: -4,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(2),
            //     child: SvgPicture.network(
            //       flagUrl,
            //       height: 16,
            //       width: 16,
            //       placeholderBuilder: (context) => Container(height: 16, width: 16, color: AppColors.textGrey),
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.ticketDetails?.organisationDetails?.fullName?.toString().capitalizeWords  ?? "",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4),
              // model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved"?              Text("${ model.ticketDetails?.ticketDetails?.resolvedAt??0} hours ${ model.ticketDetails?.ticketDetails?.resolutionDurationMinutes??0} min", style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)):
              Text(pendingText, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Container(height: 50, width: 1, color: AppColors.textGrey.withValues(alpha: 0.1)),
        SizedBox(width: AppSizes.v10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Support Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text(supportType, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketDetailsCard(BuildContext context, TicketDetailsViewModel model) {
    final ticketDetails = model.ticketDetails?.ticketDetails;
    final machineDetails = model.ticketDetails?.machineDetails;
    final customerMachineDetails = model.ticketDetails?.customerMachineDetails;

    final createdDate = ticketDetails?.createdAt != null ? model.formatDate(ticketDetails!.createdAt) : 'N/A';
    final closeDate = ticketDetails?.updatedAt != null ? model.formatDate(ticketDetails!.updatedAt) : 'N/A';
    final errorCode = ticketDetails?.errorCode == null || ticketDetails?.errorCode == '' ? '' : ticketDetails?.errorCode ?? '';
    final warrantyStatus = customerMachineDetails?.warrantyStatus ?? 'Unknown';
    final machineName = machineDetails?.machineName ?? 'Unknown';
    final modelNumber = machineDetails?.modelNumber?.toUpperCase() ?? 'Unknown';
    final ticketStatus = ticketDetails?.status ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get('ticket_details'), style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDetailItem(LanguageService.get('created_date'), createdDate)),
            ticketStatus == "Resolved" ? Expanded(child: _buildDetailItem(LanguageService.get('close_date'), closeDate)) : SizedBox.shrink(),
            if (errorCode != "") ...[Expanded(child: _buildDetailItem(LanguageService.get('error_code'), errorCode))],
            ticketStatus != "Resolved"
                ? Expanded(
                  child: _buildDetailItem(
                    LanguageService.get('warranty_status'),
                    model.getWarrantyStatusColor(warrantyStatus),
                    valueColor: warrantyStatus.toLowerCase() == 'in warranty' ? AppColors.success : AppColors.crimsonRed,
                  ),
                )
                : SizedBox.shrink(),
            if (errorCode == "") ...[Expanded(child: SizedBox())],

          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            ticketStatus == "Resolved"
                ? Expanded(
                  child: _buildDetailItem(
                    LanguageService.get('warranty_status'),
                    model.getWarrantyStatusColor(warrantyStatus),
                    valueColor: warrantyStatus.toLowerCase() == 'in warranty' ? AppColors.color41C293 : AppColors.crimsonRed,
                  ),
                )
                : SizedBox.shrink(),
            Expanded(child: _buildDetailItem(LanguageService.get('machine_name'), machineName.toUpperCase())),
            Expanded(child: _buildDetailItem(LanguageService.get('model_number'), modelNumber.toUpperCase())),
            ticketStatus != "Resolved" ? Expanded(child: SizedBox()) : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
  String _calculatePendingDuration( DateTime? tickets) {
    // if (ticket.createdAt == null) return LanguageService.get('unknown');

    try {
      final createdAt = tickets ?? DateTime.now();
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ${difference.inHours % 24}h';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return '${difference.inMinutes} ${LanguageService.get("mins")}';
      }
    } catch (e) {
      return LanguageService.get('unknown');
    }
  }
  Widget _buildProblemDescriptionCard(BuildContext context, TicketDetailsViewModel model) {
    final problem = model.ticketDetails?.ticketDetails?.problem ?? 'No problem description available';
    final engineerRemark = model.ticketDetails?.ticketDetails?.engineerRemark ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
            children: [
              TextSpan(
                text: "${LanguageService.get("problem_description")}: ",
                style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: problem.isNotEmpty ? problem : "-", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ],
          ),
        ),

        if (model.ticketDetails?.ticketDetails?.status == "Resolved") ...[
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
            ),
            padding: EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                children: [
                  TextSpan(
                    text: "${LanguageService.get("engineer_remarks")}: ",
                    style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: engineerRemark ?? "N/A", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaCard(BuildContext context, TicketDetailsViewModel model) {
    final mediaList = model.ticketDetails?.ticketDetails?.media ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaList.isEmpty) ...[
          SizedBox(),
        ] else ...[
          Text(LanguageService.get('photos_video'), style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400)),
          SizedBox(height: 10),

          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return Container(
                  width: 103,
                  height: 75,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                    color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                  ),
                  padding: EdgeInsets.all(10),
                  child: _buildMediaItemFromApi(context, media),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWarrantyInfoCard(BuildContext context, TicketDetailsViewModel model) {
    final customerMachineDetails = model.ticketDetails?.customerMachineDetails;

    final purchaseDate = customerMachineDetails?.purchaseDate != null ? model.formatDate(customerMachineDetails!.purchaseDate) : 'N/A';
    final installationDate = customerMachineDetails?.installationDate != null ? model.formatDate(customerMachineDetails!.installationDate) : 'N/A';
    final warrantyStart = customerMachineDetails?.warrantyStart != null ? model.formatDate(customerMachineDetails!.warrantyStart) : 'N/A';
    final warrantyEnd = customerMachineDetails?.warrantyEnd != null ? model.formatDate(customerMachineDetails!.warrantyEnd) : 'N/A';
    final warrantyStatus = customerMachineDetails?.warrantyStatus ?? 'Unknown';
    final invoiceContractNo = customerMachineDetails?.invoiceContractNo ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInfoRow(AppImages.purchaseDate, 'purchase_date'.lang, purchaseDate, AppColors.colorF2A22E)),
            SizedBox(width: 14),
            Expanded(child: _buildInfoRow(AppImages.installationDate, 'installation_date'.lang, installationDate, AppColors.colorFF6868)),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGrey),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInfoRow(AppImages.warrantyDate, 'warranty_start'.lang, warrantyStart, AppColors.primarySuperLight)),
            SizedBox(width: 14),
            Expanded(child: _buildInfoRow(AppImages.warrantyDate, 'warranty_end'.lang, warrantyEnd, AppColors.primarySuperLight)),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGrey),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.warrantyStatus,
                'warranty_status'.lang,
                model.getWarrantyStatusColor(warrantyStatus),
                AppColors.color41C293,
                valueColor: warrantyStatus.toLowerCase() == 'in warranty' ? AppColors.success : AppColors.redBack,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoRow(AppImages.invoice, 'invoice_contract_no'.lang, invoiceContractNo, AppColors.color41C293)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String iconPath, String label, String value, Color iconColor, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Image.asset(iconPath, width: 20, height: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMediaItemFromApi(BuildContext context, Media media) {
    final imageUrl = '${Configurations().url}${media.url}';
    final url = media.url?.toLowerCase() ?? '';

    final isVideo = url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi') || url.endsWith('.mkv');

    return GestureDetector(
      onTap: () {
        if (isVideo) {
          print('Video URL: $imageUrl');
          Navigator.pushNamed(context, Routes.videoPlayer, arguments: imageUrl);
        } else {
          Navigator.pushNamed(context, Routes.imageViewerView, arguments: imageUrl);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isVideo)
              _buildVideoThumbnail(imageUrl)
            else
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                httpHeaders: {'Connection': 'keep-alive'},
                placeholder:
                    (context, url) => Container(
                      color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                      child: Icon(Icons.error_outline, color: AppColors.textGrey, size: 20),
                    ),
              ),
            if (isVideo)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(child: Icon(Icons.play_circle_filled, color: Colors.white, size: 24)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    return FutureBuilder<String?>(
      future: _generateVideoThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppColors.primarySuperLight.withValues(alpha: 0.1),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: AppColors.primarySuperLight.withValues(alpha: 0.1),
            child: Icon(Icons.videocam, color: AppColors.textGrey, size: 20),
          );
        }

        return Image.file(
          File(snapshot.data!),
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                child: Icon(Icons.videocam, color: AppColors.textGrey, size: 20),
              ),
        );
      },
    );
  }

  Future<String?> _generateVideoThumbnail(String videoUrl) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print('Video thumbnail generation timed out for: $videoUrl');
          return null;
        },
      );
      return thumbnailPath;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  Color _getStatusColorFromString(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.blue;
      case 'resolved':
        return AppColors.white;
      case 'in progress':
        return AppColors.blue;
      case 'waiting for accept':
        return AppColors.yellow;
      case 'rejected':
        return AppColors.red;
      case 'on hold':
        return AppColors.red;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildBottomActionBar(BuildContext context, TicketDetailsViewModel model) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.white,
            child: SizedBox(
              // width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (model.ticketDetails?.ticketDetails?.IsShowChatOption == false || model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "waiting for accept")
                        ? null
                        : () {
                          model.startChat(context);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (model.ticketDetails?.ticketDetails?.IsShowChatOption == false || model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "waiting for accept") ? AppColors.gray : AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v50)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  model.ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved"
                      ? LanguageService.get('see_chat_record')
                      : LanguageService.get('chat_now'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        if (getUser().primaryRole == UserRole.organization && model.ticketDetails?.ticketDetails?.status?.toLowerCase() != "resolved")
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.white,
              child: SizedBox(
                // width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (model.formKey.currentState?.validate() == true) {
                      final _dialogService = locator<DialogService>();
                      await _dialogService.showCustomDialog(
                        variant: DialogType.loader,
                        data: LoaderDialogAttributes(task: () => model.rescheduleTicket(context)),
                      );
                    } else {
                      Fluttertoast.showToast(msg: 'Select Reschedule Time', backgroundColor: Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: model.ticketDetails?.ticketDetails?.status == "On Hold" ? AppColors.gray : AppColors.primaryLight,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v50)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(LanguageService.get('Reschedule'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Shimmer loading methods
  Widget _buildShimmerCustomerInfoCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 18, width: 150, color: AppColors.white),
                SizedBox(height: 4),
                Container(height: 14, width: 120, color: AppColors.white),
              ],
            ),
          ),
          Container(height: 50, width: 1, color: AppColors.textGrey.withValues(alpha: 0.1)),
          SizedBox(width: AppSizes.v10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(height: 12, width: 80, color: AppColors.white),
              SizedBox(height: 4),
              Container(height: 14, width: 60, color: AppColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTicketDetailsCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 120, color: AppColors.white),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDetailItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 12, width: 80, color: AppColors.white),
        SizedBox(height: 4),
        Container(height: 14, width: 60, color: AppColors.white),
      ],
    );
  }

  Widget _buildShimmerProblemDescriptionCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 150, color: AppColors.white),
          SizedBox(height: 8),
          Container(height: 14, width: double.infinity, color: AppColors.white),
          SizedBox(height: 4),
          Container(height: 14, width: 200, color: AppColors.white),
        ],
      ),
    );
  }

  Widget _buildShimmerMediaCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: 100, color: AppColors.white),
          SizedBox(height: 10),
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  width: 103,
                  height: 75,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: AppColors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerWarrantyInfoCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
          SizedBox(height: 10),
          Divider(color: AppColors.lightGrey),
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
          SizedBox(height: 10),
          Divider(color: AppColors.lightGrey),
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 16), Expanded(child: _buildShimmerInfoRow())]),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8))),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 12, width: 80, color: AppColors.white),
              SizedBox(height: 4),
              Container(height: 14, width: 60, color: AppColors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerPaymentCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGrey.withValues(alpha: 0.1),
      highlightColor: AppColors.textGrey.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 20, height: 20, color: AppColors.white),
                      SizedBox(width: 8),
                      Container(height: 16, width: 80, color: AppColors.white),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 14, width: 100, color: AppColors.white), Container(height: 16, width: 80, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGrey.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                ],
              ),
            ),
            Divider(height: 0, color: AppColors.textGrey.withValues(alpha: 0.1)),
            Row(
              children: [
                SizedBox(width: 13),
                Expanded(child: Container(height: 12, width: 100, color: AppColors.white)),
                Container(width: 22, height: 22, color: AppColors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
