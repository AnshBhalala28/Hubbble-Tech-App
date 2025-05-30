import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/ViewProfile/Model/profile_model.dart';
import 'package:wavee/Screen/ViewProfile/View/viewprofile.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/error_dialog.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import '../../Message_screen/View/messageScreen.dart';
import '../../ViewProfile/Provider/profile_provider.dart';
import '../Model/chat_screen_model.dart';
import '../Provider/chat_screen_provider.dart';

class ChatScreen extends StatefulWidget {
  int? selected;
  int? selectedIndex;

  ChatScreen({super.key, this.selected, this.selectedIndex = 0});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> categories = [
    {"title": "Concierge"},
    {"title": "Business"},
  ];

  // = 0;
  String AppLat = '';
  String AppLon = '';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = true; // Initially show loader
  ChatModel? chatModel;
  final GlobalKey<ScaffoldState> _scaffoldKey_messageboard =
      GlobalKey<ScaffoldState>();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        print("Location services are disabled.");
        isLoading = false; // Stop loader if location is disabled
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          print("Location permission denied.");
          isLoading = false; // Stop loader if permission denied
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        print("Location permissions are permanently denied.");
        isLoading = false; // Stop loader if permanently denied
      });
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();
        print(
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
        );
      });
    }
  }

  // String _formatTime(String dateTimeString) {
  //   try {
  //     DateTime dateTime = DateTime.parse(dateTimeString);
  //     return DateFormat('HH:mm').format(dateTime);
  //   } catch (e) {
  //     return '';
  //   }
  // }
  String _formatTime1(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      DateTime now = DateTime.now();

      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime dateToCompare = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      String time = DateFormat("hh:mm a").format(parsedDate);

      if (dateToCompare == today) {
        return "Today • $time";
      } else if (dateToCompare == yesterday) {
        return "Yesterday • $time";
      } else {
        return "${DateFormat("dd-MM-yyyy").format(parsedDate)} • $time";
      }
    } catch (e) {
      return "N/A";
    }
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    GetProfile();
    ChatApi();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _getCurrentLocation().then((value) {
        ChatApi();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey_messageboard,
      backgroundColor: AppColors.bgcolor,
      drawer: SideMenu(),
      body:
      // isLoading
      //     ? Center(child: CircularProgressIndicator(color: AppColors.maincolor))
      //     :
      WillPopScope(
        onWillPop: () async {
          Get.offAll(
            () => HomeNewPage(
              selected: 1,
              userName: "", // Pass userName if needed
            ),
          );
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 1.h)),
            SliverToBoxAdapter(
              child: Container(
                height: 13.h,
                color: AppColors.bgcolor,
                padding: EdgeInsets.symmetric(vertical: 10),
                // AppBar માટે space
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _scaffoldKey_messageboard.currentState?.openDrawer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 0.5.h),
                                height: 0.4.h,
                                width: 8.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "Chats",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                ViewProfile(id: loginModel?.data?.user?.id),
                              );
                            },
                            child: Container(
                              height: 11.w,
                              width: 11.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 5.w,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    (profileModel?.data?.user?.profile !=
                                                null &&
                                            profileModel!
                                                .data!
                                                .user!
                                                .profile!
                                                .isNotEmpty)
                                        ? CachedNetworkImageProvider(
                                          profileModel!.data!.user!.profile!,
                                        )
                                        : AssetImage(
                                              "assets/images/waveeLogoShort.png",
                                            )
                                            as ImageProvider,
                              ),
                            ).paddingOnly(right: 2.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 8.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w /*vertical: 0.5.h*/,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.selectedIndex = index;
                              });
                            },
                            child: Container(
                              height: 6.h,
                              width: 45.w,
                              padding: EdgeInsets.symmetric(
                                vertical: 1.h,
                                horizontal: 7.w,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                                color:
                                    widget.selectedIndex == index
                                        ? Color(0xFF734F96)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Text(
                                '${categories[index]["title"]} ',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color:
                                      widget.selectedIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search...",
                      hintStyle: TextStyle(
                        fontFamily: AppConstants.manrope,
                        fontSize: 16.sp,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget.selectedIndex == 0
                ? SliverToBoxAdapter(
                  child: Container(
                    // height: 75.h,
                    padding: EdgeInsets.zero,
                    child:
                        isLoading
                            ? Container(
                              margin: EdgeInsets.only(top: 20.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.maincolor,
                                ),
                              ),
                            )
                            : chatModel?.data?.concierges?.length == null ||
                                chatModel?.data?.concierges?.length == 0
                            ? Container(
                              margin: EdgeInsets.only(top: 25.h),
                              child: Center(
                                child: Text(
                                  "No Concierges Available",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                            )
                            : Builder(
                              builder: (context) {
                                List conciergeList =
                                    chatModel?.data?.concierges ?? [];

                                // 🔍 Filtered List based on search query
                                List filteredList =
                                    conciergeList.where((concierge) {
                                      return searchQuery.isEmpty ||
                                          (concierge.firstName
                                                  ?.toLowerCase()
                                                  .contains(
                                                    searchQuery.toLowerCase(),
                                                  ) ??
                                              false) ||
                                          (concierge.lastName
                                                  ?.toLowerCase()
                                                  .contains(
                                                    searchQuery.toLowerCase(),
                                                  ) ??
                                              false);
                                    }).toList();
                                return SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(filteredList.length, (
                                      index,
                                    ) {
                                      var concierge = filteredList[index];

                                      return Container(
                                        height: 11.h,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 0.5.h,
                                          horizontal: 3.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    (concierge.conciergeImage)
                                                        .toString(),
                                                placeholder:
                                                    (context, url) =>
                                                        CircleAvatar(
                                                          radius: 24,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                        ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => CircleAvatar(
                                                      radius: 24,

                                                      child: Image(
                                                        image: AssetImage(
                                                          "assets/images/waveeLogoShort.png",
                                                        ),
                                                      ),
                                                    ),
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              "${concierge.firstName ?? ""} ${concierge.lastName ?? "NA"}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            subtitle: Text(
                                              concierge.lastMessage ??
                                                  'No message available',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            trailing: Column(
                                              children: [
                                                concierge.unreadCount == 0
                                                    ? Container(
                                                      height: 1,
                                                      width: 1,
                                                    )
                                                    : CircleAvatar(
                                                      radius: 13,
                                                      backgroundColor:
                                                          AppColors.maincolor,
                                                      child: ClipOval(
                                                        child: Center(
                                                          child: Text(
                                                            concierge
                                                                .unreadCount
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                SizedBox(height: 0.2.h),
                                                // Text(
                                                //   _formatTime(concierge
                                                //           .lastMessageTime ??
                                                //       "N/A"),
                                                //   style: TextStyle(
                                                //     fontFamily:
                                                //         AppConstants
                                                //             .manrope,
                                                //     color: Colors.black,
                                                //     fontSize: 15.sp,
                                                //   ),
                                                // ),
                                                concierge.lastMessageTime ==
                                                            null ||
                                                        concierge
                                                                .lastMessageTime ==
                                                            ''
                                                    ? SizedBox()
                                                    : Text(
                                                      _formatTime(
                                                        concierge
                                                                .lastMessageTime ??
                                                            "N/A",
                                                      ).replaceFirst(
                                                        ', ',
                                                        '\n',
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        color: Colors.black,
                                                        fontSize: 13.sp,
                                                      ),
                                                    ),
                                              ],
                                            ),
                                            onTap: () {
                                              Get.to(
                                                MessageScreen(
                                                  chatName:
                                                      "${concierge.firstName ?? ''} ${concierge.lastName ?? ''}",
                                                  image:
                                                      concierge.conciergeImage,
                                                  conciergeID:
                                                      concierge.id.toString() ??
                                                      '',
                                                  type: "concierge",

                                                  address:
                                                      concierge.address ??
                                                      'Not Available',
                                                  phone:
                                                      concierge.phoneNumber ??
                                                      'Not Available',
                                                  dob:
                                                      concierge.dateOfBirth ??
                                                      'Not Available',
                                                  email:
                                                      concierge.email ??
                                                      'Not Available',

                                                  // type: concierge.type,
                                                ),
                                              );
                                              log(
                                                "Tapped Concierge ID: ${concierge.id.toString() ?? ''}",
                                              );
                                              ChatApi();
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                  ),
                )
                : SliverToBoxAdapter(
                  child: Container(
                    height: 75.h,
                    padding: EdgeInsets.zero,
                    child:
                        (chatModel?.data?.businessUsers == null ||
                                chatModel?.data?.businessUsers == "" ||
                                chatModel?.data?.businessUsers == 0)
                            ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.maincolor,
                              ),
                            ).paddingOnly(bottom: 2.h)
                            : (chatModel?.data?.businessUsers == null ||
                                chatModel?.data?.businessUsers == "" ||
                                chatModel?.data?.businessUsers == 0)
                            ? Center(
                              child: Text(
                                "No Message available",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ).paddingOnly(bottom: 2.h)
                            : Builder(
                              builder: (context) {
                                List businessUsersList =
                                    chatModel?.data?.businessUsers ?? [];

                                // 🔍 Apply search filter - બિઝનેસ નામ થી સર્ચ
                                List filteredList =
                                    businessUsersList.where((user) {
                                      String businessName =
                                          user.business?.businessName
                                              ?.toLowerCase() ??
                                          "";
                                      String lastMessage =
                                          user.lastMessage?.toLowerCase() ?? "";
                                      String searchQueryLower =
                                          searchQuery.toLowerCase();
                                      return searchQuery.isEmpty ||
                                          businessName.contains(
                                            searchQueryLower,
                                          ) ||
                                          lastMessage.contains(
                                            searchQueryLower,
                                          );
                                    }).toList();

                                if (filteredList.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No Chats found",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(filteredList.length, (
                                      index,
                                    ) {
                                      var user = filteredList[index];
                                      String displayName =
                                          user.business?.businessName ??
                                          "Unknown Business";

                                      return Container(
                                        height: 11.h,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 0.5.h,
                                          horizontal: 3.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    user.business?.logo
                                                        ?.toString() ??
                                                    "",
                                                placeholder:
                                                    (context, url) =>
                                                        CircleAvatar(
                                                          radius: 24,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                        ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => CircleAvatar(
                                                      radius: 24,
                                                      child: Image(
                                                        image: NetworkImage(
                                                          "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                                        ),
                                                      ),
                                                    ),
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              displayName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            subtitle: Text(
                                              user.lastMessage ??
                                                  'No message available',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            trailing: Column(
                                              children: [
                                                user.unreadCount == 0
                                                    ? Container(
                                                      height: 1,
                                                      width: 1,
                                                    )
                                                    : CircleAvatar(
                                                      radius: 13,
                                                      backgroundColor:
                                                          AppColors.maincolor,
                                                      child: ClipOval(
                                                        child: Center(
                                                          child: Text(
                                                            user.unreadCount
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                SizedBox(height: 5),
                                                user.lastMessageTime == null ||
                                                        user.lastMessageTime ==
                                                            ''
                                                    ? SizedBox()
                                                    : Text(
                                                      _formatTime(
                                                        user.lastMessageTime ??
                                                            "0",
                                                      ),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        color: Colors.black,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                              ],
                                            ),
                                            onTap: () {
                                              Get.to(
                                                MessageScreen(
                                                  chatName: displayName,
                                                  image: user.business?.logo,
                                                  conciergeID:
                                                      user.id.toString() ?? '',
                                                  type: "business",
                                                ),
                                              );
                                              log(
                                                "Tapped Business User ID: ${user.id.toString() ?? ''}",
                                              );
                                              ChatApi();
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: Bottom_bar(selected: 2),
    );
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("RegisterApi : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200 && profileModel?.status == 200) {
            print("adfdsfsdf${response.body}");
            print(
              "1111111111>>>>>>>>>>>>  ${profileModel?.data?.user?.profile}",
            );

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            log("Error");
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // void ChatApi() {
  //   setState(() {
  //     isLoading = true;  // API કૉલ શરૂ થતાં પહેલાં isLoading ને true કરો
  //   });
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       ChatProvider()
  //           .ChatApi(loginModel?.data?.user?.id, AppLon, AppLat)
  //           .then((response) async {
  //         chatModel = ChatModel.fromJson(jsonDecode(response.body));
  //         if (response.statusCode == 200) {
  //           print("adfdsfsdf${response.body}");
  //           print(
  //               "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}");
  //           if (mounted) {
  //             setState(() {
  //               isLoading = false;
  //             });
  //           }
  //         } else {
  //           setState(() {
  //             isLoading = false;
  //           });
  //           log("Error");
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }
  void ChatApi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await ChatProvider().ChatApi(
            loginModel?.data?.user?.id,
            AppLon,
            AppLat,
          );

          if (mounted) {
            setState(() {
              chatModel = ChatModel.fromJson(jsonDecode(response.body));
              isLoading = false; // API રિસ્પોન્સ મળ્યા પછી લોડિંગ બંધ કરો
            });
          }

          if (response.statusCode == 200) {
            print("API Response: ${response.body}");
            print("User Profile: ${profileModel?.data?.user?.profile}");
          } else {
            log("Error with status code: ${response.statusCode}");
            log("Response body: ${response.body}");
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false; // એરર આવે તો પણ લોડિંગ બંધ કરો
            });
          }
          log("Exception: $e");
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void ChatApi1() async {
    checkInternet().then((internet) async {
      if (internet) {
        setState(() {
          isLoading = true; // Show loader before API call
        });
        try {
          var response = await ChatProvider().ChatApi(
            loginModel?.data?.user?.id,
            AppLon,
            AppLat,
          );
          chatModel = ChatModel.fromJson(jsonDecode(response.body));

          setState(() {
            isLoading = false; // Hide loader after data is loaded
          });
        } catch (e, stackTrace) {
          // ✅ "stackTrace" catch added correctly
          log("Error ave che: $e");
          log("Stack Trace: $stackTrace"); // ✅ Stack trace logging
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}
