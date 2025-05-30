import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:wavee/Screen/ViewProfile/Model/profile_model.dart';
import 'package:wavee/Screen/ViewProfile/Provider/profile_provider.dart';
import 'package:wavee/Screen/ViewProfile/View/viewprofile.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/SideMenu.dart';
import '../../../comman/bottom_bar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/input_decoration.dart';
import '../../../comman/loader.dart';
import '../../HomeNewPage/Model/message_board_modal.dart';
import '../../HomeNewPage/Provider/homescreen_provider.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import '../../Message_screen/View/messageScreen.dart';
import '../../open_ai_chatbot/view/open_ai_screen.dart';
import '../Model/Add_Post_Model.dart';
import '../Model/ChatUserListModel.dart';
import '../Model/CreateFriendModel.dart';
import '../Model/CreateGroupModel.dart';
import '../Model/GetFriendListModel.dart';
import '../Model/GetGroupListModel.dart';
import '../Model/GetPostCommentsModel.dart';
import '../Model/GetRequestModel.dart';
import '../Model/Localpost_comments_Model.dart';
import '../Model/Localpost_model.dart';
import '../Model/PostLikeModel.dart';
import '../Model/SendPostCommentsModel.dart';
import '../Provider/messsage_board_provider.dart';
import 'GroupChatPage.dart';

class Messageboard extends StatefulWidget {
  int? selected;

  Messageboard({super.key, this.selected});

  @override
  State<Messageboard> createState() => _MessageboardState();
}

TextEditingController _descController = TextEditingController();
final PageController _pageController = PageController();
int _currentPage = 0;

class _MessageboardState extends State<Messageboard> {
  bool isLoading = false;

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  TextEditingController _commentController = TextEditingController();
  List<List<String>> postComments = [[], [], []];
  int? selectedPostIndex;
  List<int> postLikes = [0, 0, 0];
  Set<int> likedPosts = {};
  bool isLiked = false;
  int? selectedLikeIndex;
  bool isAllLiked = false;
  Map<int, bool> likedItems = {};
  List<String> categories = ['Building', 'Local'];
  int selectedCategory = 0;
  final TextEditingController groupNameController = TextEditingController();
  List<String> selectedMembers = [];

  io.File? selectedImage;
  String? imagePath;

  bool isLoadingList = false;
  bool isSending = false;
  bool isSendingComment = false;

  bool isLikeInProgress = false;
  bool isLikeInProgressLocal = false;

  List<bool> isLikedList = [];
  List<bool> isLikedListLocal = [];
  List<bool> isLikeInProgressList = [];
  List<bool> isLikeInProgressListLocal = [];
  ScrollController _scrollController = ScrollController();

  String get currentUserId => loginModel?.data?.user?.id.toString() ?? '';

  List<String> localSubCategories = ['Group', 'Friends'];
  int selectedLocalSubCategory = 0;

  // String? _currentPostId;
  List<dynamic> pendingRequests = [];
  List<String> pendingFriendRequests = [];

  String currentPostId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // જો arguments પ્રાપ્ત થયાં હોય, તો selectedCategory અને selectedLocalSubCategory set કરો.
    if (Get.arguments != null) {
      // Get.arguments એક Map હોવાની ખાતરી કરો અને ત્યાંથી value મેળવો.
      // selectedCategory = Get.arguments['selectedCategory'] ?? selectedCategory;
      // selectedLocalSubCategory =
      //     Get.arguments['selectedLocalSubCategory'] ?? selectedLocalSubCategory;
    }
    setState(() {
      isLoading = true;
    });
    MessageBoardApi();
    GetProfile();
    fetchData();
    listconciergerapi();
    localpostapi();
    setState(() {
      // getgrouplistdAp();
      GetMyJoinGroup();
      getfriendlistdAp();
    });
    loadGroups();
    Future.delayed(Duration(seconds: 2), () {
      _loadAllLikes();
      _loadAllLikesLocal();
    });

    initPendingRequests();
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() {
        isLoading = false; // Once data is fetched, set loading to false
      });
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Future<void> loadGroups() async {
    setState(() {
      isSending = true;
    });

    //   await getgrouplistdAp();
    await GetMyJoinGroup();

    setState(() {
      isSending = false;
    });
  }

  Future<void> _loadAllLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = loginModel?.data?.user?.id.toString() ?? '';

      final totalPosts = messageBoardModal?.data?.length ?? 0;

      // Make sure lists are initialized with proper length
      isLikedList = List.generate(totalPosts, (index) => false);
      isLikeInProgressList = List.generate(totalPosts, (index) => false);

      for (int i = 0; i < totalPosts; i++) {
        if (i < isLikedList.length &&
            messageBoardModal?.data?.length != null &&
            i < messageBoardModal!.data!.length) {
          final postId = messageBoardModal?.data?[i].id.toString();
          if (postId != null) {
            final key = 'image_like_${postId}_$userId';
            isLikedList[i] = prefs.getBool(key) ?? false;
          }
        }
      }
    } catch (e) {
      print("Error loading likes: $e");
    }
  }

  Future<void> _loadAllLikesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = loginModel?.data?.user?.id.toString() ?? '';

      final totalPosts = localpost_model?.data?.length ?? 0;

      // Make sure lists are initialized with proper length
      isLikedListLocal = List.generate(totalPosts, (index) => false);
      isLikeInProgressListLocal = List.generate(totalPosts, (index) => false);

      for (int i = 0; i < totalPosts; i++) {
        if (i < isLikedListLocal.length &&
            localpost_model?.data?.length != null &&
            i < localpost_model!.data!.length) {
          final postId = localpost_model?.data?[i].id.toString();
          if (postId != null) {
            final key = 'image_like_${postId}_$userId';
            isLikedListLocal[i] = prefs.getBool(key) ?? false;
          }
        }
      }
    } catch (e) {
      print("Error loading likes: $e");
    }
  }

  Future<void> _saveLikeStatus(int index, bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${messageBoardModal?.data?[index].id}_$userId';
    await prefs.setBool(key, liked);
  }

  Future<void> _saveLikeStatusLocal(int index, bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${localpost_model?.data?[index].id}_$userId';
    await prefs.setBool(key, liked);
  }

  void handleLikeToggle(
    int index,
    void Function(void Function()) localSetState,
  ) {
    if (isLikeInProgressList[index]) return;

    localSetState(() {
      isLikedList[index] = !isLikedList[index];
      isLikeInProgressList[index] = true;
    });

    _saveLikeStatus(index, isLikedList[index]);

    postslikeap(index, () {
      localSetState(() {
        isLikeInProgressList[index] = false;
      });
    });
  }

  void handleLikeToggleLocal(
    int index,
    void Function(void Function()) localSetState,
  ) {
    if (isLikeInProgressListLocal[index]) return;

    localSetState(() {
      isLikedListLocal[index] = !isLikedListLocal[index];
      isLikeInProgressListLocal[index] = true;
    });

    _saveLikeStatusLocal(index, isLikedListLocal[index]);

    postslikelocalap(index, () {
      localSetState(() {
        isLikeInProgressListLocal[index] = false;
      });
    });
  }

  // Initialize and load pending requests from SharedPreferences
  Future<void> initPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRequests = prefs.getStringList('pendingFriendRequests') ?? [];
    pendingFriendRequests = storedRequests;
    print("Loaded ${pendingFriendRequests.length} pending friend requests");
  }

  // Save pending requests to SharedPreferences
  Future<void> savePendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pendingFriendRequests', pendingFriendRequests);
    print("Saved ${pendingFriendRequests.length} pending friend requests");
  }

  Future<void> checkAcceptedRequests(List<dynamic> friendsList) async {
    bool hasChanges = false;
    List<String> updatedPendingRequests = List.from(pendingFriendRequests);

    // For each pending request, check if it's now in the friends list
    for (String requestId in pendingFriendRequests) {
      bool isNowFriend = friendsList.any(
        (friend) =>
            friend.user?.id.toString() == requestId &&
            friend.status == 'accepted', // Assuming there's a status field
      );

      if (isNowFriend) {
        // Remove from pending if now accepted
        updatedPendingRequests.remove(requestId);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      pendingFriendRequests = updatedPendingRequests;
      await savePendingRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey_messageboard =
        GlobalKey<ScaffoldState>();
    // log("Profile IMage Ave che ${messageBoardModal?.data?[0].user?.conciergeImage ?? 'no link'}");
    return Scaffold(
      bottomNavigationBar: Bottom_bar(selected: 4),
      key: _scaffoldKey_messageboard,
      drawer: SideMenu(),
      body: WillPopScope(
        onWillPop: () async {
          Get.offAll(
            () => HomeNewPage(
              selected: 1,
              userName: "", // Pass userName if needed
            ),
          );
          return false;
        },
        child: Stack(
          children: [
            Container(
              color: AppColors.bgcolor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.2.h, vertical: 1.w),
                child:
                    isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.maincolor,
                          ),
                        )
                        : CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(child: SizedBox(height: 1.h)),

                            // App Bar
                            SliverToBoxAdapter(
                              child: Container(
                                height: 13.h,
                                color: AppColors.bgcolor,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                // AppBar માટે space
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _scaffoldKey_messageboard.currentState
                                              ?.openDrawer();
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
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  vertical: 0.5.h,
                                                ),
                                                height: 0.4.h,
                                                width: 8.w,
                                                decoration: BoxDecoration(
                                                  color: AppColors.maincolor,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                              Container(
                                                height: 0.4.h,
                                                width: 6.w,
                                                decoration: BoxDecoration(
                                                  color: AppColors.maincolor,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Message Board",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // IconButton(
                                          //   icon: Icon(
                                          //     Icons.notifications_none_outlined,
                                          //     color: Colors.black87,
                                          //     size: 22.sp,
                                          //   ),
                                          //   onPressed: () {},
                                          // ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                ViewProfile(
                                                  id:
                                                      loginModel
                                                          ?.data
                                                          ?.user
                                                          ?.id,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 11.w,
                                              width: 11.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                // Circle shape added
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 5,
                                                    offset: Offset(
                                                      0,
                                                      3,
                                                    ), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 5.w,
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage:
                                                    (profileModel
                                                                    ?.data
                                                                    ?.user
                                                                    ?.profile !=
                                                                null &&
                                                            profileModel!
                                                                .data!
                                                                .user!
                                                                .profile!
                                                                .isNotEmpty)
                                                        ? CachedNetworkImageProvider(
                                                          profileModel!
                                                              .data!
                                                              .user!
                                                              .profile!,
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

                            // Main Category Tabs (Building, Local)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 6.h,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Calculate dynamic width based on screen size and number of items
                                    // For 2 tabs with some spacing between them
                                    double itemWidth =
                                        (constraints.maxWidth - 9.w) / 2;

                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (selectedCategory != index) {
                                                setState(() {
                                                  selectedCategory = index;
                                                  // Reset local subcategory to first tab when switching
                                                  selectedLocalSubCategory = 2;
                                                });
                                                //ParselViewApi();
                                              }
                                            },
                                            child: Container(
                                              height: 6.h,
                                              width: itemWidth,
                                              // Dynamic width
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 0.5,
                                                  color: Colors.grey,
                                                ),
                                                color:
                                                    selectedCategory == index
                                                        ? AppColors.maincolor
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2.w,
                                                ),
                                                child: Text(
                                                  categories[index],
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color:
                                                        selectedCategory ==
                                                                index
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(child: SizedBox(height: 1.h)),

                            // Show Local subcategories only when Local tab is selected ll local tab ma 2 tab group and friend tab code
                            if (selectedCategory == 1) // Local tab selected
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 6.h,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double itemWidth =
                                          (constraints.maxWidth - 9.4.w) / 2;

                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: localSubCategories.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (selectedLocalSubCategory !=
                                                    index) {
                                                  setState(() {
                                                    selectedLocalSubCategory =
                                                        index;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 6.h,
                                                width: itemWidth,
                                                // Dynamic width
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.grey,
                                                  ),
                                                  color:
                                                      selectedLocalSubCategory ==
                                                              index
                                                          ? AppColors.maincolor
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        localSubCategories[index] ==
                                                                'Group'
                                                            ? Icons.group
                                                            : Icons.person,
                                                        color:
                                                            selectedLocalSubCategory ==
                                                                    index
                                                                ? Colors.white
                                                                : Colors.black,
                                                        size: 18.sp,
                                                      ),
                                                      SizedBox(width: 1.w),
                                                      Flexible(
                                                        child: Text(
                                                          localSubCategories[index],
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            color:
                                                                selectedLocalSubCategory ==
                                                                        index
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                            SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                            //  new local post Ram Code
                            if (selectedCategory == 1 &&
                                selectedLocalSubCategory == 2)
                              (localpost_model?.data?.length == null ||
                                      localpost_model?.data?.length == 0)
                                  ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 16),
                                          Text(
                                            "No Posts available",
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  )
                                  : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final post =
                                            localpost_model
                                                ?.data?[index]; // ✅ Ensure safe access

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 10.0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black12,
                                                width: 0.2.w,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 3.w,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        // Optional: for rounded corners
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              localpost_model
                                                                  ?.data?[index]
                                                                  .users
                                                                  ?.first
                                                                  ?.profiles ??
                                                              "",
                                                          height: 6.h,
                                                          width: 12.w,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                          // optional
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Image(
                                                                image:
                                                                    AssetImage(
                                                                      image,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            post?.users != null
                                                                ? "${post!.users?.first.name ?? 'No Name'}"
                                                                : "Unknown User",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            formatDateTime(
                                                              post?.createdAt ??
                                                                  "",
                                                            ),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      loginModel
                                                                  ?.data
                                                                  ?.user
                                                                  ?.id ==
                                                              post?.userId
                                                          ? PopupMenuButton<
                                                            String
                                                          >(
                                                            icon: Icon(
                                                              Icons.more_vert,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                            onSelected: (
                                                              value,
                                                            ) {
                                                              if (value ==
                                                                  'edit') {
                                                                UpdatePostData(
                                                                  context,
                                                                  post,
                                                                );
                                                                print(
                                                                  "Edit selected",
                                                                );
                                                              } else if (value ==
                                                                  'delete') {
                                                                showCancelConfirmationDialog(
                                                                  context:
                                                                      context,
                                                                  post!.id.toString() ??
                                                                      "",
                                                                );
                                                                print(
                                                                  "Delete selected",
                                                                );
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) => [
                                                                  PopupMenuItem(
                                                                    value:
                                                                        'edit',
                                                                    child: Text(
                                                                      'Edit',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem(
                                                                    value:
                                                                        'delete',
                                                                    child: Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                          )
                                                          : SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 92.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: ReadMoreText(
                                                    "${post?.text == null || post?.text == "" ? "N/A" : "${post?.text.toString()}"}",
                                                    trimLines: 4,
                                                    trimLength: 146,
                                                    colorClickableText:
                                                        Colors.blue,
                                                    trimMode: TrimMode.Length,
                                                    trimCollapsedText:
                                                        ' Show more',
                                                    trimExpandedText:
                                                        ' Show less',
                                                    moreStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      letterSpacing: 1,
                                                      color:
                                                          AppColors.maincolor,
                                                    ),
                                                    lessStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                      color:
                                                          AppColors.maincolor,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ).paddingOnly(
                                                  left: 2.w,
                                                  right: 2.w,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 2.5.w,
                                                  ),
                                                  child: StatefulBuilder(
                                                    builder: (
                                                      context,
                                                      setState,
                                                    ) {
                                                      final pageCount =
                                                          post?.file?.length ??
                                                          0;

                                                      return SizedBox(
                                                        height: 35.h,
                                                        child: Stack(
                                                          children: [
                                                            (pageCount > 0)
                                                                ? PageView.builder(
                                                                  controller:
                                                                      _pageController,
                                                                  itemCount:
                                                                      pageCount,
                                                                  onPageChanged: (
                                                                    index,
                                                                  ) {
                                                                    setState(
                                                                      () =>
                                                                          _currentPage =
                                                                              index,
                                                                    );
                                                                  },
                                                                  itemBuilder: (
                                                                    context,
                                                                    index,
                                                                  ) {
                                                                    final imageUrl =
                                                                        post?.file?[index] ??
                                                                        "";

                                                                    return ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                      child: CachedNetworkImage(
                                                                        imageUrl:
                                                                            imageUrl,
                                                                        placeholder:
                                                                            (
                                                                              context,
                                                                              url,
                                                                            ) => Center(
                                                                              child:
                                                                                  CircularProgressIndicator(),
                                                                            ),
                                                                        errorWidget:
                                                                            (
                                                                              context,
                                                                              url,
                                                                              error,
                                                                            ) => Image.asset(
                                                                              "assets/images/waveeLogoShort.png",
                                                                              width:
                                                                                  double.infinity,
                                                                              height:
                                                                                  35.h,
                                                                              fit:
                                                                                  BoxFit.cover,
                                                                            ),
                                                                        width:
                                                                            double.infinity,
                                                                        height:
                                                                            35.h,
                                                                        fit:
                                                                            BoxFit.cover,
                                                                      ),
                                                                    ).marginOnly(
                                                                      right:
                                                                          1.w,
                                                                    );
                                                                  },
                                                                )
                                                                : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  child: Image.asset(
                                                                    "assets/images/waveeLogoShort.png",
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    height:
                                                                        35.h,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),

                                                            // 🔢 Image count badge
                                                            if (pageCount > 0)
                                                              Positioned(
                                                                top: 8,
                                                                right: 16,
                                                                child: Container(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                          0.6,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    '${_currentPage + 1}/$pageCount',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          12.sp,
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
                                                // Padding(
                                                //   padding: EdgeInsets.symmetric(
                                                //       vertical: 1.h,
                                                //       horizontal: 3.w),
                                                //   child: Wrap(
                                                //     spacing: 5.w,
                                                //     children: [
                                                //       // Like Button
                                                //       StatefulBuilder(
                                                //         builder: (context,
                                                //             localSetState) {
                                                //           bool isLiked = index <
                                                //               isLikedListLocal
                                                //                   .length
                                                //               ? isLikedListLocal[
                                                //           index]
                                                //               : false;
                                                //           bool isInProgress = index <
                                                //               isLikeInProgressListLocal
                                                //                   .length
                                                //               ? isLikeInProgressListLocal[
                                                //           index]
                                                //               : false;
                                                //
                                                //           return GestureDetector(
                                                //             onTap: isInProgress
                                                //                 ? null
                                                //                 : () {
                                                //               log('dadadsadad');
                                                //               if (index <
                                                //                   isLikedListLocal
                                                //                       .length &&
                                                //                   index <
                                                //                       isLikeInProgressListLocal
                                                //                           .length) {
                                                //                 localSetState(
                                                //                         () {
                                                //                       isLikedListLocal[index] =
                                                //                       !isLikedListLocal[index];
                                                //                       isLikeInProgressListLocal[index] =
                                                //                       true;
                                                //                     });
                                                //                 _saveLikeStatusLocal(
                                                //                     index,
                                                //                     isLikedListLocal[
                                                //                     index]);
                                                //                 postslikelocalap(
                                                //                     index,
                                                //                         () {
                                                //                       localSetState(
                                                //                               () {
                                                //                             isLikeInProgressListLocal[index] =
                                                //                             false;
                                                //                           });
                                                //                     });
                                                //               }
                                                //             },
                                                //             child: Row(
                                                //               children: [
                                                //                 SizedBox(
                                                //                   width: 30,
                                                //                   height: 30,
                                                //                   child: Icon(
                                                //                     isLiked
                                                //                         ? Icons
                                                //                         .favorite
                                                //                         : Icons
                                                //                         .favorite_border,
                                                //                     color: isLiked
                                                //                         ? Colors.red
                                                //                         : Colors
                                                //                         .black,
                                                //                     size: 22.sp,
                                                //                   ),
                                                //                 ),
                                                //                 Text(messageboardpostlikeModel?.likesCount.toString()??"na"),
                                                //               ],
                                                //             ),
                                                //           );
                                                //         },
                                                //       ),
                                                //
                                                //       // Comment Button
                                                //       GestureDetector(
                                                //         onTap: () async {
                                                //           // await getCommentslocalpost(
                                                //           //     context,
                                                //           //     (post?.id)
                                                //           //         .toString());
                                                //           getComments1(post?.id
                                                //               ?.toString() ??
                                                //               "");
                                                //           log("message");
                                                //         },
                                                //         child: SizedBox(
                                                //           width: 30,
                                                //           height: 30,
                                                //           child: Icon(
                                                //               Icons.comment,
                                                //               size: 20.sp,
                                                //               color: Colors
                                                //                   .black87),
                                                //         ),
                                                //       ),
                                                //
                                                //       // Share Button
                                                //       GestureDetector(
                                                //         onTap: () {
                                                //           try {
                                                //             final imageUrl =
                                                //             messageBoardModal
                                                //                 ?.data?[
                                                //             index]
                                                //                 ?.file
                                                //                 .toString();
                                                //             final linkToShare =
                                                //             (imageUrl ==
                                                //                 null ||
                                                //                 imageUrl
                                                //                     .isEmpty)
                                                //                 ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                                                //                 : imageUrl;
                                                //             shareConciergeImage(
                                                //                 linkToShare);
                                                //           } catch (e) {
                                                //             print(
                                                //                 "Error sharing: $e");
                                                //           }
                                                //         },
                                                //         child: SizedBox(
                                                //           width: 30,
                                                //           height: 30,
                                                //           child: Icon(
                                                //               Icons
                                                //                   .share_outlined,
                                                //               size: 20.sp,
                                                //               color: Colors
                                                //                   .black87),
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // )
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 3.w,
                                                  ),
                                                  child: Row(
                                                    // mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      // Like Button
                                                      StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          localSetState,
                                                        ) {
                                                          bool isLiked =
                                                              index <
                                                                      isLikedListLocal
                                                                          .length
                                                                  ? isLikedListLocal[index]
                                                                  : false;
                                                          bool isInProgress =
                                                              index <
                                                                      isLikeInProgressListLocal
                                                                          .length
                                                                  ? isLikeInProgressListLocal[index]
                                                                  : false;

                                                          return GestureDetector(
                                                            onTap:
                                                                isInProgress
                                                                    ? null
                                                                    : () {
                                                                      if (index <
                                                                              isLikedListLocal.length &&
                                                                          index <
                                                                              isLikeInProgressListLocal.length) {
                                                                        localSetState(() {
                                                                          isLikedListLocal[index] =
                                                                              !isLikedListLocal[index];
                                                                          isLikeInProgressListLocal[index] =
                                                                              true;
                                                                        });
                                                                        _saveLikeStatusLocal(
                                                                          index,
                                                                          isLikedListLocal[index],
                                                                        );
                                                                        postslikelocalap(
                                                                          index,
                                                                          () {
                                                                            localSetState(() {
                                                                              isLikeInProgressListLocal[index] =
                                                                                  false;
                                                                            });
                                                                          },
                                                                        );
                                                                      }
                                                                    },
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  isLiked
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color:
                                                                      isLiked
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .black,
                                                                  size: 22.sp,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  messageboardpostlikeModel
                                                                          ?.likesCount
                                                                          .toString() ??
                                                                      "",
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(width: 3.w),

                                                      // Comment Button
                                                      GestureDetector(
                                                        onTap: () {
                                                          getComments1(
                                                            post?.id?.toString() ??
                                                                "",
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.comment,
                                                          size: 20.sp,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      SizedBox(width: 3.w),

                                                      // Share Button
                                                      GestureDetector(
                                                        onTap: () {
                                                          try {
                                                            final imageUrl =
                                                                messageBoardModal
                                                                    ?.data?[index]
                                                                    ?.file
                                                                    .toString();
                                                            final linkToShare =
                                                                (imageUrl ==
                                                                            null ||
                                                                        imageUrl
                                                                            .isEmpty)
                                                                    ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                                                                    : imageUrl;
                                                            shareConciergeImage(
                                                              linkToShare,
                                                            );
                                                          } catch (e) {
                                                            print(
                                                              "Error sharing: $e",
                                                            );
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.share_outlined,
                                                          size: 20.sp,
                                                          color: Colors.black87,
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
                                      childCount:
                                          localpost_model?.data?.length ??
                                          0, // ✅ Prevent null issue
                                    ),
                                  ),

                            if (selectedCategory == 1 &&
                                selectedLocalSubCategory == 0)
                              (getgrouplistmodel?.data?.length == null ||
                                      getgrouplistmodel?.data?.length == 0)
                                  ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 16),
                                          Text(
                                            "No Groups available",
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  )
                                  : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final group =
                                            getgrouplistmodel?.data?[index];
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h,
                                            horizontal: 1.w,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigate to GroupChatPage
                                              Get.to(
                                                () => GroupChatPage(
                                                  chatname: group?.name ?? '',
                                                  image: group?.images,
                                                  groupid:
                                                      group?.id.toString() ??
                                                      '',
                                                  type: "residents",
                                                ),
                                              )?.then((value) {
                                                if (value == 'refresh') {
                                                  //getgrouplistdAp();

                                                  GetMyJoinGroup();
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: 11.h,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 1.5.h,
                                                horizontal: 2.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          group?.images ??
                                                          "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => CircleAvatar(
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
                                                          ) => const CircleAvatar(
                                                            radius: 24,
                                                            // backgroundColor:
                                                            //     Colors.blueAccent,
                                                            child: Image(
                                                              image: AssetImage(
                                                                "assets/images/person.jpg",
                                                              ),
                                                            ),
                                                          ),
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                top: 1.h,
                                                              ),
                                                          child: Text(
                                                            group?.name ?? "",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 0.5.h),

                                                        Row(
                                                          children: [
                                                            // For debugging: Print the values we're checking
                                                            Builder(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                debugPrint(
                                                                  "senderId: ${group?.lastmessage?.senderId}",
                                                                );
                                                                debugPrint(
                                                                  "currentUserId: $currentUserId",
                                                                );
                                                                debugPrint(
                                                                  "Is sender null? ${group?.lastmessage?.senderId == null}",
                                                                );
                                                                return Container(); // This is just a placeholder
                                                              },
                                                            ),

                                                            // Now try a different approach for checking current user
                                                            if (group
                                                                        ?.lastmessage
                                                                        ?.senderId ==
                                                                    null ||
                                                                (group
                                                                        ?.lastmessage
                                                                        ?.senderId
                                                                        ?.toString() ==
                                                                    currentUserId)) ...[
                                                              // When the last message is from the current user
                                                              Expanded(
                                                                child: Text(
                                                                  "You: ${group?.lastmessage?.message?.toString() ?? 'No Message Available'}",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            ] else ...[
                                                              // When the last message is from another user
                                                              Expanded(
                                                                child: RichText(
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  text: TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "${group?.lastmessage?.firstName ?? ''} ${group?.lastmessage?.lastName ?? ''}: ",
                                                                        style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              AppConstants.manrope,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            group?.lastmessage?.message?.toString() ??
                                                                            "No Message Available",
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              AppConstants.manrope,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),

                                                        // Row(
                                                        //   children: [
                                                        //     Text(
                                                        //     "${group?.lastmessage?.conciger?.firstName.toString() ?? "" }"  ,
                                                        //       style: const TextStyle(
                                                        //         fontWeight: FontWeight.bold,
                                                        //         fontFamily:
                                                        //         AppConstants.manrope,
                                                        //       ),
                                                        //     ),
                                                        //     SizedBox(width: 0.5.h),
                                                        //     Text(
                                                        //       // group?.lastMessage ?? 'No message',
                                                        //       group?.lastmessage?.message
                                                        //           .toString() ??
                                                        //           "No Message Available",
                                                        //       maxLines: 1,
                                                        //       overflow:
                                                        //       TextOverflow.ellipsis,
                                                        //       style: TextStyle(
                                                        //         fontWeight: FontWeight.bold,
                                                        //         fontFamily:
                                                        //         AppConstants.manrope,
                                                        //         color: Colors.grey,
                                                        //       ),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      // (group?.unreadCount ?? 0) == 0
                                                      // (group?.id ?? 0) == 0
                                                      //     ? Container(height: 1, width: 1)
                                                      //     :
                                                      group?.unreadCount == 0
                                                          ? SizedBox(
                                                            height: 2.h,
                                                          )
                                                          : Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  right: 3.5.w,
                                                                  top: 0.5.h,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 13,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .maincolor,
                                                              child: ClipOval(
                                                                child: Center(
                                                                  child: Text(
                                                                    //  (group?.unreadCount ?? 0).toString(),
                                                                    group?.unreadCount
                                                                            .toString() ??
                                                                        "",
                                                                    style: TextStyle(
                                                                      fontFamily:
                                                                          AppConstants
                                                                              .manrope,
                                                                      fontSize:
                                                                          15.sp,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      SizedBox(height: 5),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          right: 3.5.w,
                                                        ),
                                                        child: Text(
                                                          _formatTime(
                                                            group
                                                                    ?.lastmessage
                                                                    ?.createdAt ??
                                                                "00:00",
                                                          ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            color: Colors.black,
                                                            fontSize: 15.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount:
                                          getgrouplistmodel?.data?.length ?? 0,
                                    ),
                                  ),

                            // Friend List Content (when Local -> Friend selected) // Friend Listing UI Code
                            if (selectedCategory == 1 &&
                                selectedLocalSubCategory == 1)
                              (getfriendListModel?.data?.length == null ||
                                      getfriendListModel?.data?.length == 0)
                                  ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 16),
                                          Text(
                                            "No Friends available",
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  )
                                  : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        //  final group = getgrouplistmodel?.data?[index];
                                        final friend =
                                            getfriendListModel?.data?[index];

                                        String friendName =
                                            (friend?.senderId.toString() ==
                                                    (loginModel?.data?.user?.id
                                                            .toString() ??
                                                        ""))
                                                ? (friend?.receiverName
                                                        ?.toString() ??
                                                    "")
                                                : (friend?.senderName
                                                        ?.toString() ??
                                                    "");
                                        String friendImage =
                                            (friend?.senderId.toString() ==
                                                    (loginModel?.data?.user?.id
                                                            .toString() ??
                                                        ""))
                                                ? (friend?.receiverImage
                                                        ?.toString() ??
                                                    "")
                                                : (friend?.senderImage
                                                        ?.toString() ??
                                                    "");
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h,
                                            horizontal: 1.w,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              log(
                                                "chat ni id jay che che che ${getfriendListModel?.data?[index].receiverId.toString() ?? ""}",
                                              );
                                              Get.to(
                                                () => MessageScreen(
                                                  chatName: friendName ?? "",
                                                  conciergeID:
                                                      getfriendListModel
                                                          ?.data?[index]
                                                          .receiverId
                                                          .toString() ??
                                                      "",
                                                  senderid:
                                                      getfriendListModel
                                                          ?.data?[index]
                                                          .senderId
                                                          .toString() ??
                                                      "",
                                                  type: "residents",
                                                  image: friendImage ?? "",
                                                ),
                                              )?.then((value) {
                                                if (value == 'refresh') {
                                                  // Call the method you want to refresh here, e.g.:
                                                  getfriendlistdAp(); // Or your equivalent method to refresh the friend list
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: 11.h,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 1.5.h,
                                                horizontal: 2.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: friendImage,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => CircleAvatar(
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
                                                            // backgroundColor:
                                                            //     Colors.blueAccent,
                                                            child: Image.asset(
                                                              "assets/images/person.jpg",
                                                            ),
                                                          ),
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                top: 1.5.h,
                                                              ),
                                                          child: Text(
                                                            friendName,
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 0.5.h),
                                                        Text(
                                                          friend?.lastMessage ??
                                                              'No Message available',
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      friend?.unreadCount == 0
                                                          ? SizedBox(
                                                            height: 1,
                                                            width: 1,
                                                          )
                                                          : Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  right: 3.5.w,
                                                                  top: 0.5.h,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 13,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .maincolor,
                                                              child: Center(
                                                                child: Text(
                                                                  friend?.unreadCount
                                                                          .toString() ??
                                                                      "",
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    fontSize:
                                                                        15.sp,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      SizedBox(height: 5),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          right: 3.5.w,
                                                        ),
                                                        child: Text(
                                                          _formatTime(
                                                            friend?.createdAt ??
                                                                "00:00",
                                                          ),
                                                          //  friend['lastMessageTime'] ?? '00:00',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            color: Colors.black,
                                                            fontSize: 15.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount:
                                          getfriendListModel?.data?.length ?? 0,
                                    ),
                                  ),

                            // Building Message board code .. starting code first as
                            if (selectedCategory == 0)
                              messageBoardModal?.data == null ||
                                      messageBoardModal!.data!.isEmpty
                                  ? SliverToBoxAdapter(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 30.h,
                                        ),
                                        child: Text(
                                          "No post available",
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        // if (messageBoardModal?.data?.length == null
                                        //    ) {
                                        //   return Center(
                                        //     child: Text(
                                        //       "No messages available",
                                        //       style: TextStyle(
                                        //           fontSize: 16.sp,
                                        //           fontWeight: FontWeight.bold),
                                        //     ),
                                        //   );
                                        // }

                                        final post =
                                            messageBoardModal
                                                ?.data?[index]; // ✅ Ensure safe access

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 10.0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black12,
                                                width: 0.2.w,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 3.w,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 6.h,
                                                        width: 12.w,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                              messageBoardModal
                                                                          ?.data?[index]
                                                                          .user
                                                                          ?.conciergeImage ==
                                                                      null
                                                                  ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                                                                  : messageBoardModal
                                                                          ?.data?[index]
                                                                          .user
                                                                          ?.conciergeImage ??
                                                                      "",
                                                              // post.user?.conciergeImage == null
                                                              //     ? post.user?.conciergeImage.toString() ?? ""
                                                              //     : "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png", // ✅ Fallback image
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            post?.user != null
                                                                ? "${post!.user!.firstName ?? 'No Name'} ${post!.user!.lastName ?? ''}"
                                                                : "Unknown User",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            formatDateTime(
                                                              post?.createdAt ??
                                                                  "",
                                                            ),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      // Spacer(),
                                                      //  Icon(Icons.more_vert, color: Colors.black87),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 92.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: ReadMoreText(
                                                    "${post?.text == null || post?.text == "" ? "N/A" : "${post?.text.toString()}"}",
                                                    trimLines: 4,
                                                    trimLength: 146,
                                                    colorClickableText:
                                                        Colors.blue,
                                                    trimMode: TrimMode.Length,
                                                    trimCollapsedText:
                                                        ' Show more',
                                                    trimExpandedText:
                                                        ' Show less',
                                                    moreStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      letterSpacing: 1,
                                                      color:
                                                          AppColors.maincolor,
                                                    ),
                                                    lessStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                      color:
                                                          AppColors.maincolor,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ).paddingOnly(
                                                  left: 2.w,
                                                  right: 2.w,
                                                ),

                                                //
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 2.5.w,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          post?.file?.isNotEmpty ==
                                                                  true
                                                              ? post?.file![0]
                                                                      .toString() ??
                                                                  ""
                                                              : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPwQOOsR9GZtqdjmrbJLzYGuY8XNpVuGd2vZxUNHJkgGg8aL6nIz2y5Sz7KSPc6yk4QDY&usqp=CAU",
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => SizedBox(
                                                            height: 35.h,
                                                            width:
                                                                double.infinity,
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Icon(
                                                            Icons.error,
                                                            size: 24.sp,
                                                          ),
                                                      width: double.infinity,
                                                      height: 35.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                // Padding(
                                                //   padding: EdgeInsets.symmetric(
                                                //       vertical: 1.h, horizontal: 3.w),
                                                //   child: Row(
                                                //     mainAxisAlignment:
                                                //     MainAxisAlignment.spaceBetween,
                                                //     children: [
                                                //       Row(
                                                //         children: [
                                                //           StatefulBuilder(
                                                //             builder: (context, localSetState) {
                                                //               return GestureDetector(
                                                //                 onTap: isLikeInProgressList[index]
                                                //                     ? null
                                                //                     : () {
                                                //                   localSetState(() {
                                                //                     isLikedList[index] = !isLikedList[index];
                                                //                     isLikeInProgressList[index] = true;
                                                //                   });
                                                //
                                                //                   _saveLikeStatus(index, isLikedList[index]);
                                                //
                                                //                   postslikeap(index, () {
                                                //                     localSetState(() {
                                                //                       isLikeInProgressList[index] = false;
                                                //                     });
                                                //                   });
                                                //                 },
                                                //                 child: Row(
                                                //                   children: [
                                                //                     Icon(
                                                //                       isLikedList[index] ? Icons.favorite : Icons.favorite_border,
                                                //                       color: isLikedList[index] ? Colors.red : Colors.black,
                                                //                       size: 22.sp,
                                                //                     ),
                                                //                     SizedBox(width: 1.w),
                                                //                   ],
                                                //                 ),
                                                //               );
                                                //             },
                                                //           ),
                                                //
                                                //
                                                //
                                                //           SizedBox(width: 3.w),
                                                //           GestureDetector(
                                                //             onTap: () =>
                                                //                 showCommentBottomSheet(index),
                                                //             child: Row(
                                                //               children: [
                                                //                 Icon(Icons.comment,
                                                //                     size: 20.sp,
                                                //                     color: Colors.black87),
                                                //                 SizedBox(width: 1.5.w),
                                                //                 Text(
                                                //                   "${post?.totalComments ?? 0}",
                                                //                   style: TextStyle(
                                                //                     fontSize: 14.sp,
                                                //                     fontWeight: FontWeight.bold,
                                                //                     fontFamily:
                                                //                     AppConstants.manrope,
                                                //                   ),
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //           SizedBox(width: 3.w),
                                                //           GestureDetector(
                                                //             onTap: (){},
                                                //             child: Icon(Icons.share_outlined,
                                                //                 size: 20.sp, color: Colors.black87),
                                                //           ),
                                                //         ],
                                                //       )
                                                //     ],
                                                //   ),
                                                // ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 3.w,
                                                  ),
                                                  child: Wrap(
                                                    spacing: 3.w,
                                                    children: [
                                                      // Like Button
                                                      StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          localSetState,
                                                        ) {
                                                          bool isLiked =
                                                              index <
                                                                      isLikedList
                                                                          .length
                                                                  ? isLikedList[index]
                                                                  : false;
                                                          bool isInProgress =
                                                              index <
                                                                      isLikeInProgressList
                                                                          .length
                                                                  ? isLikeInProgressList[index]
                                                                  : false;

                                                          return GestureDetector(
                                                            onTap:
                                                                isInProgress
                                                                    ? null
                                                                    : () {
                                                                      if (index <
                                                                              isLikedList.length &&
                                                                          index <
                                                                              isLikeInProgressList.length) {
                                                                        localSetState(() {
                                                                          isLikedList[index] =
                                                                              !isLikedList[index];
                                                                          isLikeInProgressList[index] =
                                                                              true;
                                                                        });
                                                                        _saveLikeStatus(
                                                                          index,
                                                                          isLikedList[index],
                                                                        );
                                                                        postslikeap(
                                                                          index,
                                                                          () {
                                                                            localSetState(() {
                                                                              isLikeInProgressList[index] =
                                                                                  false;
                                                                            });
                                                                          },
                                                                        );
                                                                      }
                                                                    },
                                                            child: SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child: Icon(
                                                                isLiked
                                                                    ? Icons
                                                                        .favorite
                                                                    : Icons
                                                                        .favorite_border,
                                                                color:
                                                                    isLiked
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .black,
                                                                size: 22.sp,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),

                                                      // Comment Button
                                                      GestureDetector(
                                                        onTap: () async {
                                                          await getComments(
                                                            context,
                                                            (post?.id)
                                                                .toString(),
                                                          );
                                                          log("dasd");
                                                        },
                                                        child: SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: Icon(
                                                            Icons.comment,
                                                            size: 20.sp,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ),

                                                      // Share Button
                                                      // GestureDetector(
                                                      //   onTap: () {
                                                      //     try {
                                                      //       final imageUrl =
                                                      //           messageBoardModal
                                                      //               ?.data?[
                                                      //                   index]
                                                      //               ?.file
                                                      //               .toString();
                                                      //       final linkToShare =
                                                      //           (imageUrl ==
                                                      //                       null ||
                                                      //                   imageUrl
                                                      //                       .isEmpty)
                                                      //               ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                                                      //               : imageUrl;
                                                      //       shareConciergeImage(
                                                      //           linkToShare);
                                                      //     } catch (e) {
                                                      //       print(
                                                      //           "Error sharing: $e");
                                                      //     }
                                                      //   },
                                                      //   child: SizedBox(
                                                      //     width: 30,
                                                      //     height: 30,
                                                      //     child: Icon(
                                                      //         Icons
                                                      //             .share_outlined,
                                                      //         size: 20.sp,
                                                      //         color: Colors
                                                      //             .black87),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      childCount:
                                          messageBoardModal?.data?.length ??
                                          0, // ✅ Prevent null issue
                                    ),
                                  ),
                          ],
                        ),
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
      ),
      floatingActionButton:
          selectedCategory != 0
              ? (selectedCategory == 1 && selectedLocalSubCategory == 0
                  ? FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(900),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          String groupNameError = "";
                          String memberSelectionError = "";
                          final ScrollController dialogScrollController =
                              ScrollController();
                          final ScrollController listScrollController =
                              ScrollController();

                          // Search controller
                          final TextEditingController searchController =
                              TextEditingController();
                          String searchQuery = "";

                          return StatefulBuilder(
                            builder: (context, setState) {
                              // Filter users based on search query
                              List<dynamic> filteredUsers =
                                  chatuserlistmodel?.data?.where((user) {
                                    final String fullName =
                                        "${user.user?.firstName ?? ''} ${user.user?.lastName ?? ''}"
                                            .toLowerCase();
                                    return fullName.contains(
                                      searchQuery.toLowerCase(),
                                    );
                                  })?.toList() ??
                                  [];

                              // Direct image picker function from gallery
                              Future<void> pickImageFromGallery() async {
                                try {
                                  final ImagePicker _picker = ImagePicker();
                                  final XFile? image = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70,
                                  );

                                  if (image != null) {
                                    setState(() {
                                      selectedImage = io.File(image.path);
                                      imagePath = image.path;
                                      print(
                                        "Selected image path: ${image.path}",
                                      );
                                    });
                                  }
                                } catch (e) {
                                  print("Error picking image: $e");
                                }
                              }

                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.8,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
                                        // Header
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.group_add,
                                              color: AppColors.maincolor,
                                              size: 24,
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              'Create New Group',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 1.5.h),

                                        // Group Name Label
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Group Name',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.8.h),

                                        // Camera icon and textfield in same row with aligned height
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Camera icon
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade50, // lighter shade
                                              ),
                                              child: InkWell(
                                                onTap: pickImageFromGallery,
                                                child:
                                                    selectedImage != null
                                                        ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Image.file(
                                                            selectedImage!,
                                                            width: 40,
                                                            height: 40,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                        : Center(
                                                          child: Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            color:
                                                                Colors.black54,
                                                            size: 20,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            // Textfield
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 4.5.h,
                                                    // smaller height
                                                    child: TextField(
                                                      controller:
                                                          groupNameController,
                                                      decoration: InputDecoration(
                                                        hintText:
                                                            'Enter group name',
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          fontSize: 14.sp,
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey.shade50,
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                AppColors
                                                                    .maincolor,
                                                            width: 1.2,
                                                          ),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                    width: 1.2,
                                                                  ),
                                                            ),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          groupNameError = "";
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  if (groupNameError.isNotEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 4,
                                                        left: 4,
                                                      ),
                                                      child: Text(
                                                        groupNameError,
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Divider between Group Name and Search Bar
                                        Divider(
                                          height: 20,
                                          // Adjust height as needed
                                          thickness: 1,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade400, // Light grey color
                                        ),

                                        //  SizedBox(height: 1.5.h),

                                        // Add search bar
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: searchController,
                                            onChanged: (value) {
                                              setState(() {
                                                searchQuery = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Search members',
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Colors.grey.shade600,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 1.h),

                                        // Select Members Title
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Select Members',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            Text(
                                              '${selectedMembers.length} selected',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: AppColors.maincolor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 0.8.h),

                                        // Members list without border
                                        Container(
                                          height: 32.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Scrollbar(
                                            thumbVisibility: true,
                                            controller: listScrollController,
                                            radius: Radius.circular(8),
                                            thickness: 4,
                                            // Slimmer scrollbar
                                            child:
                                                filteredUsers.isEmpty
                                                    ? Center(
                                                      child: Text(
                                                        searchQuery.isEmpty
                                                            ? "No users available"
                                                            : "No matching members found",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
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
                                                      padding: EdgeInsets.zero,
                                                      // Remove default padding
                                                      itemCount:
                                                          filteredUsers.length,
                                                      separatorBuilder:
                                                          (_, __) => Divider(
                                                            height: 1,
                                                            thickness: 0.5,
                                                            // Thinner divider
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
                                                            filteredUsers[index];
                                                        final memberId =
                                                            user?.userId
                                                                .toString() ??
                                                            "";
                                                        final isSelected =
                                                            selectedMembers
                                                                .contains(
                                                                  memberId,
                                                                );

                                                        return ListTile(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 2,
                                                              ),
                                                          leading: CircleAvatar(
                                                            radius: 20,
                                                            // Smaller avatar size
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                            child: ClipOval(
                                                              child: CachedNetworkImage(
                                                                imageUrl:
                                                                    user
                                                                        ?.user
                                                                        ?.profile ??
                                                                    "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                                                placeholder:
                                                                    (
                                                                      context,
                                                                      url,
                                                                    ) => Image.asset(
                                                                      'assets/images/person.jpg',
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) => Image.asset(
                                                                      'assets/images/person.jpg',
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    ),
                                                                width: 40,
                                                                height: 40,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "${user?.user?.firstName ?? ""} ${user?.user?.lastName ?? "NA"}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                          trailing: Checkbox(
                                                            value: isSelected,
                                                            onChanged: (
                                                              selected,
                                                            ) {
                                                              setState(() {
                                                                if (selected ==
                                                                    true) {
                                                                  selectedMembers
                                                                      .add(
                                                                        memberId,
                                                                      );
                                                                } else {
                                                                  selectedMembers
                                                                      .remove(
                                                                        memberId,
                                                                      );
                                                                }
                                                                memberSelectionError =
                                                                    "";
                                                              });
                                                            },
                                                            activeColor:
                                                                AppColors
                                                                    .maincolor,
                                                          ),
                                                          tileColor:
                                                              isSelected
                                                                  ? Colors.blue
                                                                      .withOpacity(
                                                                        0.1,
                                                                      )
                                                                  : null,
                                                          selected: isSelected,
                                                          dense: true,
                                                          // More compact list tile
                                                          onTap: () {
                                                            setState(() {
                                                              if (isSelected) {
                                                                selectedMembers
                                                                    .remove(
                                                                      memberId,
                                                                    );
                                                              } else {
                                                                selectedMembers
                                                                    .add(
                                                                      memberId,
                                                                    );
                                                              }
                                                              memberSelectionError =
                                                                  "";
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                          ),
                                        ),

                                        // Member selection error
                                        if (memberSelectionError.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 4,
                                              left: 4,
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                memberSelectionError,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.sp,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                            ),
                                          ),

                                        SizedBox(height: 2.h),

                                        // Action Buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Cancel button
                                            batan(
                                              title: "Cancel",
                                              route: () {
                                                groupNameController.clear();
                                                selectedMembers.clear();
                                                selectedImage = null;
                                                imagePath = '';
                                                Get.back();
                                              },
                                              radius: 3.0.w,
                                              color: AppColors.maincolor,
                                              fontcolor: Colors.white,
                                              height: 4.5.h,
                                              width: 41.w,
                                              fontsize: 15.5.sp,
                                            ),
                                            SizedBox(width: 3.w),
                                            // Create Group button
                                            batan(
                                              title: "Create Group",
                                              route: () {
                                                if (groupNameController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  setState(() {
                                                    groupNameError =
                                                        "Please enter group name";
                                                    memberSelectionError = "";
                                                  });
                                                  return;
                                                }

                                                if (selectedMembers.isEmpty) {
                                                  setState(() {
                                                    memberSelectionError =
                                                        "Please select at least one member";
                                                    groupNameError = "";
                                                  });
                                                  return;
                                                }

                                                creategrouplistdAp();
                                                Get.back();
                                              },
                                              radius: 3.0.w,
                                              color: AppColors.maincolor,
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
                      print("Create Group Pressed");
                    },
                    icon: Icon(CupertinoIcons.group_solid, color: Colors.black),
                    label: Text(
                      "Create Group",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  )
                  : (selectedCategory == 1 && selectedLocalSubCategory == 1
                      ? FloatingActionButton.extended(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(900),
                        ),
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          await listconciergerapi();
                          showDialog(
                            context: context,
                            builder: (context) {
                              List<Map<String, dynamic>> selectedFriends = [];
                              String friendSelectionError = "";
                              final ScrollController dialogScrollController =
                                  ScrollController();
                              final ScrollController listScrollController =
                                  ScrollController();

                              // Search controller
                              final TextEditingController searchController =
                                  TextEditingController();
                              String searchQuery = "";

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  // Filter friends based on search query
                                  List<dynamic> filteredFriends =
                                      chatuserlistmodel?.data?.where((user) {
                                        final String fullName =
                                            "${user.user?.firstName ?? ''} ${user.user?.lastName ?? ''}"
                                                .toLowerCase();
                                        return fullName.contains(
                                          searchQuery.toLowerCase(),
                                        );
                                      })?.toList() ??
                                      [];

                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    insetPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                            0.8,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                            // Header
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_add_alt_1,
                                                  color: AppColors.maincolor,
                                                  size: 24,
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  'Add New Friend',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 1.5.h),

                                            // Add search bar
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller: searchController,
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchQuery = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'Search friends',
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 1.h),

                                            // Select Friend Title and counter
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Select Friends',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                                Text(
                                                  '${selectedFriends.length} selected',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    color: AppColors.maincolor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 0.8.h),

                                            // Friends list container
                                            Container(
                                              height: 32.h,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Scrollbar(
                                                thumbVisibility: true,
                                                controller:
                                                    listScrollController,
                                                radius: Radius.circular(8),
                                                thickness: 4,
                                                child:
                                                    filteredFriends.isEmpty
                                                        ? Center(
                                                          child: Text(
                                                            searchQuery.isEmpty
                                                                ? "No users available"
                                                                : "No matching friends found",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
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
                                                              EdgeInsets.zero,
                                                          itemCount:
                                                              filteredFriends
                                                                  .length,
                                                          separatorBuilder:
                                                              (
                                                                _,
                                                                __,
                                                              ) => Divider(
                                                                height: 1,
                                                                thickness: 0.5,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade200,
                                                              ),
                                                          itemBuilder: (
                                                            context,
                                                            index,
                                                          ) {
                                                            final userData =
                                                                filteredFriends[index];
                                                            final userId =
                                                                userData
                                                                    .user
                                                                    ?.id
                                                                    .toString();
                                                            final requestStatus =
                                                                userData
                                                                    .requestStatuses ??
                                                                [];

                                                            // Apply toLowerCase to each element in the list
                                                            final lowerCaseStatuses =
                                                                requestStatus
                                                                    .map(
                                                                      (
                                                                        status,
                                                                      ) =>
                                                                          status
                                                                              .toLowerCase(),
                                                                    )
                                                                    .toList();

                                                            final friendData = {
                                                              'id': userId,
                                                              'name':
                                                                  "${userData.user?.firstName ?? ''} ${userData.user?.lastName ?? ''}",
                                                              'image':
                                                                  userData
                                                                      .user
                                                                      ?.profile ??
                                                                  '',
                                                            };

                                                            // Check for different statuses
                                                            bool isPending =
                                                                lowerCaseStatuses
                                                                    .contains(
                                                                      "pending",
                                                                    );
                                                            bool isAccepted =
                                                                lowerCaseStatuses
                                                                    .contains(
                                                                      "accepted",
                                                                    );
                                                            bool isCancelled =
                                                                lowerCaseStatuses
                                                                    .contains(
                                                                      "cancel",
                                                                    ) ||
                                                                lowerCaseStatuses
                                                                    .contains(
                                                                      "cancelled",
                                                                    ) ||
                                                                lowerCaseStatuses
                                                                    .contains(
                                                                      "canceled",
                                                                    );
                                                            bool canSelect =
                                                                requestStatus
                                                                    .isEmpty;

                                                            bool isSelected =
                                                                selectedFriends.any(
                                                                  (element) =>
                                                                      element['id'] ==
                                                                      friendData['id'],
                                                                );

                                                            return ListTile(
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 2,
                                                                  ),
                                                              onTap: () {
                                                                if (canSelect) {
                                                                  setState(() {
                                                                    if (isSelected) {
                                                                      selectedFriends.removeWhere(
                                                                        (
                                                                          element,
                                                                        ) =>
                                                                            element['id'] ==
                                                                            friendData['id'],
                                                                      );
                                                                    } else {
                                                                      selectedFriends
                                                                          .add(
                                                                            friendData,
                                                                          );
                                                                    }
                                                                    friendSelectionError =
                                                                        "";
                                                                  });
                                                                }
                                                              },
                                                              leading: CircleAvatar(
                                                                radius: 20,
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey
                                                                        .shade200,
                                                                child: ClipOval(
                                                                  child: CachedNetworkImage(
                                                                    imageUrl:
                                                                        userData
                                                                            .user
                                                                            ?.profile ??
                                                                        "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                                                    placeholder:
                                                                        (
                                                                          context,
                                                                          url,
                                                                        ) => Image.asset(
                                                                          'assets/images/person.jpg',
                                                                          fit:
                                                                              BoxFit.cover,
                                                                        ),
                                                                    errorWidget:
                                                                        (
                                                                          context,
                                                                          url,
                                                                          error,
                                                                        ) => Image.asset(
                                                                          'assets/images/person.jpg',
                                                                          fit:
                                                                              BoxFit.cover,
                                                                        ),
                                                                    width: 40,
                                                                    height: 40,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                "${userData.user?.firstName ?? ''} ${userData.user?.lastName ?? ''}",
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
                                                                      isPending
                                                                          ? AppColors
                                                                              .maincolor
                                                                          : isAccepted
                                                                          ? Colors
                                                                              .green
                                                                          : isCancelled
                                                                          ? Colors
                                                                              .red
                                                                          : null,
                                                                ),
                                                              ),
                                                              subtitle:
                                                                  requestStatus
                                                                          .isNotEmpty
                                                                      ? Text(
                                                                        isPending
                                                                            ? "Request Pending"
                                                                            : isAccepted
                                                                            ? "Friend"
                                                                            : isCancelled
                                                                            ? "Cancelled"
                                                                            : "",
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              AppConstants.manrope,
                                                                          fontSize:
                                                                              12.sp,
                                                                          color:
                                                                              isPending
                                                                                  ? Colors.orange
                                                                                  : isAccepted
                                                                                  ? Colors.green
                                                                                  : isCancelled
                                                                                  ? Colors.red
                                                                                  : Colors.grey,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                        ),
                                                                      )
                                                                      : Text(
                                                                        "New User",
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              AppConstants.manrope,
                                                                          fontSize:
                                                                              12.sp,
                                                                          color:
                                                                              Colors.grey,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                        ),
                                                                      ),
                                                              trailing: Checkbox(
                                                                value:
                                                                    isSelected ||
                                                                    isPending ||
                                                                    isAccepted,
                                                                onChanged:
                                                                    canSelect
                                                                        ? (
                                                                          value,
                                                                        ) {
                                                                          setState(() {
                                                                            if (value ==
                                                                                true) {
                                                                              if (!isSelected) {
                                                                                selectedFriends.add(
                                                                                  friendData,
                                                                                );
                                                                              }
                                                                            } else {
                                                                              selectedFriends.removeWhere(
                                                                                (
                                                                                  element,
                                                                                ) =>
                                                                                    element['id'] ==
                                                                                    friendData['id'],
                                                                              );
                                                                            }
                                                                            friendSelectionError =
                                                                                "";
                                                                          });
                                                                        }
                                                                        : null,
                                                                activeColor:
                                                                    isPending
                                                                        ? Colors
                                                                            .orange
                                                                        : isAccepted
                                                                        ? Colors
                                                                            .green
                                                                        : AppColors
                                                                            .maincolor,
                                                                checkColor:
                                                                    Colors
                                                                        .white,
                                                                fillColor:
                                                                    !canSelect
                                                                        ? MaterialStateProperty.resolveWith(
                                                                          (
                                                                            states,
                                                                          ) =>
                                                                              isPending
                                                                                  ? Colors.orange.shade400
                                                                                  : isAccepted
                                                                                  ? Colors.green.shade400
                                                                                  : isCancelled
                                                                                  ? Colors.grey.shade400
                                                                                  : Colors.grey.shade400,
                                                                        )
                                                                        : null,
                                                              ),
                                                              tileColor:
                                                                  (isSelected ||
                                                                          !canSelect)
                                                                      ? (isPending
                                                                          ? Colors.orange.withOpacity(
                                                                            0.05,
                                                                          )
                                                                          : isAccepted
                                                                          ? Colors.green.withOpacity(
                                                                            0.05,
                                                                          )
                                                                          : isCancelled
                                                                          ? Colors.red.withOpacity(
                                                                            0.05,
                                                                          )
                                                                          : Colors.blue.withOpacity(
                                                                            0.05,
                                                                          ))
                                                                      : null,
                                                              selected:
                                                                  isSelected ||
                                                                  !canSelect,
                                                              dense: true,
                                                            );
                                                          },
                                                        ),
                                              ),
                                            ),

                                            // Selection error
                                            if (friendSelectionError.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 4,
                                                  left: 4,
                                                ),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    friendSelectionError,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            SizedBox(height: 2.h),

                                            // Action Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Cancel button
                                                batan(
                                                  title: "Cancel",
                                                  route: () => Get.back(),
                                                  radius: 3.0.w,
                                                  color: AppColors.maincolor,
                                                  fontcolor: Colors.white,
                                                  height: 4.5.h,
                                                  width: 41.w,
                                                  fontsize: 15.5.sp,
                                                ),
                                                SizedBox(width: 3.w),
                                                // Add Friend button
                                                batan(
                                                  title: "Add Friends",
                                                  route: () async {
                                                    if (selectedFriends
                                                        .isEmpty) {
                                                      setState(() {
                                                        friendSelectionError =
                                                            "Please select at least one friend";
                                                      });
                                                      return;
                                                    }

                                                    // Send friend requests to all selected friends
                                                    for (var friend
                                                        in selectedFriends) {
                                                      // Call your API to send friend request
                                                      await makefriendapi(
                                                        friend['id'],
                                                      );
                                                      print(
                                                        "receiver frd list id : ${friend['id']}",
                                                      );
                                                    }

                                                    // Refresh the friends list to reflect new pending statuses
                                                    await listconciergerapi();

                                                    Get.back();
                                                    Get.snackbar(
                                                      'Friend Request Sent',
                                                      'Friend requests sent to ${selectedFriends.length} friends',
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.7),
                                                      colorText: Colors.white,
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                    );
                                                  },
                                                  radius: 3.0.w,
                                                  color: AppColors.maincolor,
                                                  fontcolor: Colors.white,
                                                  height: 4.5.h,
                                                  width: 39.w,
                                                  fontsize: 16.sp,
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
                          print("New Friend Pressed");
                        },
                        icon: Icon(Icons.person_add_alt_1, color: Colors.black),
                        label: Text(
                          "New Friend",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      )
                      : FloatingActionButton.extended(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(900),
                        ),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          addpostsheet(
                            context,
                            (loginModel?.data?.user?.id).toString(),
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.add_circled,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Add Post",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      )))
              : FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(900),
                ),
                backgroundColor: Colors.white,
                onPressed: () {
                  Get.to(() => const ChatBotScreen());
                },
                icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
                label: Text(
                  "Ai Concierge",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
    );
  }

  void shareConciergeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      print("No image URL to share.");
      return;
    }

    try {
      Share.share(
        'Check out this concierge: $imageUrl',
        subject: "Check out this concierge's image!",
      );
    } catch (e) {
      print("Error sharing: $e");
    }
  }

  void MessageBoardApi() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "31";
    log("data jay chhe ${loginModel?.data?.user?.id.toString() ?? ""}");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().MessageBoardApi(data);
          messageBoardModal = MessageBoardModal.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200) {
            log("message board api data ave cje${response.body}");

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
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
              "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
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

  List<XFile> _images = [];

  Future<void> _pickImages(Function setModalState) async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      setModalState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void showCommentBottomSheet(BuildContext context, String postId) {
    bool isLoading = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Move the controller and isSendingComment inside the StatefulBuilder
            TextEditingController _commentController = TextEditingController();
            bool isSendingComment = false;

            // This ensures the loading spinner disappears right after render
            Future.delayed(Duration.zero, () {
              if (isLoading) {
                setModalState(() => isLoading = false);
              }
            });

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Top Drag Handle
                        Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Comment List
                        Expanded(
                          child:
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : getpostCommentsModel == null ||
                                      getpostCommentsModel?.data == null ||
                                      getpostCommentsModel!.data!.isEmpty
                                  ? Center(child: Text("No comments found"))
                                  : ListView.builder(
                                    controller: scrollController,
                                    itemCount:
                                        getpostCommentsModel!.data!.length,
                                    itemBuilder: (context, index) {
                                      final comment =
                                          getpostCommentsModel!.data![index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey.shade300,
                                          backgroundImage: null,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  comment.user?.profile ?? '',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        title: Text(comment.user?.name ?? ''),
                                        subtitle: Text(comment.comment ?? ''),
                                      );
                                    },
                                  ),
                        ),

                        // Comment Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: "Write a comment...",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            isSendingComment
                                ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : IconButton(
                                  icon: Icon(Icons.send, color: Colors.blue),
                                  onPressed: () async {
                                    if (_commentController.text.trim().isEmpty)
                                      return;

                                    setModalState(
                                      () => isSendingComment = true,
                                    );

                                    await sendComment(
                                      context,
                                      _commentController.text.trim(),
                                      postId,
                                      () {
                                        _commentController.clear();
                                        setModalState(() {});
                                      },
                                    );

                                    setModalState(
                                      () => isSendingComment = false,
                                    );
                                  },
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  final addPostFormkey = GlobalKey<FormState>();

  void addpostsheet(BuildContext parentContext, String userid) {
    bool _imagesValid = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future.delayed(Duration.zero, () {
              if (isSending) {
                setModalState(() => isSending = false);
              }
            });

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: addPostFormkey,
                child: SingleChildScrollView(
                  // controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Add Post",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _descController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      batan(
                        title: "Choose Image",
                        route: () {
                          _pickImages(setModalState);
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        width: 50.w,
                        radius: 12.0,
                        iconData: Icons.image,
                        fontsize: 17.sp,
                      ),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        const Text(
                          "Selected Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_images[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 24),
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: AppColors.maincolor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (addPostFormkey.currentState!.validate()) {
                              Addpostapi();
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: Center(
                            child: Text(
                              "Add Post",
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ),
                        ),
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
  }

  void UpdatePostData(BuildContext parentContext, dynamic post) {
    TextEditingController descUpdateController = TextEditingController(
      text: post?.text?.toString() ?? '',
    );

    List<String> _existingImages = List<String>.from(post?.file ?? []);
    List<XFile> _newImages = [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: addPostFormkey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Edit Post",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: descUpdateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          searchIcon: Icon(Icons.description),
                        ),
                      ),
                      SizedBox(height: 16),
                      batan(
                        title: "Choose Image",
                        route: () async {
                          List<XFile>? picked = await _pickImages1(
                            setModalState,
                          );
                          if (picked != null) {
                            setModalState(() {
                              _newImages.addAll(picked);
                            });
                          }
                          // _pickImages(setModalState);
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 50,
                        width: 200,
                        radius: 12.0,
                        iconData: Icons.image,
                        fontsize: 17,
                      ),
                      SizedBox(height: 16),

                      /// SHOW EXISTING IMAGES (FROM API)
                      if (_existingImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Existing Images"),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _existingImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            _existingImages[index],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              _existingImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      /// SHOW NEW IMAGES (LOCAL)
                      if (_newImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("New Images"),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _newImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            File(_newImages[index].path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              _newImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 24),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.maincolor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (addPostFormkey.currentState!.validate()) {
                              String updatedDesc =
                                  descUpdateController.text.trim();
                              List<String> updatedImages = [..._existingImages];
                              List<XFile> newImages = _newImages;

                              updatepostapi(
                                post.id.toString(),
                                updatedDesc,
                                updatedImages,
                                newImages,
                              );

                              Navigator.pop(context);
                            }
                          },

                          child: Center(
                            child: Text(
                              "Update Post",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ),
                        ),
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
  }

  Future<List<XFile>?> _pickImages1(Function setModalState) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      return pickedFiles;
    }
    return null;
  }

  void showCommentBottomSheetlocalpostcooments(
    BuildContext context,
    String postId,
  ) {
    bool isLoading = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Move the controller and isSendingComment inside the StatefulBuilder
            TextEditingController _commentControllerlocalpost =
                TextEditingController();
            bool isSendingComment = false;

            // This ensures the loading spinner disappears right after render
            Future.delayed(Duration.zero, () {
              if (isLoading) {
                setModalState(() => isLoading = false);
              }
            });

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Top Drag Handle
                        Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Comment List
                        Expanded(
                          child:
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : localpost_comments_Model == null ||
                                      localpost_comments_Model?.data == null ||
                                      localpost_comments_Model!.data!.isEmpty
                                  ? Center(child: Text("No comments found"))
                                  : ListView.builder(
                                    controller: scrollController,
                                    itemCount:
                                        localpost_comments_Model!.data!.length,
                                    itemBuilder: (context, index) {
                                      final comment =
                                          localpost_comments_Model!
                                              .data![index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey.shade300,
                                          backgroundImage: null,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  comment.user?.profile ?? '',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image(
                                                        image: AssetImage(
                                                          image,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ),
                                        title: Text(comment.user?.name ?? ''),
                                        subtitle: Text(comment.comment ?? ''),
                                      );
                                    },
                                  ),
                        ),

                        // Comment Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentControllerlocalpost,
                                decoration: InputDecoration(
                                  hintText: "Write a comment...",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            isSendingComment
                                ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : IconButton(
                                  icon: Icon(Icons.send, color: Colors.blue),
                                  onPressed: () async {
                                    if (_commentControllerlocalpost.text
                                        .trim()
                                        .isEmpty)
                                      return;

                                    // setModalState(
                                    //     () => isSendingComment = true);

                                    SendComment(
                                      _commentControllerlocalpost.text,
                                      postId,
                                    );

                                    // setModalState(
                                    //     () => isSendingComment = false);
                                  },
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> listconciergerapi() async {
    await checkInternet().then((internet) async {
      if (internet) {
        try {
          //EasyLoading.show(status: 'Loading...'); // Add loading indicator
          final response = await MessageBoardProvider().conciergerlistApi(
            (loginModel?.data?.user?.id).toString(),
          );

          if (response.statusCode == 200) {
            chatuserlistmodel = ChatUserListModel.fromJson(
              json.decode(response.body),
            );

            print("api list : ${response.body}");
            for (var user in chatuserlistmodel!.data!) {
              print(
                "User : ${user.user?.firstName} ${user.user?.lastName} - Status: ${user.requestStatuses ?? 'No Status (New User)'}",
              );

              user.requestStatuses ??= [];
            }
          }
          //EasyLoading.dismiss(); // Hide loading indicator
        } catch (e) {
          //EasyLoading.dismiss(); // Hide loading indicator on error
          print("Error fetching friend list: $e");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  GetMyJoinGroup() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
    };
    print("group list parameter : $data");
    setState(() {
      isSending = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().GetMyJoinGroup(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            getgrouplistmodel = GetGroupListModel.fromJson(responseData);
            log("near by data ave  che ceh ${response.body}");
            setState(() {
              isSending = false;
            });
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            isSending = false;
            print("Too many requests");
          } else {
            isSending = false;
            print("Internal Server Error");
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> showCancelConfirmationDialog(
    String PostId, {
    required BuildContext context,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental tap outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Text(
                  "Are you sure?",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure do you want delete this post?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: batan(
                        title: "No",
                        width: 30.w,
                        route: () {
                          Get.back();
                        },
                        color: AppColors.white,
                        fontcolor: Colors.black,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: batan(
                        title: "Yes",
                        route: () {
                          DeleteLocalPost(PostId);
                          Get.back();
                        },
                        width: 30.w,
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  localpostapi() {
    final Map<String, String> data = {
      'residentType': "residents",
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("Local post data parameter: $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localpostap(data);
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            localpost_model = Localpost_model.fromJson(responseData);
            log("local post data: ${response.body}");
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending = false;
            });
            print("Too many requests or internal server error.");
          } else {
            setState(() {
              isSending = false;
            });
            print("Unexpected error. Status code: ${response.statusCode}");
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending = false;
          });
          print("❌ Exception caught in localpostapi(): $e");
          print("📌 StackTrace:\n$stackTrace");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  EditPost() {
    final Map<String, String> data = {
      'residentType': "residents",
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("Local post data parameter: $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localpostap(data);
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            localpost_model = Localpost_model.fromJson(responseData);
            _descController.text =
                localpost_model?.data?[0].text.toString() ?? "";
            log("local post data: ${response.body}");
            // addpostsheet(
            //     isUpdate: true,
            //     context, (loginModel?.data?.user?.id).toString());
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending = false;
            });
            print("Too many requests or internal server error.");
          } else {
            setState(() {
              isSending = false;
            });
            print("Unexpected error. Status code: ${response.statusCode}");
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending = false;
          });
          print("❌ Exception caught in localpostapi(): $e");
          print("📌 StackTrace:\n$stackTrace");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  DeleteLocalPost(String id) {
    final Map<String, String> data = {'id': id};
    print("Local post data parameter: $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().DeletePost(data);
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            // localpost_model = Localpost_model.fromJson(responseData);
            log("local post data: ${response.body}");
            localpostapi();

            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending = false;
            });
            print("Too many requests or internal server error.");
          } else {
            setState(() {
              isSending = false;
            });
            print("Unexpected error. Status code: ${response.statusCode}");
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending = false;
          });
          print("❌ Exception caught in localpostapi(): $e");
          print("📌 StackTrace:\n$stackTrace");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  creategrouplistdAp() {
    final Map<String, String> data = {
      'created_by': (loginModel?.data?.user?.id).toString(),
      'name': groupNameController.text.toString(),
      'details': "",
      //'members[0]' : "",
      // 'images' : "",
    };
    //
    // for (int i = 0; i < selectedMembers.length; i++) {
    //   data['members[$i]'] = selectedMembers[i].id.toString();
    // }

    print("group list parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider()
            .creategroupapi(data, selectedMembers, imageFile: selectedImage)
            .then((response) async {
              if (response.statusCode == 200) {
                var responseData = json.decode(response.body);
                creategroupmodel = CreateGroupModel.fromJson(responseData);
                print("group check");
                // getgrouplistdAp();
                // print("response check : ${responseData}");

                await refreshGroupList();
                groupNameController.clear();
                selectedMembers.clear();
                selectedImage = null;
                imagePath = '';
                setState(() {
                  isLoading = false;
                });

                // Get.snackbar(
                //   'Success',
                //   'Group created successfully',
                //   backgroundColor: Colors.green.withOpacity(0.7),
                //   colorText: Colors.white,
                //   snackPosition: SnackPosition.BOTTOM,
                //   duration: Duration(seconds: 2),
                // );
              } else if (response.statusCode == 422) {
                print("Validation error");
                print("Too many requests");
                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
                print("Internal Server Error");
              }
            });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  makefriendapi(dynamic receiverId) {
    final Map<String, String> data = {
      'sender_id': (loginModel?.data?.user?.id).toString(),
      'receiver_id': receiverId.toString(),
    };

    print("friend request parameter: $data");

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider()
            .Friendrequestapi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                var responseData = json.decode(response.body);
                createfriendModel = CreateFriendModel.fromJson(responseData);
                print("Friend request sent successfully");
              } else if (response.statusCode == 429) {
                print("Too many requests");
                Get.snackbar(
                  'Error',
                  'Too many requests. Please try again later.',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                print("Internal Server Error: ${response.statusCode}");
              }
            })
            .catchError((error) {
              print("API Error: $error");
            });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getfriendlistdAp() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
    };
    print("group list parameter : $data");
    setState(() {
      isSending = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().GetFriendListapi(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            getfriendListModel = GetFriendListModel.fromJson(responseData);
            setState(() {});
            print("Friend list done");
            setState(() {
              isSending = false;
            });
          } else if (response.statusCode == 429) {
            setState(() {
              isSending = false;
            });
            print("Too many requests");
          } else {
            setState(() {
              isSending = false;
            });
            print("Internal Server Error");
          }
        });
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // New function to properly refresh group list and update UI
  Future<void> refreshGroupList() async {
    final Map<String, String> data = {
      'created_by': (loginModel?.data?.user?.id).toString(),
    };

    print("Refreshing group list with parameters: $data");
    setState(() {
      // Optionally show loading indicator while fetching
      isSending = true;
    });

    try {
      bool internet = await checkInternet();
      if (internet) {
        final response = await MessageBoardProvider().getgrouplistapi(data);

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);

          setState(() {
            // Optionally show loading indicator while fetching
            isSending = false;
          });
          setState(() {
            getgrouplistmodel = GetGroupListModel.fromJson(responseData);
            print("Group list updated successfully");
          });

          return;
        } else if (response.statusCode == 429) {
          setState(() {
            // Optionally show loading indicator while fetching
            isSending = false;
          });
          print("Too many requests");
        } else {
          setState(() {
            // Optionally show loading indicator while fetching
            isSending = false;
          });
          print("Internal Server Error");
        }
      } else {
        setState(() {
          // Optionally show loading indicator while fetching
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    } catch (e) {
      print("Error refreshing group list: $e");
    }
  }

  void postslikeap(int index, VoidCallback onComplete) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'type': 'post',
      'post_offer_promo_id': (messageBoardModal?.data?[index].id).toString(),
    };

    print("post like na data : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().postlikeapii(data).then((response) async {
          if (response.statusCode == 200) {
            messageboardpostlikeModel = MessageboardpostLikeModel.fromJson(
              json.decode(response.body),
            );
          }
          if (mounted) {
            onComplete();
          }
        });
      } else {
        onComplete();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void postslikelocalap(int index, VoidCallback onComplete) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'type': 'post',
      'post_offer_promo_id': (localpost_model?.data?[index].id).toString(),
    };

    print("post like na data : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().postlikeapii(data).then((response) async {
          if (response.statusCode == 200) {
            messageboardpostlikeModel = MessageboardpostLikeModel.fromJson(
              json.decode(response.body),
            );
          }
          onComplete();
        });
      } else {
        onComplete();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void Addpostapi() {
    final Map<String, String> data = {
      'user_post_id': (loginModel?.data?.user?.id).toString(),
      'description': _descController.text.trim(),
    };

    print("Post data: $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        // ✅ Pass image list to the API function
        MessageBoardProvider()
            .addpostapWithImages(bodyData: data, images: _images)
            .then((response) async {
              if (response.statusCode == 200) {
                var responseData = json.decode(response.body);
                add_Post_Model = Add_Post_Model.fromJson(responseData);
                print("Post upload successful");
                localpostapi();
                _descController.clear();
                _images = [];
              } else if (response.statusCode == 429) {
                print("Too many requests");
              } else {
                print("Internal Server Error");
              }
              if (mounted) {
                setState(() {
                  isSending = false;
                });
              }
            });
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // void updatepostapi(
  //     String postId,
  //     String description,
  //     List<String> existingImageUrls,
  //     List<XFile> newImages,
  //     ) {
  //   final Map<String, String> data = {
  //     'post_id': postId,
  //     'description': description,
  //   };
  //
  //   print("Post data: $data");
  //
  //   setState(() {
  //     isSending = true;
  //   });
  //
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       // Convert XFile to File for upload
  //       List<File> imageFiles = newImages.map((xfile) => File(xfile.path)).toList();
  //
  //       // ✅ Call the provider function
  //       MessageBoardProvider()
  //           .UpdatePost(
  //         bodyData: data,
  //         images: imageFiles,
  //       )
  //           .then((response) async {
  //         if (response.statusCode == 200) {
  //           var responseData = json.decode(response.body);
  //           print("Post update successful");
  //           localpostapi();
  //           _descController.clear();
  //           _images = [];
  //         } else if (response.statusCode == 429) {
  //           print("Too many requests");
  //         } else {
  //           print("Internal Server Error");
  //         }
  //
  //         if (mounted) {
  //           setState(() {
  //             isSending = false;
  //           });
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isSending = false;
  //       });
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }
  void updatepostapi(
    String postId,
    String description,
    List<String> existingImageUrls,
    List<XFile> newImages,
  ) {
    final Map<String, String> data = {
      'post_id': postId,
      'description': description,
      // 'existing_images': existingImageUrls, // 🔁 Include existing image URLs
    };

    print("Post data: $data");

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        List<File> imageFiles =
            newImages.map((xfile) => File(xfile.path)).toList();

        MessageBoardProvider()
            .UpdatePost(bodyData: data, images: imageFiles)
            .then((response) async {
              if (response.statusCode == 200) {
                var responseData = json.decode(response.body);
                print("Post update successful");

                localpostapi(); // Refresh local posts
                _descController.clear();
                _images = []; // Clear local image state
              } else if (response.statusCode == 429) {
                print("Too many requests");
              } else {
                print("Internal Server Error");
              }

              if (mounted) {
                setState(() {
                  isSending = false;
                });
              }
            });
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> getComments(BuildContext context, String postId) async {
    currentPostId = postId;
    final Map<String, String> data = {'post_id': postId};
    print("comments list parameter : $data");

    bool internet = await checkInternet();
    if (!internet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getcommentsapi(data);

      if (response.statusCode == 200) {
        getpostCommentsModel = GetPostCommentsModel.fromJson(
          json.decode(response.body),
        );
      } else {
        getpostCommentsModel = null;
      }
    } catch (e) {
      getpostCommentsModel = null;
      print("Error fetching comments: $e");
    }

    if (context.mounted) {
      showCommentBottomSheet(context, postId);
    }
  }

  getComments1(String postId) {
    final Map<String, String> data = {'post_id': postId};
    setState(() {
      isSending = true;
    });
    print("RegisterApi : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().getcommentslocalpostap(data).then((
          response,
        ) async {
          localpost_comments_Model = Localpost_comments_Model.fromJson(
            json.decode(response.body),
          );
          if (response.statusCode == 200) {
            print("adfdsfsdf${response.body}");
            showCommentBottomSheetlocalpostcooments(context, postId);

            print(
              "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
            );
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else {
            setState(() {
              isSending = false;
            });
            log("Error");
          }
        });
      } else {
        setState(() {
          isSending = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  SendComment(String commentText, String postId) {
    final Map<String, String> data = {
      'user_post_id': (loginModel?.data?.user?.id).toString(),
      'post_id': postId,
      'type': "comment",
      'comment': commentText,
      'user_type': '4',
    };
    setState(() {
      isSending = true;
    });
    print("RegisterApi : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().sendcommentsapi(data).then((response) async {
          sendpostCommentsModel = SendPostCommentsModel.fromJson(
            json.decode(response.body),
          );
          if (response.statusCode == 200) {
            print("adfdsfsdf${response.body}");
            getComments1(postId);

            // showCommentBottomSheetlocalpostcooments(context, postId);

            print(
              "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
            );
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else {
            setState(() {
              isSending = false;
            });
            log("Error");
          }
        });
      } else {
        setState(() {
          isSending = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> getCommentslocalpost(BuildContext context, String postId) async {
    currentPostId = postId;
    final Map<String, String> data = {'post_id': postId};
    print("comments list parameter : $data");

    bool internet = await checkInternet();
    if (!internet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getcommentslocalpostap(
        data,
      );

      if (response.statusCode == 200) {
        localpost_comments_Model = Localpost_comments_Model.fromJson(
          json.decode(response.body),
        );
      } else {
        // getpostCommentsModel = null;
      }
    } catch (e) {
      // getpostCommentsModel = null;
      print("Error fetching comments: $e");
    }

    if (context.mounted) {
      showCommentBottomSheetlocalpostcooments(context, postId);
    }
  }

  Future<void> sendComment(
    BuildContext context,
    String commentText,
    String postId,
    VoidCallback onSuccess,
  ) async {
    final Map<String, String> data = {
      'user_post_id': (loginModel?.data?.user?.id).toString(),
      'post_id': postId,
      'type': "comment",
      'comment': commentText,
      'user_type': '4',
    };

    print("sending comment parameter : $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().sendcommentsapi(data);

          if (response.statusCode == 200) {
            sendpostCommentsModel = SendPostCommentsModel.fromJson(
              json.decode(response.body),
            );
            print("Comment sent successfully");

            // Refresh comment list after send
            final refreshResponse = await MessageBoardProvider().getcommentsapi(
              {'post_id': postId},
            );
            if (refreshResponse.statusCode == 200) {
              getpostCommentsModel = GetPostCommentsModel.fromJson(
                json.decode(refreshResponse.body),
              );
              onSuccess();
            }
          } else {
            print("Failed to send comment: ${response.statusCode}");
          }
        } catch (e) {
          print("Error sending comment: $e");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  showrequestapi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().GetRequestApi(
            (loginModel?.data?.user?.id).toString(),
          );

          if (response.statusCode == 200) {
            getrequestModel = GetRequestModel.fromJson(
              json.decode(response.body),
            );

            print("api request list : ${response.body}");
          }
        } catch (e) {
          print("error");
        }
      } else {
        // EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  bool showControls = true; // To show/hide the play button

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showControls =
              !showControls; // Toggle visibility of play/pause button
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
              : const Center(child: CircularProgressIndicator()),
          if (showControls) // Show only when tapped
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: _togglePlayPause,
            ),
        ],
      ),
    );
  }
}
