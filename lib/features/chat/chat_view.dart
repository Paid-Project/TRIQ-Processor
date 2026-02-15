import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:manager/features/chat/video_chat/demo/call_screen.dart';
import 'package:manager/features/stage/widgets/call_requiest_dialog.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/widgets/common/custom_dropdown.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/common/common_cached_image.dart';
import 'package:manager/features/chat/chat.vm.dart';
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
import '../tickets/ticket_details/ticket_details.vm.dart';
import '../tickets/tickets_list/tickets_list.vm.dart' show TicketsListViewModel;
import 'model/chat_message_model.dart';

class ChatView extends StatefulWidget {
  final String contactName;
  final String contactNumber;
  final String contactInitials;
  final String? roomId;
  final String? ticketId;
  final String? ticketStatus;
  final String? userRole;
  final String? flag;
  final ChatRoomScreenType? screen;
  final Map? incomingCallData;
  const ChatView({
    super.key,
    required this.contactName,
    required this.contactNumber,
    required this.contactInitials,
    this.roomId,
    this.ticketId,
    this.flag,
    this.ticketStatus,
    this.userRole,
    this.screen,
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
      final String? ticketStatus = data['ticketStatus'];
      final String? ticketId = data['ticketId'];
      String sender_name=data['sender_name'];
      String receiver_name=data['receiver_name'];
      final String? flag = data['flag'];
      final String? profile_pic = data['profile_pic'];
      final String? eventType = data['eventType'];
      final String? callType = data['callType'];
      final String? token = data['roomToken'];
      final String? user_id = data['user_id'];
      bool isVoice=callType=='audio';


      WidgetsBinding.instance.addPostFrameCallback((c) {
        showCallRequestDialog(profile: profile_pic ?? '',
            name: sender_name,
            call_type: callType ?? '',
            flag: flag ?? '',
            onAccept: () {
              openVideoChat(roomId ?? '', status: 'call-accept',
                  isVoice: isVoice,
                  token: token ?? '',
                  userId: user_id ?? '',
                  receiver_name: receiver_name);
            },
            onDecline: () {
              openVideoChat(roomId ?? '', status: 'call-decline',
                  isVoice: isVoice,
                  token: token ?? '',
                  userId: user_id ?? '',
                  receiver_name: receiver_name);
            });
      });
    }
  }

  static Future<void> openVideoChat(String roomId,{String status = 'call-request',required bool isVoice,required String token,required String userId,required String receiver_name}) async {

    final _chatService=locator<ChatService>();
    if(status== 'call-accept'){
      final tokenResponce = await _chatService.sendVChatStatus(roomName: roomId, status: status, callType: isVoice?'audio':'video', name: receiver_name, users: userId);
      if(tokenResponce['success']){
        Get.back();
        Get.to(() => VideoCallScreen(roomName: roomId, token: tokenResponce['token'], isVoice: isVoice));
      }

    }
    else if(status== 'call-decline'){
      final tokenResponce = await _chatService.sendVChatStatus(roomName: roomId, status: status, callType: isVoice?'audio':'video', name: receiver_name, users: userId);
      Get.back();
    }


  }

  // Reschedule functionality
  Future<void> rescheduleTicket(
    BuildContext context,
    String ticketId,
    String rescheduleTime,
  ) async {

    final body = {'reschedule_time': rescheduleTime};

    final response = await _apiService.put(
      url: "${ApiEndpoints.updateTicket}/${ticketId ?? ""}",
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

  void _handleAttachmentAction(String action, ChatViewModel model) {
    // Handle different attachment actions
    switch (action) {
      case 'file':
        model.pickMultipleMediaFromAlbum();
        break;
      case 'gallery':
        // Handle multiple album selection (images and videos)
        model.pickMultipleMediaFromAlbum();
        break;
      case 'camera':
        // Handle camera - add single image to multiple selection
        model.pickImageFromCamera();
        break;
      case 'location':
        // Handle location sharing
        break;
      case 'video_call':
        // model.openVideoChat();
        break;
      case 'voice_call':
        // model.openAudioChat();
        break;
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
                                ).withOpacity(0.1),
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
                      print('Dialog closed with result: $value');
                      remarkController.clear();
                      if (value == 'cancel') {
                        remarkController.clear();
                      } else if (value == 'close') {
                        remarkController.clear();
                      }
                    } else {
                      print('Dialog closed by barrier dismiss or back button');
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.contactName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                      child: widget.flag!=null?SvgPicture.network((widget.flag??'').prefixWithBaseUrl, fit: BoxFit.cover):SizedBox(),
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
        ) : SizedBox.shrink(),
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

  Widget _buildHighlightedText(
    String text,
    String searchQuery,
    bool isSentByMe,
  ) {
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
                            onTap: () {
                              // Handle message tap (e.g., show options, copy text, etc.)
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
                                    message.isSentByMe
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
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Media attachments (images and videos)
                                  if (message.attachments.isNotEmpty) ...[
                                    ...message.attachments.asMap().entries.map((
                                      entry,
                                    ) {
                                      final attachment = entry.value;
                                      if (attachment.type == 'image') {
                                        // Get all image URLs from this message
                                        final imageUrls =
                                            message.attachments
                                                .where(
                                                  (att) => att.type == 'image',
                                                )
                                                .map((att) => att.url)
                                                .toList();

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSizes.h8,
                                          ),
                                          child: Hero(
                                            tag: 'chat_image_${attachment.url}',
                                            child: ChatCachedImage(
                                              imageUrl: attachment.url,
                                              width: 200,
                                              height: 200,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppSizes.v8,
                                                  ),
                                              allImageUrls: imageUrls,
                                              imageIndex: imageUrls.indexOf(
                                                attachment.url,
                                              ),
                                              messageContent:
                                                  message.content.isNotEmpty
                                                      ? message.content
                                                      : null,
                                            ),
                                          ),
                                        );
                                      } else if (attachment.type == 'video') {
                                        // Video attachment
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSizes.h8,
                                          ),
                                          child: Hero(
                                            tag: 'chat_video_${attachment.url}',
                                            child: _buildVideoAttachment(
                                              attachment.url,
                                              message.content.isNotEmpty
                                                  ? message.content
                                                  : null,
                                              message.isSentByMe,
                                            ),
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
                                        : Text(
                                      message.isSentByMe?message.content:message.translatedContent,
                                          style: TextStyle(
                                            color:
                                                message.isSentByMe
                                                    ? AppColors.white
                                                    : AppColors.textPrimary,
                                            fontSize: AppSizes.f14,
                                            height: 1.4,
                                            fontWeight: FontWeight.w400,
                                          ),
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
                                    _buildMessageSeenStatus(message)
                                  ],
                                )
                              ]
                              else...[
                                SizedBox(width: AppSizes.w6),
                               // _buildMessageSeenStatus(message)
                              ],
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

  Widget _buildImagePreview(ChatViewModel model) {
    if (model.hasImagePreview) {
      return _buildMultipleImagePreview(model);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMultipleImagePreview(ChatViewModel model) {
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
    print("efef ===> $videoUrl");
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
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.v24),
            border: Border.all(
              color:
                  _messageFocusNode.hasFocus
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: CommonTextField(
            controller: model.messageController,
            placeholder: 'Write Message',
            onTapOutside: (event) {},
            // onFieldSubmitted: (value) => model.sendMessage(),
            prefixIcon: PopupMenuButton<String>(
              onSelected: (value) => _handleAttachmentAction(value, model),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v23),
                side: BorderSide(
                  color: AppColors.textGrey.withValues(alpha: 0.1),
                ),
              ),
              elevation: 0,
              position: PopupMenuPosition.over,
              // offset: Offset(0, -370),
              offset: Offset(0, -180),
              menuPadding: EdgeInsets.zero,
              color: AppColors.white,
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'file',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.file,
                        label: 'File',
                        color: AppColors.violetBlue,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'gallery',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.gallery,
                        label: 'Album',
                        color: AppColors.bluebackground,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'camera',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.camera,
                        label: 'Camera',
                        color: AppColors.greenbackground,
                        onTap: () {},
                      ),
                    ),
                    // PopupMenuDivider(height: 0.5),
                    // PopupMenuItem<String>(
                    //   value: 'location',
                    //   height: 34,
                    //   child: _buildAttachmentMenuItem(
                    //     icon: AppImages.location,
                    //     label: 'Location',
                    //     color: AppColors.redbackground,
                    //     onTap: () {},
                    //   ),
                    // ),
                    // PopupMenuDivider(height: 0.5),
                    // PopupMenuItem<String>(
                    //   value: 'video_call',
                    //   height: 34,
                    //   child: _buildAttachmentMenuItem(
                    //     icon: AppImages.video,
                    //     label: 'Video Call',
                    //     color: AppColors.backgroundlightgreen,
                    //     onTap: () {},
                    //   ),
                    // ),
                    // PopupMenuDivider(height: 0.5),
                    // PopupMenuItem<String>(
                    //   value: 'voice_call',
                    //   height: 34,
                    //   child: _buildAttachmentMenuItem(
                    //     icon: AppImages.phone,
                    //     label: 'Voice Call',
                    //     color: AppColors.colorFFB141,
                    //     onTap: () {},
                    //   ),
                    // ),
                  ],
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
                // Camera button
                GestureDetector(
                  onTap:
                      () => // Handle camera - add single image to multiple selection
                          model.pickImageFromCamera(),
                  child: Image.asset(
                    AppImages.cameraOutlined,
                    width: 20,
                    height: 20,
                    color: AppColors.textGrey,
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                // GestureDetector(
                //   onTap: () {
                //     // Handle voice message
                //   },
                //   child: Image.asset(
                //     AppImages.microphone,
                //     width: 20,
                //     height: 20,
                //     color: AppColors.textGrey,
                //   ),
                // ),
                // SizedBox(width: AppSizes.w12),
                GestureDetector(
                  onTap:
                      (model.isSendingMessage || model.isUploadingImage)
                          ? null
                          : () {
                            // Send message when send button is tapped
                            if (model.messageController.text
                                    .trim()
                                    .isNotEmpty ||
                                model.hasImagePreview) {
                              model.sendMessage();
                            }
                          },
                  child:
                      (model.isSendingMessage || model.isUploadingImage)
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.black,
                              ),
                            ),
                          )
                          : Image.asset(
                            AppImages.send,
                            width: 20,
                            height: 20,
                            color:
                                (model.messageController.text
                                                .trim()
                                                .isNotEmpty ||
                                            model.hasImagePreview) &&
                                        !model.isSendingMessage &&
                                        !model.isUploadingImage
                                    ? AppColors.primaryDark
                                    : AppColors.textGrey.withValues(alpha: 0.5),
                          ),
                ),
                SizedBox(width: AppSizes.w12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentMenuItem({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h12,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.v10),
            ),
            child: Center(
              child: Image.asset(icon, width: 18, height: 18, color: color),
            ),
          ),
          SizedBox(width: AppSizes.w12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.f14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      onViewModelReady: (model) {
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
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                            itemCount:
                                model.isLoading
                                    ? 6
                                    : model.isSearchMode
                                    ? model.filteredMessages.length
                                    : model.messages.length +
                                        1, // +1 for date separator
                            itemBuilder: (context, index) {
                              if (model.isLoading) {
                                // Alternate shimmer sides for variety
                                return MessageBubbleShimmer(
                                  isSentByMe: index % 2 == 0,
                                );
                              }

                              final message =
                                  model.isSearchMode
                                      ? model.filteredMessages[index]
                                      : model.messages[index - 1];
                              return _buildMessageBubble(message, model);
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
                                          1 + // +1 for date separator
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

                                if (!model.isSearchMode && adjustedIndex == 0) {
                                  return SizedBox();
                                }

                                final message =
                                    model.isSearchMode
                                        ? model.filteredMessages[adjustedIndex]
                                        : model.messages[adjustedIndex - 1];
                                return _buildMessageBubble(message, model);
                              },
                            ),
                          ),
                ),
                // Image preview
                _buildImagePreview(model),
                // Message input or status message
                ValueListenableBuilder<String>(
                  valueListenable: model.ticketDetailsViewModel.currentOpenTicketStatus,

                  builder: (context, status, _) {

                    String status_new=(status==''?(widget.ticketStatus??''):model.ticketDetailsViewModel.currentOpenTicketStatus.value).toLowerCase();

                    AppLogger.info('''
                    currentOpenTicketStatus = ${model.ticketDetailsViewModel.currentOpenTicketStatus.value}\n
                    ticketStatus = ${widget.ticketStatus}\n
                    status = $status_new\n
                    ''');
                    if (status_new == "resolved") {
                      return SizedBox();
                    }
                    else if (status_new == "on hold") {
                      return _buildTicketStatusMessage("Ticket is on Hold", AppColors.error);
                    }
                    else if (status_new == "waiting for accept") {
                      return _buildTicketStatusMessage("Ticket Waiting for Accept", AppColors.warning);
                    }
                    else {
                      return _buildMessageInput(model);
                    }
                  },
                )
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
