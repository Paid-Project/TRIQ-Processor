import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/models/ticket.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/helpers/helpers.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../country_flag/country_helper.dart';

class TicketDetailsDialogAttributes {
  final Ticket ticket;
  final Future Function(String)? onResolvePressed;
  final Function(String, String)? onHoldPressed;
  final Function(String)? onChatPressed;

  final Function(String) onRequestResolvePressed;
  final Function(String) navigateToImageViewer;

  TicketDetailsDialogAttributes({
    required this.ticket,
    this.onResolvePressed,
    this.onHoldPressed,
    this.onChatPressed,
    required this.navigateToImageViewer,
    required this.onRequestResolvePressed,
  });
}

class TicketDetailsDialog extends StatefulWidget {
  final DialogRequest<TicketDetailsDialogAttributes> request;
  final Function(DialogResponse) completer;

  const TicketDetailsDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  _TicketDetailsDialogState createState() => _TicketDetailsDialogState();
}

class _TicketDetailsDialogState extends State<TicketDetailsDialog> {
  String? _selectedHoldOption;

  // Predefined hold duration options
  final List<String> _holdDurations = [
    '15 Mins',
    '30 Mins',
    '1 Hour',
    '2 Hours',
    '5 Hours',
    '10 Hours',
    '12 Hours',
    '1 Day',
  ];

  @override
  Widget build(BuildContext context) {
    final ticket = widget.request.data!.ticket;
    final onHoldPressed = widget.request.data!.onHoldPressed;
    final onChatPressed = widget.request.data!.onChatPressed;
    final onRequestResolvePressed = widget.request.data!.onRequestResolvePressed;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, ticket),
            Expanded(
              child: SingleChildScrollView(
                child: _buildTicketDetails(context, ticket),
              ),
            ),

            // if(ticket.status == 'Resolved')
              // _buildFooter(context, ticket, onHoldPressed, onChatPressed,onRequestResolvePressed),

            ticket.status != 'Resolved' ?
            _buildFooter(context, ticket, onHoldPressed, onChatPressed,onRequestResolvePressed) :
            Row(
              children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, DialogResponse(confirmed: true));
                  if (onChatPressed != null) {
                    onChatPressed(ticket.id);
                  }
                },
                icon: Icon(Icons.chat_bubble_outline),
                label: Text(
                  LanguageService.get("see_chat")
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                  padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                ),
              ),
            ),
              ]
            )

          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(BuildContext context, Ticket ticket) {

    return Container(
      padding: EdgeInsets.all(AppSizes.v16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info with Country Flag
          _buildInfoSection(
            context,
            children: [_buildCustomerInfo(context, ticket)],
          ),

          SizedBox(height: AppSizes.h16),

          _buildInfoSection(context,
              title: LanguageService.get("ticket_type"),
              children: [
                _buildInfoItem(
                  context,
                  label: LanguageService.get("type"),
                  value: ticket.ticketType ?? LanguageService.get("not_specified"),
                  icon: Icons.category_outlined,
                ),
              ]),



          // Ticket Pending Timer
          // _buildPendingTimerSection(context, ticket),

          SizedBox(height: AppSizes.h16),

          _buildInfoSection(
            context,
            title: LanguageService.get("issue_information"),
            children: [
              _buildInfoItem(
                context,
                label:LanguageService.get("title"),
                value: ticket.title ??LanguageService.get("not_specified"),
                icon: Icons.title,
              ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label:LanguageService.get("description"),
                value: ticket.description ?? LanguageService.get("not_specified"),
                icon: Icons.description_outlined,
                isMultiLine: true,
              ),
              SizedBox(height: AppSizes.h8),
              // _buildInfoItem(
              //   context,
              //   label: 'Type',
              //   value: ticket.ticketType ?? 'Not specified',
              //   icon: Icons.category_outlined,
              // ),
              _buildErrorWithPhotosSection(context, ticket),
            ],
          ),


          // SizedBox(height: AppSizes.h16),
          //
          // // Error/Problem with Photos
          // _buildErrorWithPhotosSection(context, ticket),

          SizedBox(height: AppSizes.h16),

          _buildInfoSection(
            context,
            title: LanguageService.get("machine_information"),
            children: [
              _buildInfoItem(
                context,
                label: LanguageService.get("machine"),
                value: ticket.machine?.machineName ?? LanguageService.get("not_specified"),
                icon: Icons.precision_manufacturing_outlined,
              ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label: LanguageService.get("model_number"),
                value: ticket.machine?.modelNumber ?? LanguageService.get("not_specified"),
                icon: Icons.numbers_outlined,
              ),
              // SizedBox(height: AppSizes.h8),
              // _buildInfoItem(
              //   context,
              //   label: 'Serial Number',
              //   value: ticket.machine?.serialNumber ?? 'Not specified',
              //   icon: Icons.confirmation_number_outlined,
              // ),
              SizedBox(height: AppSizes.h8),
              _buildInfoItem(
                context,
                label: LanguageService.get("warranty_status"),
                value: _getWarrantyStatus(ticket),
                icon: Icons.verified_outlined,
                valueColor: _getWarrantyStatusColor(_getWarrantyStatus(ticket)),
              ),
            ],
          ),

          SizedBox(height: AppSizes.h16),

          if (getUser().organizationType == OrganizationType.manufacturer && ticket.status != 'Resolved')
            _buildHoldDurationSection(context),
        ],
      ),
    );
  }


  Widget _buildTrailingFlag( String countryCode ) {
    // Get country flag from the relationship's country code
    final String countryFlag = CountryHelper().getCountryFlagFromDialCode(countryCode ?? '+91');
    return Container(
      width: AppSizes.w30,
      height: AppSizes.w30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v8),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      // Use a Center widget with Text instead of CachedNetworkImage
      child: Center(
        child: Text(
          countryFlag,
          style: TextStyle(
            fontSize: AppSizes.v18, // Adjust size as needed
          ),
        ),
      ),
    );
  }

  // Customer Info with Country Flag
  Widget _buildCustomerInfo(BuildContext context, Ticket ticket) {
    // Get processor info or use a placeholder
    final customerName = ticket.processorInfo?.name ?? 'Unknown Customer';
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
                countryCode!.isNotEmpty
                    ? _buildTrailingFlag(countryCode)
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
              // if (ticket.processorInfo?.email != null)
              //   Text(
              //     ticket.processorInfo!.email!,
              //     style: Theme.of(
              //       context,
              //     ).textTheme.bodySmall?.copyWith(color: AppColors.gray),
              //   ),
            ],
          ),
        ),
      ],
    );
  }

  // Pending Timer Section
  Widget _buildPendingTimerSection(BuildContext context, Ticket ticket) {
    bool isResolved = ticket.status == 'Resolved';
    final pendingDuration = !isResolved ?
    _calculatePendingDuration(ticket):
    _calculateClosedDuration(ticket);

    return Container(
      padding: EdgeInsets.all(AppSizes.v12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.v12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: AppColors.warning,
            size: AppSizes.v24,
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isResolved? LanguageService.get("closed_at") : LanguageService.get("ticket_pending"),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  pendingDuration,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Error/Problem with Photos Section
  Widget _buildErrorWithPhotosSection(BuildContext context, Ticket ticket) {
    return _buildInfoSection(
      context,
      title: LanguageService.get("error_problem_details"),
      children: [
        ...List.generate(ticket.additionalInfo?.length ?? 0, (index) {
          return _buildInfoItem(
            context,
            label: ticket.additionalInfo![index].title!,
            value: ticket.additionalInfo![index].description!,
            icon: Icons.error_outline,
            isMultiLine: true,
          );
        }),
        SizedBox(height: AppSizes.h12),
        if (ticket.attachments != null && ticket.attachments!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.get("photos_attachments"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSizes.h8),
              SizedBox(
                height: AppSizes.h120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ticket.attachments!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.request.data?.navigateToImageViewer.call(
                          ticket.attachments![index],
                        );
                      },
                      child: Container(
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
                            placeholder:
                                (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: AppColors.lightGrey,
                                  child: Icon(
                                    Icons.attachment,
                                    color: AppColors.gray,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        else
          Text(
            LanguageService.get("no_photos_attached"),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildHoldDurationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get("reschedule"),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSizes.h8),
        Wrap(
          spacing: AppSizes.w8,
          runSpacing: AppSizes.h8,
          children:
              _holdDurations.map((option) {
                final isSelected = _selectedHoldOption == option;
                return ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.primary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedHoldOption = selected ? option : null;
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: AppColors.white,
                  side: BorderSide(color: AppColors.primary),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    Ticket ticket,
    Function(String, String)? onHoldPressed,
    Function(String)? onChatPressed,
      Function(String) onRequestResolvePressed,
  ) {
    // Check if resolveRequest count is greater than or equal to 3
    bool showDirectResolveButton =
    (ticket.resolveRequest != null && ticket.resolveRequest! >= 3);
    bool canRequestClose = showDirectResolveButton ? true : true;
    String remainingTime = '';
    if (!showDirectResolveButton && ticket.lastPingTime != null) {
      try {
        final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
        final now = DateTime.now();

        // Handle case where lastPingTime might be in the future
        if (lastPingDateTime.isAfter(now)) {
          canRequestClose = false;
          remainingTime = '00:00:30'; // Default to 1 hour if date is invalid
        } else {
          final oneHourAfterPing = lastPingDateTime.add(Duration(seconds: 30));
          canRequestClose = now.isAfter(oneHourAfterPing);

          if (!canRequestClose) {
            final remaining = oneHourAfterPing.difference(now);
            final hours = remaining.inHours;
            final minutes = (remaining.inMinutes % 60).toString().padLeft(
              2,
              '0',
            );
            final seconds = (remaining.inSeconds % 60).toString().padLeft(
              2,
              '0',
            );
            remainingTime = '${hours}Hr:${minutes}Min:${seconds}sec';
          }
        }
      } catch (e) {
        // If parsing fails, allow the request (default behavior)
        canRequestClose = true;
        remainingTime = '0:00:00';
      }
    }
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
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, DialogResponse(confirmed: true));
                    if (onChatPressed != null) {
                      onChatPressed(ticket.id);
                    }
                  },
                  icon: Icon(Icons.chat_bubble_outline),
                  label: Text((ticket.status == 'OnHold' ? LanguageService.get("resume_chat") : ticket.status == 'Open' ? LanguageService.get("accept") : LanguageService.get("chat")) ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                    padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                  ),
                ),
              ),
              if (getUser().organizationType == OrganizationType.manufacturer)
                SizedBox(width: AppSizes.w12),
              if (getUser().organizationType == OrganizationType.manufacturer)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedHoldOption != null
                            ? () {
                              Navigator.pop(
                                context,
                                DialogResponse(confirmed: true),
                              );
                              if (onHoldPressed != null) {
                                onHoldPressed(ticket.id, _selectedHoldOption!);
                              }
                            }
                            : null,
                    icon: Icon(Icons.pause_circle_outline),
                    label: Text( LanguageService.get("reschedule")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                      disabledBackgroundColor: AppColors.warning.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (getUser().organizationType == OrganizationType.manufacturer && ticket.status == 'InProgress' )
          // Add Resolve button at the bottom
            StatefulBuilder(
              builder: (context, setState) {
                // Create a timer that updates the remaining time every second (only if not showing direct resolve)
                if (!showDirectResolveButton && !canRequestClose) {
                  Timer.periodic(Duration(seconds: 1), (timer) {
                    if (!context.mounted) {
                      timer.cancel();
                      return;
                    }

                    try {
                      final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
                      final now = DateTime.now();
                      final oneHourAfterPing = lastPingDateTime.add(
                        Duration(seconds: 30),
                      );

                      if (now.isAfter(oneHourAfterPing)) {
                        setState(() {
                          canRequestClose = true;
                          remainingTime = '0:00:00';
                        });
                        timer.cancel();
                      } else {
                        final remaining = oneHourAfterPing.difference(now);
                        final hours = remaining.inHours;
                        final minutes = (remaining.inMinutes % 60)
                            .toString()
                            .padLeft(2, '0');
                        final seconds = (remaining.inSeconds % 60)
                            .toString()
                            .padLeft(2, '0');

                        setState(() {
                          remainingTime = '${hours} :${minutes} :${seconds} ';
                        });
                      }
                    } catch (e) {
                      timer.cancel();
                    }
                  });
                }

                return Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.v20),
                      topRight: Radius.circular(AppSizes.v20),
                    ),
                  ),
                  padding: EdgeInsets.only(top:10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (getUser().organizationType ==
                          OrganizationType.manufacturer) ...[
                        // Show different button based on resolveRequest count
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            canRequestClose
                                ? () async {
                              // if (showDirectResolveButton) {
                                // Direct resolve functionality
                                Navigator.pop(context, DialogResponse());
                                widget.request.data!.onResolvePressed!(ticket.id);
                              // } else {
                              //   // Request resolve functionality
                              //   widget.request.data!.onRequestResolvePressed(ticket.id);
                              //   Navigator.pop(context, DialogResponse());
                              // }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              canRequestClose
                                  ? (showDirectResolveButton
                                  ? Colors.green
                                  : AppColors.primary)
                                  : AppColors.gray,
                              disabledBackgroundColor: AppColors.darkGray,
                              padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.v12),
                              ),
                            ),
                            child: Text(
                              // showDirectResolveButton ?
                              LanguageService.get("resolve_ticket"),
                                  // : (canRequestClose
                                  // ? 'Send request To close the ticket'
                                  // : 'Wait to close ticket')
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Show a timer indicator if the button is disabled
                        if (!showDirectResolveButton && !canRequestClose)
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: AppColors.primary.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${LanguageService.get("time_remaining")}: $remainingTime',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Show explanation if direct resolve button is displayed
                        if (showDirectResolveButton)
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      LanguageService.get("multiple_resolution_requests"),
                                        style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Ticket ticket) {
    final status = ticket.status ?? 'Open';
    final statusColor = _getStatusColor(status);
    bool isResolved = ticket.status == 'Resolved';
    final pendingDuration = !isResolved ?
    _calculatePendingDuration(ticket):
    _calculateClosedDuration(ticket);

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
                  '${LanguageService.get("ticket")} #${ticket.ticketId ?? ticket.id.substring(0, 8) ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.v18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.white),
                onPressed: () {
                  Navigator.pop(context, DialogResponse());
                },
              ),
            ],
          ),
          SizedBox(height: AppSizes.h8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Icon(
                      _getStatusIcon(status),
                      color: AppColors.white,
                      size: 14,
                    ),
                    SizedBox(width: AppSizes.w4),
                    Text(
                      formatStatus(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Creation date with a more visible format
              if (ticket.createdAt != null)
                Expanded(
                  child: Text(
                    isResolved ? '${LanguageService.get("resolved_at")}: $pendingDuration' :
                    '${LanguageService.get("Resolved In")}: $pendingDuration',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
      String ? title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (title != null)
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
                  color: AppColors.textSecondary,
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

  // Helper method to get the country code for the processor
  String? _getCountryCode(Ticket ticket) {

    if (ticket.processorInfo?.countryCode != null) {
      return ticket.processorInfo?.countryCode;
    }
    return '+91';
  }

  // Helper method to calculate how long the ticket has been pending
  String _calculatePendingDuration(Ticket ticket) {
    if (ticket.createdAt == null) return 'Unknown';

    try {
      final createdAt = DateTime.parse(ticket.createdAt!);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${LanguageService.get("days")} ${difference.inHours % 24} ${LanguageService.get("hours")}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${LanguageService.get("hours")} ${difference.inMinutes % 60} ${LanguageService.get("minutes")}';
      } else {
        return '${difference.inMinutes} ${LanguageService.get("minutes")}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _calculateClosedDuration(Ticket ticket) {
    if (ticket.completedDate == null) return 'Unknown';

    try {
      return DateFormat('HH:mm, MMM dd').format(ticket.completedDate!);
    } catch (e) {
      return 'Unknown';
    }
  }


  // Helper method to get the warranty status
  String _getWarrantyStatus(Ticket ticket) {
    DateTime? startDate;
    DateTime? endDate;
    if (ticket.machine?.warranty != null) {
      startDate = DateTime.parse(
        ticket.machine?.warranty?.startDate ??
            DateTime.now().toUtc().toIso8601String(),
      );
      endDate = DateTime.parse(
        ticket.machine?.warranty?.expirationDate ??
            DateTime.now().toUtc().toIso8601String(),
      );
    }
    String status = 'N/A';
    if (startDate != null && endDate != null) {
      if (DateTime.now().isAfter(startDate) &&
          DateTime.now().isBefore(endDate)) {
        status = 'active';
      }
      if (endDate.isBefore(DateTime.now())) {
        status = 'expired';
      }
    }
    switch (status.toLowerCase()) {
      case 'active':
        return LanguageService.get("in_warranty");
      case 'n/a':
        return LanguageService.get("not_started");
      case 'expired':
        return LanguageService.get("out_of_warranty");
      default:
        return "N/A";
    }
  }

  // Helper method to get color for warranty status
  Color _getWarrantyStatusColor(String status) {
    if (status.toLowerCase().contains('under warranty')) {
      return AppColors.success;
    } else if (status.toLowerCase().contains('expired') ||
        status.toLowerCase().contains('out of warranty')) {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    if (duration.inHours >= 24) {
      return '${duration.inDays}d';
    } else {
      return '${duration.inHours}h';
    }
  }

  // Helper method for relative time
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Helper method for detailed date and time
  String _formatDateDetailed(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yy - HH:mm').format(dateTime);
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
