import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wavee/Screen/ViewProfile/Model/profile_model.dart';
import 'package:wavee/Screen/ViewProfile/Provider/profile_provider.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/bottom_bar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/input_decoration.dart';
import '../../../comman/loader.dart';
import '../../../comman/viewPdfFunction.dart';
import '../../HomeNewPage/Model/message_board_modal.dart';
import '../../HomeNewPage/Provider/homescreen_provider.dart';
import '../Model/Add_Post_Model.dart';
import '../Model/ChatUserListModel.dart';
import '../Model/CreateFriendModel.dart';
import '../Model/CreateGroupModel.dart';
import '../Model/GetFriendListModel.dart';
import '../Model/GetGroupListModel.dart';
import '../Model/GetPostCommentsModel.dart';
import '../Model/GetRequestModel.dart';
import '../Model/Localpost_model.dart';
import '../Model/PostLikeModel.dart';
import '../Model/SendPostCommentsModel.dart';
import '../Provider/messsage_board_provider.dart';

class Messageboard extends StatefulWidget {
  int? selected;

  Messageboard({super.key, this.selected});

  @override
  State<Messageboard> createState() => _MessageboardState();
}

TextEditingController _descController = TextEditingController();
TextEditingController _title = TextEditingController();
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
  bool isSending1 = false;
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
  List<dynamic> pendingRequests = [];
  List<String> pendingFriendRequests = [];
  String currentPostId = '';
  final PagingController<int, Data1> _pagingController = PagingController(
    firstPageKey: 1,
  );
  final PageController _pageController = PageController();

  String formatPostDate(String? createdAt) {
    if (createdAt == null) return "";
    tz.initializeTimeZones();
    final ukTimeZone = tz.getLocation('Europe/London');
    final utcDate = DateTime.parse(createdAt);
    final postDateUk = tz.TZDateTime.from(utcDate, ukTimeZone);
    final nowUk = tz.TZDateTime.now(ukTimeZone);
    final postDateDay = DateTime(
      postDateUk.year,
      postDateUk.month,
      postDateUk.day,
    );
    final nowDay = DateTime(nowUk.year, nowUk.month, nowUk.day);

    final difference = nowDay.difference(postDateDay).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return "$difference days ago";
    }
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {}
    setState(() {
      isLoading = true;
    });
    MessageBoardApi();
    GetProfile();
    fetchData();
    listconciergerapi();
    localpostapi();
    setState(() {
      GetMyJoinGroup();
      getfriendlistdAp();
    });
    _pagingController.addPageRequestListener(_fetchPage);
    loadGroups();
    Future.delayed(Duration(milliseconds: 100), () {
      _loadAllLikesLocal();
      _loadAllLikes();
    });

    initPendingRequests();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    final params = {
      'residentType': 'residents',
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
      'page': pageKey.toString(),
    };

    try {
      final res = await MessageBoardProvider().localPostApi(params);
      final model = Localpost_model.fromJson(res.data);
      final posts = model.data?.data ?? [];
      final totalPages = model.data?.totalPages ?? 1;
      final isLast = pageKey >= totalPages;

      await Future.delayed(const Duration(milliseconds: 500));

      // _ensureToggleLists(posts.length);

      if (isLast) {
        _pagingController.appendLastPage(posts);
      } else {
        _pagingController.appendPage(posts, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadGroups() async {
    setState(() {
      isSending = true;
    });

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
    } catch (e) {}
  }

  Future<void> _loadAllLikesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = loginModel?.data?.user?.id.toString() ?? '';

      final totalPosts = localpost_model?.data?.data?.length ?? 0;

      isLikedListLocal = List.generate(totalPosts, (index) => false);
      isLikeInProgressListLocal = List.generate(totalPosts, (index) => false);

      for (int i = 0; i < totalPosts; i++) {
        if (i < isLikedListLocal.length &&
            localpost_model?.data?.data?.length != null &&
            i < localpost_model!.data!.data!.length) {
          final postId = localpost_model?.data?.data?[i].id.toString();
          if (postId != null) {
            final key = 'image_like_${postId}_$userId';
            isLikedListLocal[i] = prefs.getBool(key) ?? false;
          }
        }
      }
    } catch (e) {}
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
    final key = 'image_like_${localpost_model?.data?.data?[index].id}_$userId';
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

  List<String> options = ['All', 'My Building', 'Local', 'Friends', 'Group'];
  String selectedOption = 'My Building';

  Future<void> initPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRequests = prefs.getStringList('pendingFriendRequests') ?? [];
    pendingFriendRequests = storedRequests;
  }

  Future<void> savePendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pendingFriendRequests', pendingFriendRequests);
  }

  Future<void> checkAcceptedRequests(List<dynamic> friendsList) async {
    bool hasChanges = false;
    List<String> updatedPendingRequests = List.from(pendingFriendRequests);

    for (String requestId in pendingFriendRequests) {
      bool isNowFriend = friendsList.any(
        (friend) =>
            friend.user?.id.toString() == requestId &&
            friend.status == 'accepted',
      );

      if (isNowFriend) {
        updatedPendingRequests.remove(requestId);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      pendingFriendRequests = updatedPendingRequests;
      await savePendingRequests();
    }
  }

  Offset _cartButtonPosition = Offset.zero;
  int cartCount = cartDetailsModel?.data?.length ?? 0;

  bool isDetailLoading = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey_messageboard =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                  height: 95.h,
                  decoration: BoxDecoration(
                    color: AppColors.bgcolor,
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                      left: BorderSide(color: Colors.grey),
                      right: BorderSide(color: Colors.grey),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Text(
                        "Message Board",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        height: 0.5.h,
                        width: 23.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: AppColors.maincolor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 5.h,
                            width: 40.w,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: AppColors.white,
                                borderRadius: BorderRadius.circular(10),

                                hint: Text(
                                  "Select option",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                value: selectedOption,
                                icon: Icon(Icons.keyboard_arrow_down),
                                items:
                                    ['My Building', 'Local']
                                        .map(
                                          (option) => DropdownMenuItem(
                                            value: option,
                                            child: Container(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedOption = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          selectedOption == "My Building"
                              ? SizedBox()
                              : GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 0.8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child:
                                      // selectedOption == "All"
                                      //     ?SizedBox()
                                      // InkWell(
                                      //         onTap: () {
                                      //           Get.to(() => const ChatBotScreen());
                                      //         },
                                      //         child: Row(
                                      //           children: [
                                      //             Text(
                                      //               "Ai Concierge",
                                      //               style: TextStyle(
                                      //                 fontFamily: AppConstants.manrope,
                                      //                 fontSize: 16.sp,
                                      //                 fontWeight: FontWeight.bold,
                                      //                 color: Colors.grey,
                                      //               ),
                                      //             ),
                                      //             SizedBox(width: 2.w),
                                      //             Icon(CupertinoIcons.chat_bubble_2,
                                      //                 color: Colors.grey),
                                      //           ],
                                      //         ),
                                      //       )
                                      //     :
                                      selectedOption == "My Building"
                                          ? SizedBox()
                                          // InkWell(
                                          //             onTap: () {
                                          //               Get.to(() => const ChatBotScreen());
                                          //             },
                                          //             child: Row(
                                          //               children: [
                                          //                 Text(
                                          //                   "Ai Concierge",
                                          //                   style: TextStyle(
                                          //                     fontFamily:
                                          //                         AppConstants.manrope,
                                          //                     fontSize: 16.sp,
                                          //                     fontWeight: FontWeight.bold,
                                          //                     color: Colors.grey,
                                          //                   ),
                                          //                 ),
                                          //                 SizedBox(width: 2.w),
                                          //                 Icon(CupertinoIcons.chat_bubble_2,
                                          //                     color: Colors.grey),
                                          //               ],
                                          //             ),
                                          //           )
                                          : selectedOption == "Local"
                                          ? InkWell(
                                            onTap: () {
                                              addpostsheet(
                                                context,
                                                (loginModel?.data?.user?.id)
                                                    .toString(),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Add Post",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Icon(
                                                  Icons
                                                      .add_circle_outline_rounded,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          )
                                          : SizedBox(),

                                  //  selectedOption == "Friends"
                                  //     ? InkWell(
                                  //         onTap: () async {
                                  //           await listconciergerapi();
                                  //           showDialog(
                                  //             context: context,
                                  //             builder: (context) {
                                  //               List<
                                  //                       Map<String,
                                  //                           dynamic>>
                                  //                   selectedFriends =
                                  //                   [];
                                  //               String
                                  //                   friendSelectionError =
                                  //                   "";
                                  //               final ScrollController
                                  //                   dialogScrollController =
                                  //                   ScrollController();
                                  //               final ScrollController
                                  //                   listScrollController =
                                  //                   ScrollController();

                                  //               final TextEditingController
                                  //                   searchController =
                                  //                   TextEditingController();
                                  //               String
                                  //                   searchQuery =
                                  //                   "";
                                  //               return StatefulBuilder(
                                  //                 builder: (context,
                                  //                     setState) {
                                  //                   List<dynamic>
                                  //                       filteredFriends =
                                  //                       chatuserlistmodel
                                  //                               ?.data
                                  //                               ?.where((user) {
                                  //                             final String
                                  //                                 fullName =
                                  //                                 "${user.user?.firstName ?? ''} ${user.user?.lastName ?? ''}".toLowerCase();
                                  //                             return fullName.contains(searchQuery.toLowerCase());
                                  //                           })?.toList() ??
                                  //                           [];
                                  //                   return Dialog(
                                  //                     shape:
                                  //                         RoundedRectangleBorder(
                                  //                       borderRadius:
                                  //                           BorderRadius.circular(
                                  //                               20),
                                  //                     ),
                                  //                     insetPadding: EdgeInsets.symmetric(
                                  //                         horizontal:
                                  //                             12,
                                  //                         vertical:
                                  //                             16),
                                  //                     child:
                                  //                         Container(
                                  //                       constraints:
                                  //                           BoxConstraints(
                                  //                         maxHeight:
                                  //                             MediaQuery.of(context).size.height *
                                  //                                 0.8,
                                  //                       ),
                                  //                       padding: EdgeInsets.symmetric(
                                  //                           horizontal:
                                  //                               16,
                                  //                           vertical:
                                  //                               16),
                                  //                       decoration:
                                  //                           BoxDecoration(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(20),
                                  //                         color: Colors
                                  //                             .white,
                                  //                       ),
                                  //                       child:
                                  //                           SingleChildScrollView(
                                  //                         keyboardDismissBehavior:
                                  //                             ScrollViewKeyboardDismissBehavior.onDrag,
                                  //                         controller:
                                  //                             dialogScrollController,
                                  //                         child:
                                  //                             Column(
                                  //                           mainAxisSize:
                                  //                               MainAxisSize.min,
                                  //                           children: [
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.center,
                                  //                               children: [
                                  //                                 Icon(Icons.person_add_alt_1, color: AppColors.maincolor, size: 24),
                                  //                                 SizedBox(width: 2.w),
                                  //                                 Text(
                                  //                                   'Add New Friend',
                                  //                                   style: TextStyle(
                                  //                                     color: Colors.black,
                                  //                                     fontSize: 18.sp,
                                  //                                     fontWeight: FontWeight.w700,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                   ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                             SizedBox(height: 1.5.h),
                                  //                             Container(
                                  //                               decoration: BoxDecoration(
                                  //                                 color: Colors.grey.shade100,
                                  //                                 borderRadius: BorderRadius.circular(10),
                                  //                               ),
                                  //                               child: TextField(
                                  //                                 controller: searchController,
                                  //                                 onChanged: (value) {
                                  //                                   setState(() {
                                  //                                     searchQuery = value;
                                  //                                   });
                                  //                                 },
                                  //                                 decoration: InputDecoration(
                                  //                                   hintText: 'Search friends',
                                  //                                   prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                  //                                   border: InputBorder.none,
                                  //                                   contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  //                                 ),
                                  //                                 style: TextStyle(
                                  //                                   fontSize: 14.sp,
                                  //                                   fontFamily: AppConstants.manrope,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                             SizedBox(height: 1.h),
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //                               children: [
                                  //                                 Text(
                                  //                                   'Select Friends',
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16.sp,
                                  //                                     fontWeight: FontWeight.w600,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                   ),
                                  //                                 ),
                                  //                                 Text(
                                  //                                   '${selectedFriends.length} selected',
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 14.sp,
                                  //                                     fontWeight: FontWeight.w500,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                     color: AppColors.maincolor,
                                  //                                   ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                             SizedBox(height: 0.8.h),
                                  //                             Container(
                                  //                               height: 32.h,
                                  //                               decoration: BoxDecoration(
                                  //                                 color: Colors.white,
                                  //                                 borderRadius: BorderRadius.circular(12),
                                  //                               ),
                                  //                               child: Scrollbar(
                                  //                                 thumbVisibility: true,
                                  //                                 controller: listScrollController,
                                  //                                 radius: Radius.circular(8),
                                  //                                 thickness: 4,
                                  //                                 child: filteredFriends.isEmpty
                                  //                                     ? Center(
                                  //                                         child: Text(
                                  //                                           searchQuery.isEmpty ? "No users available" : "No matching friends found",
                                  //                                           style: TextStyle(
                                  //                                             fontSize: 14.sp,
                                  //                                             fontFamily: AppConstants.manrope,
                                  //                                             color: Colors.grey.shade600,
                                  //                                           ),
                                  //                                         ),
                                  //                                       )
                                  //                                     : ListView.separated(
                                  //                                         controller: listScrollController,
                                  //                                         padding: EdgeInsets.zero,
                                  //                                         itemCount: filteredFriends.length,
                                  //                                         separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                                  //                                         itemBuilder: (context, index) {
                                  //                                           final userData = filteredFriends[index];
                                  //                                           final userId = userData.user?.id.toString();
                                  //                                           final requestStatus = userData.requestStatuses ?? [];
                                  //                                           final lowerCaseStatuses = requestStatus.map((status) => status.toLowerCase()).toList();
                                  //                                           final friendData = {
                                  //                                             'id': userId,
                                  //                                             'name': "${userData.user?.firstName ?? ''} ${userData.user?.lastName ?? ''}",
                                  //                                             'image': userData.user?.profile ?? '',
                                  //                                           };
                                  //                                           bool isPending = lowerCaseStatuses.contains("pending");
                                  //                                           bool isAccepted = lowerCaseStatuses.contains("accepted");
                                  //                                           bool isCancelled = lowerCaseStatuses.contains("cancel") || lowerCaseStatuses.contains("cancelled") || lowerCaseStatuses.contains("canceled");
                                  //                                           bool canSelect = requestStatus.isEmpty;
                                  //                                           bool isSelected = selectedFriends.any((element) => element['id'] == friendData['id']);
                                  //                                           return ListTile(
                                  //                                             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  //                                             onTap: () {
                                  //                                               if (canSelect) {
                                  //                                                 setState(() {
                                  //                                                   if (isSelected) {
                                  //                                                     selectedFriends.removeWhere((element) => element['id'] == friendData['id']);
                                  //                                                   } else {
                                  //                                                     selectedFriends.add(friendData);
                                  //                                                   }
                                  //                                                   friendSelectionError = "";
                                  //                                                 });
                                  //                                               }
                                  //                                             },
                                  //                                             leading: CircleAvatar(
                                  //                                               radius: 20,
                                  //                                               backgroundColor: Colors.grey.shade200,
                                  //                                               child: ClipOval(
                                  //                                                 child: CachedNetworkImage(
                                  //                                                   imageUrl: userData.user?.profile ?? "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                  //                                                   placeholder: (context, url) => Image.asset(
                                  //                                                     'assets/images/person.jpg',
                                  //                                                     fit: BoxFit.cover,
                                  //                                                   ),
                                  //                                                   errorWidget: (context, url, error) => Image.asset(
                                  //                                                     'assets/images/person.jpg',
                                  //                                                     fit: BoxFit.cover,
                                  //                                                   ),
                                  //                                                   width: 40,
                                  //                                                   height: 40,
                                  //                                                   fit: BoxFit.cover,
                                  //                                                 ),
                                  //                                               ),
                                  //                                             ),
                                  //                                             title: Text(
                                  //                                               "${userData.user?.firstName ?? ''} ${userData.user?.lastName ?? ''}",
                                  //                                               style: TextStyle(
                                  //                                                 fontFamily: AppConstants.manrope,
                                  //                                                 fontWeight: FontWeight.w500,
                                  //                                                 fontSize: 14.sp,
                                  //                                                 color: isPending
                                  //                                                     ? AppColors.maincolor
                                  //                                                     : isAccepted
                                  //                                                         ? Colors.green
                                  //                                                         : isCancelled
                                  //                                                             ? Colors.red
                                  //                                                             : null,
                                  //                                               ),
                                  //                                             ),
                                  //                                             subtitle: requestStatus.isNotEmpty
                                  //                                                 ? Text(
                                  //                                                     isPending
                                  //                                                         ? "Request Pending"
                                  //                                                         : isAccepted
                                  //                                                             ? "Friend"
                                  //                                                             : isCancelled
                                  //                                                                 ? "Cancelled"
                                  //                                                                 : "",
                                  //                                                     style: TextStyle(
                                  //                                                       fontFamily: AppConstants.manrope,
                                  //                                                       fontSize: 12.sp,
                                  //                                                       color: isPending
                                  //                                                           ? Colors.orange
                                  //                                                           : isAccepted
                                  //                                                               ? Colors.green
                                  //                                                               : isCancelled
                                  //                                                                   ? Colors.red
                                  //                                                                   : Colors.grey,
                                  //                                                       fontStyle: FontStyle.italic,
                                  //                                                     ),
                                  //                                                   )
                                  //                                                 : Text(
                                  //                                                     "New User",
                                  //                                                     style: TextStyle(
                                  //                                                       fontFamily: AppConstants.manrope,
                                  //                                                       fontSize: 12.sp,
                                  //                                                       color: Colors.grey,
                                  //                                                       fontStyle: FontStyle.italic,
                                  //                                                     ),
                                  //                                                   ),
                                  //                                             trailing: Checkbox(
                                  //                                               value: isSelected || isPending || isAccepted,
                                  //                                               onChanged: canSelect
                                  //                                                   ? (value) {
                                  //                                                       setState(() {
                                  //                                                         if (value == true) {
                                  //                                                           if (!isSelected) {
                                  //                                                             selectedFriends.add(friendData);
                                  //                                                           }
                                  //                                                         } else {
                                  //                                                           selectedFriends.removeWhere((element) => element['id'] == friendData['id']);
                                  //                                                         }
                                  //                                                         friendSelectionError = "";
                                  //                                                       });
                                  //                                                     }
                                  //                                                   : null,
                                  //                                               activeColor: isPending
                                  //                                                   ? Colors.orange
                                  //                                                   : isAccepted
                                  //                                                       ? Colors.green
                                  //                                                       : AppColors.maincolor,
                                  //                                               checkColor: Colors.white,
                                  //                                               fillColor: !canSelect
                                  //                                                   ? MaterialStateProperty.resolveWith((states) => isPending
                                  //                                                       ? Colors.orange.shade400
                                  //                                                       : isAccepted
                                  //                                                           ? Colors.green.shade400
                                  //                                                           : isCancelled
                                  //                                                               ? Colors.grey.shade400
                                  //                                                               : Colors.grey.shade400)
                                  //                                                   : null,
                                  //                                             ),
                                  //                                             tileColor: (isSelected || !canSelect)
                                  //                                                 ? (isPending
                                  //                                                     ? Colors.orange.withOpacity(0.05)
                                  //                                                     : isAccepted
                                  //                                                         ? Colors.green.withOpacity(0.05)
                                  //                                                         : isCancelled
                                  //                                                             ? Colors.red.withOpacity(0.05)
                                  //                                                             : Colors.blue.withOpacity(0.05))
                                  //                                                 : null,
                                  //                                             selected: isSelected || !canSelect,
                                  //                                             dense: true,
                                  //                                           );
                                  //                                         },
                                  //                                       ),
                                  //                               ),
                                  //                             ),
                                  //                             if (friendSelectionError.isNotEmpty)
                                  //                               Padding(
                                  //                                 padding: EdgeInsets.only(top: 4, left: 4),
                                  //                                 child: Align(
                                  //                                   alignment: Alignment.center,
                                  //                                   child: Text(
                                  //                                     friendSelectionError,
                                  //                                     style: TextStyle(
                                  //                                       color: Colors.red,
                                  //                                       fontSize: 16.sp,
                                  //                                       fontFamily: AppConstants.manrope,
                                  //                                     ),
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             SizedBox(height: 2.h),
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.end,
                                  //                               children: [
                                  //                                 batan(
                                  //                                   title: "Cancel",
                                  //                                   route: () => Get.back(),
                                  //                                   radius: 3.0.w,
                                  //                                   color: AppColors.maincolor,
                                  //                                   fontcolor: Colors.white,
                                  //                                   height: 4.5.h,
                                  //                                   width: 41.w,
                                  //                                   fontsize: 15.5.sp,
                                  //                                 ),
                                  //                                 SizedBox(width: 3.w),
                                  //                                 batan(
                                  //                                   title: "Add Friends",
                                  //                                   route: () async {
                                  //                                     if (selectedFriends.isEmpty) {
                                  //                                       setState(() {
                                  //                                         friendSelectionError = "Please select at least one friend";
                                  //                                       });
                                  //                                       return;
                                  //                                     }

                                  //                                     for (var friend in selectedFriends) {
                                  //                                       await makefriendapi(friend['id']);
                                  //
                                  //                                     }

                                  //                                     await listconciergerapi();

                                  //                                     Get.back();
                                  //                                     Get.snackbar(
                                  //                                       'Friend Request Sent',
                                  //                                       'Friend requests sent to ${selectedFriends.length} friends',
                                  //                                       backgroundColor: Colors.green.withOpacity(0.7),
                                  //                                       colorText: Colors.white,
                                  //                                       snackPosition: SnackPosition.BOTTOM,
                                  //                                     );
                                  //                                   },
                                  //                                   radius: 3.0.w,
                                  //                                   color: AppColors.maincolor,
                                  //                                   fontcolor: Colors.white,
                                  //                                   height: 4.5.h,
                                  //                                   width: 39.w,
                                  //                                   fontsize: 16.sp,
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           ],
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   );
                                  //                 },
                                  //               );
                                  //             },
                                  //           );
                                  //           print(
                                  //               "New Friend Pressed");
                                  //         },
                                  //         child: Row(
                                  //           children: [
                                  //             Text(
                                  //               "New Friend",
                                  //               style: TextStyle(
                                  //                 fontFamily:
                                  //                     AppConstants
                                  //                         .manrope,
                                  //                 fontSize: 16.sp,
                                  //                 fontWeight:
                                  //                     FontWeight
                                  //                         .bold,
                                  //                 color:
                                  //                     Colors.grey,
                                  //               ),
                                  //             ),
                                  //             SizedBox(
                                  //                 width: 2.w),
                                  //             Icon(
                                  //                 Icons
                                  //                     .add_circle_outline_rounded,
                                  //                 color: Colors
                                  //                     .grey),
                                  //           ],
                                  //         ),
                                  //       )
                                  //     : InkWell(
                                  //         onTap: () {
                                  //           showDialog(
                                  //             context: context,
                                  //             builder: (context) {
                                  //               String
                                  //                   groupNameError =
                                  //                   "";
                                  //               String
                                  //                   memberSelectionError =
                                  //                   "";
                                  //               final ScrollController
                                  //                   dialogScrollController =
                                  //                   ScrollController();
                                  //               final ScrollController
                                  //                   listScrollController =
                                  //                   ScrollController();

                                  //               final TextEditingController
                                  //                   searchController =
                                  //                   TextEditingController();
                                  //               String
                                  //                   searchQuery =
                                  //                   "";

                                  //               return StatefulBuilder(
                                  //                 builder: (context,
                                  //                     setState) {
                                  //                   List<dynamic>
                                  //                       filteredUsers =
                                  //                       chatuserlistmodel
                                  //                               ?.data
                                  //                               ?.where((user) {
                                  //                             final String
                                  //                                 fullName =
                                  //                                 "${user.user?.firstName ?? ''} ${user.user?.lastName ?? ''}".toLowerCase();
                                  //                             return fullName.contains(searchQuery.toLowerCase());
                                  //                           })?.toList() ??
                                  //                           [];

                                  //                   Future<void>
                                  //                       pickImageFromGallery() async {
                                  //                     try {
                                  //                       final ImagePicker
                                  //                           _picker =
                                  //                           ImagePicker();
                                  //                       final XFile?
                                  //                           image =
                                  //                           await _picker
                                  //                               .pickImage(
                                  //                         source:
                                  //                             ImageSource.gallery,
                                  //                         imageQuality:
                                  //                             70,
                                  //                       );

                                  //                       if (image !=
                                  //                           null) {
                                  //                         setState(
                                  //                             () {
                                  //                           selectedImage =
                                  //                               io.File(image.path);
                                  //                           imagePath =
                                  //                               image.path;
                                  //                           print(
                                  //                               "Selected image path: ${image.path}");
                                  //                         });
                                  //                       }
                                  //                     } catch (e) {
                                  //                       print(
                                  //                           "Error picking image: $e");
                                  //                     }
                                  //                   }

                                  //                   return Dialog(
                                  //                     shape:
                                  //                         RoundedRectangleBorder(
                                  //                       borderRadius:
                                  //                           BorderRadius.circular(
                                  //                               20),
                                  //                     ),
                                  //                     insetPadding: EdgeInsets.symmetric(
                                  //                         horizontal:
                                  //                             12,
                                  //                         vertical:
                                  //                             16),
                                  //                     child:
                                  //                         Container(
                                  //                       constraints:
                                  //                           BoxConstraints(
                                  //                         maxHeight:
                                  //                             MediaQuery.of(context).size.height *
                                  //                                 0.8,
                                  //                       ),
                                  //                       padding: EdgeInsets.symmetric(
                                  //                           horizontal:
                                  //                               16,
                                  //                           vertical:
                                  //                               16),
                                  //                       decoration:
                                  //                           BoxDecoration(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(20),
                                  //                         color: Colors
                                  //                             .white,
                                  //                       ),
                                  //                       child:
                                  //                           SingleChildScrollView(
                                  //                         keyboardDismissBehavior:
                                  //                             ScrollViewKeyboardDismissBehavior.onDrag,
                                  //                         controller:
                                  //                             dialogScrollController,
                                  //                         child:
                                  //                             Column(
                                  //                           mainAxisSize:
                                  //                               MainAxisSize.min,
                                  //                           children: [
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.center,
                                  //                               children: [
                                  //                                 Icon(Icons.group_add, color: AppColors.maincolor, size: 24),
                                  //                                 SizedBox(width: 2.w),
                                  //                                 Text(
                                  //                                   'Create New Group',
                                  //                                   style: TextStyle(
                                  //                                     color: Colors.black,
                                  //                                     fontSize: 18.sp,
                                  //                                     fontWeight: FontWeight.w700,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                   ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                             SizedBox(height: 1.5.h),
                                  //                             Align(
                                  //                               alignment: Alignment.centerLeft,
                                  //                               child: Text(
                                  //                                 'Group Name',
                                  //                                 style: TextStyle(
                                  //                                   fontSize: 16.sp,
                                  //                                   fontWeight: FontWeight.w600,
                                  //                                   fontFamily: AppConstants.manrope,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                             SizedBox(height: 0.8.h),
                                  //                             Row(
                                  //                               crossAxisAlignment: CrossAxisAlignment.center,
                                  //                               children: [
                                  //                                 Container(
                                  //                                   width: 40,
                                  //                                   height: 40,
                                  //                                   decoration: BoxDecoration(
                                  //                                     shape: BoxShape.circle,
                                  //                                     color: Colors.grey.shade50,
                                  //                                   ),
                                  //                                   child: InkWell(
                                  //                                     onTap: pickImageFromGallery,
                                  //                                     child: selectedImage != null
                                  //                                         ? ClipRRect(
                                  //                                             borderRadius: BorderRadius.circular(20),
                                  //                                             child: Image.file(
                                  //                                               selectedImage!,
                                  //                                               width: 40,
                                  //                                               height: 40,
                                  //                                               fit: BoxFit.cover,
                                  //                                             ),
                                  //                                           )
                                  //                                         : Center(
                                  //                                             child: Icon(
                                  //                                               Icons.camera_alt_outlined,
                                  //                                               color: Colors.black54,
                                  //                                               size: 20,
                                  //                                             ),
                                  //                                           ),
                                  //                                   ),
                                  //                                 ),
                                  //                                 SizedBox(width: 3.w),
                                  //                                 Expanded(
                                  //                                   child: Column(
                                  //                                     crossAxisAlignment: CrossAxisAlignment.start,
                                  //                                     children: [
                                  //                                       SizedBox(
                                  //                                         height: 4.5.h,
                                  //                                         child: TextField(
                                  //                                           controller: groupNameController,
                                  //                                           decoration: InputDecoration(
                                  //                                             hintText: 'Enter group name',
                                  //                                             hintStyle: TextStyle(
                                  //                                               color: Colors.grey.shade400,
                                  //                                               fontFamily: AppConstants.manrope,
                                  //                                               fontSize: 14.sp,
                                  //                                             ),
                                  //                                             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  //                                             filled: true,
                                  //                                             fillColor: Colors.grey.shade50,
                                  //                                             border: OutlineInputBorder(
                                  //                                               borderRadius: BorderRadius.circular(10),
                                  //                                               borderSide: BorderSide(color: Colors.grey.shade300),
                                  //                                             ),
                                  //                                             focusedBorder: OutlineInputBorder(
                                  //                                               borderRadius: BorderRadius.circular(10),
                                  //                                               borderSide: BorderSide(color: AppColors.maincolor, width: 1.2),
                                  //                                             ),
                                  //                                             errorBorder: OutlineInputBorder(
                                  //                                               borderRadius: BorderRadius.circular(10),
                                  //                                               borderSide: BorderSide(color: Colors.red, width: 1.2),
                                  //                                             ),
                                  //                                           ),
                                  //                                           style: TextStyle(
                                  //                                             fontSize: 14.sp,
                                  //                                             fontFamily: AppConstants.manrope,
                                  //                                           ),
                                  //                                           onChanged: (value) {
                                  //                                             setState(() {
                                  //                                               groupNameError = "";
                                  //                                             });
                                  //                                           },
                                  //                                         ),
                                  //                                       ),
                                  //                                       if (groupNameError.isNotEmpty)
                                  //                                         Padding(
                                  //                                           padding: EdgeInsets.only(top: 4, left: 4),
                                  //                                           child: Text(
                                  //                                             groupNameError,
                                  //                                             style: TextStyle(
                                  //                                               color: Colors.red,
                                  //                                               fontSize: 12.sp,
                                  //                                               fontFamily: AppConstants.manrope,
                                  //                                             ),
                                  //                                           ),
                                  //                                         ),
                                  //                                     ],
                                  //                                   ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                             Divider(
                                  //                               height: 20,
                                  //                               thickness: 1,
                                  //                               color: Colors.grey.shade400,
                                  //                             ),
                                  //                             Container(
                                  //                               decoration: BoxDecoration(
                                  //                                 color: Colors.grey.shade100,
                                  //                                 borderRadius: BorderRadius.circular(10),
                                  //                               ),
                                  //                               child: TextField(
                                  //                                 controller: searchController,
                                  //                                 onChanged: (value) {
                                  //                                   setState(() {
                                  //                                     searchQuery = value;
                                  //                                   });
                                  //                                 },
                                  //                                 decoration: InputDecoration(
                                  //                                   hintText: 'Search members',
                                  //                                   prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                  //                                   border: InputBorder.none,
                                  //                                   contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  //                                 ),
                                  //                                 style: TextStyle(
                                  //                                   fontSize: 14.sp,
                                  //                                   fontFamily: AppConstants.manrope,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                             SizedBox(height: 1.h),
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //                               children: [
                                  //                                 Text(
                                  //                                   'Select Members',
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16.sp,
                                  //                                     fontWeight: FontWeight.w600,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                   ),
                                  //                                 ),
                                  //                                 Text(
                                  //                                   '${selectedMembers.length} selected',
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 14.sp,
                                  //                                     fontWeight: FontWeight.w500,
                                  //                                     fontFamily: AppConstants.manrope,
                                  //                                     color: AppColors.maincolor,
                                  //                                   ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                             SizedBox(height: 0.8.h),
                                  //                             Container(
                                  //                               height: 32.h,
                                  //                               decoration: BoxDecoration(
                                  //                                 color: Colors.white,
                                  //                                 borderRadius: BorderRadius.circular(12),
                                  //                               ),
                                  //                               child: Scrollbar(
                                  //                                 thumbVisibility: true,
                                  //                                 controller: listScrollController,
                                  //                                 radius: Radius.circular(8),
                                  //                                 thickness: 4,
                                  //                                 child: filteredUsers.isEmpty
                                  //                                     ? Center(
                                  //                                         child: Text(
                                  //                                           searchQuery.isEmpty ? "No users available" : "No matching members found",
                                  //                                           style: TextStyle(
                                  //                                             fontSize: 14.sp,
                                  //                                             fontFamily: AppConstants.manrope,
                                  //                                             color: Colors.grey.shade600,
                                  //                                           ),
                                  //                                         ),
                                  //                                       )
                                  //                                     : ListView.separated(
                                  //                                         controller: listScrollController,
                                  //                                         padding: EdgeInsets.zero,
                                  //                                         itemCount: filteredUsers.length,
                                  //                                         separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                                  //                                         itemBuilder: (context, index) {
                                  //                                           final user = filteredUsers[index];
                                  //                                           final memberId = user?.userId.toString() ?? "";
                                  //                                           final isSelected = selectedMembers.contains(memberId);

                                  //                                           return ListTile(
                                  //                                             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  //                                             leading: CircleAvatar(
                                  //                                               radius: 20,
                                  //                                               backgroundColor: Colors.grey.shade200,
                                  //                                               child: ClipOval(
                                  //                                                 child: CachedNetworkImage(
                                  //                                                   imageUrl: user?.user?.profile ?? "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                                  //                                                   placeholder: (context, url) => Image.asset(
                                  //                                                     'assets/images/person.jpg',
                                  //                                                     fit: BoxFit.cover,
                                  //                                                   ),
                                  //                                                   errorWidget: (context, url, error) => Image.asset(
                                  //                                                     'assets/images/person.jpg',
                                  //                                                     fit: BoxFit.cover,
                                  //                                                   ),
                                  //                                                   width: 40,
                                  //                                                   height: 40,
                                  //                                                   fit: BoxFit.cover,
                                  //                                                 ),
                                  //                                               ),
                                  //                                             ),
                                  //                                             title: Text(
                                  //                                               "${user?.user?.firstName ?? ""} ${user?.user?.lastName ?? "NA"}",
                                  //                                               style: TextStyle(
                                  //                                                 fontFamily: AppConstants.manrope,
                                  //                                                 fontWeight: FontWeight.w500,
                                  //                                                 fontSize: 14.sp,
                                  //                                               ),
                                  //                                             ),
                                  //                                             trailing: Checkbox(
                                  //                                               value: isSelected,
                                  //                                               onChanged: (selected) {
                                  //                                                 setState(() {
                                  //                                                   if (selected == true) {
                                  //                                                     selectedMembers.add(memberId);
                                  //                                                   } else {
                                  //                                                     selectedMembers.remove(memberId);
                                  //                                                   }
                                  //                                                   memberSelectionError = "";
                                  //                                                 });
                                  //                                               },
                                  //                                               activeColor: AppColors.maincolor,
                                  //                                             ),
                                  //                                             tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                                  //                                             selected: isSelected,
                                  //                                             dense: true,
                                  //                                             onTap: () {
                                  //                                               setState(() {
                                  //                                                 if (isSelected) {
                                  //                                                   selectedMembers.remove(memberId);
                                  //                                                 } else {
                                  //                                                   selectedMembers.add(memberId);
                                  //                                                 }
                                  //                                                 memberSelectionError = "";
                                  //                                               });
                                  //                                             },
                                  //                                           );
                                  //                                         },
                                  //                                       ),
                                  //                               ),
                                  //                             ),
                                  //                             if (memberSelectionError.isNotEmpty)
                                  //                               Padding(
                                  //                                 padding: EdgeInsets.only(top: 4, left: 4),
                                  //                                 child: Align(
                                  //                                   alignment: Alignment.center,
                                  //                                   child: Text(
                                  //                                     memberSelectionError,
                                  //                                     style: TextStyle(
                                  //                                       color: Colors.red,
                                  //                                       fontSize: 14.sp,
                                  //                                       fontFamily: AppConstants.manrope,
                                  //                                     ),
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             SizedBox(height: 2.h),
                                  //                             Row(
                                  //                               mainAxisAlignment: MainAxisAlignment.end,
                                  //                               children: [
                                  //                                 batan(
                                  //                                   title: "Cancel",
                                  //                                   route: () {
                                  //                                     groupNameController.clear();
                                  //                                     selectedMembers.clear();
                                  //                                     selectedImage = null;
                                  //                                     imagePath = '';
                                  //                                     Get.back();
                                  //                                   },
                                  //                                   radius: 3.0.w,
                                  //                                   color: AppColors.maincolor,
                                  //                                   fontcolor: Colors.white,
                                  //                                   height: 4.5.h,
                                  //                                   width: 41.w,
                                  //                                   fontsize: 15.5.sp,
                                  //                                 ),
                                  //                                 SizedBox(width: 3.w),
                                  //                                 batan(
                                  //                                   title: "Create Group",
                                  //                                   route: () {
                                  //                                     if (groupNameController.text.trim().isEmpty) {
                                  //                                       setState(() {
                                  //                                         groupNameError = "Please enter group name";
                                  //                                         memberSelectionError = "";
                                  //                                       });
                                  //                                       return;
                                  //                                     }

                                  //                                     if (selectedMembers.isEmpty) {
                                  //                                       setState(() {
                                  //                                         memberSelectionError = "Please select at least one member";
                                  //                                         groupNameError = "";
                                  //                                       });
                                  //                                       return;
                                  //                                     }

                                  //                                     creategrouplistdAp();
                                  //                                     Get.back();
                                  //                                   },
                                  //                                   radius: 3.0.w,
                                  //                                   color: AppColors.maincolor,
                                  //                                   fontcolor: Colors.white,
                                  //                                   height: 4.5.h,
                                  //                                   width: 39.w,
                                  //                                   fontsize: 15.sp,
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           ],
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   );
                                  //                 },
                                  //               );
                                  //             },
                                  //           );
                                  //           print(
                                  //               "Create Group Pressed");
                                  //         },
                                  //         child: Row(
                                  //           children: [
                                  //             Text(
                                  //               "Create Group",
                                  //               style: TextStyle(
                                  //                 fontFamily:
                                  //                     AppConstants
                                  //                         .manrope,
                                  //                 fontSize: 16.sp,
                                  //                 fontWeight:
                                  //                     FontWeight
                                  //                         .bold,
                                  //                 color:
                                  //                     Colors.grey,
                                  //               ),
                                  //             ),
                                  //             SizedBox(
                                  //                 width: 2.w),
                                  //             Icon(
                                  //                 Icons
                                  //                     .add_circle_outline_rounded,
                                  //                 color: Colors
                                  //                     .grey),
                                  //           ],
                                  //         ),
                                  //       ),
                                ),
                              ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      selectedOption == "My Building"
                          ? messageBoardModal?.data?.length == 0 ||
                                  messageBoardModal?.data?.length == null
                              ? Center(
                                child: Container(
                                  height: 70.h,
                                  child: Text(
                                    "No Posts available",
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ),
                              )
                              : Container(
                                height: 60.h,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: messageBoardModal?.data?.length,
                                  itemBuilder: (context, index) {
                                    final post =
                                        messageBoardModal?.data?[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 0.5.h,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black12,
                                          width: 0.2.w,
                                        ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 1,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 9.w,
                                                width: 9.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.maincolor,
                                                    width: 1,
                                                  ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      messageBoardModal
                                                                  ?.data?[index]
                                                                  .user
                                                                  ?.conciergeImage ==
                                                              null
                                                          ? "https://portal.wavee.ai/public/desktop/front/company_logo/Screenshot+2025-06-07+at+11.07.09.png"
                                                          : messageBoardModal
                                                                  ?.data?[index]
                                                                  .user
                                                                  ?.conciergeImage ??
                                                              "",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                "${messageBoardModal?.data?[index].user?.firstName ?? ""} ${messageBoardModal?.data?[index].user?.lastName ?? ""}",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                "•${formatPostDate(messageBoardModal?.data?[index].createdAt)}",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              Spacer(),
                                              InkWell(
                                                onTap: () {
                                                  showBlockUserDialog(
                                                    context,
                                                    supportUrl,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.more_vert_outlined,
                                                ).paddingOnly(right: 2.w),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "${messageBoardModal?.data?[index].title ?? ""}",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.maincolor,
                                            ),
                                          ),
                                          ReadMoreText(
                                            "${messageBoardModal?.data?[index].text == null || messageBoardModal?.data?[index].text == "" ? "N/A" : "${messageBoardModal?.data?[index].text}"}",
                                            trimLines: 4,
                                            trimLength: 146,
                                            colorClickableText: Colors.blue,
                                            trimMode: TrimMode.Length,
                                            trimCollapsedText: ' Show more',
                                            trimExpandedText: ' Show less',
                                            moreStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppConstants.manrope,
                                              letterSpacing: 1,
                                              color: AppColors.maincolor,
                                            ),
                                            lessStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppConstants.manrope,
                                              letterSpacing: 1,
                                              color: AppColors.maincolor,
                                            ),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.h,
                                              horizontal: 2.5.w,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child:
                                                  post?.file?.isNotEmpty == true
                                                      ? (post!.file![0]
                                                              .toLowerCase()
                                                              .endsWith('.pdf')
                                                          ? GestureDetector(
                                                            onTap: () async {
                                                              final url =
                                                                  post.file![0];
                                                              final uri =
                                                                  Uri.parse(
                                                                    url,
                                                                  );
                                                              Get.to(
                                                                PdfView(
                                                                  link:
                                                                      uri.toString(),
                                                                ),
                                                              );
                                                              // if (await canLaunchUrl(uri)) {
                                                              //   final launched = await launchUrl(
                                                              //     uri,
                                                              //     mode: LaunchMode.externalApplication,
                                                              //   );
                                                              //   if (!launched) {
                                                              //     ScaffoldMessenger.of(context).showSnackBar(
                                                              //       SnackBar(content: Text("Failed to open externally")),
                                                              //     );
                                                              //   }
                                                              // } else {
                                                              //   ScaffoldMessenger.of(context).showSnackBar(
                                                              //     SnackBar(content: Text("Cannot open PDF")),
                                                              //   );
                                                              // }
                                                            },

                                                            child: Container(
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              height: 8.h,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .picture_as_pdf,
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                      size:
                                                                          25.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          2.w,
                                                                    ),
                                                                    Text(
                                                                      "View PDF",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : CachedNetworkImage(
                                                            imageUrl:
                                                                post.file![0],
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => SizedBox(
                                                                  height: 30.h,
                                                                  width:
                                                                      double
                                                                          .infinity,
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
                                                            width:
                                                                double.infinity,
                                                            height: 30.h,
                                                            fit: BoxFit.cover,
                                                          ))
                                                      : SizedBox(height: 0.h),
                                            ),
                                          ),
                                          SizedBox(height: 1.5.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    (messageBoardModal
                                                                ?.data?[index]
                                                                .totalComments)
                                                            .toString() +
                                                        " Replies",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFF3E3E3E),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    (messageBoardModal
                                                                ?.data?[index]
                                                                .totalLikes)
                                                            .toString() +
                                                        " Likes",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFF3E3E3E),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
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
                                                                  print(
                                                                    "like count${messageBoardModal?.data?[index].totalLikes}",
                                                                  );
                                                                  if (index <
                                                                          isLikedList
                                                                              .length &&
                                                                      index <
                                                                          isLikeInProgressList
                                                                              .length) {
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
                                                        child: Text(
                                                          "Like",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                isLiked
                                                                    ? Colors.red
                                                                    : Color(
                                                                      0XFF3E3E3E,
                                                                    ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Container(
                                                    height: 2.h,
                                                    width: 0.5.w,
                                                    decoration: BoxDecoration(
                                                      color: Color(0XFF3E3E3E),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  InkWell(
                                                    onTap: () async {
                                                      await getComments(
                                                        context,
                                                        (post?.id).toString(),
                                                      );
                                                    },
                                                    child: Text(
                                                      "Comment",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0XFF3E3E3E,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                          : selectedOption == "Local"
                          ? Container(
                            height: 60.h,
                            child: PagedListView<int, Data1>(
                              pagingController: _pagingController,
                              padding: EdgeInsets.zero,
                              builderDelegate: PagedChildBuilderDelegate<Data1>(
                                itemBuilder: (_, post, idx) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 0.5.h,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 4.w,
                                              backgroundImage:
                                                  post
                                                              .users
                                                              ?.first
                                                              .profiles
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? CachedNetworkImageProvider(
                                                        post
                                                            .users!
                                                            .first
                                                            .profiles!,
                                                      )
                                                      : const AssetImage(
                                                            'assets/images/waveeLogoShort.png',
                                                          )
                                                          as ImageProvider,
                                            ),
                                            SizedBox(width: 2.w),
                                            SizedBox(width: 2.w),
                                            Text(
                                              "${post.users?[0].name ?? ""}",
                                              style: TextStyle(
                                                fontFamily:
                                                AppConstants.manrope,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              "•${formatPostDate(post.createdAt)}",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey,
                                                fontFamily:
                                                AppConstants.manrope,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            loginModel?.data?.user?.id ==
                                                post?.userId
                                                ? PopupMenuButton<String>(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Colors.black87,
                                              ),
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  UpdatePostData(
                                                    context,
                                                    post,
                                                  );
                                                } else if (value ==
                                                    'delete') {
                                                  showCancelConfirmationDialog(
                                                    context: context,
                                                    post!.id.toString() ??
                                                        "",
                                                  );
                                                  print(
                                                    "Delete selected",
                                                  );
                                                } else if (value ==
                                                    'report') {
                                                  showBlockUserDialog(
                                                    context,
                                                    supportUrl,
                                                  );
                                                  print(
                                                    "Delete selected",
                                                  );
                                                }
                                              },
                                              itemBuilder:
                                                  (
                                                  BuildContext context,
                                                  ) => [
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontFamily:
                                                      AppConstants
                                                          .manrope,
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontFamily:
                                                      AppConstants
                                                          .manrope,
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'report',
                                                  child: Text(
                                                    'Report',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontFamily:
                                                      AppConstants
                                                          .manrope,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                                : InkWell(
                                              onTap: () {
                                                showBlockUserDialog(
                                                  context,
                                                  supportUrl,
                                                );
                                              },
                                              child: Icon(
                                                Icons.more_vert_outlined,
                                              ).paddingOnly(right: 2.w),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          "${post.title ?? ""}",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.maincolor,
                                          ),
                                        ),
                                        ReadMoreText(
                                          "${post.text == null || post.text == "" ? "N/A" : "${post.text}"}",
                                          trimLines: 4,
                                          trimLength: 146,
                                          colorClickableText: Colors.blue,
                                          trimMode: TrimMode.Length,
                                          trimCollapsedText: ' Show more',
                                          trimExpandedText: ' Show less',
                                          moreStyle: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppConstants.manrope,
                                            letterSpacing: 1,
                                            color: AppColors.maincolor,
                                          ),
                                          lessStyle: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppConstants.manrope,
                                            letterSpacing: 1,
                                            color: AppColors.maincolor,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                        post?.file?.length == 0 ||
                                            post?.file?.length == null
                                            ? SizedBox()
                                            : Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1.h,
                                            horizontal: 2.5.w,
                                          ),
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              final pageCount =
                                                  post?.file?.length ?? 0;
                                              return SizedBox(
                                                height: 35.h,
                                                child: Stack(
                                                  children: [
                                                    PageView.builder(
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
                                                              fit:
                                                              BoxFit.cover,
                                                            ),
                                                            width:
                                                            double
                                                                .infinity,
                                                            height: 35.h,
                                                            fit:
                                                            BoxFit
                                                                .cover,
                                                          ),
                                                        ).marginOnly(
                                                          right: 1.w,
                                                        );
                                                      },
                                                    ),
                                                    Positioned(
                                                      top: 8,
                                                      right: 16,
                                                      child: Container(
                                                        padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical: 4,
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
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  (post
                                                      .totalComments)
                                                      .toString() +
                                                      " Replies",
                                                  style: TextStyle(
                                                    fontFamily:
                                                    AppConstants.manrope,
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color(0XFF3E3E3E),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  (post
                                                      .totalLikes)
                                                      .toString() +
                                                      " Likes",
                                                  style: TextStyle(
                                                    fontFamily:
                                                    AppConstants.manrope,
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color(0XFF3E3E3E),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                // GestureDetector(
                                                //   onTap: () {
                                                //     try {
                                                //       final imageUrl =
                                                //           messageBoardModal
                                                //               ?.data?[
                                                //                   index]
                                                //               ?.file
                                                //               .toString();
                                                //       final linkToShare = (imageUrl ==
                                                //                   null ||
                                                //               imageUrl
                                                //                   .isEmpty)
                                                //           ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                                                //           : imageUrl;
                                                //       shareConciergeImage(
                                                //           linkToShare);
                                                //     } catch (e) {
                                                //       print(
                                                //           "Error sharing: $e");
                                                //     }
                                                //   },
                                                //   child: Icon(
                                                //     Icons
                                                //         .share_outlined,
                                                //     size: 18.sp,
                                                //     color: Color(
                                                //         0XFF3E3E3E),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                StatefulBuilder(
                                                  builder: (
                                                      context,
                                                      localSetState,
                                                      ) {
                                                    bool isLiked =
                                                    idx <
                                                        isLikedListLocal
                                                            .length
                                                        ? isLikedListLocal[idx]
                                                        : false;
                                                    bool isInProgress =
                                                    idx <
                                                        isLikeInProgressListLocal
                                                            .length
                                                        ? isLikeInProgressListLocal[idx]
                                                        : false;

                                                    return GestureDetector(
                                                      onTap:
                                                      isInProgress
                                                          ? null
                                                          : () {
                                                        if (idx <
                                                            isLikedListLocal
                                                                .length &&
                                                            idx <
                                                                isLikeInProgressListLocal
                                                                    .length) {
                                                          localSetState(() {
                                                            isLikedListLocal[idx] =
                                                            !isLikedListLocal[idx];
                                                            isLikeInProgressListLocal[idx] =
                                                            true;
                                                          });
                                                          _saveLikeStatusLocal(
                                                            idx,
                                                            isLikedListLocal[idx],
                                                          );
                                                          postslikelocalap(
                                                            idx,
                                                                () {
                                                              localSetState(() {
                                                                isLikeInProgressListLocal[idx] =
                                                                false;
                                                              });
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Text(
                                                        "Like",
                                                        style: TextStyle(
                                                          fontFamily:
                                                          AppConstants
                                                              .manrope,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color:
                                                          isLiked
                                                              ? Colors.red
                                                              : Color(
                                                            0XFF3E3E3E,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(width: 2.w),
                                                Container(
                                                  height: 2.h,
                                                  width: 0.5.w,
                                                  decoration: BoxDecoration(
                                                    color: Color(0XFF3E3E3E),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                InkWell(
                                                  onTap: () {
                                                    getComments1(
                                                      context,
                                                      post?.id?.toString() ??
                                                          "",
                                                    );
                                                  },
                                                  child: Text(
                                                    "Comment",
                                                    style: TextStyle(
                                                      fontFamily:
                                                      AppConstants
                                                          .manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(
                                                        0XFF3E3E3E,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  );
                                },
                                firstPageProgressIndicatorBuilder:
                                    (_) => Center(
                                      child: Loader(),
                                    ),
                                newPageProgressIndicatorBuilder:
                                    (_) => Center(
                                      child: CircularProgressIndicator(color: AppColors.blackColor,),
                                    ),
                                noItemsFoundIndicatorBuilder:
                                    (_) => Center(
                                      child: Text('No Posts available'),
                                    ),
                                firstPageErrorIndicatorBuilder:
                                    (_) => Center(
                                      child: Text('Failed to load posts'),
                                    ),
                                newPageErrorIndicatorBuilder:
                                    (_) => Center(
                                      child: Text('Failed to load more posts'),
                                    ),
                              ),
                            ),
                          )
                          // localpost_model?.data?.data?.length == null ||
                          //             localpost_model?.data?.data?.length == 0
                          //         ? Center(
                          //           child: Container(
                          //             height: 70.h,
                          //             child: Text(
                          //               "No Posts available",
                          //               style: TextStyle(
                          //                 fontSize: 17.sp,
                          //                 color: Colors.black,
                          //                 fontWeight: FontWeight.normal,
                          //                 fontFamily: AppConstants.manrope,
                          //               ),
                          //             ),
                          //           ),
                          //         )
                          //         : Container(
                          //           height: 60.h,
                          //           child: ListView.builder(
                          //             padding: EdgeInsets.zero,
                          //             itemCount:
                          //                 localpost_model?.data?.data?.length,
                          //             itemBuilder: (context, index) {
                          //               final post =
                          //                   localpost_model?.data?.data?[index];
                          //               return Container(
                          //                 margin: EdgeInsets.symmetric(
                          //                   vertical: 0.5.h,
                          //                 ),
                          //                 padding: EdgeInsets.symmetric(
                          //                   horizontal: 3.w,
                          //                   vertical: 2.h,
                          //                 ),
                          //                 decoration: BoxDecoration(
                          //                   border: Border.all(
                          //                     color: Colors.black12,
                          //                     width: 0.2.w,
                          //                   ),
                          //                   color: Colors.white,
                          //                   borderRadius: BorderRadius.circular(20),
                          //                   boxShadow: [
                          //                     BoxShadow(
                          //                       color: Colors.black12,
                          //                       blurRadius: 1,
                          //                       offset: Offset(0, 1),
                          //                     ),
                          //                   ],
                          //                 ),
                          //                 child: Column(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.start,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.start,
                          //                   children: [
                          //                     Row(
                          //                       crossAxisAlignment:
                          //                           CrossAxisAlignment.center,
                          //                       children: [
                          //                         Container(
                          //                           height: 9.w,
                          //                           width: 9.w,
                          //                           decoration: BoxDecoration(
                          //                             shape: BoxShape.circle,
                          //                             border: Border.all(
                          //                               color: AppColors.maincolor,
                          //                               width: 1,
                          //                             ),
                          //                             image: DecorationImage(
                          //                               image:
                          //                                   (localpost_model
                          //                                               ?.data
                          //                                               ?.data?[index]
                          //                                               .users?[0]
                          //                                               .profiles
                          //                                               ?.isNotEmpty ??
                          //                                           false)
                          //                                       ? CachedNetworkImageProvider(
                          //                                         localpost_model!
                          //                                             .data!
                          //                                             .data![index]
                          //                                             .users![0]
                          //                                             .profiles!,
                          //                                       )
                          //                                       : const AssetImage(
                          //                                             'assets/images/waveeLogoShort.png',
                          //                                           )
                          //                                           as ImageProvider,
                          //                               fit: BoxFit.cover,
                          //                             ),
                          //                           ),
                          //                         ),
                          //
                          //                         SizedBox(width: 2.w),
                          //                         Text(
                          //                           "${localpost_model?.data?.data?[index].users?[0].name ?? ""}",
                          //                           style: TextStyle(
                          //                             fontFamily:
                          //                                 AppConstants.manrope,
                          //                             fontSize: 15.sp,
                          //                             fontWeight: FontWeight.bold,
                          //                           ),
                          //                         ),
                          //                         SizedBox(width: 2.w),
                          //                         Text(
                          //                           "•${formatPostDate(localpost_model?.data?.data?[index].createdAt)}",
                          //                           style: TextStyle(
                          //                             fontSize: 14.sp,
                          //                             color: Colors.grey,
                          //                             fontFamily:
                          //                                 AppConstants.manrope,
                          //                             fontWeight: FontWeight.bold,
                          //                           ),
                          //                         ),
                          //                         Spacer(),
                          //                         loginModel?.data?.user?.id ==
                          //                                 post?.userId
                          //                             ? PopupMenuButton<String>(
                          //                               icon: Icon(
                          //                                 Icons.more_vert,
                          //                                 color: Colors.black87,
                          //                               ),
                          //                               onSelected: (value) {
                          //                                 if (value == 'edit') {
                          //                                   UpdatePostData(
                          //                                     context,
                          //                                     post,
                          //                                   );
                          //                                 } else if (value ==
                          //                                     'delete') {
                          //                                   showCancelConfirmationDialog(
                          //                                     context: context,
                          //                                     post!.id.toString() ??
                          //                                         "",
                          //                                   );
                          //                                   print(
                          //                                     "Delete selected",
                          //                                   );
                          //                                 } else if (value ==
                          //                                     'report') {
                          //                                   showBlockUserDialog(
                          //                                     context,
                          //                                     supportUrl,
                          //                                   );
                          //                                   print(
                          //                                     "Delete selected",
                          //                                   );
                          //                                 }
                          //                               },
                          //                               itemBuilder:
                          //                                   (
                          //                                     BuildContext context,
                          //                                   ) => [
                          //                                     PopupMenuItem(
                          //                                       value: 'edit',
                          //                                       child: Text(
                          //                                         'Edit',
                          //                                         style: TextStyle(
                          //                                           fontSize: 16.sp,
                          //                                           fontFamily:
                          //                                               AppConstants
                          //                                                   .manrope,
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     PopupMenuItem(
                          //                                       value: 'delete',
                          //                                       child: Text(
                          //                                         'Delete',
                          //                                         style: TextStyle(
                          //                                           fontSize: 16.sp,
                          //                                           fontFamily:
                          //                                               AppConstants
                          //                                                   .manrope,
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     PopupMenuItem(
                          //                                       value: 'report',
                          //                                       child: Text(
                          //                                         'Report',
                          //                                         style: TextStyle(
                          //                                           fontSize: 16.sp,
                          //                                           fontFamily:
                          //                                               AppConstants
                          //                                                   .manrope,
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                   ],
                          //                             )
                          //                             : InkWell(
                          //                               onTap: () {
                          //                                 showBlockUserDialog(
                          //                                   context,
                          //                                   supportUrl,
                          //                                 );
                          //                               },
                          //                               child: Icon(
                          //                                 Icons.more_vert_outlined,
                          //                               ).paddingOnly(right: 2.w),
                          //                             ),
                          //                       ],
                          //                     ),
                          //                     Text(
                          //                       "${localpost_model?.data?.data?[index].title ?? ""}",
                          //                       style: TextStyle(
                          //                         fontFamily: AppConstants.manrope,
                          //                         fontSize: 16.sp,
                          //                         fontWeight: FontWeight.bold,
                          //                         color: AppColors.maincolor,
                          //                       ),
                          //                     ),
                          //                     ReadMoreText(
                          //                       "${localpost_model?.data?.data?[index].text == null || localpost_model?.data?.data?[index].text == "" ? "N/A" : "${localpost_model?.data?.data?[index].text}"}",
                          //                       trimLines: 4,
                          //                       trimLength: 146,
                          //                       colorClickableText: Colors.blue,
                          //                       trimMode: TrimMode.Length,
                          //                       trimCollapsedText: ' Show more',
                          //                       trimExpandedText: ' Show less',
                          //                       moreStyle: TextStyle(
                          //                         fontSize: 15.sp,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontFamily: AppConstants.manrope,
                          //                         letterSpacing: 1,
                          //                         color: AppColors.maincolor,
                          //                       ),
                          //                       lessStyle: TextStyle(
                          //                         fontSize: 15.sp,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontFamily: AppConstants.manrope,
                          //                         letterSpacing: 1,
                          //                         color: AppColors.maincolor,
                          //                       ),
                          //                       style: TextStyle(
                          //                         fontSize: 16.sp,
                          //                         color: Colors.grey.shade500,
                          //                         fontWeight: FontWeight.normal,
                          //                         fontFamily: AppConstants.manrope,
                          //                       ),
                          //                     ),
                          //                     post?.file?.length == 0 ||
                          //                             post?.file?.length == null
                          //                         ? SizedBox()
                          //                         : Padding(
                          //                           padding: EdgeInsets.symmetric(
                          //                             vertical: 1.h,
                          //                             horizontal: 2.5.w,
                          //                           ),
                          //                           child: StatefulBuilder(
                          //                             builder: (context, setState) {
                          //                               final pageCount =
                          //                                   post?.file?.length ?? 0;
                          //                               return SizedBox(
                          //                                 height: 35.h,
                          //                                 child: Stack(
                          //                                   children: [
                          //                                     PageView.builder(
                          //                                       controller:
                          //                                           _pageController,
                          //                                       itemCount:
                          //                                           pageCount,
                          //                                       onPageChanged: (
                          //                                         index,
                          //                                       ) {
                          //                                         setState(
                          //                                           () =>
                          //                                               _currentPage =
                          //                                                   index,
                          //                                         );
                          //                                       },
                          //                                       itemBuilder: (
                          //                                         context,
                          //                                         index,
                          //                                       ) {
                          //                                         final imageUrl =
                          //                                             post?.file?[index] ??
                          //                                             "";
                          //                                         return ClipRRect(
                          //                                           borderRadius:
                          //                                               BorderRadius.circular(
                          //                                                 10,
                          //                                               ),
                          //                                           child: CachedNetworkImage(
                          //                                             imageUrl:
                          //                                                 imageUrl,
                          //                                             placeholder:
                          //                                                 (
                          //                                                   context,
                          //                                                   url,
                          //                                                 ) => Center(
                          //                                                   child:
                          //                                                       CircularProgressIndicator(),
                          //                                                 ),
                          //                                             errorWidget:
                          //                                                 (
                          //                                                   context,
                          //                                                   url,
                          //                                                   error,
                          //                                                 ) => Image.asset(
                          //                                                   "assets/images/waveeLogoShort.png",
                          //                                                   fit:
                          //                                                       BoxFit.cover,
                          //                                                 ),
                          //                                             width:
                          //                                                 double
                          //                                                     .infinity,
                          //                                             height: 35.h,
                          //                                             fit:
                          //                                                 BoxFit
                          //                                                     .cover,
                          //                                           ),
                          //                                         ).marginOnly(
                          //                                           right: 1.w,
                          //                                         );
                          //                                       },
                          //                                     ),
                          //                                     Positioned(
                          //                                       top: 8,
                          //                                       right: 16,
                          //                                       child: Container(
                          //                                         padding:
                          //                                             EdgeInsets.symmetric(
                          //                                               horizontal:
                          //                                                   10,
                          //                                               vertical: 4,
                          //                                             ),
                          //                                         decoration: BoxDecoration(
                          //                                           color: Colors
                          //                                               .black
                          //                                               .withOpacity(
                          //                                                 0.6,
                          //                                               ),
                          //                                           borderRadius:
                          //                                               BorderRadius.circular(
                          //                                                 20,
                          //                                               ),
                          //                                         ),
                          //                                         child: Text(
                          //                                           '${_currentPage + 1}/$pageCount',
                          //                                           style: TextStyle(
                          //                                             color:
                          //                                                 Colors
                          //                                                     .white,
                          //                                             fontSize:
                          //                                                 12.sp,
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                   ],
                          //                                 ),
                          //                               );
                          //                             },
                          //                           ),
                          //                         ),
                          //                     SizedBox(height: 1.5.h),
                          //                     Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.spaceBetween,
                          //                       children: [
                          //                         Row(
                          //                           children: [
                          //                             Text(
                          //                               (localpost_model
                          //                                           ?.data
                          //                                           ?.data?[index]
                          //                                           .totalComments)
                          //                                       .toString() +
                          //                                   " Replies",
                          //                               style: TextStyle(
                          //                                 fontFamily:
                          //                                     AppConstants.manrope,
                          //                                 fontSize: 16.sp,
                          //                                 fontWeight:
                          //                                     FontWeight.bold,
                          //                                 color: Color(0XFF3E3E3E),
                          //                               ),
                          //                             ),
                          //                             SizedBox(width: 2.w),
                          //                             Text(
                          //                               (localpost_model
                          //                                           ?.data
                          //                                           ?.data?[index]
                          //                                           .totalLikes)
                          //                                       .toString() +
                          //                                   " Likes",
                          //                               style: TextStyle(
                          //                                 fontFamily:
                          //                                     AppConstants.manrope,
                          //                                 fontSize: 16.sp,
                          //                                 fontWeight:
                          //                                     FontWeight.bold,
                          //                                 color: Color(0XFF3E3E3E),
                          //                               ),
                          //                             ),
                          //                             SizedBox(width: 2.w),
                          //                             // GestureDetector(
                          //                             //   onTap: () {
                          //                             //     try {
                          //                             //       final imageUrl =
                          //                             //           messageBoardModal
                          //                             //               ?.data?[
                          //                             //                   index]
                          //                             //               ?.file
                          //                             //               .toString();
                          //                             //       final linkToShare = (imageUrl ==
                          //                             //                   null ||
                          //                             //               imageUrl
                          //                             //                   .isEmpty)
                          //                             //           ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
                          //                             //           : imageUrl;
                          //                             //       shareConciergeImage(
                          //                             //           linkToShare);
                          //                             //     } catch (e) {
                          //                             //       print(
                          //                             //           "Error sharing: $e");
                          //                             //     }
                          //                             //   },
                          //                             //   child: Icon(
                          //                             //     Icons
                          //                             //         .share_outlined,
                          //                             //     size: 18.sp,
                          //                             //     color: Color(
                          //                             //         0XFF3E3E3E),
                          //                             //   ),
                          //                             // ),
                          //                           ],
                          //                         ),
                          //                         Row(
                          //                           children: [
                          //                             StatefulBuilder(
                          //                               builder: (
                          //                                 context,
                          //                                 localSetState,
                          //                               ) {
                          //                                 bool isLiked =
                          //                                     index <
                          //                                             isLikedListLocal
                          //                                                 .length
                          //                                         ? isLikedListLocal[index]
                          //                                         : false;
                          //                                 bool isInProgress =
                          //                                     index <
                          //                                             isLikeInProgressListLocal
                          //                                                 .length
                          //                                         ? isLikeInProgressListLocal[index]
                          //                                         : false;
                          //
                          //                                 return GestureDetector(
                          //                                   onTap:
                          //                                       isInProgress
                          //                                           ? null
                          //                                           : () {
                          //                                             if (index <
                          //                                                     isLikedListLocal
                          //                                                         .length &&
                          //                                                 index <
                          //                                                     isLikeInProgressListLocal
                          //                                                         .length) {
                          //                                               localSetState(() {
                          //                                                 isLikedListLocal[index] =
                          //                                                     !isLikedListLocal[index];
                          //                                                 isLikeInProgressListLocal[index] =
                          //                                                     true;
                          //                                               });
                          //                                               _saveLikeStatusLocal(
                          //                                                 index,
                          //                                                 isLikedListLocal[index],
                          //                                               );
                          //                                               postslikelocalap(
                          //                                                 index,
                          //                                                 () {
                          //                                                   localSetState(() {
                          //                                                     isLikeInProgressListLocal[index] =
                          //                                                         false;
                          //                                                   });
                          //                                                 },
                          //                                               );
                          //                                             }
                          //                                           },
                          //                                   child: Text(
                          //                                     "Like",
                          //                                     style: TextStyle(
                          //                                       fontFamily:
                          //                                           AppConstants
                          //                                               .manrope,
                          //                                       fontSize: 16.sp,
                          //                                       fontWeight:
                          //                                           FontWeight.bold,
                          //                                       color:
                          //                                           isLiked
                          //                                               ? Colors.red
                          //                                               : Color(
                          //                                                 0XFF3E3E3E,
                          //                                               ),
                          //                                     ),
                          //                                   ),
                          //                                 );
                          //                               },
                          //                             ),
                          //                             SizedBox(width: 2.w),
                          //                             Container(
                          //                               height: 2.h,
                          //                               width: 0.5.w,
                          //                               decoration: BoxDecoration(
                          //                                 color: Color(0XFF3E3E3E),
                          //                                 borderRadius:
                          //                                     BorderRadius.circular(
                          //                                       20,
                          //                                     ),
                          //                               ),
                          //                             ),
                          //                             SizedBox(width: 2.w),
                          //                             InkWell(
                          //                               onTap: () {
                          //                                 getComments1(
                          //                                   context,
                          //                                   post?.id?.toString() ??
                          //                                       "",
                          //                                 );
                          //                               },
                          //                               child: Text(
                          //                                 "Comment",
                          //                                 style: TextStyle(
                          //                                   fontFamily:
                          //                                       AppConstants
                          //                                           .manrope,
                          //                                   fontSize: 16.sp,
                          //                                   fontWeight:
                          //                                       FontWeight.bold,
                          //                                   color: Color(
                          //                                     0XFF3E3E3E,
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ],
                          //                 ),
                          //               );
                          //             },
                          //           ),
                          //         )
                          : SizedBox(),
                      //  selectedOption == "Group"
                      //     ? getgrouplistmodel?.data?.length == null ||
                      //             getgrouplistmodel?.data?.length == 0
                      //         ? Center(
                      //             child: Container(
                      //               height: 70.h,
                      //               child: Text(
                      //                 "No Group available",
                      //                 style: TextStyle(
                      //                   fontSize: 17.sp,
                      //                   color: Colors.black,
                      //                   fontWeight: FontWeight.normal,
                      //                   fontFamily:
                      //                       AppConstants.manrope,
                      //                 ),
                      //               ),
                      //             ),
                      //           )
                      //         : Container(
                      //             height: 70.h,
                      //             child: ListView.builder(
                      //               padding: EdgeInsets.symmetric(
                      //                   horizontal: 2.w, vertical: 1.h),
                      //               itemCount: getgrouplistmodel
                      //                       ?.data?.length ??
                      //                   0,
                      //               itemBuilder: (context, index) {
                      //                 final group = getgrouplistmodel
                      //                     ?.data?[index];
                      //                 return GestureDetector(
                      //                   onTap: () {
                      //                     Get.to(() => GroupChatPage(
                      //                           chatname:
                      //                               group?.name ?? '',
                      //                           image: group?.images,
                      //                           groupid: group?.id
                      //                                   .toString() ??
                      //                               '',
                      //                           type: "residents",
                      //                         ))?.then((value) {
                      //                       if (value == 'refresh') {
                      //                         GetMyJoinGroup();
                      //                       }
                      //                     });
                      //                   },
                      //                   child: Stack(
                      //                     children: [
                      //                       Container(
                      //                         margin: EdgeInsets.only(
                      //                             bottom: 1.5.h),
                      //                         padding:
                      //                             EdgeInsets.all(2.w),
                      //                         decoration: BoxDecoration(
                      //                           color: Colors.white,
                      //                           borderRadius:
                      //                               BorderRadius
                      //                                   .circular(20),
                      //                           border: Border.all(
                      //                               color: Colors.grey,
                      //                               width: 0.5),
                      //                           boxShadow: [
                      //                             BoxShadow(
                      //                               color:
                      //                                   Colors.black12,
                      //                               blurRadius: 4,
                      //                               offset:
                      //                                   Offset(0, 2),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         child: Row(
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment
                      //                                   .center,
                      //                           children: [
                      //                             Container(
                      //                               width: 17.w,
                      //                               height: 17.w,
                      //                               decoration:
                      //                                   BoxDecoration(
                      //                                 shape: BoxShape
                      //                                     .circle,
                      //                                 image:
                      //                                     DecorationImage(
                      //                                   image:
                      //                                       CachedNetworkImageProvider(
                      //                                     group?.images ??
                      //                                         "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                      //                                   ),
                      //                                   fit: BoxFit
                      //                                       .cover,
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                             SizedBox(width: 3.w),
                      //                             Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               children: [
                      //                                 Row(
                      //                                   children: [
                      //                                     Row(
                      //                                       children: [
                      //                                         Container(
                      //                                           width:
                      //                                               10,
                      //                                           height:
                      //                                               10,
                      //                                           decoration:
                      //                                               BoxDecoration(
                      //                                             color:
                      //                                                 Colors.green,
                      //                                             shape:
                      //                                                 BoxShape.circle,
                      //                                             border: Border.all(
                      //                                                 color: Colors.white,
                      //                                                 width: 1.5),
                      //                                           ),
                      //                                         ),
                      //                                         SizedBox(
                      //                                           width:
                      //                                               1.w,
                      //                                         ),
                      //                                         Text(
                      //                                           "Online",
                      //                                           style:
                      //                                               TextStyle(
                      //                                             fontSize:
                      //                                                 14.sp,
                      //                                             fontWeight:
                      //                                                 FontWeight.bold,
                      //                                             fontFamily:
                      //                                                 AppConstants.manrope,
                      //                                           ),
                      //                                         ),
                      //                                       ],
                      //                                     ),
                      //                                   ],
                      //                                 ),
                      //                                 Text(
                      //                                   group?.name ??
                      //                                       "N/A",
                      //                                   style: TextStyle(
                      //                                       fontSize:
                      //                                           16.sp,
                      //                                       fontWeight:
                      //                                           FontWeight
                      //                                               .bold,
                      //                                       fontFamily:
                      //                                           AppConstants
                      //                                               .manrope,
                      //                                       color: Color(
                      //                                           0XFF000000)),
                      //                                 ),
                      //                                 SizedBox(
                      //                                     height:
                      //                                         0.5.h),
                      //                                 Text(
                      //                                   group?.lastmessage
                      //                                           ?.message
                      //                                           ?.toString() ??
                      //                                       "N/A",
                      //                                   overflow:
                      //                                       TextOverflow
                      //                                           .ellipsis,
                      //                                   maxLines: 1,
                      //                                   style: TextStyle(
                      //                                       fontSize:
                      //                                           13.sp,
                      //                                       color: Color(
                      //                                           0XFF000000),
                      //                                       fontFamily:
                      //                                           AppConstants
                      //                                               .manrope,
                      //                                       fontWeight:
                      //                                           FontWeight
                      //                                               .normal),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                             SizedBox(width: 2.w),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       Positioned(
                      //                         right: 2.w,
                      //                         top: 1.5.h,
                      //                         child: Row(
                      //                           children: [
                      //                             Text(
                      //                               "Yesterday",
                      //                               style: TextStyle(
                      //                                   fontSize: 15.sp,
                      //                                   color: Color(
                      //                                       0xFF000000),
                      //                                   fontFamily:
                      //                                       AppConstants
                      //                                           .manrope,
                      //                                   fontWeight:
                      //                                       FontWeight
                      //                                           .normal),
                      //                             ),
                      //                             Icon(
                      //                               Icons
                      //                                   .arrow_forward_ios_rounded,
                      //                               size: 15.sp,
                      //                             )
                      //                           ],
                      //                         ),
                      //                       )
                      //                     ],
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           )
                      //     : selectedOption == "Friends"
                      //         ? getfriendListModel?.data?.length ==
                      //                     null ||
                      //                 getfriendListModel
                      //                         ?.data?.length ==
                      //                     0
                      //             ? Center(
                      //                 child: Container(
                      //                   height: 70.h,
                      //                   child: Text(
                      //                     "No Friends available",
                      //                     style: TextStyle(
                      //                       fontSize: 17.sp,
                      //                       color: Colors.black,
                      //                       fontWeight:
                      //                           FontWeight.normal,
                      //                       fontFamily:
                      //                           AppConstants.manrope,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               )
                      //             : Container(
                      //                 height: 70.h,
                      //                 child: ListView.builder(
                      //                   padding: EdgeInsets.zero,
                      //                   itemCount: getfriendListModel
                      //                           ?.data?.length ??
                      //                       0,
                      //                   itemBuilder: (context, index) {
                      //                     final friend =
                      //                         getfriendListModel
                      //                             ?.data?[index];
                      //                     String friendName = (friend
                      //                                 ?.senderId
                      //                                 .toString() ==
                      //                             (loginModel?.data
                      //                                     ?.user?.id
                      //                                     .toString() ??
                      //                                 ""))
                      //                         ? (friend?.receiverName
                      //                                 ?.toString() ??
                      //                             "")
                      //                         : (friend?.senderName
                      //                                 ?.toString() ??
                      //                             "");

                      //                     String friendImage = (friend
                      //                                 ?.senderId
                      //                                 .toString() ==
                      //                             (loginModel?.data
                      //                                     ?.user?.id
                      //                                     .toString() ??
                      //                                 ""))
                      //                         ? (friend?.receiverImage
                      //                                 ?.toString() ??
                      //                             "")
                      //                         : (friend?.senderImage
                      //                                 ?.toString() ??
                      //                             "");

                      //                     return Padding(
                      //                       padding:
                      //                           EdgeInsets.symmetric(
                      //                               vertical: 0.5.h,
                      //                               horizontal: 1.w),
                      //                       child: GestureDetector(
                      //                         onTap: () {
                      //                           log("chat ni id jay che che che ${getfriendListModel?.data?[index].receiverId.toString() ?? ""}");
                      //                           Get.to(() =>
                      //                               MessageScreen(
                      //                                 chatName:
                      //                                     friendName ??
                      //                                         "",
                      //                                 conciergeID: getfriendListModel
                      //                                         ?.data?[
                      //                                             index]
                      //                                         .receiverId
                      //                                         .toString() ??
                      //                                     "",
                      //                                 senderid: getfriendListModel
                      //                                         ?.data?[
                      //                                             index]
                      //                                         .senderId
                      //                                         .toString() ??
                      //                                     "",
                      //                                 type: "residents",
                      //                                 image:
                      //                                     friendImage ??
                      //                                         "",
                      //                               ))?.then((value) {
                      //                             if (value ==
                      //                                 'refresh') {
                      //                               getfriendlistdAp();
                      //                             }
                      //                           });
                      //                         },
                      //                         child: Stack(
                      //                           children: [
                      //                             Container(
                      //                               margin:
                      //                                   EdgeInsets.only(
                      //                                       bottom:
                      //                                           1.5.h),
                      //                               padding:
                      //                                   EdgeInsets.all(
                      //                                       2.w),
                      //                               decoration:
                      //                                   BoxDecoration(
                      //                                 color:
                      //                                     Colors.white,
                      //                                 borderRadius:
                      //                                     BorderRadius
                      //                                         .circular(
                      //                                             20),
                      //                                 border: Border.all(
                      //                                     color: Colors
                      //                                         .grey,
                      //                                     width: 0.5),
                      //                                 boxShadow: [
                      //                                   BoxShadow(
                      //                                     color: Colors
                      //                                         .black12,
                      //                                     blurRadius: 4,
                      //                                     offset:
                      //                                         Offset(
                      //                                             0, 2),
                      //                                   ),
                      //                                 ],
                      //                               ),
                      //                               child: Row(
                      //                                 crossAxisAlignment:
                      //                                     CrossAxisAlignment
                      //                                         .center,
                      //                                 children: [
                      //                                   Container(
                      //                                     width: 17.w,
                      //                                     height: 17.w,
                      //                                     decoration:
                      //                                         BoxDecoration(
                      //                                       border: Border.all(
                      //                                           color: Colors
                      //                                               .grey,
                      //                                           width:
                      //                                               1),
                      //                                       shape: BoxShape
                      //                                           .circle,
                      //                                       image:
                      //                                           DecorationImage(
                      //                                         image:
                      //                                             CachedNetworkImageProvider(
                      //                                           friendImage ??
                      //                                               "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                      //                                         ),
                      //                                         fit: BoxFit
                      //                                             .fill,
                      //                                       ),
                      //                                     ),
                      //                                   ),
                      //                                   SizedBox(
                      //                                       width: 3.w),
                      //                                   Column(
                      //                                     crossAxisAlignment:
                      //                                         CrossAxisAlignment
                      //                                             .start,
                      //                                     children: [
                      //                                       Row(
                      //                                         children: [
                      //                                           Row(
                      //                                             children: [
                      //                                               Container(
                      //                                                 width: 10,
                      //                                                 height: 10,
                      //                                                 decoration: BoxDecoration(
                      //                                                   color: Colors.green,
                      //                                                   shape: BoxShape.circle,
                      //                                                   border: Border.all(color: Colors.white, width: 1.5),
                      //                                                 ),
                      //                                               ),
                      //                                               SizedBox(
                      //                                                 width: 1.w,
                      //                                               ),
                      //                                               Text(
                      //                                                 "Last Online 2 minutes ago",
                      //                                                 style: TextStyle(
                      //                                                   fontSize: 14.sp,
                      //                                                   fontWeight: FontWeight.normal,
                      //                                                   fontFamily: AppConstants.manrope,
                      //                                                   color: Color(0XFF000000),
                      //                                                 ),
                      //                                               ),
                      //                                             ],
                      //                                           ),
                      //                                         ],
                      //                                       ),
                      //                                       Text(
                      //                                         friendName ??
                      //                                             "N/A",
                      //                                         style: TextStyle(
                      //                                             fontSize: 16
                      //                                                 .sp,
                      //                                             fontWeight: FontWeight
                      //                                                 .bold,
                      //                                             fontFamily: AppConstants
                      //                                                 .manrope,
                      //                                             color:
                      //                                                 Color(0XFF000000)),
                      //                                       ),
                      //                                       SizedBox(
                      //                                           height:
                      //                                               0.5.h),
                      //                                       Text(
                      //                                         friend?.lastMessage ??
                      //                                             'No Message available',
                      //                                         overflow:
                      //                                             TextOverflow
                      //                                                 .ellipsis,
                      //                                         maxLines:
                      //                                             1,
                      //                                         style: TextStyle(
                      //                                             fontSize: 13
                      //                                                 .sp,
                      //                                             color: Color(
                      //                                                 0XFF000000),
                      //                                             fontFamily: AppConstants
                      //                                                 .manrope,
                      //                                             fontWeight:
                      //                                                 FontWeight.normal),
                      //                                       ),
                      //                                     ],
                      //                                   ),
                      //                                   SizedBox(
                      //                                       width: 2.w),
                      //                                 ],
                      //                               ),
                      //                             ),
                      //                             Positioned(
                      //                               right: 2.w,
                      //                               top: 1.5.h,
                      //                               child: Row(
                      //                                 children: [
                      //                                   Text(
                      //                                     _formatTime(friend
                      //                                             ?.createdAt ??
                      //                                         "00:00"),
                      //                                     style: TextStyle(
                      //                                         fontSize:
                      //                                             15.sp,
                      //                                         color: Color(
                      //                                             0xFF000000),
                      //                                         fontFamily:
                      //                                             AppConstants
                      //                                                 .manrope,
                      //                                         fontWeight:
                      //                                             FontWeight
                      //                                                 .normal),
                      //                                   ),
                      //                                   Icon(
                      //                                     Icons
                      //                                         .arrow_forward_ios_rounded,
                      //                                     size: 15.sp,
                      //                                   )
                      //                                 ],
                      //                               ),
                      //                             )
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     );
                      //                   },
                      //                 ),
                      //               )
                      //         : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          if (isSending1)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      bottomNavigationBar: Bottom_bar(selected: 0),
    );
  }

  void shareConciergeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    try {
      Share.share(
        'Check out this concierge: $imageUrl',
        subject: "Check out this concierge's image!",
      );
    } catch (e) {}
  }

  void MessageBoardApi() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "31";

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().messageBoardApi(data);

          if (response.statusCode == 200) {
            try {
              messageBoardModal = MessageBoardModal.fromJson(response.data);

              setState(() {
                isLoading = false;
              });
            } catch (e) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });

            buildErrorDialog(
              context,
              'Error',
              'Something went wrong. Please try again later.',
            );
          }
        } catch (e, stackTrace) {
          setState(() {
            isLoading = false;
          });

          buildErrorDialog(
            context,
            'Error',
            'Failed to load data. Please try again.',
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(
          context,
          'No Internet',
          'Please check your connection and try again.',
        );
      }
    });
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(response.data);
          if (response.statusCode == 200 && profileModel?.status == 200) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            TextEditingController _commentController = TextEditingController();
            bool isSendingComment = false;

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
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        SizedBox(height: 12),
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
                                              errorWidget: (
                                                context,
                                                url,
                                                error,
                                              ) {
                                                return Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1,
                                                    ),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        "assets/images/waveeLogoShort.png",
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        title: Text(comment.user?.name ?? ''),
                                        subtitle: Text(comment.comment ?? ''),
                                      );
                                    },
                                  ),
                        ),
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
                      Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _title,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter Title";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Title',
                          searchIcon: Icon(
                            Icons.title,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
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
    TextEditingController titleUpdate = TextEditingController(
      text: post?.title?.toString() ?? '',
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
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: titleUpdate,
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
                      SizedBox(height: 8),
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

  Future<void> listconciergerapi() async {
    await checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().listConciergeApi(
            (loginModel?.data?.user?.id).toString(),
          );

          if (response.statusCode == 200) {
            chatuserlistmodel = ChatUserListModel.fromJson(response.data);

            for (var user in chatuserlistmodel!.data!) {
              user.requestStatuses ??= [];
            }
          }
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  GetMyJoinGroup() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
    };

    setState(() {
      isSending = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().getMyJoinGroupApi(data).then((response) async {
          if (response.statusCode == 200) {
            getgrouplistmodel = GetGroupListModel.fromJson(response.data);

            setState(() {
              isSending = false;
            });
          } else if (response.statusCode == 429 || response.statusCode == 500) {
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

  Future<void> showCancelConfirmationDialog(
    String PostId, {
    required BuildContext context,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
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

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localPostApi(data);
          if (response.statusCode == 200) {
            localpost_model = Localpost_model.fromJson(response.data);

            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending = false;
          });
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

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localPostApi(data);
          if (response.statusCode == 200) {
            localpost_model = Localpost_model.fromJson(response.data);
            _descController.text =
                localpost_model?.data?.data?[0].text.toString() ?? "";

            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending = false;
          });
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  DeleteLocalPost(String id) {
    final Map<String, String> data = {'id': id};

    setState(() {
      isSending1 = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localPostDeleteApi(
            data,
          );
          if (response.statusCode == 200) {
            localpostapi();
            _pagingController.refresh();

            if (mounted) {
              setState(() {
                isSending1 = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isSending1 = false;
            });
          } else {
            setState(() {
              isSending1 = false;
            });
          }
        } catch (e, stackTrace) {
          setState(() {
            isSending1 = false;
          });
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
    };

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider()
            .createGroupApi(
              bodyData: data,
              memberIds: selectedMembers,
              images: selectedImage != null ? [XFile(selectedImage!.path)] : [],
            )
            .then((response) async {
              if (response.statusCode == 200) {
                creategroupmodel = CreateGroupModel.fromJson(response.data);

                await refreshGroupList();
                groupNameController.clear();
                selectedMembers.clear();
                selectedImage = null;
                imagePath = '';
                setState(() {
                  isLoading = false;
                });
              } else if (response.statusCode == 422) {
                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
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

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider()
            .friendRequestApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                createfriendModel = CreateFriendModel.fromJson(response.data);
              } else if (response.statusCode == 429) {
                Get.snackbar(
                  'Error',
                  'Too many requests. Please try again later.',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Too many requests. Please try again later.',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            })
            .catchError((error) {});
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getfriendlistdAp() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
    };

    setState(() {
      isSending = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().groupFriendRequestApi(data).then((
          response,
        ) async {
          if (response.statusCode == 200) {
            getfriendListModel = GetFriendListModel.fromJson(response.data);

            setState(() {
              isSending = false;
            });
          } else if (response.statusCode == 429) {
            setState(() {
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });
            Get.snackbar(
              'Error',
              'Internal Server Error',
              backgroundColor: Colors.red.withOpacity(0.7),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
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

  Future<void> refreshGroupList() async {
    final Map<String, String> data = {
      'created_by': (loginModel?.data?.user?.id).toString(),
    };

    setState(() {
      isSending = true;
    });

    try {
      bool internet = await checkInternet();
      if (internet) {
        final response = await MessageBoardProvider().getGroupApi(data);
        getgrouplistmodel = GetGroupListModel.fromJson(response.data);

        if (response.statusCode == 200) {
          setState(() {
            isSending = false;
          });
          setState(() {});

          return;
        } else if (response.statusCode == 429) {
          setState(() {
            isSending = false;
          });
        } else {
          setState(() {
            isSending = false;
          });
        }
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    } catch (e) {}
  }

  void postslikeap(int index, VoidCallback onComplete) {
    final Map<String, String> data = {
      'user_post_id': (loginModel?.data?.user?.id).toString(),
      'type': 'like',
      'post_id': messageBoardModal?.data?[index].id.toString() ?? "",
      "user_type": "4",
    };

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().addLikeCommentApi(data).then((response) async {
          if (response.statusCode == 200) {
            messageboardpostlikeModel = MessageboardpostLikeModel.fromJson(
              response.data,
            );
            MessageBoardApi();
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
      'user_post_id': (loginModel?.data?.user?.id).toString(),
      'type': 'like',
      'post_id': (localpost_model?.data?.data?[index].id).toString(),
      "user_type": "4",
    };

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider().addLikeCommentApi(data).then((response) async {
          if (response.statusCode == 200) {
            messageboardpostlikeModel = MessageboardpostLikeModel.fromJson(
              response.data,
            );
          }
          onComplete();
          _pagingController.refresh();
          localpostapi();
        });
      } else {
        onComplete();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void Addpostapi() {
    if (addPostFormkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();

      final Map<String, String> data = {
        'user_post_id': (loginModel?.data?.user?.id).toString(),
        'description': _descController.text.trim(),
        'title': _title.text.trim(),
      };

      setState(() {
        isSending1 = true;
      });

      checkInternet().then((internet) async {
        if (internet) {
          MessageBoardProvider()
              .addPostApiWithImages(bodyData: data, images: _images)
              .then((response) async {
                if (response.statusCode == 200) {
                  add_Post_Model = Add_Post_Model.fromJson(response.data);
                  _pagingController.refresh();

                  localpostapi();
                  _descController.clear();
                  _title.clear();
                  _images = [];
                } else if (response.statusCode == 429) {
                } else {}
                if (mounted) {
                  setState(() {
                    isSending1 = false;
                  });
                }
              });
        } else {
          setState(() {
            isSending1 = false;
          });
          buildErrorDialog(context, 'Error', "Internet Required");
        }
      });
    }
  }

  void updatepostapi(
    String postId,
    String description,
    List<String> existingImageUrls,
    List<XFile> newImages,
  ) {
    final Map<String, String> data = {
      'post_id': postId,
      'description': description,
    };

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        MessageBoardProvider()
            .editPostApi(bodyData: data, images: newImages)
            .then((response) async {
              if (response.statusCode == 200) {
                localpostapi();
                _descController.clear();
                _images = [];
              } else if (response.statusCode == 429) {
                Get.snackbar(
                  'Error',
                  'Too many requests',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Internal Server Error',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
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

    bool internet = await checkInternet();
    if (!internet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getPostCommentApi(data);

      if (response.statusCode == 200) {
        getpostCommentsModel = GetPostCommentsModel.fromJson(response.data);
        MessageBoardApi();
      } else {
        getpostCommentsModel = null;
      }
    } catch (e) {
      getpostCommentsModel = null;
    }

    if (context.mounted) {
      showCommentBottomSheet(context, postId);
    }
  }

  Future<void> getComments1(BuildContext context, String postId) async {
    currentPostId = postId;
    final Map<String, String> data = {'post_id': postId};

    bool internet = await checkInternet();
    if (!internet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getPostCommentApi(data);

      if (response.statusCode == 200) {
        getpostCommentsModel = GetPostCommentsModel.fromJson(response.data);
        localpostapi();
      } else {
        getpostCommentsModel = null;
      }
    } catch (e) {
      getpostCommentsModel = null;
    }

    if (context.mounted) {
      showCommentBottomSheet(context, postId);
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

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().addLikeCommentApi(data);

          if (response.statusCode == 200) {
            sendpostCommentsModel = SendPostCommentsModel.fromJson(
              response.data,
            );

            final refreshResponse = await MessageBoardProvider()
                .addLikeCommentApi({'post_id': postId});
            if (refreshResponse.statusCode == 200) {
              getpostCommentsModel = GetPostCommentsModel.fromJson(
                refreshResponse.data,
              );
              MessageBoardApi();
              localpostapi();
              _pagingController.refresh();

              onSuccess();
            }
          } else {}
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  showrequestapi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().getRequestAppApi(
            (loginModel?.data?.user?.id).toString(),
          );

          if (response.statusCode == 200) {
            getrequestModel = GetRequestModel.fromJson(response.data);
          }
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  final String supportUrl = "https://www.wavee.ai/help-center";

  void showBlockUserDialog(BuildContext context, String supportUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                width: 73.w,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      "Report this Post",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'Are you sure you want to report this post?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey.shade800,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    isLoading
                        ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: CircularProgressIndicator(
                            color: AppColors.maincolor,
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "No",
                                  width: 30.w,
                                  route: () {
                                    Navigator.of(context).pop();
                                  },
                                  color: AppColors.white,
                                  fontcolor: Colors.black,
                                  height: 5.h,
                                  fontsize: 16.sp,
                                  radius: 12.0,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "Yes",
                                  route: () async {
                                    setState(() => isLoading = true);

                                    final Uri url = Uri.parse(supportUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Could not launch URL"),
                                        ),
                                      );
                                    }

                                    setState(() => isLoading = false);
                                    Navigator.of(context).pop();
                                  },
                                  color: AppColors.maincolor,
                                  fontcolor: Colors.white,
                                  height: 5.h,
                                  fontsize: 16.sp,
                                  radius: 12.0,
                                  width: 30.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
  bool showControls = true;

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
          showControls = !showControls;
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
          if (showControls)
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
