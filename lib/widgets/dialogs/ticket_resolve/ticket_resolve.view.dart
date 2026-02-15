import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/ticket_resolve/ticket_resolve.vm.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/models/ticket.dart';
import '../../../resources/app_resources/app_resources.dart';

class TicketResolveDialogAttributes {
  final String ticketId;
  final Function(String) onResolvePressed;
  final Function(String) onRejectPressed;
  final Function closeDialog;

  TicketResolveDialogAttributes({
    required this.ticketId,
    required this.onResolvePressed,
    required this.onRejectPressed,
    required this.closeDialog,
  });
}

class TicketResolveDialog extends StatefulWidget {
  final DialogRequest<TicketResolveDialogAttributes> request;
  final Function(DialogResponse) completer;

  const TicketResolveDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  _TicketResolveDialogState createState() => _TicketResolveDialogState();
}

class _TicketResolveDialogState extends State<TicketResolveDialog> {
  late TicketResolveDialogViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TicketResolveDialogViewModel();
    viewModel.init(widget.request.data!.ticketId);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: viewModel.isLoading
                ? _buildLoadingState()
                : viewModel.ticket == null
                ? _buildErrorState(context)
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTicketDetails(context),
                  ),
                ),
                _buildResolutionForm(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSizes.v24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.h16),
          Text(
           LanguageService.get("loading_ticket_details"),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.v24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          SizedBox(height: AppSizes.h16),
          Text(
            LanguageService.get("failed_load_ticket_details"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            LanguageService.get("please_try_again_later"),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.h16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(
              LanguageService.get("Close"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ticket = viewModel.ticket!;
    final status = ticket.status ?? 'Open';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.all(AppSizes.v16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.v16),
          topRight: Radius.circular(AppSizes.v16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${LanguageService.get("resolved_tickets")} #${ticket.ticketId??ticket.id.substring(0, 8) ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SizedBox(height: AppSizes.h8),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w10,
                  vertical: AppSizes.h4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.v16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(status), color: AppColors.white, size: 14),
                    SizedBox(width: AppSizes.w4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.w8),
              if (ticket.createdAt != null)
                Expanded(
                  child: Text(
                    _formatDateDetailed(ticket.createdAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, Ticket ticket) {
    // Get processor info or use a placeholder
    final customerName = ticket.manufacturerInfo?.name ?? 'Unknown Customer';
    final countryCode = _getCountryCode(ticket);

    return Row(
      children: [
        // Country Flag
        Container(
          width: AppSizes.w40,
          height: AppSizes.w30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v4),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.v4),
            child:
            countryCode.isNotEmpty
                ? Image.asset(
              'assets/flags/$countryCode.png',
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                Icons.flag_outlined,
                color: AppColors.primary,
              ),
            )
                : Icon(Icons.flag_outlined, color: AppColors.primary),
          ),
        ),
        SizedBox(width: AppSizes.w12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (ticket.processorInfo?.email != null)
                Text(
                  ticket.processorInfo!.email!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primary.withValues(alpha: 0.8)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCountryCode(Ticket ticket) {
    // This is a placeholder - You'd need to implement the actual logic
    // to extract country code from your data model
    return 'in'; // Default to India for this example
  }



  Widget _buildTicketDetails(BuildContext context) {
    final ticket = viewModel.ticket!;

    return Container(
      padding: EdgeInsets.all(AppSizes.v16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfo(context, ticket),
          SizedBox(height: AppSizes.h12),
          _buildInfoSection(
            context,
            title: LanguageService.get("issue_information"),
            children: [
              _buildInfoItem(
                context,
                label: LanguageService.get("title"),
                value: ticket.title ?? LanguageService.get("no_title"),
                icon: Icons.title,
              ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label: LanguageService.get("description"),
                value: ticket.description ?? LanguageService.get("no_description"),
                icon: Icons.description_outlined,
                isMultiLine: true,
              ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label:LanguageService.get("type"),
                value: ticket.ticketType ?? LanguageService.get("no_type"),
                icon: Icons.category_outlined,
              ),
            ],
          ),

          SizedBox(height: AppSizes.h16),

          _buildInfoSection(
            context,
            title: LanguageService.get("machine_information"),
            children: [
              _buildInfoItem(
                context,
                label: LanguageService.get("machine"),
                value: ticket.machine?.machineName ?? LanguageService.get("no_machine"),
                icon: Icons.precision_manufacturing_outlined,
              ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label: LanguageService.get("model_number"),
                value: ticket.machine?.modelNumber ?? LanguageService.get("no_model_number"),
                icon: Icons.numbers_outlined,
              ),
            ],
          ),

          SizedBox(height: AppSizes.h16),

          // Attachments Section
          if (ticket.attachments != null && ticket.attachments!.isNotEmpty)
            _buildInfoSection(
              context,
              title: LanguageService.get("attachments"),
              children: [
                SizedBox(
                  height: AppSizes.h120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ticket.attachments!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: AppSizes.w8),
                        width: AppSizes.h120,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                          child: CachedNetworkImage(
                            imageUrl: ticket.attachments![index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey,
                              child: Icon(
                                Icons.attachment,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResolutionForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.v16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.v16),
          bottomRight: Radius.circular(AppSizes.v16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resolve Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:()=> onResolved(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                    disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
                  ),
                  child: viewModel.isSubmitting
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: AppSizes.w8),
                      Text(
                        LanguageService.get("mark_as_resolved"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSizes.w12),
              TextButton(
                onPressed: ()=>onRejected(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(
                  LanguageService.get("cancel")
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onResolved(BuildContext context) {
    final onResolvePressed = widget.request.data!.onResolvePressed;
    onResolvePressed.call(widget.request.data!.ticketId);
    Navigator.of(context).pop();
  }


  void onRejected(BuildContext context) {
    final onRejectPressed = widget.request.data!.onRejectPressed;
    onRejectPressed.call(widget.request.data!.ticketId);
    Navigator.of(context).pop();
  }

  Widget _buildInfoSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppSizes.h8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.v12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.v12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      BuildContext context, {
        required String label,
        required String value,
        required IconData icon,
        bool isMultiLine = false,
        Color? valueColor,
      }) {
    return Row(
      crossAxisAlignment:
      isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.v6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.v8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        SizedBox(width: AppSizes.w12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSizes.h2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: isMultiLine ? FontWeight.normal : FontWeight.w500,
                ),
                maxLines: isMultiLine ? 5 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for detailed date formatting
  String _formatDateDetailed(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Color and icon methods for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.info;
      case 'in progress':
        return AppColors.primary;
      case 'pending':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.darkGray;
      default:
        return AppColors.gray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.fiber_new;
      case 'in progress':
        return Icons.engineering;
      case 'pending':
        return Icons.hourglass_empty;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.archive;
      default:
        return Icons.help_outline;
    }
  }
}