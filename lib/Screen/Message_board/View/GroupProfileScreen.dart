import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../Model/AddGroupMemberModel.dart';
import '../Model/ChatUserListModel.dart';
import '../Model/DeleteGroupModel.dart';
import '../Model/GetGroupListModel.dart';
import '../Model/GroupProfileModel.dart';
import '../Model/RemoveGroupMemberModel.dart';
import '../Provider/messsage_board_provider.dart';
import 'messageboard.dart';

class GroupProfileScreen extends StatefulWidget {
  final String groupName;
  final String? groupImage;
  final String groupid;

  const GroupProfileScreen({
    Key? key,
    required this.groupName,
    this.groupImage,
    required this.groupid,
  }) : super(key: key);

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  bool isSending = false;
  bool isLoading = false;

  List<String> selectedMembers = [];
  List<String> existingMembers = [];
  List<String> requestedMembers = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getmembersapi().then((_) {
      listconciergerapi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Group Info",
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: AppConstants.manrope,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          isLoading
              ? Loader().paddingOnly(top: 5.h)
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Center(
                      child: CircleAvatar(
                        radius: 35.sp,
                        backgroundImage:
                            widget.groupImage != null &&
                                    widget.groupImage!.isNotEmpty
                                ? NetworkImage(widget.groupImage!)
                                : AssetImage("assets/images/waveeLogoShort.png")
                                    as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Center(
                      child: Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Center(
                      child: Text(
                        "${groupprofileModel?.data?.length ?? 0} Members",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          child: batan(
                            title: "Add Members",
                            route: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String groupNameError = "";
                                  String memberSelectionError = "";
                                  final ScrollController
                                  dialogScrollController = ScrollController();
                                  final ScrollController listScrollController =
                                      ScrollController();
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxHeight:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.8,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: SingleChildScrollView(
                                            keyboardDismissBehavior:
                                                ScrollViewKeyboardDismissBehavior
                                                    .onDrag,
                                            controller: dialogScrollController,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.group_add,
                                                      color:
                                                          AppColors.maincolor,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      'Add New Members',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 1.5.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Select Members',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${selectedMembers.length} selected',
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 0.8.h),
                                                Container(
                                                  height: 32.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Scrollbar(
                                                    thumbVisibility: true,
                                                    controller:
                                                        listScrollController,
                                                    radius: Radius.circular(8),
                                                    thickness: 4,
                                                    child:
                                                        chatuserlistmodel
                                                                        ?.data
                                                                        ?.length ==
                                                                    null ||
                                                                chatuserlistmodel
                                                                        ?.data
                                                                        ?.length ==
                                                                    0
                                                            ? Center(
                                                              child: Text(
                                                                "No users available",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade600,
                                                                ),
                                                              ),
                                                            )
                                                            : ListView.separated(
                                                              controller:
                                                                  listScrollController,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              itemCount:
                                                                  chatuserlistmodel
                                                                      ?.data
                                                                      ?.length ??
                                                                  0,
                                                              separatorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                  ) => Divider(
                                                                    height: 1,
                                                                    thickness:
                                                                        0.5,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade200,
                                                                  ),
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                final user =
                                                                    chatuserlistmodel
                                                                        ?.data?[index];
                                                                final memberId =
                                                                    user?.id
                                                                        .toString() ??
                                                                    "";

                                                                final isExistingMember =
                                                                    existingMembers
                                                                        .contains(
                                                                          memberId,
                                                                        );
                                                                final isRequestedMember =
                                                                    requestedMembers
                                                                        .contains(
                                                                          memberId,
                                                                        );

                                                                final isSelected =
                                                                    selectedMembers
                                                                        .contains(
                                                                          memberId,
                                                                        ) ||
                                                                    isExistingMember ||
                                                                    isRequestedMember;

                                                                print(
                                                                  "existingMembers: $existingMembers",
                                                                );
                                                                print(
                                                                  "requestedMembers: $requestedMembers",
                                                                );

                                                                return CheckboxListTile(
                                                                  tileColor:
                                                                      Colors
                                                                          .transparent,
                                                                  value:
                                                                      isSelected,
                                                                  onChanged:
                                                                      (isExistingMember ||
                                                                              isRequestedMember)
                                                                          ? null
                                                                          : (
                                                                            selected,
                                                                          ) {
                                                                            setState(() {
                                                                              if (selected ==
                                                                                  true) {
                                                                                selectedMembers.add(
                                                                                  memberId,
                                                                                );
                                                                              } else {
                                                                                selectedMembers.remove(
                                                                                  memberId,
                                                                                );
                                                                              }
                                                                            });
                                                                          },
                                                                  title: Text(
                                                                    "${chatuserlistmodel?.data?[index].user?.firstName ?? ""} ${chatuserlistmodel?.data?[index].user?.lastName ?? "NA"}",
                                                                    style: TextStyle(
                                                                      fontFamily:
                                                                          AppConstants
                                                                              .manrope,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14.sp,
                                                                      color:
                                                                          isExistingMember
                                                                              ? Colors.grey.shade500
                                                                              : Colors.black,
                                                                    ),
                                                                  ),
                                                                  secondary: CircleAvatar(
                                                                    radius: 20,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade200,
                                                                    backgroundImage:
                                                                        null,
                                                                    child: ClipOval(
                                                                      child: CachedNetworkImage(
                                                                        imageUrl:
                                                                            chatuserlistmodel?.data?[index].user?.profile ??
                                                                            "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                                                        placeholder:
                                                                            (
                                                                              context,
                                                                              url,
                                                                            ) => Image.asset(
                                                                              'assets/images/waveeLogoShort.png',
                                                                              fit:
                                                                                  BoxFit.cover,
                                                                            ),
                                                                        errorWidget:
                                                                            (
                                                                              context,
                                                                              url,
                                                                              error,
                                                                            ) => Image.asset(
                                                                              'assets/images/waveeLogoShort.png',
                                                                              fit:
                                                                                  BoxFit.cover,
                                                                            ),
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        fit:
                                                                            BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  subtitle:
                                                                      isRequestedMember
                                                                          ? Text(
                                                                            "Request Pending",
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.orange,
                                                                              fontSize:
                                                                                  12.sp,
                                                                            ),
                                                                          )
                                                                          : null,
                                                                  activeColor:
                                                                      isRequestedMember
                                                                          ? Colors
                                                                              .orange
                                                                          : AppColors
                                                                              .maincolor,

                                                                  checkColor:
                                                                      Colors
                                                                          .white,
                                                                  contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                  dense: true,
                                                                );
                                                              },
                                                            ),
                                                  ),
                                                ),
                                                if (memberSelectionError
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 4,
                                                      left: 4,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        memberSelectionError,
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14.sp,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(height: 2.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    batan(
                                                      title: "Cancel",
                                                      route: () {
                                                        selectedMembers.clear();
                                                        Get.back();
                                                      },
                                                      radius: 3.0.w,
                                                      color:
                                                          AppColors.maincolor,
                                                      fontcolor: Colors.white,
                                                      height: 4.5.h,
                                                      width: 41.w,
                                                      fontsize: 15.5.sp,
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    batan(
                                                      title: "Add Members",
                                                      route: () {
                                                        if (selectedMembers
                                                            .isEmpty) {
                                                          setState(() {
                                                            memberSelectionError =
                                                                "Please select at least one member.";
                                                          });
                                                          return;
                                                        }

                                                        List<String>
                                                        newMembersToAdd =
                                                            selectedMembers
                                                                .where(
                                                                  (memberId) =>
                                                                      !existingMembers
                                                                          .contains(
                                                                            memberId,
                                                                          ),
                                                                )
                                                                .toList();

                                                        for (String memberId
                                                            in newMembersToAdd) {
                                                          groupmemberaddAp(
                                                            memberId,
                                                          );
                                                        }

                                                        selectedMembers.clear();
                                                        getmembersapi();
                                                        Get.back();

                                                        if (newMembersToAdd
                                                            .isNotEmpty) {
                                                          Get.snackbar(
                                                            'Friend Request Sent',
                                                            'Friend request sent to ${selectedMembers}',
                                                            backgroundColor:
                                                                Colors.green
                                                                    .withOpacity(
                                                                      0.7,
                                                                    ),
                                                            colorText:
                                                                Colors.white,
                                                            snackPosition:
                                                                SnackPosition
                                                                    .BOTTOM,
                                                          );
                                                        }
                                                      },
                                                      radius: 3.0.w,
                                                      color:
                                                          AppColors.maincolor,
                                                      fontcolor: Colors.white,
                                                      height: 4.5.h,
                                                      width: 39.w,
                                                      fontsize: 15.sp,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            radius: 3.w,
                            color: AppColors.maincolor,
                            fontcolor: Colors.white,
                            height: 6.h,
                            width: 43.w,
                            fontsize: 15.sp,
                            iconData: Icons.add_circle_outline,
                          ),
                        ),
                        Align(
                          child: batan(
                            title: "Delete Group",
                            route: () {
                              showDeleteConfirmation(context);
                            },
                            radius: 3.w,
                            color: AppColors.maincolor,
                            fontcolor: Colors.white,
                            height: 6.h,
                            width: 42.w,
                            fontsize: 15.sp,
                            iconData1: Icons.delete_forever,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${groupprofileModel?.data?.length ?? 0} Members",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            (groupprofileModel?.data
                                    ?.where(
                                      (member) =>
                                          member.status == "approved" ||
                                          member.status == "accepted",
                                    )
                                    .length ??
                                0),
                        itemBuilder: (context, index) {
                          final acceptedMembers =
                              groupprofileModel?.data
                                  ?.where(
                                    (member) =>
                                        member.status == "approved" ||
                                        member.status == "accepted",
                                  )
                                  .toList() ??
                              [];

                          final member = acceptedMembers[index];

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 0.2.h),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(
                                    horizontal: 0,
                                    vertical: -3,
                                  ),
                                  leading: InkWell(
                                    onTap: () {},
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: member.profile ?? '',
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        placeholder:
                                            (context, url) => CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                            ),
                                        errorWidget:
                                            (
                                              context,
                                              url,
                                              error,
                                            ) => CircleAvatar(
                                              radius: 20,
                                              backgroundImage: AssetImage(
                                                'assets/images/waveeLogoShort.png',
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "${member.firstName ?? ''} ${member.lastName ?? ''}",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      if (member.id != null) {
                                        groupmemberremoveAp(
                                          member.id.toString(),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                              if (index != acceptedMembers.length - 1)
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 0.8,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          if (isSending)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(child: Loader()),
              ),
            ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  "Delete Group",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Are you sure you want to delete this group?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 20),
                Divider(thickness: 1),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(thickness: 1),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            deleteGroupApi();
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: AppColors.maincolor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getmembersapi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().groupMemberApi(
            (widget.groupid).toString(),
          );

          if (response.statusCode == 200) {
            groupprofileModel = GroupProfileModel.fromJson(response.data);

            existingMembers =
                groupprofileModel?.data
                    ?.where(
                      (member) =>
                          member.status == "approved" ||
                          member.status == "accepted",
                    )
                    .map((member) => member.id.toString())
                    .toList() ??
                [];

            requestedMembers =
                groupprofileModel?.data
                    ?.where((member) => member.status == "pending")
                    .map((member) => member.id.toString())
                    .toList() ??
                [];

            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print("error");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  groupmemberremoveAp(String userId) {
    final Map<String, String> data = {
      'user_id': userId,
      'group_id': widget.groupid,
      'status': "",
    };

    print("group remove list parameter : $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().removeGroupMemberApi(data).then((
          response,
        ) async {
          if (response.statusCode == 200) {
            removegroupMemberModel = RemoveGroupMemberModel.fromJson(
              response.data,
            );

            await getmembersapi();
            setState(() {
              groupprofileModel?.data?.removeWhere(
                (member) => member.id == userId,
              );
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  listconciergerapi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().listConciergeApi(
            (loginModel?.data?.user?.id).toString(),
          );

          if (response.statusCode == 200) {
            chatuserlistmodel = ChatUserListModel.fromJson(response.data);
            setState(() {});
          }
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  groupmemberaddAp(String userId) {
    final Map<String, String> data = {
      'user_id': userId,
      'group_id': widget.groupid,
    };

    print("add group member parameter : $data");

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().addGroupMemebrApi(data).then((response) async {
          if (response.statusCode == 200) {
            addgroupMemberModel = AddGroupMemberModel.fromJson(response.data);
          } else {
            print("Failed to add $userId, code: ${response.statusCode}");
            Get.snackbar(
              'Sorry',
              'Faild to add member',
              backgroundColor: Colors.red.withOpacity(0.7),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  deleteGroupApi() async {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().deleteGroupApi(
            widget.groupid.toString(),
            loginModel?.data?.user?.id.toString() ?? "",
          );

          if (response.statusCode == 200) {
            deletegroupModel = DeleteGroupModel.fromJson(response.data);

            setState(() {
              isSending = false;
            });

            Get.snackbar(
              'Sucess',
              'Group delete successfully',
              backgroundColor: Colors.green,
              colorText: Colors.black,
              snackPosition: SnackPosition.BOTTOM,
            );

            Get.to(
              Messageboard(),
              arguments: {"selectedCategory": 1, "selectedLocalSubCategory": 0},
            );
          } else {
            setState(() {
              isSending = false;
            });

            buildErrorDialog(context, 'Error', "Failed to delete group");
          }
        } catch (e) {
          setState(() {
            isSending = false;
          });

          print("error: ${e.toString()}");
          buildErrorDialog(context, 'Error', "Something went wrong");
        }
      } else {
        setState(() {
          isSending = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getgrouplistdAp() {
    final Map<String, String> data = {
      'created_by': (loginModel?.data?.user?.id).toString(),
    };
    print("group list parameter : $data");
    setState(() {
      isSending = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().getGroupApi(data).then((response) async {
          if (response.statusCode == 200) {
            getgrouplistmodel = GetGroupListModel.fromJson(response.data);
            isSending = false;
          } else if (response.statusCode == 429) {
            isSending = false;
          } else {
            isSending = false;
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
