// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:inview_notifier_list/inview_notifier_list.dart';
// import 'package:readmore/readmore.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../comman/Custom_AppBar.dart';
// import '../../../comman/check_inernet_connecty.dart';
// import '../../../comman/colors.dart';
// import '../../../comman/const.dart';
// import '../../../comman/custom_batan.dart';
// import '../../../comman/error_dialog.dart';
// import '../../../comman/loader.dart';
// import '../../../comman/videowidget.dart';
// import '../../Community Screen/Community Screen/Model/BusnessViewModal.dart';
// import '../../Community Screen/Community Screen/Model/OfferPromoAsViewedModel.dart';
// import '../../Community Screen/Community Screen/Model/businesslikemodel.dart';
// import '../../Community Screen/Community Screen/Provider/community_provider.dart';
// import '../../Community Screen/Community Screen/view/FullScreenImageView.dart';
// import '../../Event/Model/send_event_model.dart';
// import '../../Event/Provider/eventProvider.dart';
// import '../../messageScreen/View/messageScreen.dart';
// import '../../productDetailPage/view/product_detail_page.dart';
// import '../../serviceDetailPage/View/service_detail_page.dart';
//
// class BusinessDetailScreen extends StatefulWidget {
//   final BusnessViewModal? busnessviewmodal;
//
//   const BusinessDetailScreen({super.key, required this.busnessviewmodal});
//
//   @override
//   _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
// }
//
// class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
//   late BusnessViewModal currentModal;
//   bool isSending = false;
//   String AppLat = '';
//   String AppLon = '';
//   String selectedUserId = '';
//   List<String> sentEventIds = [];
//   bool isRequestValid = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController requestController = TextEditingController();
//   late String _mapStyle;
//   bool isLoading = false;
//   bool load = false;
//   bool isMapLoading = false;
//   bool isLocationFetched = false;
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {});
//
//     _getCurrentLocation();
//   }
//
//   void moveToLocation() {}
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         isLoading = false;
//         isMapLoading = false;
//       });
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           isLoading = false;
//           isMapLoading = false;
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         isLoading = false;
//         isMapLoading = false;
//       });
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     AppLat = position.latitude.toString();
//     AppLon = position.longitude.toString();
//
//     setState(() {
//       isLocationFetched = true;
//     });
//
//     getCityName(position.latitude, position.longitude);
//
//     setState(() {
//       isMapLoading = false;
//     });
//   }
//
//   String? city;
//
//   Future<void> getCityName(double latitude, double longitude) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         latitude,
//         longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           city = placemarks[0].locality;
//         });
//
//         BussinessViewProfile((busnessviewmodal?.data?.business?.id).toString());
//
//         setState(() {
//           isSending = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isSending = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final busnessviewmodal = widget.busnessviewmodal;
//     final GlobalKey<ScaffoldState> scaffoldKeyParcel =
//         GlobalKey<ScaffoldState>();
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 1.h),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                   child: TitleBar(
//                     back: () {
//                       Get.back();
//                     },
//                     title: 'Business Details',
//                     drawerCallback: () {},
//                   ),
//                 ),
//                 SizedBox(height: 1.h),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 0.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Material(
//                             color: Colors.white70,
//                             borderRadius: BorderRadius.circular(20),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 1.h),
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 40,
//                                         backgroundImage:
//                                             (busnessviewmodal
//                                                         ?.data
//                                                         ?.business
//                                                         ?.logo
//                                                         ?.isNotEmpty ??
//                                                     false)
//                                                 ? CachedNetworkImageProvider(
//                                                   busnessviewmodal!
//                                                       .data!
//                                                       .business!
//                                                       .logo!,
//                                                 )
//                                                 : const AssetImage(
//                                                       "assets/images/waveeLogoShort.png",
//                                                     )
//                                                     as ImageProvider,
//                                       ).paddingOnly(right: 2.5.w, top: 1.h),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               busnessviewmodal
//                                                       ?.data
//                                                       ?.business
//                                                       ?.businessName ??
//                                                   "N/A",
//                                               style: TextStyle(
//                                                 fontSize: 18.sp,
//                                                 fontWeight: FontWeight.w900,
//                                                 fontFamily:
//                                                     AppConstants.manrope,
//                                               ),
//                                             ),
//                                             SizedBox(height: 0.5.h),
//                                             Text(
//                                               "${(busnessviewmodal?.data?.distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
//                                               style: TextStyle(
//                                                 fontSize: 15.sp,
//                                                 fontFamily:
//                                                     AppConstants.manrope,
//                                               ),
//                                             ),
//                                             SizedBox(height: 0.5.h),
//                                             busnessviewmodal
//                                                             ?.data
//                                                             ?.business
//                                                             ?.user
//                                                             ?.address ==
//                                                         null ||
//                                                     busnessviewmodal
//                                                             ?.data
//                                                             ?.business
//                                                             ?.user
//                                                             ?.address ==
//                                                         0 ||
//                                                     busnessviewmodal
//                                                             ?.data
//                                                             ?.business
//                                                             ?.user
//                                                             ?.address ==
//                                                         ""
//                                                 ? Container()
//                                                 : Text(
//                                                   busnessviewmodal
//                                                                   ?.data
//                                                                   ?.business
//                                                                   ?.user
//                                                                   ?.address
//                                                                   ?.city !=
//                                                               null &&
//                                                           busnessviewmodal
//                                                                   ?.data
//                                                                   ?.business
//                                                                   ?.user
//                                                                   ?.address
//                                                                   ?.country !=
//                                                               null
//                                                       ? "${busnessviewmodal?.data?.business?.user?.address?.city}, ${busnessviewmodal?.data?.business?.user?.address?.country}"
//                                                       : "N/A",
//                                                   style: TextStyle(
//                                                     fontSize: 15.sp,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                   ),
//                                                 ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ).paddingOnly(left: 2.w),
//                                   Container(
//                                     margin: EdgeInsets.only(top: 1.5.h),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         for (
//                                           int i = 0;
//                                           i <
//                                               (busnessviewmodal
//                                                       ?.data
//                                                       ?.business
//                                                       ?.tags
//                                                       ?.length ??
//                                                   0);
//                                           i++
//                                         ) ...[
//                                           Container(
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: 2.w,
//                                               vertical: 0.5.h,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               border: Border.all(
//                                                 color: Colors.grey.shade200,
//                                               ),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Container(
//                                                   height: 2.5.h,
//                                                   width: 2.5.h,
//                                                   decoration:
//                                                       const BoxDecoration(
//                                                         shape: BoxShape.circle,
//                                                       ),
//                                                   child: ClipOval(
//                                                     child: Image.network(
//                                                       busnessviewmodal
//                                                               ?.data
//                                                               ?.business
//                                                               ?.tags?[i]
//                                                               .img ??
//                                                           "",
//                                                       height: 3.h,
//                                                       width: 3.h,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 1.w),
//                                                 Text(
//                                                   busnessviewmodal
//                                                           ?.data
//                                                           ?.business
//                                                           ?.tags?[i]
//                                                           .name ??
//                                                       "No Tags",
//                                                   style: TextStyle(
//                                                     color: AppColors.black,
//                                                     fontSize: 16.sp,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(width: 2.w),
//                                         ],
//                                       ],
//                                     ).paddingOnly(left: 2.w, bottom: 1.h),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ).paddingSymmetric(horizontal: 16, vertical: 1.h),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.only(left: 2.w),
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     if (busnessviewmodal?.data?.business?.id !=
//                                         null) {
//                                       await handleLikeTap();
//                                     } else {}
//                                   },
//                                   child: Container(
//                                     height: 4.5.h,
//                                     width: 27.w,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 5,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade300,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           busnessviewmodal?.data?.isLiked ==
//                                                   true
//                                               ? Icons.favorite
//                                               : Icons.favorite_outline,
//                                           color:
//                                               busnessviewmodal?.data?.isLiked ==
//                                                       true
//                                                   ? Colors.red
//                                                   : Colors.black,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {},
//                                 child: Container(
//                                   height: 4.5.h,
//                                   width: 27.w,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       Icons.location_on,
//                                       color: Colors.black,
//                                       size: 6.w,
//                                     ),
//                                     onPressed: () {
//                                       if (busnessviewmodal?.data?.business !=
//                                           null) {
//                                         AppLat =
//                                             busnessviewmodal!
//                                                 .data!
//                                                 .business!
//                                                 .latitude
//                                                 .toString();
//                                         AppLon =
//                                             busnessviewmodal
//                                                 .data!
//                                                 .business!
//                                                 .longitude
//                                                 .toString();
//                                         selectedUserId =
//                                             busnessviewmodal.data!.business!.id
//                                                 .toString();
//
//                                         Get.back();
//                                         moveToLocation();
//                                       } else {}
//                                     },
//                                     padding: EdgeInsets.zero,
//                                     constraints: const BoxConstraints(),
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {},
//                                 child: Container(
//                                   height: 4.5.h,
//                                   width: 27.w,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       CupertinoIcons.chat_bubble_text,
//                                       color: AppColors.black,
//                                       size: 5.w,
//                                     ),
//                                     onPressed: () {
//                                       Get.to(
//                                         MessageScreen(
//                                           type: "business",
//                                           chatName:
//                                               busnessviewmodal
//                                                   ?.data
//                                                   ?.business
//                                                   ?.businessName ??
//                                               "N/A",
//                                           conciergeID:
//                                               (busnessviewmodal
//                                                       ?.data
//                                                       ?.business
//                                                       ?.user
//                                                       ?.id)
//                                                   .toString(),
//                                           image:
//                                               busnessviewmodal
//                                                   ?.data
//                                                   ?.business
//                                                   ?.logo ??
//                                               "",
//                                         ),
//                                       );
//                                     },
//                                     padding: EdgeInsets.zero,
//                                     constraints: const BoxConstraints(),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ).paddingSymmetric(horizontal: 16),
//                           SizedBox(height: 1.h),
//                           if ((busnessviewmodal?.data?.posts ?? [])
//                                   .isNotEmpty ||
//                               (busnessviewmodal?.data?.events ?? [])
//                                   .isNotEmpty ||
//                               (busnessviewmodal?.data?.offerPromotions ?? [])
//                                   .isNotEmpty ||
//                               (busnessviewmodal?.data?.services ?? [])
//                                   .isNotEmpty ||
//                               (busnessviewmodal?.data?.products ?? [])
//                                   .isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   if ((busnessviewmodal?.data?.posts ?? [])
//                                       .isNotEmpty) ...[
//                                     SizedBox(height: 1.h),
//                                     buildMediaListView(
//                                       busnessviewmodal?.data?.posts ?? [],
//                                     ),
//                                   ],
//                                   if ((busnessviewmodal?.data?.events ?? [])
//                                       .isNotEmpty) ...[
//                                     SizedBox(height: 2.h),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16.0,
//                                       ),
//                                       child: Text(
//                                         "Events",
//                                         style: TextStyle(
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: AppConstants.manrope,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(height: 1.h),
//                                     buildEventListView(),
//                                   ],
//                                   if ((busnessviewmodal
//                                               ?.data
//                                               ?.offerPromotions ??
//                                           [])
//                                       .isNotEmpty) ...[
//                                     SizedBox(height: 2.h),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16.0,
//                                       ),
//                                       child: Text(
//                                         "Offers & Promotions",
//                                         style: TextStyle(
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: AppConstants.manrope,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(height: 1.h),
//                                     buildListView(
//                                       busnessviewmodal?.data?.offerPromotions
//                                               ?.map((e) => e.files ?? "")
//                                               .toList() ??
//                                           [],
//                                       busnessviewmodal?.data?.offerPromotions
//                                               ?.map((e) => e.url ?? "")
//                                               .toList() ??
//                                           [],
//                                       busnessviewmodal?.data?.offerPromotions
//                                               ?.map(
//                                                 (e) => e.title ?? "No Title",
//                                               )
//                                               .toList() ??
//                                           [],
//                                     ),
//                                   ],
//                                   if ((busnessviewmodal?.data?.services ?? [])
//                                       .isNotEmpty) ...[
//                                     SizedBox(height: 2.h),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16.0,
//                                       ),
//                                       child: Text(
//                                         "Services",
//                                         style: TextStyle(
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: AppConstants.manrope,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(height: 1.h),
//                                     buildServiceListView(
//                                       busnessviewmodal?.data?.services ?? [],
//                                     ),
//                                   ],
//                                 ],
//                               ).paddingSymmetric(horizontal: 0),
//                             ),
//                           SizedBox(height: 3.h),
//                           Container(
//                             width: 110.w,
//                             padding: EdgeInsets.symmetric(vertical: 2.h),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.grey.shade300,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 buildListTile(
//                                   icon: Icons.location_on,
//                                   title: "Address",
//                                   subtitle:
//                                       "${(busnessviewmodal?.data?.business?.user?.address?.address ?? "").toString()}${(busnessviewmodal?.data?.business?.user?.address?.city ?? "No Address").toString()}${(busnessviewmodal?.data?.business?.user?.address?.country ?? "").toString()}",
//                                 ),
//                                 Divider(color: Colors.grey.shade300),
//                                 buildListTile(
//                                   icon: Icons.phone,
//                                   title: "Phone",
//                                   subtitle:
//                                       busnessviewmodal
//                                                       ?.data
//                                                       ?.business
//                                                       ?.user
//                                                       ?.mobileNo ==
//                                                   null ||
//                                               busnessviewmodal
//                                                       ?.data
//                                                       ?.business
//                                                       ?.user
//                                                       ?.mobileNo ==
//                                                   ""
//                                           ? "N/A"
//                                           : (busnessviewmodal
//                                                   ?.data
//                                                   ?.business
//                                                   ?.user
//                                                   ?.mobileNo)
//                                               .toString(),
//                                 ),
//                               ],
//                             ),
//                           ).paddingSymmetric(horizontal: 16),
//                           SizedBox(height: 2.h),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                             ),
//                             child: Text(
//                               "You May Also Like",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                                 fontFamily: AppConstants.manrope,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 1.h),
//                           Column(
//                             children: [
//                               for (
//                                 int i = 0;
//                                 i <
//                                         (busnessviewmodal
//                                                 ?.data
//                                                 ?.nearbyBusinesses
//                                                 ?.length ??
//                                             0) &&
//                                     i < 5;
//                                 i++
//                               ) ...[
//                                 InkWell(
//                                   onTap: () async {
//                                     final businessId =
//                                         busnessviewmodal
//                                             ?.data
//                                             ?.nearbyBusinesses?[i]
//                                             .id
//                                             ?.toString();
//                                     if (businessId != null) {
//                                       await BussinessViewProfile(businessId);
//                                     }
//                                   },
//                                   child: Container(
//                                     width: 110.w,
//                                     margin: const EdgeInsets.symmetric(
//                                       vertical: 4,
//                                       horizontal: 16,
//                                     ),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 2,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             BussinessViewProfile(
//                                               (busnessviewmodal
//                                                       ?.data
//                                                       ?.nearbyBusinesses?[i]
//                                                       .id)
//                                                   .toString(),
//                                             );
//                                           },
//                                           child: CircleAvatar(
//                                             radius: 20,
//                                             backgroundImage: NetworkImage(
//                                               busnessviewmodal
//                                                       ?.data
//                                                       ?.nearbyBusinesses?[i]
//                                                       .logo ??
//                                                   "https://randomuser.me/api/portraits/men/1.jpg",
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 busnessviewmodal
//                                                             ?.data
//                                                             ?.nearbyBusinesses?[i]
//                                                             .businessName
//                                                             ?.isNotEmpty ==
//                                                         true
//                                                     ? busnessviewmodal!
//                                                         .data!
//                                                         .nearbyBusinesses![i]
//                                                         .businessName!
//                                                     : "N/A",
//                                                 style: const TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontFamily:
//                                                       AppConstants.manrope,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Container(
//                                                 width: double.infinity,
//                                                 padding: EdgeInsets.symmetric(
//                                                   horizontal: 2.w,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                                 child: ReadMoreText(
//                                                   busnessviewmodal
//                                                               ?.data
//                                                               ?.nearbyBusinesses?[i]
//                                                               .description
//                                                               ?.isNotEmpty ==
//                                                           true
//                                                       ? busnessviewmodal!
//                                                           .data!
//                                                           .nearbyBusinesses![i]
//                                                           .description!
//                                                       : "N/A",
//                                                   trimLines: 3,
//                                                   colorClickableText:
//                                                       Colors.blue,
//                                                   trimMode: TrimMode.Line,
//                                                   trimCollapsedText:
//                                                       ' Show more',
//                                                   trimExpandedText:
//                                                       ' Show less',
//                                                   moreStyle: TextStyle(
//                                                     fontSize: 15.sp,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                     letterSpacing: 1,
//                                                     color: AppColors.maincolor,
//                                                   ),
//                                                   lessStyle: TextStyle(
//                                                     fontSize: 15.sp,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                     fontWeight: FontWeight.bold,
//                                                     letterSpacing: 1,
//                                                     color: AppColors.maincolor,
//                                                   ),
//                                                   style: TextStyle(
//                                                     fontSize: 16.sp,
//                                                     color: Colors.grey.shade500,
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               RichText(
//                                                 text: TextSpan(
//                                                   children: [
//                                                     const TextSpan(
//                                                       text: "Distance :- ",
//                                                       style: TextStyle(
//                                                         color: Colors.black,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 14,
//                                                         fontFamily:
//                                                             AppConstants
//                                                                 .manrope,
//                                                       ),
//                                                     ),
//                                                     TextSpan(
//                                                       text:
//                                                           (busnessviewmodal
//                                                                       ?.data
//                                                                       ?.nearbyBusinesses?[i]
//                                                                       .distance !=
//                                                                   null)
//                                                               ? "${busnessviewmodal!.data!.nearbyBusinesses![i].distance!.toStringAsFixed(2)} mi"
//                                                               : "N/A",
//                                                       style: TextStyle(
//                                                         color: Colors.green,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 14.sp,
//                                                         fontFamily:
//                                                             AppConstants
//                                                                 .manrope,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (isSending)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   child: Center(child: Loader()),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> BussinessViewProfile(String id) async {
//     setState(() => isSending = true);
//
//     bool internet = await checkInternet();
//     if (!internet) {
//       setState(() => isSending = false);
//       buildErrorDialog(context, 'Error', "Internet Required");
//       return;
//     }
//
//     final response = await CommunityProvider().businessProfileViewApi(
//       id,
//       AppLat,
//       AppLon,
//     );
//
//     if (response.statusCode == 200) {
//       final newModal = BusnessViewModal.fromJson(response.data);
//
//       setState(() {
//         isSending = false;
//         widget.busnessviewmodal?.data = newModal.data;
//       });
//     } else {
//       setState(() => isSending = false);
//       buildErrorDialog(context, 'Error', "Something went wrong");
//     }
//   }
//
//   handleLikeTap() {
//     bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
//     String newLikeStatus = isCurrentlyLiked ? "0" : "1";
//     final Map<String, String> data = {
//       'user_id': (loginModel?.data?.user?.id).toString(),
//       'business_id': (busnessviewmodal?.data?.business?.id).toString(),
//       'is_like': newLikeStatus,
//     };
//
//     setState(() {
//       isSending = true;
//     });
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CommunityProvider()
//             .businessLikeApi(data)
//             .then((response) async {
//               if (response.statusCode == 200) {
//                 bussinesslikemodel = BussinessLikeModel.fromJson(response.data);
//
//                 setState(() {
//                   isSending = true;
//                 });
//
//                 final String businessId =
//                     (busnessviewmodal?.data?.business?.id).toString();
//                 Get.back();
//                 await Future.delayed(const Duration(milliseconds: 100));
//                 BussinessViewProfile(businessId);
//               } else if (response.statusCode == 429) {
//                 setState(() {
//                   isSending = true;
//                 });
//               } else {
//                 EasyLoading.showError("Internal Server Error");
//               }
//             })
//             .catchError((error, stackTrace) {});
//       } else {
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   OfferPromoAsViewedApi() {
//     final Map<String, String> data = {
//       'user_id': (loginModel?.data?.user?.id).toString(),
//       'offerPromotion_id':
//           (busnessviewmodal?.data?.offerPromotions?[0].id).toString(),
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CommunityProvider().markOfferPromoApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             offerpromoAsviewedmodel = OfferPromoAsViewedModel.fromJson(
//               response.data,
//             );
//           } else if (response.statusCode == 429) {
//           } else {}
//         });
//       } else {
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   Widget buildListTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(icon, size: 25, color: Colors.black54),
//           SizedBox(width: 4.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 SizedBox(height: 0.5.h),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: Colors.black87,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
//         ],
//       ),
//     );
//   }
//
//   Widget buildMediaListView(List<Posts> mediaItems) {
//     return SizedBox(
//       height: 35.h,
//       child: InViewNotifierList(
//         scrollDirection: Axis.horizontal,
//         isInViewPortCondition: (deltaTop, deltaBottom, viewPortDimension) {
//           return deltaTop < (0.5 * viewPortDimension) &&
//               deltaBottom > (0.5 * viewPortDimension);
//         },
//         itemCount: mediaItems.length,
//         builder: (context, index) {
//           final item = mediaItems[index];
//           return InViewNotifierWidget(
//             id: '$index',
//             builder: (context, isInView, _) {
//               return Container(
//                 width: 44.w,
//                 height: 30.h,
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade300, width: 1.5),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child:
//                       item.type == 'video'
//                           ? VideoWidget(
//                             videoUrl: item.file ?? '',
//                             play: isInView,
//                             postId: item.id ?? 0,
//                           )
//                           : GestureDetector(
//                             onTap: () {
//                               // Get.to(
//                               //   () => FullScreenImageView(
//                               //     imageUrl: item.file ?? '',
//                               //     postId: item.id ?? 0,
//                               //   ),
//                               // );
//                             },
//                             child:
//                                 item.file == null || item.file!.isEmpty
//                                     ? const Center(
//                                       child: CircularProgressIndicator(),
//                                     )
//                                     : CachedNetworkImage(
//                                       imageUrl: item.file!,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                       placeholder:
//                                           (context, url) => const Center(
//                                             child: CircularProgressIndicator(),
//                                           ),
//                                       errorWidget:
//                                           (context, url, error) => const Icon(
//                                             Icons.broken_image,
//                                             size: 40,
//                                             color: Colors.grey,
//                                           ),
//                                     ),
//                           ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget buildEventListView() {
//     if (busnessviewmodal?.data?.events == null ||
//         busnessviewmodal!.data!.events!.isEmpty) {
//       return const Center();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
//           String eventId =
//               busnessviewmodal?.data?.events?[index].id?.toString() ?? "";
//
//           bool isRequestSent = sentEventIds.contains(eventId);
//           bool isLoading = false;
//
//           return StatefulBuilder(
//             builder: (context, setState) {
//               void showRequestDialog() {
//                 if (busnessviewmodal?.data?.events?[index].requestEvent
//                         ?.toLowerCase() ==
//                     "pending") {
//                   return;
//                 }
//
//                 requestController.clear();
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return StatefulBuilder(
//                       builder: (context, setDialogState) {
//                         return Dialog(
//                           backgroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Form(
//                               key: _formKey,
//                               autovalidateMode:
//                                   AutovalidateMode.onUserInteraction,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       Align(
//                                         alignment: Alignment.center,
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             vertical: 10,
//                                           ),
//                                           child: Text(
//                                             "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} "
//                                             "${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 18.sp,
//                                               fontFamily: AppConstants.manrope,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                       const Align(
//                                         alignment: Alignment.topRight,
//                                         child: CloseButton(),
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     busnessviewmodal
//                                             ?.data
//                                             ?.events?[index]
//                                             .title ??
//                                         "N/A",
//                                     style: const TextStyle(
//                                       fontFamily: AppConstants.manrope,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black38,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     busnessviewmodal
//                                                 ?.data
//                                                 ?.events?[index]
//                                                 .eventDate !=
//                                             null
//                                         ? DateFormat.jm().format(
//                                           DateTime.parse(
//                                             busnessviewmodal!
//                                                 .data!
//                                                 .events![index]
//                                                 .eventDate!,
//                                           ),
//                                         )
//                                         : "N/A",
//                                     style: const TextStyle(
//                                       fontFamily: AppConstants.manrope,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black38,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   TextFormField(
//                                     controller: requestController,
//                                     maxLines: 3,
//                                     decoration: InputDecoration(
//                                       hintText: "Enter your request...",
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: Colors.black26,
//                                         ),
//                                       ),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: Colors.black26,
//                                         ),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: Colors.blue,
//                                         ),
//                                       ),
//                                       errorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                       focusedErrorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                       fillColor: Colors.white,
//                                       filled: true,
//                                     ),
//                                     style: const TextStyle(color: Colors.black),
//                                     validator: (value) {
//                                       if (value == null ||
//                                           value.trim().isEmpty) {
//                                         return "Please enter your request";
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   const SizedBox(height: 20),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       batan(
//                                         title: "Send Request",
//                                         route: () async {
//                                           if (_formKey.currentState!
//                                               .validate()) {
//                                             setDialogState(() {
//                                               isLoading = true;
//                                             });
//                                             setState(() {
//                                               busnessviewmodal!
//                                                   .data!
//                                                   .events![index]
//                                                   .requestEvent = "pending";
//                                             });
//                                             await sendlistap(eventId);
//                                             setDialogState(() {
//                                               isLoading = false;
//                                             });
//                                             Get.back();
//                                           }
//                                         },
//                                         radius: 4.0.w,
//                                         color: AppColors.maincolor,
//                                         fontcolor: AppColors.white,
//                                         height: 5.h,
//                                         width: 72.w,
//                                         fontsize: 17.sp,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               }
//
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 3.0,
//                   vertical: 4.0,
//                 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ListTile(
//                     onTap: () {
//                       showRequestDialog();
//                     },
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     leading: Container(
//                       width: 15.w,
//                       height: 7.h,
//                       decoration: const BoxDecoration(shape: BoxShape.circle),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(30),
//                         child:
//                             busnessviewmodal?.data?.events?[index].attachment !=
//                                     null
//                                 ? CachedNetworkImage(
//                                   imageUrl:
//                                       busnessviewmodal!
//                                           .data!
//                                           .events![index]
//                                           .attachment!,
//                                   placeholder:
//                                       (context, url) => const Center(
//                                         child: CircularProgressIndicator(),
//                                       ),
//                                   errorWidget:
//                                       (context, url, error) => Image.asset(
//                                         "assets/images/waveeLogoShort.png",
//                                         fit: BoxFit.cover,
//                                         width: double.infinity,
//                                         height: double.infinity,
//                                       ),
//                                   fit: BoxFit.cover,
//                                 )
//                                 : Image.asset(
//                                   "assets/images/waveeLogoShort.png",
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                 ),
//                       ),
//                     ),
//                     title: Text(
//                       busnessviewmodal?.data?.events?[index].title ??
//                           "No Title",
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: AppConstants.manrope,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               color: Colors.red,
//                               size: 16.sp,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 busnessviewmodal
//                                         ?.data
//                                         ?.events?[index]
//                                         .location ??
//                                     'No Location',
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   color: Colors.grey[600],
//                                   fontFamily: AppConstants.manrope,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               color: Colors.blue,
//                               size: 16.sp,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 (String? eventDate) {
//                                   if (eventDate == null || eventDate.isEmpty) {
//                                     return "N/A";
//                                   }
//                                   DateTime parsedDate = DateTime.parse(
//                                     eventDate,
//                                   );
//                                   return DateFormat(
//                                     'yyyy-MM-dd hh:mm a',
//                                   ).format(parsedDate);
//                                 }(
//                                   busnessviewmodal
//                                           ?.data
//                                           ?.events?[index]
//                                           .eventDate ??
//                                       "",
//                                 ),
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey[700],
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     trailing:
//                         isLoading
//                             ? const CircularProgressIndicator(
//                               color: Colors.blue,
//                             )
//                             : InkWell(
//                               onTap: () {
//                                 showRequestDialog();
//                               },
//                               child:
//                                   busnessviewmodal
//                                               ?.data
//                                               ?.events?[index]
//                                               .requestEvent
//                                               ?.toLowerCase() ==
//                                           "pending"
//                                       ? const Text(
//                                         "Requested",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.orange,
//                                         ),
//                                       )
//                                       : const Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 16,
//                                         color: Colors.black54,
//                                       ),
//                             ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//       ],
//     );
//   }
//
//   sendlistap(selectedid) {
//     final Map<String, String> data = {};
//     data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
//     data['event_id'] = selectedid ?? "";
//
//     setState(() {
//       isLoading = true;
//     });
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         EventProvider()
//             .sendeventapi(data)
//             .then((response) async {
//               sendeventModel = SendeventModel.fromJson(response.data);
//
//               if (response.statusCode == 200 || sendeventModel?.data == 200) {
//               } else if (response.statusCode == 422) {
//                 load = false;
//               } else {
//                 EasyLoading.showError("Internal Server Error");
//               }
//
//               setState(() {
//                 isLoading = false;
//               });
//               return false;
//             })
//             .catchError((error) {
//               setState(() {
//                 isLoading = false;
//               });
//               EasyLoading.showError("Request Failed");
//               return false;
//             });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//         return false;
//       }
//     });
//   }
//
//   Widget buildListView(
//     List<String?> items,
//     List<String?> links,
//     List<String?> titles,
//   ) {
//     if (busnessviewmodal?.data?.offerPromotions == null ||
//         busnessviewmodal!.data!.offerPromotions!.isEmpty) {}
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ...List.generate(items.length, (index) {
//           String? linkUrl = links[index]?.trim();
//
//           String displayUrl = '';
//           if (linkUrl != null && linkUrl.isNotEmpty) {
//             try {
//               Uri uri = Uri.parse(linkUrl);
//               displayUrl = uri.host;
//
//               if (displayUrl.length > 30) {
//                 displayUrl = '${displayUrl.substring(0, 27)}...';
//               }
//             } catch (e) {
//               displayUrl = linkUrl;
//               if (displayUrl.length > 30) {
//                 displayUrl = '${displayUrl.substring(0, 27)}...';
//               }
//             }
//           }
//
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 onTap: () async {
//                   OfferPromoAsViewedApi();
//                   if (linkUrl != null && linkUrl.isNotEmpty) {
//                     Uri uri = Uri.parse(linkUrl);
//
//                     if (await canLaunchUrl(uri)) {
//                       await launchUrl(
//                         uri,
//                         mode: LaunchMode.externalApplication,
//                       );
//                     } else {}
//                   } else {}
//                 },
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 leading: Container(
//                   width: 15.w,
//                   height: 7.h,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 3,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: CachedNetworkImage(
//                       imageUrl: items[index] ?? '',
//                       placeholder:
//                           (context, url) =>
//                               const Center(child: CircularProgressIndicator()),
//                       errorWidget:
//                           (context, url, error) => Image.network(
//                             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdQLwDqDwd2JfzifvfBTFT8I7iKFFevcedYg&s",
//                           ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   titles[index] ?? "No Title",
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 subtitle: Row(
//                   children: [
//                     Icon(Icons.link, size: 16.sp, color: Colors.blue),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         displayUrl.isNotEmpty
//                             ? displayUrl
//                             : "No link available",
//                         style: TextStyle(
//                           fontFamily: AppConstants.manrope,
//                           fontSize: 14.sp,
//                           color: Colors.blue,
//                           decoration:
//                               linkUrl != null && linkUrl.isNotEmpty
//                                   ? TextDecoration.underline
//                                   : TextDecoration.none,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget buildServiceListView(List<Services> services) {
//     if (busnessviewmodal?.data?.services == null ||
//         busnessviewmodal!.data!.services!.isEmpty) {
//       return const Center();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ...List.generate(services.length, (index) {
//           String imageUrl = services[index].images ?? '';
//
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 onTap: () {
//                   Get.to(
//                     () => ServiceDetailsPage(
//                       serviceID: services[index].id.toString() ?? "",
//                       businessID:
//                           busnessviewmodal?.data?.business?.id.toString() ?? "",
//                     ),
//                   );
//                 },
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 leading: Container(
//                   width: 15.w,
//                   height: 7.h,
//                   decoration: const BoxDecoration(shape: BoxShape.circle),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: CachedNetworkImage(
//                       imageUrl:
//                           imageUrl.isNotEmpty
//                               ? imageUrl
//                               : 'https://media.hswstatic.com/eyJidWNrZXQiOiJjb250ZW50Lmhzd3N0YXRpYy5jb20iLCJrZXkiOiJnaWZcL3BsYXlcLzBiN2Y0ZTliLWY1OWMtNDAyNC05ZjA2LWIzZGMxMjg1MGFiNy0xOTIwLTEwODAuanBnIiwiZWRpdHMiOnsicmVzaXplIjp7IndpZHRoIjo4Mjh9fX0=',
//                       fit: BoxFit.cover,
//                       placeholder:
//                           (context, url) =>
//                               const Center(child: CircularProgressIndicator()),
//                       errorWidget:
//                           (context, url, error) => Icon(
//                             Icons.home_repair_service,
//                             color: Colors.grey,
//                             size: 8.w,
//                           ),
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   services[index].title ?? "Service Name",
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(
//                           "£",
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             "Price: ${services[index].price ?? 'N/A'}",
//                             style: TextStyle(
//                               fontSize: 15.sp,
//                               color: Colors.green[700],
//                               fontFamily: AppConstants.manrope,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.event_available,
//                           color: Colors.blue,
//                           size: 16.sp,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             "Availability: ${services[index].availability ?? 'N/A'}",
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               color: Colors.blue[700],
//                               fontFamily: AppConstants.manrope,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget buildProductList(List<Products> products) {
//     if (busnessviewmodal?.data?.products == null ||
//         busnessviewmodal!.data!.products!.isEmpty) {
//       return const Center();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ...List.generate(products.length, (index) {
//           final product = products[index];
//
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 onTap: () {
//                   Get.to(
//                     () => ProductDetailPage(
//                       productID: product.id.toString() ?? "",
//                       type: "product",
//                     ),
//                   );
//                 },
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child:
//                       (product.image != null && product.image!.isNotEmpty)
//                           ? CachedNetworkImage(
//                             imageUrl: product.image!,
//                             width: 60,
//                             height: 60,
//                             fit: BoxFit.cover,
//                             placeholder:
//                                 (context, url) => Container(
//                                   width: 60,
//                                   height: 60,
//                                   color: Colors.grey[300],
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                     ),
//                                   ),
//                                 ),
//                             errorWidget:
//                                 (context, url, error) => Image.asset(
//                                   'assets/images/waveeLogoShort.png',
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                 ),
//                           )
//                           : Image.asset(
//                             'assets/images/waveeLogoShort.png',
//                             width: 60,
//                             height: 60,
//                             fit: BoxFit.cover,
//                           ),
//                 ),
//                 title: Text(
//                   product.name ?? '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         if (product.offerPrice != null)
//                           Text(
//                             "£${product.offerPrice}",
//                             style: TextStyle(
//                               fontSize: 15.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                               fontFamily: AppConstants.manrope,
//                             ),
//                           ),
//                         if (product.offerPrice != null)
//                           const SizedBox(width: 6),
//                         Text(
//                           "£${product.price}",
//                           style: TextStyle(
//                             fontSize: 15.sp,
//                             color:
//                                 product.offerPrice != null
//                                     ? Colors.grey
//                                     : Colors.black,
//                             decoration:
//                                 product.offerPrice != null
//                                     ? TextDecoration.lineThrough
//                                     : TextDecoration.none,
//                             fontFamily: AppConstants.manrope,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       product.description ?? '',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontFamily: AppConstants.manrope,
//                       ),
//                     ),
//                   ],
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }
