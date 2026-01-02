import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/customSnackBars.dart';
import 'package:wavee/Utils/linkView.dart';
import 'package:wavee/Utils/loader.dart';
import 'package:wavee/Utils/viewPdfFunction.dart';

import '../../../Utils/bottomBar.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/customInputDecoration.dart';
import '../../../Utils/errorDialog.dart';
import '../../HomeScreen/Provider/homescreenProvider.dart';
import '../../HomeScreen/modal/messageBoardModal.dart';
import '../../MessageBoard/modal/Add_Post_Model.dart';
import '../../MessageBoard/modal/GetPostCommentsModel.dart';
import '../../MessageBoard/modal/Localpost_model.dart';
import '../../MessageBoard/modal/PostLikeModel.dart';
import '../../MessageBoard/modal/SendPostCommentsModel.dart';
import '../../messageBoard/Provider/messageBoardProvider.dart';

class Messageboard extends StatefulWidget {
  int? selected;

  Messageboard({super.key, this.selected});

  @override
  State<Messageboard> createState() => _MessageboardState();
}

TextEditingController _descController = TextEditingController();
TextEditingController _title = TextEditingController();
int _currentPage = 0;

class _MessageboardState extends State<Messageboard> {
  bool isLoading = false;

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  final TextEditingController _commentController = TextEditingController();
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
  final ScrollController _scrollController = ScrollController();

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
    localpostapi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore &&
          hasMoreData) {
        isLoadingMore = true;
        currentPage++;
        localpostapi(page: currentPage);
      }
    });
    MessageBoardApi();
    fetchData();
    // listconciergerapi();
    setState(() {
      // GetMyJoinGroup();
      // getfriendlistdAp();
    });

    loadGroups();
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadAllLikesLocal();
      _loadAllLikes();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> loadGroups() async {
    setState(() {
      isSending = true;
    });

    // await GetMyJoinGroup();

    setState(() {
      isSending = false;
    });
  }

  Future<void> _loadAllLikes() async {
    try {
      final userId = loginModel?.data?.user?.id.toString() ?? '';
      final totalPosts = messageBoardModal?.data?.length ?? 0;

      isLikedList = List.generate(totalPosts, (index) => false);
      isLikeInProgressList = List.generate(totalPosts, (index) => false);

      for (int i = 0; i < totalPosts; i++) {
        if (i < isLikedList.length &&
            i < (messageBoardModal?.data?.length ?? 0)) {
          final postId = messageBoardModal?.data?[i].id.toString();
          if (postId != null) {
            final key = 'image_like_${postId}_$userId';
            final value = await secureStorage.read(key: key);
            isLikedList[i] = value == 'true';
          }
        }
      }
    } catch (e) {
      print("Error loading likes: $e");
    }
  }

  Future<void> _loadAllLikesLocal() async {
    try {
      final userId = loginModel?.data?.user?.id.toString() ?? '';
      final totalPosts = localpost_model?.data?.data?.length ?? 0;

      isLikedListLocal = List.generate(totalPosts, (index) => false);
      isLikeInProgressListLocal = List.generate(totalPosts, (index) => false);

      for (int i = 0; i < totalPosts; i++) {
        if (i < isLikedListLocal.length &&
            i < (localpost_model?.data?.data?.length ?? 0)) {
          final postId = localpost_model?.data?.data?[i].id.toString();
          if (postId != null) {
            final key = 'image_like_${postId}_$userId';
            final value = await secureStorage.read(key: key);
            isLikedListLocal[i] = value == 'true';
          }
        }
      }
    } catch (e) {
      print("Error loading local likes: $e");
    }
  }

  Future<void> _saveLikeStatus(int index, bool liked) async {
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final postId = messageBoardModal?.data?[index].id.toString();
    if (postId != null) {
      final key = 'image_like_${postId}_$userId';
      await secureStorage.write(key: key, value: liked.toString());
    }
  }

  Future<void> _saveLikeStatusLocal(int index, bool liked) async {
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final postId = localpost_model?.data?.data?[index].id.toString();
    if (postId != null) {
      final key = 'image_like_${postId}_$userId';
      await secureStorage.write(key: key, value: liked.toString());
    }
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
  String selectedOption = 'All Updates';

  int cartCount = cartDetailsModel?.data?.length ?? 0;

  bool isDetailLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ThemeToggleButton(),
              Row(
                children: [
                  Text(
                    "Message Board",
                    style: TextStyle(
                      fontSize: 20.sp,
                      color:
                          theme.isDark
                              ? Color(0xf0C4B595)
                              : AppColors.lightText,
                      fontFamily: AppConstants.manropeBold,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            theme.isDark
                                ? Color(0xf0262626)
                                : AppColors.black.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: theme.isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 2.h),
              Row(
                children: [
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(30),

                    child: Container(
                      height: 5.h,
                      width: 45.w,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.isDark ? Color(0xf0262626) : Colors.white,
                        border: Border.all(
                          color:
                              theme.isDark
                                  ? Color(0xf0262626)
                                  : Colors.grey.shade200,
                        ),
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Pill shape mate
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedOption,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey, // Image mujab no color
                          ),
                          elevation: 16,
                          borderRadius: BorderRadius.circular(20),
                          dropdownColor: Colors.white,

                          selectedItemBuilder: (BuildContext context) {
                            return [
                              'All Updates',
                              'My Building',
                              'Announcements',
                              // 'Events',
                            ].map((String value) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  selectedOption ?? "All Updates",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        theme.isDark
                                            ? Color(0xf0C4B595)
                                            : AppColors.lightText,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items:
                              [
                                'All Updates',
                                'My Building',
                                'Announcements',
                                // 'Events',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            theme.isDark
                                                ? value == selectedOption
                                                    ? Color(0xf0C4B595)
                                                    : Colors.black
                                                : value == selectedOption
                                                ? AppColors.lightText
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                          onChanged: (newValue) {
                            setState(() {
                              selectedOption = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  selectedOption == "Announcements"
                      ? GestureDetector(
                        onTap: () {
                          final List<String> buildingNames =
                              (localpost_model?.data?.data ?? [])
                                  .map(
                                    (item) =>
                                        item.users?.isNotEmpty == true
                                            ? item.users![0].buildingName ?? ""
                                            : "",
                                  )
                                  .where((name) => name.isNotEmpty)
                                  .toList();
                          final uniqueBuildings =
                              buildingNames.toSet().toList();

                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.maincolor.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_rounded,
                                          color: AppColors.maincolor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Information",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 18.sp,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          uniqueBuildings.isEmpty
                                              ? "No posts available yet in your neighbourhood"
                                              : "The following buildings in your neighbourhood posted on Wavee Ai:",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 15.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        uniqueBuildings.isEmpty
                                            ? Container(
                                              padding: EdgeInsets.all(2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "No buildings found",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : SizedBox(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    ...uniqueBuildings.map(
                                                      (name) => Card(
                                                        elevation: 1,
                                                        color: AppColors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 5.w,
                                                                vertical: 1.h,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .location_city,
                                                                size: 20.sp,
                                                                color:
                                                                    AppColors
                                                                        .maincolor,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              // 1129.29 2588.44
                                                              Expanded(
                                                                child: Text(
                                                                  capitalizeEachWord(
                                                                    name,
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppColors.maincolor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => Get.back(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.white,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  theme.isDark
                                      ? Color(0xf0262626)
                                      : Colors.white,
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color:
                                  theme.isDark
                                      ? Color(0xf0C4B595)
                                      : Color(0xf0809DCD),
                              size: 19.sp,
                            ),
                          ),
                        ),
                      ).paddingOnly(right: 9.w, left: 1.w)
                      : const SizedBox(),
                  selectedOption == "Announcements"
                      ? InkWell(
                        onTap: () {
                          addpostsheet(
                            context,
                            (loginModel?.data?.user?.id).toString(),
                          );
                        },
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 5.h,
                            padding: EdgeInsets.all(8),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color:
                                  theme.isDark
                                      ? Color(0xf0262626)
                                      : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Add Post",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 15.sp,

                                    color:
                                        theme.isDark
                                            ? Color(0xf0C4B595)
                                            : Color(0xf0809DCD),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color:
                                      theme.isDark
                                          ? Color(0xf0C4B595)
                                          : Color(0xf0809DCD),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : const SizedBox(),
                ],
              ).paddingOnly(bottom: 1.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      selectedOption == "All Updates" ||
                              selectedOption == "My Building"
                          ? messageBoardModal?.data?.length == 0 ||
                                  messageBoardModal?.data?.length == null
                              ? Center(
                                child: SizedBox(
                                  height: 70.h,
                                  child: Text(
                                    "No Posts available",
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox(
                                height: Get.height,
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
                                        color:
                                            theme.isDark
                                                ? Color(0xFF242424)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(20),

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
                                              // Profile Image
                                              CachedNetworkImage(
                                                imageUrl:
                                                    messageBoardModal
                                                        ?.data?[index]
                                                        .user
                                                        ?.conciergeImage ??
                                                    "",
                                                imageBuilder:
                                                    (
                                                      context,
                                                      imageProvider,
                                                    ) => Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                placeholder:
                                                    (
                                                      context,
                                                      url,
                                                    ) => const SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                          Icons.error,
                                                          size: 40,
                                                        ),
                                              ),

                                              SizedBox(width: 2.w),

                                              // Text container that adapts to screen width
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // User name
                                                    Flexible(
                                                      child: Text(
                                                        "${messageBoardModal?.data?[index].user?.firstName ?? ""} ${messageBoardModal?.data?[index].user?.lastName ?? ""}",
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope1,
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.isDark
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .maincolor,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(width: 1.w),

                                                    // Dot and time
                                                    Flexible(
                                                      child: Text(
                                                        "• ${formatPostDate(messageBoardModal?.data?[index].createdAt)}",
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: Colors.grey,
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
                                          ).paddingOnly(bottom: 2.h),

                                          Text(
                                            messageBoardModal
                                                    ?.data?[index]
                                                    .title ??
                                                "",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.normal,
                                              color:
                                                  theme.isDark
                                                      ? Colors.white
                                                      : AppColors.maincolor,
                                            ),
                                          ),
                                          ExpandableClickableText(
                                            text:
                                                messageBoardModal
                                                    ?.data?[index]
                                                    .text ??
                                                "N/A",
                                            trimLength: 140,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),

                                          post?.nocomment == 1
                                              ? Text(
                                                "[COMMENT ARE DISABLED IN THIS POST]",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manropeBold,
                                                  fontSize: 14.sp,
                                                  color:
                                                      theme.isDark
                                                          ? Colors.white
                                                          : AppColors.maincolor,
                                                ),
                                              )
                                              : SizedBox(),

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
                                                                  child: const Center(
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
                                                    "${messageBoardModal?.data?[index].totalComments} Replies",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          theme.isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    "${messageBoardModal?.data?[index].totalLikes} Likes",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          theme.isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ).paddingOnly(bottom: 1.h),
                                          Container(
                                            height: 0.2.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? Colors.white10
                                                      : Colors.grey.shade100,
                                            ),
                                          ).paddingOnly(bottom: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // Like Button
                                              StatefulBuilder(
                                                builder: (
                                                  context,
                                                  setLocalState,
                                                ) {
                                                  bool isLiked =
                                                      index < isLikedList.length
                                                          ? isLikedList[index]
                                                          : false;
                                                  bool isInProgress =
                                                      index <
                                                              isLikeInProgressList
                                                                  .length
                                                          ? isLikeInProgressList[index]
                                                          : false;

                                                  return InkWell(
                                                    onTap:
                                                        isInProgress
                                                            ? null
                                                            : () {
                                                              handleLikeToggle(
                                                                index,
                                                                setLocalState,
                                                              );
                                                            },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 5.w,
                                                            vertical: 1.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            theme.isDark
                                                                ? Color(0xf02F2F2F)
                                                                : Colors
                                                                    .grey[100],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            size: 18.sp,
                                                            color:
                                                                isLiked
                                                                    ? Colors.red
                                                                    : (theme.isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .grey[700]),
                                                          ),
                                                          SizedBox(width: 1.w),
                                                          Text(
                                                            "Like",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  isLiked
                                                                      ? Colors
                                                                          .red
                                                                      : (theme.isDark
                                                                          ? Colors
                                                                              .white70
                                                                          : Colors
                                                                              .grey[700]),
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Comment Button
                                              InkWell(
                                                onTap: () {
                                                  getComments(
                                                    context,
                                                    post?.id?.toString() ?? "",
                                                    post?.nocomment ?? 0,
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 1.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                            : Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons
                                                            .chat_bubble,
                                                        size: 18.sp,
                                                        color:
                                                            theme.isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                    .grey[700],
                                                      ),
                                                      SizedBox(width: 1.w),
                                                      Text(
                                                        "Comment",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color:
                                                              theme.isDark
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .grey[700],
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Save Button
                                              InkWell(
                                                onTap: () {
                                                  // Bookmark functionality
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 1.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                            : Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.bookmark_border,
                                                    size: 18.sp,
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white70
                                                            : Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                          : selectedOption == "Announcements"
                          ? localpost_model?.data?.data?.length == null ||
                                  localpost_model?.data?.data?.length == 0
                              ? Center(
                                child: SizedBox(
                                  height: Get.height,
                                  child: Text(
                                    "No Posts available",
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color:
                                          theme.isDark
                                              ? Colors.white
                                              : AppColors.black,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ),
                              ).paddingOnly(top: 25.h)
                              : SizedBox(
                                height:Get.height,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      localpost_model?.data?.data?.length,
                                  itemBuilder: (context, index) {
                                    final post =
                                        localpost_model?.data?.data?[index];
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
                                        color:
                                            theme.isDark
                                                ? Color(0xFF1E1E1E)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              theme.isDark ? 0.3 : 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
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
                                                    image:
                                                        (localpost_model
                                                                    ?.data
                                                                    ?.data?[index]
                                                                    .users?[0]
                                                                    .profiles
                                                                    ?.isNotEmpty ??
                                                                false)
                                                            ? CachedNetworkImageProvider(
                                                              localpost_model!
                                                                  .data!
                                                                  .data![index]
                                                                  .users![0]
                                                                  .profiles!,
                                                            )
                                                            : const AssetImage(
                                                                  'assets/images/waveeLogoShort.png',
                                                                )
                                                                as ImageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 2.w),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // User name
                                                    Flexible(
                                                      child: Text(
                                                        localpost_model
                                                                ?.data
                                                                ?.data?[index]
                                                                .users?[0]
                                                                .name ??
                                                            "",
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope1,
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(width: 1.w),

                                                    // Dot and time
                                                    Flexible(
                                                      child: Text(
                                                        "•${formatPostDate(localpost_model?.data?.data?[index].createdAt)}",
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: Colors.grey,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // const Spacer(),
                                              loginModel?.data?.user?.id ==
                                                      post?.userId
                                                  ? PopupMenuButton<String>(
                                                    color:
                                                        theme.isDark
                                                            ? Color(0xFF1E1E1E)
                                                            : AppColors.white,

                                                    icon: Icon(
                                                      Icons.more_vert,
                                                      color:
                                                          theme.isDark
                                                              ? AppColors.white
                                                              : Colors.black87,
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
                                                      }
                                                      // else if (value ==
                                                      //     'report') {
                                                      //   showBlockUserDialog(
                                                      //     context,
                                                      //     supportUrl,
                                                      //   );
                                                      // }
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
                                                        ],
                                                  )
                                                  : InkWell(
                                                    onTap: () {
                                                      showBlockUserDialog(
                                                        context,
                                                        supportUrl,
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons.more_vert_outlined,
                                                    ).paddingOnly(right: 2.w),
                                                  ),
                                            ],
                                          ),
                                          Text(
                                            localpost_model
                                                    ?.data
                                                    ?.data?[index]
                                                    .title ??
                                                "",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope1,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.isDark
                                                      ? AppColors.white
                                                      : AppColors.maincolor,
                                            ),
                                          ),
                                          ReadMoreText(
                                            localpost_model
                                                            ?.data
                                                            ?.data?[index]
                                                            .text ==
                                                        null ||
                                                    localpost_model
                                                            ?.data
                                                            ?.data?[index]
                                                            .text ==
                                                        ""
                                                ? "N/A"
                                                : "${localpost_model?.data?.data?[index].text}",
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
                                              ? const SizedBox()
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
                                                                      ) => const Center(
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
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
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

                                          SizedBox(height: 1.5.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${localpost_model?.data?.data?[index].totalComments} Replies",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          theme.isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    "${localpost_model?.data?.data?[index].totalLikes} Likes",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          theme.isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 0.2.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? Colors.white10
                                                      : Colors.grey.shade100,
                                            ),
                                          ).paddingOnly(bottom: 1.h, top: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // Like Button
                                              StatefulBuilder(
                                                builder: (
                                                  context,
                                                  setLocalState,
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

                                                  return InkWell(
                                                    onTap:
                                                        isInProgress
                                                            ? null
                                                            : () {
                                                              if (index <
                                                                      isLikedListLocal
                                                                          .length &&
                                                                  index <
                                                                      isLikeInProgressListLocal
                                                                          .length) {
                                                                setLocalState(() {
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
                                                                    setLocalState(() {
                                                                      isLikeInProgressListLocal[index] =
                                                                          false;
                                                                    });
                                                                  },
                                                                );
                                                              }
                                                            },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 5.w,
                                                            vertical: 1.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            theme.isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                      0.05,
                                                                    )
                                                                : Colors
                                                                    .grey[100],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            size: 18.sp,
                                                            color:
                                                                isLiked
                                                                    ? Colors.red
                                                                    : (theme.isDark
                                                                        ? Colors
                                                                            .white70
                                                                        : Colors
                                                                            .grey[700]),
                                                          ),
                                                          SizedBox(width: 1.w),
                                                          Text(
                                                            "Like",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  isLiked
                                                                      ? Colors
                                                                          .red
                                                                      : (theme.isDark
                                                                          ? Colors
                                                                              .white70
                                                                          : Colors
                                                                              .grey[700]),
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Comment Button
                                              InkWell(
                                                onTap: () {
                                                  getComments1(
                                                    context,
                                                    post?.id?.toString() ?? "",
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 1.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                            : Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons
                                                            .chat_bubble,
                                                        size: 18.sp,
                                                        color:
                                                            theme.isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                    .grey[700],
                                                      ),
                                                      SizedBox(width: 1.w),
                                                      Text(
                                                        "Comment",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color:
                                                              theme.isDark
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .grey[700],
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Bookmark Button
                                              InkWell(
                                                onTap: () {
                                                  // Bookmark functionality
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 1.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                            : Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.bookmark_border,
                                                    size: 18.sp,
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white70
                                                            : Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (isLoadingMore)
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                color: AppColors.blackColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                          : const SizedBox(),

                    ],
                  ),
                ),
              ),
            ],
          ).paddingOnly(left: 4.w, right: 4.w, top: 8.h),
          if (isComment)
            Container(
              color: AppColors.black.withValues(alpha: .2),
              child: Loader(),
            ),
          if (isSending1)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      bottomNavigationBar: const BottomBar(selected: 0),
    );
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
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
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

  List<XFile> _images = [];

  Future<void> _pickImages(Function setModalState) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setModalState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void showCommentBottomSheet(
    BuildContext context,
    String postId,
    int comment,
  ) {
    bool isLoading = true;
    final theme = Provider.of<ThemeController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDark ? Color(0xFF252525) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            TextEditingController commentController = TextEditingController();
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
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 12),
                        const Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : getpostCommentsModel == null ||
                                      getpostCommentsModel?.data == null ||
                                      getpostCommentsModel!.data!.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // એક સરસ ચેટ કે કમેન્ટ આઇકન
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "No comments found",
                                          style: TextStyle(
                                            fontFamily:
                                                AppConstants.manropeBold,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // સબ ટેક્સ્ટ (વધારાની વિગત માટે)
                                        Text(
                                          "Be the first one to start the conversation!",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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
                                                      const CircularProgressIndicator(
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
                                                    image: const DecorationImage(
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
                        comment == 1
                            ? SizedBox() // Disable comment input if value = 1
                            : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    style: TextStyle(
                                      color:
                                          theme.isDark
                                              ? AppColors.black
                                              : AppColors.black,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Write a comment...",
                                      filled: true,
                                      hintStyle: TextStyle(
                                        color:
                                            theme.isDark
                                                ? AppColors.black
                                                : AppColors.black,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 16,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                isSendingComment
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        if (commentController.text
                                            .trim()
                                            .isEmpty)
                                          return;

                                        setModalState(
                                          () => isSendingComment = true,
                                        );

                                        await sendComment(
                                          context,
                                          commentController.text.trim(),
                                          postId,
                                          () {
                                            commentController.clear();
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
    final theme = Provider.of<ThemeController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDark ? Color(0xFF252525) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manropeBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const Text(
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
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter Title";
                          }
                          return null;
                        },

                        style: TextStyle(
                          color:
                              theme.isDark ? AppColors.black : AppColors.black,
                          fontFamily: AppConstants.manrope,
                        ),
                        decoration: inputDecoration(
                          hintText: 'Enter Title',
                          isDark: theme.isDark,

                          searchIcon: Icon(
                            Icons.title,
                            size: 20.sp,
                            color: AppColors.black,
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
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color:
                              theme.isDark ? AppColors.black : AppColors.black,
                          fontFamily: AppConstants.manrope,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          isDark: theme.isDark,
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
                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        const Text(
                          "Selected Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      const SizedBox(height: 8),
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
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
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
                      const SizedBox(height: 24),
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
                              Get.back();
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
                                fontFamily: AppConstants.manropeBold,
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
    final theme = Provider.of<ThemeController>(context, listen: false);

    List<String> existingImages = List<String>.from(post?.file ?? []);
    List<XFile> newImages0 = [];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDark ? Color(0xFF252525) : Colors.white,
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
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manropeBold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: titleUpdate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your title";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color:
                              theme.isDark ? AppColors.black : AppColors.black,
                          fontFamily: AppConstants.manrope,
                        ),
                        decoration: inputDecoration(
                          hintText: 'Enter Title',
                          searchIcon: const Icon(
                            Icons.title,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descUpdateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color:
                              theme.isDark ? AppColors.black : AppColors.black,
                          fontFamily: AppConstants.manrope,
                        ),
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          searchIcon: const Icon(
                            Icons.description,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      batan(
                        title: "Choose Image",
                        route: () async {
                          List<XFile>? picked = await _pickImages1(
                            setModalState,
                          );
                          if (picked != null) {
                            setModalState(() {
                              newImages0.addAll(picked);
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
                      const SizedBox(height: 16),
                      if (existingImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Existing Images"),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: existingImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            existingImages[index],
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
                                              existingImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
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
                      if (newImages0.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("New Images"),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: newImages0.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            File(newImages0[index].path),
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
                                              newImages0.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
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
                      const SizedBox(height: 24),
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
                              String title = titleUpdate.text.trim();
                              List<String> updatedImages = [...existingImages];
                              List<XFile> newImages = newImages0;

                              updatepostapi(
                                post.id.toString(),
                                updatedDesc,
                                title,
                                updatedImages,
                                newImages,
                              );

                              Get.back();
                            }
                          },
                          child: Center(
                            child: Text(
                              "Update Post",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manropeBold,
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
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      return pickedFiles;
    }
    return null;
  }

  // Future<void> listconciergerapi() async {
  //   await checkInternet().then((internet) async {
  //     if (internet) {
  //       try {
  //         final response = await MessageBoardProvider().listConciergeApi(
  //           (loginModel?.data?.user?.id).toString(),
  //         );
  //
  //         if (response.statusCode == 200) {
  //           chatuserlistmodel = ChatUserListModel.fromJson(response.data);
  //
  //           for (var user in chatuserlistmodel!.data!) {
  //             user.requestStatuses ??= [];
  //           }
  //         }
  //       } catch (e) {}
  //     } else {
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

  // GetMyJoinGroup() {
  //   final Map<String, String> data = {
  //     'user_id': (loginModel?.data?.user?.id).toString(),
  //   };
  //
  //   setState(() {
  //     isSending = true;
  //   });
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       MessageBoardProvider().getMyJoinGroupApi(data).then((response) async {
  //         if (response.statusCode == 200) {
  //           getgrouplistmodel = GetGroupListModel.fromJson(response.data);
  //
  //           setState(() {
  //             isSending = false;
  //           });
  //         } else if (response.statusCode == 429 || response.statusCode == 500) {
  //           isSending = false;
  //         } else {
  //           isSending = false;
  //         }
  //       });
  //     } else {
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

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
                          Get.back();
                          DeleteLocalPost(PostId);
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

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  Future<void> localpostapi({int page = 1}) async {
    final Map<String, String> data = {
      'residentType': "residents",
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
      'page': page.toString(),
    };

    if (page == 1) setState(() => isSending = true);

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localPostApi(data);
          if (response.statusCode == 200) {
            final newData = Localpost_model.fromJson(response.data);

            if (mounted) {
              setState(() {
                if (page == 1) {
                  localpost_model = newData;
                } else {
                  localpost_model?.data?.data?.addAll(newData.data?.data ?? []);
                }

                // If API returns less than 10 items, no more data to load
                hasMoreData = (newData.data?.data?.length ?? 0) == 10;
                isLoadingMore = false;
                isSending = false;
              });
            }
          } else {
            setState(() {
              isLoadingMore = false;
              isSending = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoadingMore = false;
            isSending = false;
          });
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void DeleteLocalPost(String id) {
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
            // Remove the deleted post from the local list immediately
            if (mounted) {
              setState(() {
                // localpost_model?.data?.data?.removeWhere((post) => post.id.toString() == id);
                isSending1 = false;
              });
            }
            showSnackBar(
              context: context,
              title: 'Success',
              message: 'Post deleted successfully',
              backgoundColor: Colors.green,
              ColorText: Colors.white,
            );
            await localpostapi();
          } else {
            if (mounted) {
              setState(() {
                isSending1 = false;
              });
            }
            showSnackBar(
              context: context,
              title: 'Error',
              message: 'Failed to delete post',
              backgoundColor: AppColors.redColor,
              ColorText: Colors.white,
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isSending1 = false;
            });
          }
          showSnackBar(
            context: context,
            title: 'Error',
            message: 'An error occurred while deleting post',
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            isSending1 = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
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
          // _pagingController.refresh();
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
    String title,
    List<String> existingImageUrls,
    List<XFile> newImages,
  ) {
    final Map<String, String> data = {
      'post_id': postId,
      'description': description,
      'title': title,
    };

    setState(() {
      isSending1 = true;
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
                if (mounted) {
                  setState(() {
                    isSending1 = false;
                  });
                }
              } else if (response.statusCode == 429) {
                showSnackBar(
                  context: context,
                  title: 'Error',
                  message: 'Too many requests',
                  backgoundColor: AppColors.redColor,
                  ColorText: Colors.white,
                );

                if (mounted) {
                  setState(() {
                    isSending1 = false;
                  });
                }
              } else {
                showSnackBar(
                  context: context,
                  title: 'Error',
                  message: 'Internal server error',
                  backgoundColor: AppColors.redColor,
                  ColorText: Colors.white,
                );
              }

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

  bool isComment = false;

  Future<void> getComments(
    BuildContext context,
    String postId,
    int? comment,
  ) async {
    setState(() {
      isComment = true;
    });
    comment = comment ?? 0; // prevent null → default 0

    currentPostId = postId;
    final Map<String, String> data = {'post_id': postId};

    bool internet = await checkInternet();
    if (!internet) {
      setState(() {
        isComment = false;
      });
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getPostCommentApi(data);

      if (response.statusCode == 200) {
        getpostCommentsModel = GetPostCommentsModel.fromJson(response.data);
        MessageBoardApi();
        setState(() {
          isComment = false;
        });
      } else {
        getpostCommentsModel = null;
        setState(() {
          isComment = false;
        });
      }
    } catch (e) {
      getpostCommentsModel = null;
      setState(() {
        isComment = false;
      });
    }

    if (context.mounted) {
      showCommentBottomSheet(context, postId, comment);
      setState(() {
        isComment = false;
      });
    }
  }

  Future<void> getComments1(BuildContext context, String postId) async {
    setState(() {
      isComment = true;
    });
    currentPostId = postId;
    final Map<String, String> data = {'post_id': postId};

    bool internet = await checkInternet();
    if (!internet) {
      setState(() {
        isComment = false;
      });
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await MessageBoardProvider().getPostCommentApi(data);

      if (response.statusCode == 200) {
        getpostCommentsModel = GetPostCommentsModel.fromJson(response.data);
        localpostapi();
        setState(() {
          isComment = false;
        });
      } else {
        getpostCommentsModel = null;
        setState(() {
          isComment = false;
        });
      }
    } catch (e) {
      getpostCommentsModel = null;
      setState(() {
        isComment = false;
      });
    }

    if (context.mounted) {
      setState(() {
        isComment = false;
      });
      showCommentBottomSheet(context, postId, 0);
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
                .getPostCommentApi({'post_id': postId});
            if (refreshResponse.statusCode == 200) {
              getpostCommentsModel = GetPostCommentsModel.fromJson(
                refreshResponse.data,
              );
              MessageBoardApi();
              localpostapi();

              onSuccess();
            }
          } else {}
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // showrequestapi() {
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       try {
  //         final response = await MessageBoardProvider().getRequestAppApi(
  //           (loginModel?.data?.user?.id).toString(),
  //         );
  //
  //         if (response.statusCode == 200) {
  //           getrequestModel = GetRequestModel.fromJson(response.data);
  //         }
  //       } catch (e) {}
  //     } else {
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

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
                padding: const EdgeInsets.all(16),
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
                    Row(
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
                                Get.back();
                                launchTermsUrl();
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

  void launchTermsUrl() async {
    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse("https://wavee.ai/contact");
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      log("Error launching URL: $e");
      // You can show an error message here if needed
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String capitalizeEachWord(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool onlyIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            if (!onlyIcon) ...[
              SizedBox(width: 2.w),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
