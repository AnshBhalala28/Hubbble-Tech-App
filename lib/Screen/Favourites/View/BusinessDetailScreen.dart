import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../../comman/videowidget.dart';
import '../../Community Screen/Community Screen/Model/BusnessViewModal.dart';
import '../../Community Screen/Community Screen/Model/OfferPromoAsViewedModel.dart';
import '../../Community Screen/Community Screen/Model/businesslikemodel.dart';
import '../../Community Screen/Community Screen/Provider/community_provider.dart';
import '../../Community Screen/Community Screen/view/FullScreenImageView.dart';
import '../../Message_screen/View/messageScreen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final BusnessViewModal? busnessviewmodal;

  const BusinessDetailScreen({Key? key, required this.busnessviewmodal})
      : super(key: key);

  @override
  _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late BusnessViewModal currentModal;
  bool isSending = false;
  String AppLat = '';
  String AppLon = '';
  String selectedUserId = '';

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  void moveToLocation() {
    // Implement your location functionality here
    // Same as in your bottom sheet
  }

  Widget buildListTile(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: Colors.black54),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontFamily: AppConstants.manrope),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        ],
      ),
    );
  }

  Widget buildMediaListView(List<Posts> mediaItems) {
    return SizedBox(
      height: 35.h,
      child: InViewNotifierList(
        scrollDirection: Axis.horizontal,
        isInViewPortCondition: (deltaTop, deltaBottom, viewPortDimension) {
          return deltaTop < (0.5 * viewPortDimension) &&
              deltaBottom > (0.5 * viewPortDimension);
        },
        itemCount: mediaItems.length,
        builder: (context, index) {
          final item = mediaItems[index];
          return InViewNotifierWidget(
            id: '$index',
            builder: (context, isInView, _) {
              return Container(
                width: 44.w,
                height: 30.h,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.type == 'video'
                      ? VideoWidget(
                          videoUrl: item.file ?? '',
                          play: isInView,
                          postId: item.id ?? 0,
                        )
                      : GestureDetector(
                          onTap: () {
                            print("Image tapped: ${item.file}");
                            Get.to(() => FullScreenImageView(
                                  imageUrl: item.file ?? '',
                                  postId: item.id ?? 0,
                                ));
                          },
                          child: CachedNetworkImage(
                            imageUrl: item.file ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Image.asset(
                              'assets/images/waveeLogoShort.png',
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'aassets/images/waveeLogoShort.png',
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildEventListView() {
    if (busnessviewmodal?.data?.events == null ||
        busnessviewmodal!.data!.events!.isEmpty) {
      return Center(
          // child: Container(
          //   margin: EdgeInsets.only(top: 4.h),
          //   child: Text(
          //     "No Events Available",
          //     style: TextStyle(
          //         fontSize: 17.sp,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.grey),
          //   ),
          // ),
          );
    }

    // Return Column instead of SizedBox to avoid nested scrolling issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use List.generate instead of ListView.builder to avoid nested scrolling
        ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  // Handle event tap if needed
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 3,
                    //     spreadRadius: 1,
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: busnessviewmodal?.data?.events?[index].attachment !=
                            null
                        ? CachedNetworkImage(
                            imageUrl: busnessviewmodal!
                                .data!.events![index].attachment!,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(
                              Icons.event,
                              color: Colors.grey,
                              size: 8.w,
                            ),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.event,
                            color: Colors.grey,
                            size: 8.w,
                          ),
                  ),
                ),
                title: Text(
                  busnessviewmodal?.data?.events?[index].title ?? "No Title",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 16.sp),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${busnessviewmodal?.data?.events?[index].location ?? 'No Location'}",
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontFamily: AppConstants.manrope),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.blue, size: 16.sp),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            (String? eventDate) {
                              if (eventDate == null || eventDate.isEmpty)
                                return "N/A";
                              DateTime parsedDate = DateTime.parse(eventDate);
                              return DateFormat('yyyy-MM-dd hh:mm a')
                                  .format(parsedDate);
                            }(busnessviewmodal
                                    ?.data?.events?[index].eventDate ??
                                ""),
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
            ),
          );
        }),
      ],
    );
  }

  //Offers/promotion
  Widget buildListView(
      List<String?> items, List<String?> links, List<String?> titles) {
    if (busnessviewmodal?.data?.offerPromotions == null ||
        busnessviewmodal!.data!.offerPromotions!.isEmpty) {
      // return Center(
      //   child: Container(
      //     margin: EdgeInsets.only(top: 4.h),
      //     child: Text(
      //       "No Offers/Promotions Available",
      //       style: TextStyle(
      //           fontSize: 17.sp,
      //           fontWeight: FontWeight.bold,
      //           color: Colors.grey),
      //     ),
      //   ),
      // );
    }

    // Remove SizedBox height constraint and ListView.builder scrolling
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use Column instead of ListView.builder to avoid nested scrolling
        ...List.generate(items.length, (index) {
          String? linkUrl = links[index]?.trim();
          // Format URL for display - show only domain
          String displayUrl = '';
          if (linkUrl != null && linkUrl.isNotEmpty) {
            try {
              Uri uri = Uri.parse(linkUrl);
              displayUrl = uri.host;
              // If URL is too long, truncate it
              if (displayUrl.length > 30) {
                displayUrl = displayUrl.substring(0, 27) + '...';
              }
            } catch (e) {
              displayUrl = linkUrl;
              if (displayUrl.length > 30) {
                displayUrl = displayUrl.substring(0, 27) + '...';
              }
            }
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () async {
                  OfferPromoAsViewedApi();
                  if (linkUrl != null && linkUrl.isNotEmpty) {
                    Uri uri = Uri.parse(linkUrl);
                    print("Opening URL: $linkUrl"); // Debugging

                    // Check if the URL can be launched before opening
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      print("Error: Could not launch $linkUrl");
                    }
                  } else {
                    print("Error: Invalid URL");
                  }
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: items[index] ?? '',
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdQLwDqDwd2JfzifvfBTFT8I7iKFFevcedYg&s"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  titles[index] ?? "No Title",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayUrl.isNotEmpty
                            ? displayUrl
                            : "No link available",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 14.sp,
                          color: Colors.blue,
                          decoration: linkUrl != null && linkUrl.isNotEmpty
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildServiceListView(List<Services> services) {
    if (busnessviewmodal?.data?.services == null ||
        busnessviewmodal!.data!.services!.isEmpty) {
      return Center(
          // child: Container(
          //   margin: EdgeInsets.only(top: 4.h),
          //   child: Text(
          //     "No Services Available",
          //     style: TextStyle(
          //         fontSize: 17.sp,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.grey),
          //   ),
          // ),
          );
    }

    // Return Column instead of SizedBox to avoid nested scrolling issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use List.generate instead of ListView.builder to avoid nested scrolling
        ...List.generate(services.length, (index) {
          String imageUrl = services[index].images ?? ''; // Handle null case

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  // Handle service tap if needed
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 3,
                    //     spreadRadius: 1,
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://media.hswstatic.com/eyJidWNrZXQiOiJjb250ZW50Lmhzd3N0YXRpYy5jb20iLCJrZXkiOiJnaWZcL3BsYXlcLzBiN2Y0ZTliLWY1OWMtNDAyNC05ZjA2LWIzZGMxMjg1MGFiNy0xOTIwLTEwODAuanBnIiwiZWRpdHMiOnsicmVzaXplIjp7IndpZHRoIjo4Mjh9fX0=',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(
                        Icons.home_repair_service,
                        color: Colors.grey,
                        size: 8.w,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  services[index].title ?? "Service Name",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        // Icon(Icons.attach_money,
                        //     color: Colors.green, size: 16.sp),

                        Text(
                          "£",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Price: ${services[index].price ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.green[700],
                              fontFamily: AppConstants.manrope,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event_available,
                            color: Colors.blue, size: 16.sp),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Availability: ${services[index].availability ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blue[700],
                              fontFamily: AppConstants.manrope,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final busnessviewmodal = widget.busnessviewmodal;
    final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      drawer: const SideMenu(),
      key: _scaffoldKeyParcel,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TitleBar(
                    back: () {
                      Get.back();
                    },
                    title: 'Business Details',
                    drawerCallback: () {
                      _scaffoldKeyParcel.currentState?.openDrawer();
                    },
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  // Business info row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: (busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.logo
                                                    ?.isNotEmpty ??
                                                false)
                                            ? CachedNetworkImageProvider(
                                                busnessviewmodal!
                                                    .data!.business!.logo!)
                                            : AssetImage(
                                                    "assets/images/waveeLogoShort.png")
                                                as ImageProvider,
                                      ).paddingOnly(right: 2.5.w, top: 1.h),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              busnessviewmodal?.data?.business
                                                      ?.businessName ??
                                                  "N/A",
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w900,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              "${(busnessviewmodal?.data?.distanceToBusiness ?? 0).toStringAsFixed(1)} Miles",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            busnessviewmodal?.data?.business
                                                            ?.user?.address ==
                                                        null ||
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.user
                                                            ?.address ==
                                                        0 ||
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.user
                                                            ?.address ==
                                                        ""
                                                ? Container()
                                                : Text(
                                                    busnessviewmodal
                                                                    ?.data
                                                                    ?.business
                                                                    ?.user
                                                                    ?.address
                                                                    ?.city !=
                                                                null &&
                                                            busnessviewmodal
                                                                    ?.data
                                                                    ?.business
                                                                    ?.user
                                                                    ?.address
                                                                    ?.country !=
                                                                null
                                                        ? "${busnessviewmodal?.data?.business?.user?.address?.city}, ${busnessviewmodal?.data?.business?.user?.address?.country}"
                                                        : "N/A",
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(left: 2.w),

                                  // Tags row
                                  Container(
                                    margin: EdgeInsets.only(top: 1.5.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                (busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.tags
                                                        ?.length ??
                                                    0);
                                            i++) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2.w,
                                                vertical: 0.5.h),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: 2.5.h,
                                                  width: 2.5.h,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      busnessviewmodal
                                                              ?.data
                                                              ?.business
                                                              ?.tags?[i]
                                                              .img ??
                                                          "",
                                                      height: 3.h,
                                                      width: 3.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 1.w),
                                                Text(
                                                  busnessviewmodal
                                                          ?.data
                                                          ?.business
                                                          ?.tags?[i]
                                                          .name ??
                                                      "No Tags",
                                                  style: TextStyle(
                                                    color: AppColors.black,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                        ]
                                      ],
                                    ).paddingOnly(left: 2.w, bottom: 1.h),
                                  ),
                                ],
                              ),
                            ),
                          ).paddingSymmetric(horizontal: 16, vertical: 1.h),

                          // Action buttons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (busnessviewmodal?.data?.business?.id !=
                                        null) {
                                      await handleLikeTap();
                                    } else {
                                      print("Error: Business ID is null.");
                                    }
                                  },
                                  child: Container(
                                    height: 4.5.h,
                                    width: 27.w,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          busnessviewmodal?.data?.isLiked ==
                                                  true
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color:
                                              busnessviewmodal?.data?.isLiked ==
                                                      true
                                                  ? Colors.red
                                                  : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 4.5.h,
                                  width: 27.w,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Colors.black,
                                      size: 6.w,
                                    ),
                                    onPressed: () {
                                      if (busnessviewmodal?.data?.business !=
                                          null) {
                                        AppLat = busnessviewmodal!
                                            .data!.business!.latitude
                                            .toString();
                                        AppLon = busnessviewmodal!
                                            .data!.business!.longitude
                                            .toString();
                                        selectedUserId = busnessviewmodal!
                                            .data!.business!.id
                                            .toString();

                                        Navigator.pop(context);
                                        moveToLocation();
                                      } else {
                                        print("Error: Business data is null");
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 4.5.h,
                                  width: 27.w,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      CupertinoIcons.chat_bubble_text,
                                      color: AppColors.black,
                                      size: 5.w,
                                    ),
                                    onPressed: () {
                                      print(
                                          'Hello Id ${busnessviewmodal?.data?.business?.user?.id}');
                                      print(
                                          'Mine Id ${loginModel?.data?.user?.id}');
                                      print(
                                          'Image is ${busnessviewmodal?.data?.business?.logo}');
                                      Get.to(MessageScreen(
                                        type: "business",
                                        chatName: busnessviewmodal?.data
                                                ?.business?.businessName ??
                                            "N/A",
                                        conciergeID: (busnessviewmodal
                                                ?.data?.business?.user?.id)
                                            .toString(),
                                        image: busnessviewmodal
                                                ?.data?.business?.logo ??
                                            "",
                                      ));
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 16),

                          SizedBox(height: 1.h),

                          // Posts, Events, Offers, Services sections
                          if ((busnessviewmodal?.data?.posts ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.events ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.offerPromotions ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.services ?? [])
                                  .isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //posts
                                  if ((busnessviewmodal?.data?.posts ?? [])
                                      .isNotEmpty) ...[
                                    SizedBox(height: 1.h),
                                    buildMediaListView(
                                        busnessviewmodal?.data?.posts ?? []),
                                  ],

                                  //events
                                  if ((busnessviewmodal?.data?.events ?? [])
                                      .isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Events",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    buildEventListView(),
                                  ],

                                  //offers
                                  if ((busnessviewmodal
                                              ?.data?.offerPromotions ??
                                          [])
                                      .isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Offers & Promotions",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    buildListView(
                                      busnessviewmodal?.data?.offerPromotions
                                              ?.map((e) => e.files ?? "")
                                              .toList() ??
                                          [],
                                      busnessviewmodal?.data?.offerPromotions
                                              ?.map((e) => e.url ?? "")
                                              .toList() ??
                                          [],
                                      busnessviewmodal?.data?.offerPromotions
                                              ?.map(
                                                  (e) => e.title ?? "No Title")
                                              .toList() ??
                                          [],
                                    ),
                                  ],

                                  //services
                                  if ((busnessviewmodal?.data?.services ?? [])
                                      .isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Services",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    buildServiceListView(
                                        busnessviewmodal?.data?.services ?? []),
                                  ],
                                ],
                              ).paddingSymmetric(horizontal: 0),
                            ),

                          SizedBox(height: 3.h),

                          // Address and Phone container
                          Container(
                            width: 110.w,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildListTile(
                                  icon: Icons.location_on,
                                  title: "Address",
                                  subtitle:
                                      "${(busnessviewmodal?.data?.business?.user?.address?.address ?? "").toString()}${(busnessviewmodal?.data?.business?.user?.address?.city ?? "No Address").toString()}${(busnessviewmodal?.data?.business?.user?.address?.country ?? "").toString()}",
                                ),
                                Divider(color: Colors.grey.shade300),
                                buildListTile(
                                  icon: Icons.phone,
                                  title: "Phone",
                                  subtitle: busnessviewmodal?.data?.business
                                                  ?.user?.mobileNo ==
                                              null ||
                                          busnessviewmodal?.data?.business?.user
                                                  ?.mobileNo ==
                                              ""
                                      ? "N/A"
                                      : (busnessviewmodal
                                              ?.data?.business?.user?.mobileNo)
                                          .toString(),
                                ),
                              ],
                            ),
                          ).paddingSymmetric(horizontal: 16),

                          SizedBox(height: 2.h),

                          // You May Also Like section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "You May Also Like",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ),

                          SizedBox(height: 1.h),

                          Column(
                            children: [
                              for (int i = 0;
                                  i <
                                          (busnessviewmodal?.data
                                                  ?.nearbyBusinesses?.length ??
                                              0) &&
                                      i < 5;
                                  i++) ...[
                                InkWell(
                                  // onTap: () {
                                  //   print("Business Check ID: ${busnessviewmodal?.data?.nearbyBusinesses?[i].id}");
                                  //   BussinessViewProfile((busnessviewmodal?.data?.nearbyBusinesses?[i].id).toString());
                                  // },

                                  onTap: () async {
                                    final businessId = busnessviewmodal
                                        ?.data?.nearbyBusinesses?[i].id
                                        ?.toString();
                                    if (businessId != null) {
                                      await BussinessViewProfile(businessId);
                                    }
                                  },

                                  child: Container(
                                    width: 110.w,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 16),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            print(
                                                "Business ID: ${busnessviewmodal?.data?.nearbyBusinesses?[i].id}");
                                            BussinessViewProfile(
                                                (busnessviewmodal
                                                        ?.data
                                                        ?.nearbyBusinesses?[i]
                                                        .id)
                                                    .toString());
                                          },
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                              busnessviewmodal
                                                      ?.data
                                                      ?.nearbyBusinesses?[i]
                                                      .logo ??
                                                  "https://randomuser.me/api/portraits/men/1.jpg",
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                busnessviewmodal
                                                            ?.data
                                                            ?.nearbyBusinesses?[
                                                                i]
                                                            .businessName
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? busnessviewmodal!
                                                        .data!
                                                        .nearbyBusinesses![i]
                                                        .businessName!
                                                    : "N/A",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        AppConstants.manrope),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ReadMoreText(
                                                  busnessviewmodal
                                                              ?.data
                                                              ?.nearbyBusinesses?[
                                                                  i]
                                                              .description
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? busnessviewmodal!
                                                          .data!
                                                          .nearbyBusinesses![i]
                                                          .description!
                                                      : "N/A",
                                                  trimLines: 3,
                                                  colorClickableText:
                                                      Colors.blue,
                                                  trimMode: TrimMode.Line,
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
                                                          AppColors.maincolor),
                                                  lessStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                      color:
                                                          AppColors.maincolor),
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.grey.shade500,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Distance :- ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily: AppConstants
                                                            .manrope,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: (busnessviewmodal
                                                                  ?.data
                                                                  ?.nearbyBusinesses?[
                                                                      i]
                                                                  .distance !=
                                                              null)
                                                          ? "${busnessviewmodal!.data!.nearbyBusinesses![i].distance!.toStringAsFixed(2)} mi"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.sp,
                                                        fontFamily: AppConstants
                                                            .manrope,
                                                      ),
                                                    ),
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
                              ]
                            ],
                          ),
                          SizedBox(height: 20), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
    );
  }

  // BussinessViewProfile(String id) {
  //   // EasyLoading.show();
  //
  //   setState(() {
  //     isSending = true; // Show Loader
  //   });
  //
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       CommunityProvider()
  //           .projectlistapi(
  //           (loginModel?.data?.user?.id).toString(), id, AppLat, AppLon)
  //           .then((response) async {
  //         busnessviewmodal =
  //             BusnessViewModal.fromJson(json.decode(response.body));
  //         if (response.statusCode == 200) {
  //           print("check navigate");
  //           //log("data ave che che ${response.body}");
  //           //  EasyLoading.dismiss();
  //           setState(() {
  //             isSending = false; // Hide Loader
  //           });
  //
  //           // final String businessId =
  //           // (busnessviewmodal?.data?.business?.id).toString();
  //           // Get.back();
  //           // await Future.delayed(Duration(milliseconds: 100));
  //           // BussinessViewProfile(businessId);
  //
  //           Get.to(() => BusinessDetailScreen(busnessviewmodal: busnessviewmodal));
  //         } else if (response.statusCode == 422) {
  //           // EasyLoading.dismiss();
  //           setState(() {
  //             isSending = false; // Hide Loader
  //           });
  //         } else {
  //           //EasyLoading.dismiss();
  //           setState(() {
  //             isSending = false;
  //           });
  //         }
  //       });
  //     } else {
  //       // setState(() {});
  //       // EasyLoading.dismiss();
  //       setState(() {
  //         isSending = false;
  //       });
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

  Future<void> BussinessViewProfile(String id) async {
    setState(() => isSending = true);

    bool internet = await checkInternet();
    if (!internet) {
      setState(() => isSending = false);
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    final response = await CommunityProvider().projectlistapi(
      (loginModel?.data?.user?.id).toString(),
      id,
      AppLat,
      AppLon,
    );

    if (response.statusCode == 200) {
      final newModal = BusnessViewModal.fromJson(json.decode(response.body));

      // setState(() => isSending = false);
      print("check navigate");

      setState(() {
        isSending = false;
        widget.busnessviewmodal?.data = newModal.data;
      });
    } else {
      setState(() => isSending = false);
      buildErrorDialog(context, 'Error', "Something went wrong");
    }
  }

  handleLikeTap() {
    bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
    String newLikeStatus = isCurrentlyLiked ? "0" : "1";
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'is_like': newLikeStatus,
    };
    print("🟢 Request Parameter: $data");

    setState(() {
      isSending = true; // Show Loader
      //  showSuccessMsg = true;
    });

    //   EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().IsLikeApi(data).then((response) async {
          if (response.statusCode == 200) {
            bussinesslikemodel =
                BussinessLikeModel.fromJson(json.decode(response.body));
            print("Done Like Message");
            print("Response: ${response.body}");

            setState(() {
              isSending = true; // Show Loader
              //  showSuccessMsg = false;
            });

            // EasyLoading.dismiss();
            // EasyLoading.showSuccess("Like Sent Successfully!");
            //request.clear();
            final String businessId =
                (busnessviewmodal?.data?.business?.id).toString();
            Get.back(); // પહેલા પાછળ જાઓ
            await Future.delayed(Duration(milliseconds: 100)); // થોડી રાહ જુઓ
            BussinessViewProfile(businessId);
          } else if (response.statusCode == 429) {
            setState(() {
              isSending = true; // Show Loader
              //  showSuccessMsg = false;
            });

            //  EasyLoading.dismiss();
          } else {
            print(
                "Internal Server Error - Status Code: ${response.statusCode}");
            //  EasyLoading.dismiss();
            EasyLoading.showError("Internal Server Error");
          }
        }).catchError((error, stackTrace) {
          // EasyLoading.dismiss();
          //           // EasyLoading.showError("Something went wrong");
          //log("Erroerwerwrwerwr");
          print(" Error in like API: $error");
          print(" Stack Trace: $stackTrace"); // 🔹 Stack Trace print
        });
      } else {
        //  EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  OfferPromoAsViewedApi() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'offerPromotion_id':
          (busnessviewmodal?.data?.offerPromotions?[0].id).toString(),
    };
    print("request offres promotion view parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().OfferPromoAsViewed(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            offerpromoAsviewedmodel =
                OfferPromoAsViewedModel.fromJson(responseData);
            print("View done");
          } else if (response.statusCode == 429) {
            print("Too many requests");
          } else {
            print("Internal Server Error");
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}

// How to use this screen:
// Get.to(BusinessDetailScreen(busnessviewmodal: busnessViewModal));
