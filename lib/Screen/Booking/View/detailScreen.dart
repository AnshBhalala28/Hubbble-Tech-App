// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Screen/Booking/View/service_booking_screen.dart';
//
// import '../../../comman/Custom_AppBar.dart';
// import '../../../comman/SideMenu.dart';
// import '../../../comman/colors.dart';
// import '../../../comman/const.dart';
// import '../../HomeNewPage/View/homenewpage.dart';
// import '../../open_ai_chatbot/view/open_ai_screen.dart';
// import 'booking_screen.dart';
// import 'event_booking_screen.dart';
//
// class DetailScreen extends StatefulWidget {
//   const DetailScreen({super.key});
//
//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }
//
// bool isLoading = false;
//
// class _DetailScreenState extends State<DetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<ScaffoldState> _scaffoldKeyDetail =
//         GlobalKey<ScaffoldState>();
//     return Scaffold(
//       drawer: const SideMenu(),
//       key: _scaffoldKeyDetail,
//       backgroundColor: AppColors.bgcolor,
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
//         child: Column(
//           children: [
//             SizedBox(height: 4.h),
//             TitleBar(
//               back: () {
//                 Get.to(HomeNewPage(
//                   selected: 1,
//                   userName: '',
//                 ));
//               },
//               title: 'Booking',
//               drawerCallback: () {
//                 _scaffoldKeyDetail.currentState?.openDrawer();
//               },
//             ),
//             SizedBox(height: 2.h),
//             menuItem(
//                 Icons.event,
//                 "Events",
//                 "Specify the date and time of the event. ",
//                 context,
//                 const EventbookingScreen(
//                     // id: loginModel?.data?.user?.id,
//                     )),
//             const SizedBox(height: 10),
//             menuItem(
//               Icons.apartment,
//               "Amenities",
//               "Details about your Booking",
//               context,
//               const BookingScreen(
//                   /*id: loginModel?.data?.user?.id,*/
//                   ),
//             ),
//             const SizedBox(height: 10),
//
//             menuItem(
//               Icons.design_services,
//               "Service",
//               "Details about your Booking",
//               context,
//                ServiceBookingScreen(
//                   /*id: loginModel?.data?.user?.id,*/
//                   ),
//             ),
//             const SizedBox(height: 10),
//             // menuItem(
//             //     Icons.design_services,
//             //     "Services",
//             //     "	Assistance available anytime you need it.",
//             //     context,
//             //     MyHome_Screen(
//             //       id: loginModel?.data?.user?.id,
//             //     ),
//             // ),
//           ],
//         ),
//       ),
//       floatingActionButton: isLoading
//           ? Container()
//           : FloatingActionButton.extended(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(900),
//               ),
//               backgroundColor: Colors.white,
//               onPressed: () {
//                 Get.to(const ChatBotScreen());
//               },
//               icon:
//                   const Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
//               label: Text(
//                 "Ai Concierge",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16.sp,
//                     fontFamily: AppConstants.manrope),
//               ),
//             ),
//     );
//   }
//
//   Widget menuItem(IconData icon, String title, String description,
//       BuildContext context, Widget screen) {
//     return Container(
//       alignment: Alignment.center,
//       height: 12.h,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: AppColors.maincolor, size: 30),
//         title: Text(title,
//             style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: AppConstants.manrope)),
//         subtitle: Text(
//           description,
//           style: TextStyle(
//             fontSize: 15.sp,
//             color: Colors.grey,
//             fontFamily: AppConstants.manrope,
//           ),
//         ),
//         trailing:
//             const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
//         onTap: () {
//           Get.off(screen);
//         },
//       ),
//     );
//   }
// }
