import 'package:flutter/material.dart';
import 'package:manager/features/chat/group_info/add_members/add_members.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/widgets/common/common_cached_image.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/dialogs/image_preview/image_preview_dialog.dart';
import 'package:stacked/stacked.dart';

import 'group_info.vm.dart';

class GroupInfoScreen extends StatefulWidget {
  final String? roomId;
  final String contactNumber;
  final String contactName;
  const GroupInfoScreen({super.key, required this.contactName,required this.contactNumber,this.roomId});


  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GroupInfoViewModel>.reactive(
      viewModelBuilder: () => GroupInfoViewModel(),
      onViewModelReady: (model) {
        model.init(rootID: widget.roomId);
      },
      builder: (context, model, child) {
        final imageAttachments =
        model.imageAttachments
            .where((attachment) => attachment.file.url.trim().isNotEmpty)
            .toList(growable: false);
        final imageUrls =
        imageAttachments
            .map((attachment) => attachment.file.url.trim())
            .where((url) => url.isNotEmpty)
            .toList(growable: false);

        return Scaffold(
          backgroundColor: const Color(0xffF5F6F8),

          appBar: _buildAppBar(context),

          body: SingleChildScrollView(
            child: Column(
              children: [

                /// GROUP HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [

                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.forum,size:30),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.contactName,
                              style:  TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Group | ${widget.contactNumber} ",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                      ),

                      /// CALL BUTTON
                      Container(
                        padding:  EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.violetBlue.withAlpha(022),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:  Icon(Icons.call,color:AppColors.violetBlue,size: 20,),
                      ),

                      const SizedBox(width: 10),

                      /// VIDEO BUTTON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bluebackground.withAlpha(022),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:  Icon(Icons.videocam,color: AppColors.bluebackground,size: 20,),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                /// MEDIA SECTION
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon( Icons.image_outlined,size:20),
                              SizedBox(width: 10,),
                              Text(
                                "Media, Docs",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.roomId != null) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.chatMediaScreen,
                                  arguments: widget.roomId,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.softGray,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.textGrey.withValues(alpha: 0.1),
                                ),
                              ),
                              child:  Image.asset(
                                AppImages.arrowRight,
                                width: 16,
                                height: 16,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 12),

                      if (model.isAttachmentsLoading)
                        const SizedBox(
                          height: 84,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (model.attachmentsLoadError != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.softGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            model.attachmentsLoadError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else if (imageUrls.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "No images shared yet",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 84,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageAttachments.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final attachment = imageAttachments[index];

                                return GestureDetector(
                                  onTap: () {
                                    showImagePreviewDialog(
                                      context: context,
                                      imageUrls: imageUrls,
                                      initialIndex: index,
                                    );
                                  },
                                  child: Hero(
                                    tag: 'chat_image_${attachment.file.url}',
                                    child: CommonCachedImage(
                                      imageUrl: attachment.file.url,
                                      width: 84,
                                      height: 84,
                                      borderRadius: BorderRadius.circular(14),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// SWITCHES
                // Container(
                //   color: Colors.white,
                //   child: Column(
                //     children: [
                //       SwitchListTile(
                //         title: const Text("Mute Notification",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
                //         value: false,
                //         onChanged: (v) {},
                //         thumbColor: WidgetStateProperty.all(Colors.grey),
                //         trackColor: WidgetStateProperty.all(Color(0xffE7E7ED)),
                //         trackOutlineColor: WidgetStateProperty.all(AppColors.white),
                //       ),
                //       const Divider(),
                //
                //       // SwitchListTile(
                //       //   title: const Text("Mute Calls"),
                //       //   value: false,
                //       //   onChanged: (v){},
                //       // ),
                //       SwitchListTile(
                //         title:  Text("Mute Calls",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
                //         value: false,
                //         onChanged: (v) {},
                //         thumbColor: WidgetStateProperty.all(Colors.grey),
                //         trackColor: WidgetStateProperty.all(Color(0xffE7E7ED)),
                //         trackOutlineColor: WidgetStateProperty.all(AppColors.white),
                //       ),
                //       const Divider(),
                //     ],
                //   ),
                // ),

                // const SizedBox(height: 10),

                /// CHAT BACKGROUND
                // Container(
                //   color: Colors.white,
                //   child: ListTile(
                //     title: const Text("Chat Backgrounds",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
                //     trailing:    Container(
                //       padding: const EdgeInsets.all(6),
                //       decoration: BoxDecoration(
                //         color: AppColors.softGray,
                //         borderRadius: BorderRadius.circular(10),
                //         border: Border.all(
                //           color: AppColors.textGrey.withValues(alpha: 0.1),
                //         ),
                //       ),
                //       child: Image.asset(
                //         AppImages.arrowRight,
                //         width: 16,
                //         height: 16,
                //         color: AppColors.darkGray,
                //       ),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 10),

                /// MEMBERS
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Divider(),

                      // ─── HEADER ROW ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Group Members",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Search icon / Close icon toggle
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: model.isSearching
                                  ? IconButton(
                                key: const ValueKey('close'),
                                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                                onPressed: model.toggleSearch,
                              )
                                  : IconButton(
                                key: const ValueKey('search'),
                                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                                onPressed: model.toggleSearch,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─── ANIMATED SEARCH FIELD ───
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: model.isSearching
                            ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: TextField(
                            autofocus: true,
                            onChanged: model.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: "Search members...",
                              hintStyle: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: AppColors.softGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),

                      const Divider(),

                      // ─── ADD MEMBERS TILE ───
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.add)),
                        title: const Text(
                          "Add Members",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // trailing: Container(
                        //   width: 32,
                        //   height: 32,
                        //   decoration: BoxDecoration(
                        //     color: AppColors.primary.withValues(alpha: 0.08),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                        // ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddMembersScreen(roomId: widget.roomId),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // ─── MEMBERS LIST ───
                      if (model.isMembersLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (model.membersLoadError != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            model.membersLoadError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else if (model.filteredMembers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              model.isSearching
                                  ? "No members match your search"
                                  : "No members found",
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = model.filteredMembers[index];
                              final subtitleParts = [
                                if (member.email.trim().isNotEmpty) member.email.trim(),
                                if (member.countryCode.trim().isNotEmpty) member.countryCode.trim(),
                              ];

                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.softGray,
                                      child: Text(
                                        (member.fullName.trim().isNotEmpty
                                            ? member.fullName.trim()[0]
                                            : 'U')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      member.fullName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: subtitleParts.isEmpty
                                        ? null
                                        : Text(
                                      subtitleParts.join(' | '),
                                      style: const TextStyle(color: AppColors.textGrey),
                                    ),
                                  ),
                                  if (index != model.filteredMembers.length - 1)
                                    const Divider(height: 5),
                                ],
                              );
                            },
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// LEAVE GROUP
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.logout,color: Colors.red),
                    title: const Text(
                      "Leave The Group",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: widget.roomId == null
                        ? null
                        : () {
                      model.leaveGroup(widget.roomId!);
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

}
PreferredSizeWidget _buildAppBar(BuildContext context, ) {
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.darkGray.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "Group info",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.w12),

      ],
    ),
    titleSpacing: 0,
    actions: [

      SizedBox(width: 50),


    ],
  );
}
