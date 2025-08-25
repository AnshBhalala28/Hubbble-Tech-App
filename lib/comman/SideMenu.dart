// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
// import 'package:wavee/Screen/Authcation/View/loginscreen.dart' show LoginScreen;
// import 'package:wavee/Screen/Booking/View/booking_screen.dart';
// import 'package:wavee/Screen/Booking/View/event_booking_screen.dart';
// import 'package:wavee/Screen/Booking/View/service_booking_screen.dart';
// import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
// import 'package:wavee/Screen/Favourites/View/FavouriteBusinessesPage.dart';
// import 'package:wavee/Screen/Message_board/View/messageboard.dart';
// import 'package:wavee/Screen/visitor/View/visitorscreen.dart';
// import 'package:wavee/comman/const.dart';
// import 'package:wavee/comman/custom_button.dart';
// import 'package:wavee/comman/error_dialog.dart';
// import 'package:wavee/comman/store_local.dart';
//
// import '../Screen/Authcation/Model/DeleteAccountModel.dart';
// import '../Screen/Authcation/Provider/authcation_provider.dart';
// import '../Screen/Booking/View/book_amenities.dart';
// import '../Screen/Community Screen/Community Screen/view/community_screen.dart';
// import '../Screen/Event/View/event_screen.dart';
// import '../Screen/Manintenance/View/maintenance_view.dart';
// import '../Screen/Oredrscreen/View/order_screen_view.dart';
// import '../Screen/Parcel/parcel_Screen_View/parcel_View.dart';
// import '../Screen/upcomingRequest/View/Request_Page.dart';
// import '../Screen/upcomingRequest/View/group_screen.dart';
// import '../Screen/viewProfile/Model/profile_model.dart';
// import '../Screen/viewProfile/Provider/profile_provider.dart';
// import '../Screen/viewProfile/View/viewprofile.dart';
// import 'check_inernet_connecty.dart';
// import 'colors.dart';
// import 'custom_snack_bar.dart';
// import 'expension_tile.dart';
//
// class SideMenu extends StatefulWidget {
//   const SideMenu({super.key});
//
//   @override
//   State<SideMenu> createState() => _SideMenuState();
// }
//
// class _SideMenuState extends State<SideMenu> {
//   bool isImageLoading = true;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     setState(() {
//       isImageLoading = true;
//       isLoading = true;
//     });
//     GetProfile();
//   }
//
//   final TextEditingController password = TextEditingController();
//
//   void launchPrivacyPolicyUrl() async {
//     final Uri url = Uri.parse("https://www.wavee.ai/privacy-policy");
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $url';
//     }
//   }
//
//   void launchTermsUrl() async {
//     final Uri url = Uri.parse("https://www.wavee.ai/terms-of-service");
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $url';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double widthDrawer = 80.w;
//     return Drawer(
//       elevation: 00,
//       backgroundColor: Colors.white,
//       width: widthDrawer,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//       child: Container(
//         width: widthDrawer,
//         decoration: BoxDecoration(borderRadius: BorderRadius.zero),
//         height: MediaQuery.of(context).size.height,
//         child: ListView(
//           children: [
//             SizedBox(height: 0.5.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       margin: EdgeInsets.symmetric(horizontal: 1.w),
//                       height: 23.w,
//                       width: 23.w,
//                       padding: EdgeInsets.all(1.w),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.white, width: 1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: ClipOval(
//                         child: CachedNetworkImage(
//                           fit: BoxFit.cover,
//                           imageUrl: profileModel?.data?.user?.profile ?? '',
//                           placeholder:
//                               (context, url) =>
//                                   Center(child: CircularProgressIndicator()),
//                           errorWidget:
//                               (context, url, error) => CircleAvatar(
//                                 backgroundImage: AssetImage(
//                                   "assets/images/waveeLogoShort.png",
//                                 ),
//                               ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 1.h),
//                     GestureDetector(
//                       onTap: () {},
//                       child: Text(
//                         '${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}',
//                         style: TextStyle(
//                           fontFamily: AppConstants.manrope,
//                           color: Colors.black,
//                           letterSpacing: 1,
//                           fontSize: 17.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 1.h),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 0.5.h),
//             Divider(),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//               child: Column(
//                 children: [
//                   CustomExpansionTile(
//                     title: 'My Home',
//                     leadingIcon: CupertinoIcons.home,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.to(ParcelScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.pages_sharp,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Parcel',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(VisitorScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.group,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Visitors',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(MaintenanceScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.toolbox,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Maintenance',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(Messageboard(selected: 4));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   CupertinoIcons.conversation_bubble,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Message Board',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(RequestPage());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.person_add,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Friends',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(GroupRequestScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.group,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Groups',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(BookAmenities_Screen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.hotTubPerson,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Amenities',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(BookingScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.apartment,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Amenities Booking',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   CustomExpansionTile(
//                     title: "Live Chat",
//                     leadingIcon: CupertinoIcons.chat_bubble_2_fill,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.to(ChatScreen(selected: 2, selectedIndex: 0));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.conciergeBell,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Concierge',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(ChatScreen(selected: 2, selectedIndex: 1));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.building,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Businesses',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           // Get.to(() => const ChatBotScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.lightbulb_outline,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Wave Ai Concierge',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   CustomExpansionTile(
//                     title: "Community",
//                     leadingIcon: CupertinoIcons.person_3_fill,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(CommunityScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 SizedBox(
//                                   width: 50.w,
//                                   child: Text(
//                                     'Wave Services',
//                                     style: TextStyle(
//                                       fontFamily: AppConstants.manrope,
//                                       color: Colors.black,
//                                       letterSpacing: 1,
//                                       fontSize: 17.sp,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(FavouriteBusinessesPage());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.favorite,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Favourites',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(EventScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.event,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Events',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(ServiceBookingScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.design_services_rounded,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Services Booking',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                           Get.to(EventbookingScreen());
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.event,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Events Booking',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   CustomExpansionTile(
//                     title: "Shopping",
//                     leadingIcon: Icons.shopping_bag,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.to(
//                             AddToCartView(selected: 4, fromBottomBar: true),
//                           );
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.bagShopping,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'My Cart',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           Get.to(Order_Screen(selected: 5));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.toolbox,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'My Order',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   CustomExpansionTile(
//                     title: "Settings",
//                     leadingIcon: Icons.settings,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Get.to(viewProfile(id: loginModel?.data?.user?.id));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.person,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'My Profile',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           launchPrivacyPolicyUrl();
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.toolbox,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Privacy Policy',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           launchTermsUrl();
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   FontAwesomeIcons.toolbox,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Terms & Conditions',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {
//                           showDialog(
//                             barrierDismissible: false,
//                             context: context,
//                             builder: (BuildContext context) {
//                               bool isLoading = false;
//
//                               return StatefulBuilder(
//                                 builder: (context, setState) {
//                                   return Dialog(
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     backgroundColor: Colors.transparent,
//                                     child: Container(
//                                       width: 73.w,
//                                       padding: EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.white,
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           SizedBox(height: 2.h),
//                                           Text(
//                                             "Delete Account",
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               fontSize: 18.sp,
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.black,
//                                               fontFamily: AppConstants.manrope,
//                                             ),
//                                           ),
//                                           SizedBox(height: 1.5.h),
//                                           Text(
//                                             "Are you sure you want to delete your account?\nThis action cannot be undone.",
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               fontSize: 15.sp,
//                                               color: Colors.grey.shade800,
//                                               fontFamily: AppConstants.manrope,
//                                             ),
//                                           ),
//                                           SizedBox(height: 2.h),
//                                           isLoading
//                                               ? Padding(
//                                                 padding: EdgeInsets.symmetric(
//                                                   vertical: 2.h,
//                                                 ),
//                                                 child:
//                                                     CircularProgressIndicator(
//                                                       color:
//                                                           AppColors.maincolor,
//                                                     ),
//                                               )
//                                               : Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Material(
//                                                       elevation: 2,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             12,
//                                                           ),
//                                                       child: batan(
//                                                         title: "No",
//                                                         route: () {
//                                                           Navigator.of(
//                                                             context,
//                                                           ).pop();
//                                                         },
//                                                         color: AppColors.white,
//                                                         fontcolor: Colors.black,
//                                                         height: 5.h,
//                                                         fontsize: 16.sp,
//                                                         radius: 12.0,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: 2.w),
//                                                   Expanded(
//                                                     child: Material(
//                                                       elevation: 2,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             12,
//                                                           ),
//                                                       child: batan(
//                                                         title: "Yes",
//                                                         route: () async {
//                                                           setState(() {
//                                                             isLoading = true;
//                                                           });
//
//                                                           await DeleteAccount1();
//
//                                                           if (Navigator.canPop(
//                                                             context,
//                                                           )) {
//                                                             Navigator.of(
//                                                               context,
//                                                             ).pop();
//                                                           }
//
//                                                           setState(() {
//                                                             isLoading = false;
//                                                           });
//                                                         },
//                                                         color:
//                                                             AppColors.maincolor,
//                                                         fontcolor: Colors.white,
//                                                         height: 5.h,
//                                                         fontsize: 16.sp,
//                                                         radius: 12.0,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                           SizedBox(height: 1.h),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   CupertinoIcons.delete,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Delete Account',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 1.5.h),
//                       InkWell(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.pages_sharp,
//                                   color: Colors.black,
//                                   size: 20.sp,
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(
//                                   'Core Capabilities',
//                                   style: TextStyle(
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                     letterSpacing: 1,
//                                     fontSize: 17.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               CupertinoIcons.right_chevron,
//                               color: Colors.black,
//                               size: 20.sp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 1.5.h),
//                   Container(
//                     width: double.infinity,
//                     height: 5.h,
//                     child: TextButton(
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (BuildContext context) {
//                             bool isLoading = false;
//
//                             return StatefulBuilder(
//                               builder: (context, setState) {
//                                 return Dialog(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   backgroundColor: Colors.transparent,
//                                   child: Container(
//                                     width: 73.w,
//                                     padding: EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: AppColors.white,
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         SizedBox(height: 2.h),
//                                         Text(
//                                           "Logout",
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 18.sp,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.black,
//                                             fontFamily: AppConstants.manrope,
//                                           ),
//                                         ),
//                                         SizedBox(height: 1.5.h),
//                                         Text(
//                                           'Are You Sure Want to Logout Your Account',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 15.sp,
//                                             color: Colors.grey.shade800,
//                                             fontFamily: AppConstants.manrope,
//                                           ),
//                                         ),
//                                         SizedBox(height: 2.h),
//                                         isLoading
//                                             ? Padding(
//                                               padding: EdgeInsets.symmetric(
//                                                 vertical: 2.h,
//                                               ),
//                                               child: CircularProgressIndicator(
//                                                 color: AppColors.maincolor,
//                                               ),
//                                             )
//                                             : Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Material(
//                                                     elevation: 2,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           12,
//                                                         ),
//                                                     child: batan(
//                                                       title: "No",
//                                                       route: () {
//                                                         Navigator.of(
//                                                           context,
//                                                         ).pop();
//                                                       },
//                                                       color: AppColors.white,
//                                                       fontcolor: Colors.black,
//                                                       height: 5.h,
//                                                       fontsize: 16.sp,
//                                                       radius: 12.0,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 2.w),
//                                                 Expanded(
//                                                   child: Material(
//                                                     elevation: 2,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           12,
//                                                         ),
//                                                     child: batan(
//                                                       title: "Yes",
//                                                       route: () async {
//                                                         await SaveDataLocal.clearUserData();
//                                                         Get.offAll(
//                                                           () => LoginScreen(),
//                                                         );
//                                                       },
//                                                       color:
//                                                           AppColors.maincolor,
//                                                       fontcolor: Colors.white,
//                                                       height: 5.h,
//                                                       fontsize: 16.sp,
//                                                       radius: 12.0,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                         SizedBox(height: 1.h),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         backgroundColor: AppColors.maincolor,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: Text(
//                         "Log out",
//                         style: TextStyle(
//                           fontFamily: AppConstants.manrope,
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   DeleteAccount1() {
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await AuthProvider().deleteAccApi(
//             loginModel?.data?.user?.id.toString() ?? "",
//           );
//
//           deleteAccountModel = DeleteAccountModel.fromJson(response.data);
//           if (response.statusCode == 200) {
//             showSnackBar(
//               title: "Delete",
//               message: "Delete Account successfully.",
//               backgoundColor: AppColors.white,
//               ColorText: AppColors.maincolor,
//               IconColor: AppColors.white,
//               IconName: Icons.check_circle,
//             );
//
//             SaveDataLocal.clearUserData();
//             setState(() {
//               isLoading = false;
//             });
//             await Get.offAll(() => LoginScreen());
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//             showSnackBar(
//               title: "Error",
//               message: "${deleteAccountModel?.message}",
//               backgoundColor: Colors.red.shade400,
//               ColorText: Colors.white,
//               IconColor: Colors.white,
//             );
//           }
//         } catch (e, stackTrace) {
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//             });
//           }
//
//           showSnackBar(
//             title: "Error",
//             message: "${e}",
//             backgoundColor: Colors.red.shade400,
//             ColorText: Colors.white,
//             IconColor: Colors.white,
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   GetProfile() {
//     final Map<String, String> data = {
//       'id': loginModel?.data?.user?.id.toString() ?? '',
//     };
//     checkInternet().then((internet) async {
//       if (internet) {
//         ProfileProvider().profileApi(data).then((response) async {
//           profileModel = ProfileModel.fromJson(response.data);
//           if (response.statusCode == 200 && profileModel?.status == 200) {
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
// }
