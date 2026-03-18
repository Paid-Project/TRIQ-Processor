import 'package:flutter/material.dart';
import 'package:manager/features/chat/group_info/add_members/add_members.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
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
        model.init();
      },
      builder:
          (context, model, child) =>
          Scaffold(
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
                            // Container(
                            //   padding: const EdgeInsets.all(6),
                            //   decoration: BoxDecoration(
                            //     color: AppColors.softGray,
                            //     borderRadius: BorderRadius.circular(10),
                            //     border: Border.all(
                            //       color: AppColors.textGrey.withValues(alpha: 0.1),
                            //     ),
                            //   ),
                            //   child:  Image.asset(
                            //     AppImages.arrowRight,
                            //     width: 16,
                            //     height: 16,
                            //     color: AppColors.darkGray,
                            //   ),
                            // ),

                          ],
                        ),

                        // const SizedBox(height: 12),

                        // SizedBox(
                        //   height: 60,
                        //   child: ListView.builder(
                        //       scrollDirection: Axis.horizontal,
                        //       itemCount: 5,
                        //       itemBuilder: (_,i){
                        //         return Container(
                        //           margin: const EdgeInsets.only(right:10),
                        //           width: 70,
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey.shade300,
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //         );
                        //       }),
                        // )
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
                        const ListTile(
                          title: Text("Group Members",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
                          trailing: Icon(Icons.search,color: AppColors.textPrimary,),
                        ),

                        const Divider(),

                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.add)),
                          title: const Text("Add Members",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
                          trailing: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddMembersScreen(),
                              ),
                            );
                          },
                        ),

                        const Divider(),

                        if (model.isDropdownLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (model.employeeLoadError != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              model.employeeLoadError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else if (model.employees.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "No employees found",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.employees.length,
                            itemBuilder: (context, index) {
                              final member = model.employees[index];
                              final subtitleParts = [
                                if ((member.designation?.name ?? '').trim().isNotEmpty)
                                  member.designation!.name!.trim(),
                                if ((member.phone ?? '').trim().isNotEmpty)
                                  member.phone!.trim(),
                              ];

                              return Column(
                                children: [
                                  ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(
                                      member.displayName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: subtitleParts.isEmpty
                                        ? null
                                        : Text(
                                            subtitleParts.join(' | '),
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                  ),
                                  if (index != model.employees.length - 1)
                                    const Divider(height: 5),
                                ],
                              );
                            },
                          ),

                        // _memberTile(false),
                        // _memberTile(true),
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
          ),
    );
  }

  static Widget _memberTile(bool dividers){
    return  Column(
      children: [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text("Leslie Alexander",style: TextStyle(color: AppColors.textPrimary,fontWeight: FontWeight.w600),),
        ),
        dividers == true?SizedBox() :Divider(height:5)
      ],
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

      SizedBox(width: 25),


    ],
  );
}
