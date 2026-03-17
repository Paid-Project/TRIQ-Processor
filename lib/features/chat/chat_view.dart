import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:manager/features/chat/video_chat/demo/call_screen.dart';

import 'package:manager/features/tickets/ticket_details/ticket_details.view.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/widgets/common/custom_dropdown.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/common/common_cached_image.dart';
import 'package:manager/features/chat/chat.vm.dart';
import 'package:manager/features/chat/video_chat/demo/location_service.dart';
import 'package:manager/features/chat/widgets/chat_audio_message_bubble.dart';
import 'package:manager/features/chat/widgets/voice_record_action_button.dart';
import 'package:manager/features/chat/widgets/voice_recording_bar.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../api_endpoints.dart';
import '../../core/locator.dart';
import '../../core/utils/app_logger.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../resources/enums/chat_enum.dart';
import '../../routes/routes.dart';
import '../../services/api.service.dart';
import '../../services/language.service.dart';
import '../stage/widgets/call_requiest_dialog.dart';
import '../tickets/tickets_list/tickets_list.vm.dart' show TicketsListViewModel;
import 'model/chat_message_model.dart';

class ChatView extends StatefulWidget {
  final bool? isVisible;
  final String contactName;
  final String contactNumber;
  final String contactInitials;
  final String? roomId;
  final String? ticketId;
  final String? ticketStatus;
  final String? userRole;
  final String? flag;
  final ChatRoomScreenType? screen;
  final String? updatedAt;
  final Map? incomingCallData;
  const ChatView({
    super.key,
    required this.contactName,
    required this.contactNumber,
    required this.contactInitials,
    this.isVisible = true,
    this.roomId,
    this.ticketId,
    this.flag,
    this.ticketStatus,
    this.userRole,
    this.screen,
    this.updatedAt,
    this.incomingCallData,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  final FocusNode _messageFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final _apiService = locator<ApiService>();
  TicketsListViewModel ticketDetailsViewModel = TicketsListViewModel();
  TextEditingController remarkController = TextEditingController();
  int initCount=0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((v){
      _handleCallRecieve();
    });
  }


  @override
  void dispose() {
    _messageFocusNode.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch(ChatViewModel model) {
    model.toggleSearchMode();

    if (model.isSearchMode) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchFocusNode.unfocus();
    }
  }


  _handleCallRecieve(){
    if(widget.incomingCallData!=null) {
      final data=widget.incomingCallData??{};
      final String? roomId = data['room_id'];
      final String senderName = data['sender_name'] ?? '';
      final String receiverName = data['receiver_name'] ?? '';
      final String? flag = data['flag'];
      final String? profilePic = data['profile_pic'];
      final String? callType = data['callType'];
      final String? token = data['roomToken'];
      final String userId = data['user_id'] ?? '';
      final bool isVoice = callType == 'audio';


      WidgetsBinding.instance.addPostFrameCallback((c) {
        showCallRequestDialog(profile: profilePic ?? '',
            name: senderName,
            call_type: callType ?? '',
            flag: flag ?? '',
            onAccept: () {
              openVideoChat(roomId ?? '', status: 'call-accept',
                  isVoice: isVoice,
                  token: token ?? '',
                  userId: userId,
                  receiverName: receiverName);
            },
            onDecline: () {
              openVideoChat(roomId ?? '', status: 'call-decline',
                  isVoice: isVoice,
                  token: token ?? '',
                  userId: userId,
                  receiverName: receiverName);
            });
      });
    }
  }

  static Future<void> openVideoChat(String roomId,{String status = 'call-request',required bool isVoice,required String token,required String userId,required String receiverName}) async {

    final chatService = locator<ChatService>();
    if(status== 'call-accept'){
      final tokenResponse = await chatService.sendVChatStatus(roomName: roomId, status: status, callType: isVoice ? 'audio' : 'video', name: receiverName, users: userId);
      if(tokenResponse['success']){
        Get.back();
        Get.to(() => VideoCallScreen(roomName: roomId, token: tokenResponse['token'], isVoice: isVoice));
      }

    }
    else if(status== 'call-decline'){
      await chatService.sendVChatStatus(roomName: roomId, status: status, callType: isVoice ? 'audio' : 'video', name: receiverName, users: userId);
      Get.back();
    }


  }

  // Reschedule functionality
  Future<void> rescheduleTicket(
      BuildContext context,
      String ticketId,
      String rescheduleTime,
      ) async
  {

    final body = {'reschedule_time': rescheduleTime};

    final response = await _apiService.put(
      url: "${ApiEndpoints.updateTicket}/$ticketId",
      data: body,
    );

    if (response.statusCode == 200) {
      await ticketDetailsViewModel.loadActiveTickets();
      AppLogger.info(
        'Site visit ticket created successfully: ${response.data['ticket']['_id']}',
      );
      Fluttertoast.showToast(
        msg: response.data["message"] ?? 'Reschedule successfully!',
        backgroundColor: Colors.green,
      );
    } else {
      AppLogger.error('Failed to Reschedule');
      Fluttertoast.showToast(
        msg: 'Failed to Reschedule',
        backgroundColor: Colors.green,
      );
    }
  }


  void _handleResolveAction(ChatViewModel model) {
    // Handle resolve action
    if (widget.ticketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ticket ID available for resolution')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        remarkController.clear();
        return AlertDialog(
          title: Text('Engineer Remark'),
          content: TextField(
            controller: remarkController,
            decoration: InputDecoration(
              hintText: 'Enter your remark',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // String remark = remarkController.text;
                if (remarkController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Enter Your Remark",
                    backgroundColor: Colors.red,
                  );
                } else {
                  Navigator.of(context).pop();

                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {

                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: 400,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon

                              CircleAvatar(
                                backgroundColor: Color(
                                  0xFF7C4DFF,
                                ).withValues(alpha: 0.1),
                                radius: 30,
                                child: Image.asset(AppImages.ticketSummary,height: 30,width: 30,),
                              ),
                              SizedBox(height: 10),

                              // Title
                              Text(
                                'Close This Ticket?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              // Description
                              Text(
                                'Closing this ticket means the customer\'s issue has been successfully resolved.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                              // SizedBox(height: 4),

                              // Question
                              Text(
                                'Are you sure you want to close this ticket?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 10),

                              // Buttons
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Cancel Button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      elevation: 0,
                                      fixedSize: Size(80, 50),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 12),

                                  // Close Ticket Button
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final result = await model.resolveChat(widget.ticketId!, remarkController.text);
                                      if (result == true) {
                                        Get.back(result: true);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      elevation: 0,
                                      fixedSize: Size(150, 50),
                                    ),
                                    child: Text(
                                      'Yes, Close Ticket',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      AppLogger.info('Dialog closed with result');
                      remarkController.clear();
                      if (value == 'cancel') {
                        remarkController.clear();
                      } else if (value == 'close') {
                        remarkController.clear();
                      }
                    } else {
                      AppLogger.info('Dialog closed by barrier dismiss or back button');
                      remarkController.clear();
                    }
                  });
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatViewModel model) {
    return GradientAppBar(
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleWidget: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkGray.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.contactInitials,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,

                ),

              ),
            ),
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded( // ✅ IMPORTANT
                      child: Text(
                        widget.contactName,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // ✅ must
                      ),
                    ),
                    SizedBox(width: AppSizes.w8),
                    Container(
                      width: 20,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: widget.flag != null
                            ? SvgPicture.network(
                          (widget.flag ?? '').prefixWithBaseUrl,
                          fit: BoxFit.cover,
                        )
                            : SizedBox(),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.contactNumber,
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      actions: [
        InkWell(
          child: Image.asset(
            AppImages.search,
            width: 20,
            height: 20,
            color: AppColors.white,
          ),
          onTap: () => _toggleSearch(model),
        ),
        SizedBox(width: 16),
        // PopupMenuButton<String>(
        //   icon: Icon(Icons.more_vert, color: AppColors.white, size: 20),
        //   menuPadding: EdgeInsets.zero,
        //   offset: Offset(-10, 40),
        //   onSelected: (String value) {
        //     if (value == 'resolve') {
        //       _handleResolveAction(model);
        //     }
        //   },
        //   itemBuilder:
        //       (BuildContext context) => [
        //         PopupMenuItem<String>(
        //           value: 'resolve',
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(vertical: 8),
        //             child: Text('Resolve', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        //           ),
        //         ),
        //       ],
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //   color: AppColors.white,
        //   shadowColor: AppColors.black.withValues(alpha: 0.1),
        // ),

        widget.ticketStatus != "Resolved" && widget.userRole == "organization"?
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.white, size: 20),
          menuPadding: EdgeInsets.zero,
          offset: Offset(-10, 40),
          onSelected: (String value) {
            if (value == 'resolve') {
              _handleResolveAction(model);
            }
          },
          itemBuilder:
              (BuildContext context) => [
            // Reschedule Item
            PopupMenuItem<String>(
              value: 'reschedule',
              height: 100,
              child: Container(
                width: 300, // Set consistent width
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      LanguageService.get('reschedule'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Dropdown Field
                    CustomDropdownFormField<String>( // <-- 1. Specify the type
                      value: null,
                      label: LanguageService.get('select_time'),

                      // 2. Convert the 'items' list to DropdownMenuItems
                      items: const [
                        DropdownMenuItem<String>(
                          value: "10",
                          child: Text("10 Min"),
                        ),
                        DropdownMenuItem<String>(
                          value: "15",
                          child: Text("15 Min"),
                        ),
                        DropdownMenuItem<String>(
                          value: "20",
                          child: Text("20 Min"),
                        ),
                        DropdownMenuItem<String>(
                          value: "30",
                          child: Text("30 Min"),
                        ),
                        DropdownMenuItem<String>(
                          value: "45",
                          child: Text("45 Min"),
                        ),
                        DropdownMenuItem<String>(
                          value: "60",
                          child: Text("60 Min"),
                        ),
                      ],
                      onChanged: (value) {
                        rescheduleTicket(
                          context,
                          widget.ticketId ?? "",
                          value ?? "",
                        );
                      },
                      validator: (value) {
                        return value == null
                            ? LanguageService.get('please_select_time')
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
            ),

            // Mark As Resolved Item
            PopupMenuItem<String>(
              value: 'resolve',
              child: Container(
                width: 250, // Match width with reschedule item
                padding: EdgeInsets.only(top: 10, bottom: 10),

                child: Text(
                  'Mark As Resolved',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
          elevation: 8,
        ) :
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.white, size: 20),
          menuPadding: EdgeInsets.zero,
          offset: Offset(-10, 40),
          onSelected: (String value) {
            if (value == 'resolve') {
              _handleResolveAction(model);
            }
            if (value == 'Exit Group') {
              showExitGroupDialog(context);
            }

            if (value == 'Group info') {
              model.navigateToGroupInfoChats();
              // group info open
            }
          },
          itemBuilder:
              (BuildContext context) => [
            // // Reschedule Item
            // PopupMenuItem<String>(
            //   value: 'reschedule',
            //   height: 100,
            //   child: Container(
            //     width: 300, // Set consistent width
            //     padding: EdgeInsets.only(top: 10, bottom: 10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         // Header
            //         Text(
            //           LanguageService.get('reschedule'),
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.w600,
            //             color: AppColors.textPrimary,
            //           ),
            //         ),
            //         SizedBox(height: 5),
            //         // Dropdown Field
            //         CustomDropdownFormField<String>( // <-- 1. Specify the type
            //           value: null,
            //           label: LanguageService.get('select_time'),
            //
            //           // 2. Convert the 'items' list to DropdownMenuItems
            //           items: const [
            //             DropdownMenuItem<String>(
            //               value: "10",
            //               child: Text("10 Min"),
            //             ),
            //             DropdownMenuItem<String>(
            //               value: "15",
            //               child: Text("15 Min"),
            //             ),
            //             DropdownMenuItem<String>(
            //               value: "20",
            //               child: Text("20 Min"),
            //             ),
            //             DropdownMenuItem<String>(
            //               value: "30",
            //               child: Text("30 Min"),
            //             ),
            //             DropdownMenuItem<String>(
            //               value: "45",
            //               child: Text("45 Min"),
            //             ),
            //             DropdownMenuItem<String>(
            //               value: "60",
            //               child: Text("60 Min"),
            //             ),
            //           ],
            //           onChanged: (value) {
            //             rescheduleTicket(
            //               context,
            //               widget.ticketId ?? "",
            //               value ?? "",
            //             );
            //           },
            //           validator: (value) {
            //             return value == null
            //                 ? LanguageService.get('please_select_time')
            //                 : null;
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Divider
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
            ),

            // Mark As Resolved Item
            PopupMenuItem<String>(
              value: 'resolve',
              child: Container(
                width: 250, // Match width with reschedule item
                padding: EdgeInsets.only(top: 10, bottom: 10),

                child: Text(
                  'Mark As Resolved',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Mark As Resolved Item
            PopupMenuItem<String>(
              value: 'Group info',
              child: Container(
                width: 250, // Match width with reschedule item
                padding: EdgeInsets.only(top: 10, bottom: 10),

                child: Text(
                  'Group Info',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Divider
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
            ),
            // Mark As Resolved Item
            PopupMenuItem<String>(
              value: 'Exit Group',

              child: Container(
                width: 250, // Match width with reschedule item
                padding: EdgeInsets.only(top: 10, bottom: 10),

                child: Text(
                  'Exit Group',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
          elevation: 8,
        ),
      ],
    );
  }

  Widget _buildSearchBar(ChatViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: model.searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
          suffixIcon:
          model.searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.gray),
            onPressed: () {
              model.searchController.clear();
              model.clearSearch();
            },
          )
              : null,
        ),
      ),
    );
  }

  Uri? _extractLocationUri(String text) {
    final trimmed = text.trim();
    final match = RegExp(r'https?://maps\.google\.com/\?q=([-0-9.]+),([-0-9.]+)').firstMatch(trimmed);
    if (match != null) {
      return Uri.tryParse(match.group(0)!);
    }

    final liveLocationMatch = RegExp(r'Live location:\s*(https?://maps\.google\.com/\?q=([-0-9.]+),([-0-9.]+))').firstMatch(trimmed);
    if (liveLocationMatch != null) {
      return Uri.tryParse(liveLocationMatch.group(1)!);
    }

    return null;
  }

  Future<void> _openLocationMessage(String text) async {
    final webUri = _extractLocationUri(text);
    if (webUri == null) return;

    try {
      final coordinates = webUri.queryParameters['q']?.split(',');
      final lat = coordinates != null && coordinates.isNotEmpty ? coordinates[0] : null;
      final lng = coordinates != null && coordinates.length > 1 ? coordinates[1] : null;

      if (lat != null && lng != null) {
        final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
        if (await canLaunchUrl(geoUri)) {
          final launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          if (launched) return;
        }
      }

      final launchedWeb = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!launchedWeb) {
        Fluttertoast.showToast(msg: 'Map open nahi ho pa raha.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Map open nahi ho pa raha.');
    }
  }

  Widget _buildMessageText(String text, bool isSentByMe) {
    final locationUri = _extractLocationUri(text);
    final displayText = isSentByMe ? text : text;
    final textWidget = Text(
      displayText,
      style: TextStyle(
        color: isSentByMe ? AppColors.white : AppColors.textPrimary,
        fontSize: AppSizes.f14,
        height: 1.4,
        fontWeight: FontWeight.w400,
        decoration: locationUri != null ? TextDecoration.underline : null,
      ),
    );

    if (locationUri == null) {
      return textWidget;
    }

    return InkWell(
      onTap: () => _openLocationMessage(text),
      child: textWidget,
    );
  }
  Widget _buildHighlightedText(
      String text,
      String searchQuery,
      bool isSentByMe,
      )
  {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: isSentByMe ? AppColors.white : AppColors.textPrimary,
          fontSize: AppSizes.f14,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerSearchQuery = searchQuery.toLowerCase();
    final index = lowerText.indexOf(lowerSearchQuery);

    if (index == -1) {
      return Text(
        text,
        style: TextStyle(
          color: isSentByMe ? AppColors.white : AppColors.textPrimary,
          fontSize: AppSizes.f14,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final baseColor = isSentByMe ? AppColors.white : AppColors.textPrimary;
    final highlightColor = isSentByMe ? AppColors.white : AppColors.primary;
    final highlightBackground =
    isSentByMe
        ? AppColors.white.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.2);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, index),
            style: TextStyle(
              color: baseColor,
              fontSize: AppSizes.f14,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: text.substring(index, index + searchQuery.length),
            style: TextStyle(
              color: highlightColor,
              backgroundColor: highlightBackground,
              fontSize: AppSizes.f14,
              height: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(index + searchQuery.length),
            style: TextStyle(
              color: baseColor,
              fontSize: AppSizes.f14,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: AppSizes.w8),
            Text(
              'Loading more messages...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, ChatViewModel model) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: AppSizes.h2,
                horizontal: AppSizes.w16,
              ),
              child: Row(
                mainAxisAlignment:
                message.isSentByMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message content
                  Flexible(
                    child: Column(
                      crossAxisAlignment:
                      message.isSentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Message bubble
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            onLongPress:
                            message.isDeleted
                                ? null
                                : () {
                              _showMessageOptions(
                                context,
                                message,
                                model,
                              );
                            },
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSizes.v18),
                              topRight: Radius.circular(AppSizes.v18),
                              bottomLeft:
                              message.isSentByMe
                                  ? Radius.circular(AppSizes.v18)
                                  : Radius.circular(0),
                              bottomRight:
                              message.isSentByMe
                                  ? Radius.circular(0)
                                  : Radius.circular(AppSizes.v18),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.w16,
                                vertical: AppSizes.h12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                message.isDeleted
                                    ? (message.isSentByMe
                                    ? AppColors.primaryDark.withValues(
                                  alpha: 0.45,
                                )
                                    : AppColors.lightGrey.withValues(
                                  alpha: 0.5,
                                ))
                                    : message.isSentByMe
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.v18),
                                  topRight: Radius.circular(AppSizes.v18),
                                  bottomLeft:
                                  message.isSentByMe
                                      ? Radius.circular(AppSizes.v18)
                                      : Radius.circular(0),
                                  bottomRight:
                                  message.isSentByMe
                                      ? Radius.circular(0)
                                      : Radius.circular(AppSizes.v18),
                                ),
                                border:
                                message.isDeleted
                                    ? Border.all(
                                  color:
                                  message.isSentByMe
                                      ? AppColors.primaryDark
                                      .withValues(alpha: 0.3)
                                      : AppColors.lightGrey,
                                  width: 1,
                                )
                                    : null,
                              ),
                              child:
                              message.isDeleted
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.block_rounded,
                                    size: 14,
                                    color:
                                    message.isSentByMe
                                        ? AppColors.white
                                        .withValues(alpha: 0.6)
                                        : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'This message was deleted',
                                    style: TextStyle(
                                      color:
                                      message.isSentByMe
                                          ? AppColors.white
                                          .withValues(
                                        alpha: 0.65,
                                      )
                                          : AppColors.textSecondary,
                                      fontSize: AppSizes.f13,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                                  : Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Reply reference (if this message is a reply)
                                  if (message.replyTo != null) ...[
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 6,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                        message.isSentByMe
                                            ? AppColors.white
                                            .withValues(
                                          alpha: 0.15,
                                        )
                                            : AppColors.primaryDark
                                            .withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color:
                                            message.isSentByMe
                                                ? AppColors.white
                                                .withValues(
                                              alpha: 0.6,
                                            )
                                                : AppColors
                                                .primaryDark,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message
                                                .replyTo!
                                                .sender
                                                .fullName,
                                            style: TextStyle(
                                              color:
                                              message.isSentByMe
                                                  ? AppColors.white
                                                  .withValues(
                                                alpha: 0.9,
                                              )
                                                  : AppColors
                                                  .primaryDark,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            message.replyTo!.previewText,
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                              message.isSentByMe
                                                  ? AppColors.white
                                                  .withValues(
                                                alpha: 0.7,
                                              )
                                                  : AppColors
                                                  .textSecondary,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Media attachments (images and videos)
                                  if (message
                                      .attachments
                                      .isNotEmpty) ...[
                                    ...message.attachments.asMap().entries.map((
                                        entry,
                                        ) {
                                      final attachment = entry.value;
                                      if (attachment.type == 'image') {
                                        // Get all image URLs from this message
                                        final imageUrls =
                                        message.attachments
                                            .where(
                                              (att) =>
                                          att.type ==
                                              'image',
                                        )
                                            .map((att) => att.url)
                                            .toList();

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSizes.h8,
                                          ),
                                          child: Hero(
                                            tag:
                                            'chat_image_${attachment.url}',
                                            child: ChatCachedImage(
                                              imageUrl: attachment.url,
                                              width: 200,
                                              height: 200,
                                              borderRadius:
                                              BorderRadius.circular(
                                                AppSizes.v8,
                                              ),
                                              allImageUrls: imageUrls,
                                              imageIndex: imageUrls
                                                  .indexOf(
                                                attachment.url,
                                              ),
                                              messageContent:
                                              message
                                                  .content
                                                  .isNotEmpty
                                                  ? message.content
                                                  : null,
                                            ),
                                          ),
                                        );
                                      } else if (attachment.type ==
                                          'video') {
                                        // Video attachment
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSizes.h8,
                                          ),
                                          child: Hero(
                                            tag:
                                            'chat_video_${attachment.url}',
                                            child:
                                            _buildVideoAttachment(
                                              attachment.url,
                                              message
                                                  .content
                                                  .isNotEmpty
                                                  ? message.content
                                                  : null,
                                              message.isSentByMe,
                                            ),
                                          ),
                                        );
                                      } else if (attachment.isAudio) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSizes.h8,
                                          ),
                                          child: ChatAudioMessageBubble(
                                            messageId: message.id,
                                            attachment: attachment,
                                            isSentByMe: message.isSentByMe,
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }),
                                  ],

                                  // Message text (only show if not empty)
                                  if (message.content.isNotEmpty) ...[
                                    model.isSearchMode
                                        ? _buildHighlightedText(
                                      message.content,
                                      model.searchQuery,
                                      message.isSentByMe,
                                    )
                                        : _buildMessageText(
                                      message.isSentByMe
                                          ? message.content
                                          : message.translatedContent,
                                      message.isSentByMe,
                                    ),
                                  ],

                                  // // Translated text if available
                                  // if (message.content.isNotEmpty) ...[
                                  //   SizedBox(height: AppSizes.h6),
                                  //   Container(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: AppSizes.w8,
                                  //       vertical: AppSizes.h4,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color:
                                  //           message.isSentByMe
                                  //               ? AppColors.white.withValues(
                                  //                 alpha: 0.15,
                                  //               )
                                  //               : AppColors.lightGray
                                  //                   .withValues(alpha: 0.5),
                                  //       borderRadius: BorderRadius.circular(
                                  //         AppSizes.v8,
                                  //       ),
                                  //     ),
                                  //     child: Text(
                                  //       message.content,
                                  //       style: TextStyle(
                                  //         color:
                                  //             message.isSentByMe
                                  //                 ? AppColors.white.withValues(
                                  //                   alpha: 0.9,
                                  //                 )
                                  //                 : AppColors.textSecondary,
                                  //         fontSize: AppSizes.f12,
                                  //         height: 1.3,
                                  //         fontStyle: FontStyle.italic,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 👇 Reactions (WhatsApp style bottom)
                        if (message.reactions.isNotEmpty)
                          Transform.translate(
                            offset: Offset(0, -6),
                            child: Align(
                              alignment:
                              message.isSentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _buildGroupedReactions(
                                    message.reactions,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Timestamp and status
                        Container(
                          margin: EdgeInsets.only(top: AppSizes.h4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                            message.isSentByMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Text(
                                "${_formatTimestamp(message.createdAt)} •",
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: AppSizes.f10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (message.isSentByMe) ...[
                                SizedBox(width: AppSizes.w6),
                                Row(
                                  children: [
                                    _buildMessageStatus(message),
                                    SizedBox(width: AppSizes.w6),
                                    GestureDetector(
                                        onTap: () {
                                          _showRecipientList(message);
                                        },
                                        child: _buildMessageSeenStatus(message)),
                                  ],
                                ),
                              ],
                              // else...[
                              //   SizedBox(width: AppSizes.w6),
                              //   _buildMessageSeenStatus(message)
                              // ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }
  void _showMessageOptions(
      BuildContext context,
      ChatMessageModel message,
      ChatViewModel model,
      )
  {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSizes.h5),
              Center(
                child: SizedBox(
                  width: 80, // 👈 jitna chhota chahiye
                  child: Divider(thickness: 2, color: AppColors.textGrey),
                ),
              ),
              SizedBox(height: AppSizes.h5),

              /// 👇 MESSAGE PREVIEW
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: AppSizes.w16),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.whisperGray,
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
                child: Text(
                  message.previewText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h10),
              // Divider(),
              Align(
                alignment: Alignment.centerLeft,

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.h10),
                  child: Text(
                    "React",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              /// 👇 EMOJI REACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _reactionEmoji("🙏", message, model),
                    _reactionEmoji("👍", message, model),
                    _reactionEmoji("😂", message, model),
                    _reactionEmoji("❤️", message, model),
                    _reactionEmoji("😮", message, model),
                  ],
                ),
              ),

              Divider(),

              _optionTile(Icons.reply, "Reply", () {
                Navigator.pop(context);
                model.setReplyMessage(message);
              }),

              _optionTile(Icons.copy, "Copy", () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                Fluttertoast.showToast(msg: "Copied");
              }),

              if (message.isSentByMe && !message.isDeleted)
                _optionTile(Icons.edit, "Edit", () {
                  Navigator.pop(context);
                  model.editMessage(message);
                }),

              if (message.isSentByMe && !message.isDeleted)
                _optionTile(
                  Icons.delete,
                  "Delete",
                      () {
                    Navigator.pop(context);
                    model.deleteMessage(message.id);
                  },
                  isDestructive: true,
                  showBorder: false,
                ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
  Widget _buildMessageStatus(ChatMessageModel message) {
    Color statusColor;

    switch (message.status) {
      case MessageStatus.sent:
        statusColor = AppColors.textGrey;
        break;
      case MessageStatus.delivered:
      case MessageStatus.read:
        statusColor = AppColors.primary;
        break;
      case MessageStatus.failed:
        statusColor = AppColors.error;
        break;
      case MessageStatus.unknown:
        statusColor = AppColors.textGrey;
        break;
    }

    return Text(
      message.status.name.toUpperCase(),
      style: TextStyle(
        color: statusColor,
        fontSize: AppSizes.f10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMessageSeenStatus(ChatMessageModel message) {


    if(message.readBy.length>1) {
      return SizedBox(
        width: 25,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12.0, color: Colors.blue),
            // Position the second icon slightly offset
            Transform.translate(
              offset: Offset(-8.0, 0.0), // Adjust offset as needed
              child: Icon(Icons.check, size: 12.0, color: Colors.blue),
            ),
          ],
        ),
      );

    } else {
      return
        Text(
          "UNSEEN",
          style: TextStyle(
            fontSize: AppSizes.f10,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  void _showRecipientList(ChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return RecipientListWidget(message: message);
      },
    );
  }

  Widget _buildImagePreview(ChatViewModel model) {
    if (model.hasImagePreview) {
      return _buildMultipleImagePreview(model);
    }
    return const SizedBox.shrink();
  }
  Widget _optionTile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool showBorder = true,
        bool isDestructive = false, // 👈 NEW
      }) {
    final Color textColor = isDestructive ? Colors.red : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration:
        showBorder
            ? BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
        )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Icon(icon, size: 20, color: textColor),
          ],
        ),
      ),
    );
  }

  /// Build grouped reactions (WhatsApp style) - groups same emojis with count
  List<Widget> _buildGroupedReactions(List<Reaction> reactions) {
    // Group reactions by emoji
    final Map<String, int> emojiCounts = {};
    for (var reaction in reactions) {
      emojiCounts[reaction.emoji] = (emojiCounts[reaction.emoji] ?? 0) + 1;
    }

    return emojiCounts.entries.map((entry) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.key, style: TextStyle(fontSize: 14)),
            if (entry.value > 1) ...[
              SizedBox(width: 2),
              Text(
                '${entry.value}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
  Widget _reactionEmoji(
      String emoji,
      ChatMessageModel message,
      ChatViewModel model,
      )
  {

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        model.reactToMessage(message.id, emoji);
      },
      child: Text(emoji, style: TextStyle(fontSize: 20)),
    );
  }
  Widget _buildMultipleImagePreview(ChatViewModel model)
  {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count and clear all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${model.selectedMediaPaths.length} media file${model.selectedMediaPaths.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => model.removeMultipleImagePreviews(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h8),
          // Media grid
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: model.selectedMediaPaths.length,
              itemBuilder: (context, index) {
                final mediaType =
                index < model.selectedMediaTypes.length
                    ? model.selectedMediaTypes[index]
                    : 'image';
                return Container(
                  margin: EdgeInsets.only(right: AppSizes.w8),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                        ),
                        child: Hero(
                          tag:
                          'preview_${mediaType}_${model.selectedMediaPaths[index]}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.v8),
                            child:
                            mediaType == 'video'
                                ? _buildVideoThumbnail(
                              model.selectedMediaPaths[index],
                            )
                                : Image.file(
                              File(model.selectedMediaPaths[index]),
                              fit: BoxFit.cover,
                              errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                  ) {
                                return Container(
                                  color: AppColors.lightGrey.withValues(
                                    alpha: 0.3,
                                  ),
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppColors.textGrey,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Video play icon overlay
                      if (mediaType == 'video')
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppSizes.v8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: AppColors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => model.removeImageFromMultiple(index),
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoAttachment(
      String videoUrl,
      String? messageContent,
      bool isSentByMe,
      ) {
    return GestureDetector(
      onTap: () {
        // Navigate to video player or show video in fullscreen
        _showVideoPlayer(videoUrl);
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.v8),
          color: AppColors.lightGrey.withValues(alpha: 0.3),
        ),
        child: Stack(
          children: [
            // Video thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.v8),
              child: _buildVideoThumbnail(videoUrl),
            ),
            // Play button overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.v8),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            // Message content overlay if available
            if (messageContent != null && messageContent.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSizes.v8),
                      bottomRight: Radius.circular(AppSizes.v8),
                    ),
                  ),
                  child: Text(
                    messageContent,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
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
          // Video thumbnail generation timed out
          return null;
        },
      );
      return thumbnailPath;
    } catch (e) {
      // Error generating video thumbnail
      return null;
    }
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    videoUrl = videoUrl.replaceFirst("http", "https");
    AppLogger.info('Generating video thumbnail');
    return FutureBuilder<String?>(
      future: _generateVideoThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppColors.primarySuperLight.withValues(alpha: 0.1),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: AppColors.primarySuperLight.withValues(alpha: 0.1),
            child: Icon(Icons.videocam, color: AppColors.textGrey, size: 20),
          );
        }

        // Use Image.file with cacheWidth and cacheHeight for memory optimization
        return Image.file(
          File(snapshot.data!),
          width: double.infinity,
          fit: BoxFit.fill,
          cacheWidth: 200,
          cacheHeight: 200,
          errorBuilder:
              (context, error, stackTrace) => Container(
            color: AppColors.primarySuperLight.withValues(alpha: 0.1),
            child: Icon(
              Icons.videocam,
              color: AppColors.textGrey,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  void _showVideoPlayer(String videoUrl) {
    videoUrl = videoUrl.replaceFirst("http", "https");
    Navigator.pushNamed(context, Routes.videoPlayer, arguments: videoUrl);
  }

  Widget _buildTicketStatusMessage(String message, Color color) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }


  Widget _buildMessageInput(ChatViewModel model) {
    final showSendButton =
        (model.messageController.text.trim().isNotEmpty || model.hasImagePreview) &&
            !model.isRecordingAudio;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: model.isRecordingAudio
                    ? VoiceRecordingBar(
                  key: const ValueKey('recording-bar'),
                  duration: model.recordingDuration,
                  cancelProgress: model.recordingCancelProgress,
                  shouldCancel: model.shouldCancelRecording,
                )
                    : Container(
                  key: const ValueKey('message-input'),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.v24),
                    border: Border.all(
                      color: _messageFocusNode.hasFocus
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: CommonTextField(
                    controller: model.messageController,
                    placeholder: 'Write Message',
                    onTapOutside: (event) {},
                    prefixIcon: GestureDetector(
                      onTap: model.toggleAttachment,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          AppImages.attachment,
                          width: 20,
                          height: 20,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: model.pickImageFromCamera,
                          child: Image.asset(
                            AppImages.cameraOutlined,
                            width: 20,
                            height: 20,
                            color: AppColors.textGrey,
                          ),
                        ),
                        SizedBox(width: AppSizes.w12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.w12),
            VoiceRecordActionButton(
              showSendButton: showSendButton,
              isBusy: model.isSendingMessage || model.isUploadingImage,
              isRecording: model.isRecordingAudio,
              onSend: () {
                if (showSendButton) {
                  model.sendMessage();
                }
              },
              onRecordStart: () {
                FocusScope.of(context).unfocus();
                if (model.showAttachment) {
                  model.toggleAttachment();
                }
                model.startAudioRecording();
              },
              onRecordUpdate: (details) {
                model.updateRecordingDrag(details.offsetFromOrigin.dx);
              },
              onRecordEnd: () {
                model.completeRecordingGesture();
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      onViewModelReady: (model) {
        print("1:- ${widget.screen}");
        model.fetchInitialData(roomId1: widget.roomId,screen: widget.screen);

        // Add some sample messages for demonstration
        // model.addSampleMessage();

        // Add listener to text controller for dynamic UI updates
        model.messageController.addListener(() {
          setState(() {
            // This will trigger a rebuild to update the send button appearance
          });
        });
      },
      builder:
          (context, model, child) {

        if(initCount==0) {
          model.ticketDetailsViewModel.currentOpenTicketStatus.value =
              widget.ticketStatus ?? '';
          initCount++;
        }
        return Scaffold(
          appBar: _buildAppBar(context, model),
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(widget.isVisible == true )
                    PendingStatusCard(
                      title: widget.updatedAt ?? "N/A",
                      ticketNumber: widget.contactNumber,
                      status: widget.ticketStatus,
                      child: TicketDetailsView(
                        ticketId: widget.ticketId,
                        isEmbedded: true,
                      ),
                    ),
                  // PendingStatusCard(
                  //   title: widget.updatedAt ?? "N/A",
                  //   ticketNumber: widget.contactNumber,
                  //   status: widget.ticketStatus,
                  //   onToggle: (isExpanded) {
                  //     setState(() {
                  //       model.isTicketDetailsExpanded = isExpanded;
                  //     });
                  //   },
                  // ),
                  if (model.isTicketDetailsExpanded)
                    SizedBox(height: 10,)
                  //   Expanded(
                  //     child: TicketDetailsView(
                  //       ticketId: widget.ticketId,
                  //       isEmbedded: true,
                  //     ),
                  //   )
                  else ...[
                    // Animated search bar
                    SlideTransition(
                      position: _slideAnimation,
                      child:
                      model.isSearchMode
                          ? _buildSearchBar(model)
                          : const SizedBox.shrink(),
                    ),
                    // Messages list
                    Flexible(
                      child:
                      model.isLoading
                          ? ListView.builder(
                        controller: model.scrollController,
                        padding: EdgeInsets.only(top: AppSizes.h8),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return MessageBubbleShimmer(
                            isSentByMe: index % 2 == 0,
                          );
                        },
                      )
                          : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo is ScrollUpdateNotification) {
                            // Check if user scrolled to the bottom (for loading more messages)
                            // Since list is reversed, bottom is where older messages are
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent -
                                    100 &&
                                model.hasMoreMessages &&
                                !model.isLoadingMore) {
                              model.loadMoreMessages();
                            }
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: model.scrollController,
                          reverse: true,
                          padding: EdgeInsets.only(
                            top: AppSizes.h10,
                            bottom: 20,
                          ),
                          itemCount:
                          model.isSearchMode
                              ? model.filteredMessages.length
                              : model.messages.length +
                              1 +
                              (model.isLoadingMore ? 1 : 0),
                          // +1 for loading indicator
                          itemBuilder: (context, index) {
                            // Show loading indicator at the bottom (visually top) when loading more
                            if (!model.isSearchMode &&
                                model.isLoadingMore &&
                                index == 0) {
                              return _buildLoadingIndicator();
                            }

                            // Adjust index for loading indicator
                            final adjustedIndex =
                            model.isLoadingMore ? index - 1 : index;

                            if (!model.isSearchMode &&
                                adjustedIndex == 0) {
                              return SizedBox();
                            }

                            final message =
                            model.isSearchMode
                                ? model
                                .filteredMessages[adjustedIndex]
                                :model.messages.reversed.toList()[adjustedIndex - 1];
                            return _buildMessageBubble(message, model);
                          },
                        ),
                      ),
                    ),
                  ],
                  // Image preview
                  _buildImagePreview(model),
                  // Reply preview bar (WhatsApp style)
                  if (model.replyMessage != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.3),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  model.replyMessage!.sender.fullName,
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  model.replyMessage!.previewText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => model.cancelReply(),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Edit mode banner
                  if (model.isEditMode)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: AppColors.primaryDark,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Editing message',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => model.cancelEdit(),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Message input or status message
                  if (!model.isTicketDetailsExpanded)
                    ValueListenableBuilder<String>(
                      valueListenable: model.ticketDetailsViewModel.currentOpenTicketStatus,

                      builder: (context, status, _) {
                        if (model.chatRoomScreenType == ChatRoomScreenType.groupChat) {
                          return _buildMessageInput(model);
                        }

                        String statusNew = (status == '' ? (widget.ticketStatus ?? '') : model.ticketDetailsViewModel.currentOpenTicketStatus.value).toLowerCase();

                        AppLogger.info('''
                    currentOpenTicketStatus = ${model.ticketDetailsViewModel.currentOpenTicketStatus.value}\n
                    ticketStatus = ${widget.ticketStatus}\n
                    status = $statusNew\n
                    ''');
                        if (statusNew == "resolved") {
                          return SizedBox();
                        }
                        else if (statusNew == "on hold") {
                          return _buildTicketStatusMessage("Ticket is on Hold", AppColors.error);
                        }
                        else if (statusNew == "waiting for accept") {
                          return _buildTicketStatusMessage("Ticket Waiting for Accept", AppColors.warning);
                        }
                        else {
                          return _buildMessageInput(model);
                        }
                      },
                    )
                ],
              ),
              if (model.showAttachment)
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: AttachmentSheet(model: model),
                ),

            ],
          ),
        );
      },
    );
  }
}

class MessageBubbleShimmer extends StatelessWidget {
  final bool isSentByMe;

  const MessageBubbleShimmer({super.key, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment:
                isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Message bubble shimmer
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft:
                        isSentByMe
                            ? const Radius.circular(18)
                            : const Radius.circular(0),
                        bottomRight:
                        isSentByMe
                            ? const Radius.circular(0)
                            : const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 80, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp shimmer
                  Container(height: 10, width: 50, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
class PendingStatusCard extends StatefulWidget {
  final String title;
  final String? ticketNumber;
  final String? status;
  final Widget? child;
  final ValueChanged<bool>? onToggle;

  const PendingStatusCard({
    super.key,
    required this.title,
    this.ticketNumber,
    this.status,
    this.child,
    this.onToggle,
  });

  @override
  State<PendingStatusCard> createState() => _PendingStatusCardState();
}

class _PendingStatusCardState extends State<PendingStatusCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _isResolved => widget.status?.toLowerCase() == 'resolved';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:
        _isResolved
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (widget.onToggle != null) {
                widget.onToggle!(_isExpanded);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Status text
                  Expanded(
                    child:
                    _isResolved
                        ? Text(
                      widget.title.isNotEmpty && widget.title != "N/A"
                          ? 'Resolved In: ${widget.title}'
                          : 'Resolved',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        : RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Pending Since: ",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: widget.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.child != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: widget.child!,
            ),
        ],
      ),
    );
  }
}
class AttachmentSheet extends StatelessWidget {
  final ChatViewModel model;

  const AttachmentSheet({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.f10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28),bottom: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          /// GRID
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            childAspectRatio: 0.8,
            // childAspectRatio: 0.65,
            // mainAxisSpacing: 12,
            // crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [

              _buildAttachmentMenuItem(
                icon: AppImages.file,
                label: 'File',
                color: AppColors.violetBlue,
                onTap: () {
                  model.toggleAttachmentSelect(false);
                  // Navigator.pop(context);
                  model.pickMultipleMediaFromAlbum();
                },
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.gallery,
                label: 'Album',
                color: AppColors.bluebackground,
                onTap: () {
                  model.toggleAttachmentSelect(false);
                  // Navigator.pop(context);
                  model.pickMultipleMediaFromAlbum();
                },
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.camera,
                label: 'Camera',
                color: AppColors.greenbackground,
                onTap: () {

                  model.toggleAttachmentSelect(false);
                  model.pickImageFromCamera();
                },
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.location,
                label: 'Location',
                color: AppColors.redbackground,
                onTap: () async {
                  if (model.showAttachment) {
                    model.toggleAttachment();
                  }

                  final result = await showModalBottomSheet<_LocationPickerResult>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const _LocationPickerSheet(),
                  );

                  if (result == null) return;

                  await model.sendLocationMessage(
                    latitude: result.latitude,
                    longitude: result.longitude,
                    isLiveLocation: result.isLiveLocation,
                  );
                },
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.video,
                label: 'Video Call',
                color: AppColors.backgroundlightgreen,
                onTap: () {},
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.phone,
                label: 'Voice Call',
                color: AppColors.colorFFB141,
                onTap: () {},
              ),

              _buildAttachmentMenuItem(
                icon: AppImages.microphone,
                label: "Audio",
                color: Colors.deepPurple,
                onTap: () {
                  model.pickAudioFileAndSend();
                },
              ),
            ],
          ),

          // const SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget _buildAttachmentMenuItem({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              color: color,
            ),
          ),

          SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

}

class _LocationPickerResult {
  const _LocationPickerResult({
    required this.latitude,
    required this.longitude,
    this.isLiveLocation = false,
  });

  final double latitude;
  final double longitude;
  final bool isLiveLocation;
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet();

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  Position? _currentPosition;
  bool _hasLocationPermission = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _hasLocationPermission =
          permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse;

      if (!_hasLocationPermission) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Location permission denied.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Location service (GPS) off hai.';
        });
        return;
      }

      final position = await LocationService.getCurrentLocation();

      if (!mounted) return;

      if (position == null) {
        setState(() {
          _isLoading = false;
          _error = 'Location fetch nahi ho pa raha. Phir se try karein.';
        });
        return;
      }

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Location load fail ho gaya. Phir se try karein.';
      });
    }
  }

  void _submit({required bool isLiveLocation}) {
    final position = _currentPosition;
    if (position == null) return;

    Navigator.of(context).pop(
      _LocationPickerResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isLiveLocation: isLiveLocation,
      ),
    );
  }

  String _formatAccuracy() {
    final accuracy = _currentPosition?.accuracy;
    if (accuracy == null) return 'Fetching accuracy';
    return 'Accurate to ${accuracy.toStringAsFixed(0)} meters';
  }

  String _formatCoordinates() {
    final position = _currentPosition;
    if (position == null) return 'Coordinates unavailable';
    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF08111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Row(
                  children: [
                    const Text(
                      'Send location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadLocation,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : _error != null
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off_rounded,
                          color: Colors.white70,
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLocation,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current location',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatCoordinates(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAccuracy(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LocationActionTile(
                      icon: Icons.my_location_rounded,
                      title: 'Send your current location',
                      subtitle: 'Send exact coordinates in chat',
                      onTap: () => _submit(isLiveLocation: false),
                    ),
                    const SizedBox(height: 10),
                    _LocationActionTile(
                      icon: Icons.share_location_rounded,
                      title: 'Share live location',
                      subtitle: 'Send live location link in chat',
                      onTap: () => _submit(isLiveLocation: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationActionTile extends StatelessWidget {
  const _LocationActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0E1B2A),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null ? Colors.white24 : Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void showExitGroupDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,

    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20), // screen margin
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: Icon(
                  Icons.forum_outlined,
                  size: 32,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              /// title
              const Text(
                "Exit Group",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              /// description
              Text(
                "Are you sure you want to exit this group?\n"
                    "You will no longer receive updates or be part of this conversation.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 22),

              /// buttons
              Row(
                children: [

                  /// cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// exit button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // exit group logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0, //
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Yes, Exit Group",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
class RecipientListWidget extends StatefulWidget {
  final ChatMessageModel message;

  const RecipientListWidget({super.key, required this.message});

  @override
  State<RecipientListWidget> createState() => _RecipientListWidgetState();
}

class _RecipientListWidgetState extends State<RecipientListWidget> {

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    //
    // final readUsers = widget.message.readBy;
    // final unreadUsers = widget.message.sentTo
    //     .where((u) => !readUsers.any((r) => r.id == u.id))
    //     .toList();

    // final users = selectedTab == 0 ? unreadUsers : readUsers;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [

            /// drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 10),

            /// header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Recipient List",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40,)
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [

                    _tabButton(
                      // title: "Unread (${unreadUsers.length})",
                      title: "Unread ()",
                      index: 0,
                    ),

                    _tabButton(
                      title: "Read ()",
                      // title: "Read (${readUsers.length})",
                      index: 1,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// user list
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {

                  // final user = users[index];

                  return Container(

                    padding: EdgeInsets.symmetric(horizontal: AppSizes.f8),
                    decoration: BoxDecoration(

                      border: Border(

                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,

                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          "?",
                        ),
                      ),
                      title: Text("Leslie Alexander",style: TextStyle(fontSize: 14,color: AppColors.black),),

                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String title, required int index}) {

    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: selectedTab == 0 ?BorderRadius.horizontal(right: Radius.circular(0),left: Radius.circular(25)):BorderRadius.horizontal(right: Radius.circular(25),left: Radius.circular(0)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



















