// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../comman/Custom_AppBar.dart';
// import '../../../comman/check_inernet_connecty.dart';
// import '../../../comman/colors.dart';
// import '../../../comman/const.dart';
// import '../../../comman/error_dialog.dart';
// import '../../../comman/loader.dart';
// import '../../Community Screen/Community Screen/Model/BusnessViewModal.dart';
// import '../../Community Screen/Community Screen/Model/GetLikeModal.dart';
// import '../../Community Screen/Community Screen/provider/community_provider.dart';
// import '../../homePage/view/homenewpage.dart';
// import 'BusinessDetailScreen.dart';
//
// class FavouriteBusinessesPage extends StatefulWidget {
//   const FavouriteBusinessesPage({super.key});
//
//   @override
//   State<FavouriteBusinessesPage> createState() =>
//       _FavouriteBusinessesPageState();
// }
//
// class _FavouriteBusinessesPageState extends State<FavouriteBusinessesPage> {
//   String AppLat = '';
//   String AppLon = '';
//   bool isLoading = false;
//   final bool _isBottomSheetOpen = false;
//   bool isSending = false;
//   String selectedUserId = '';
//   late GoogleMapController mapController;
//   bool isMapLoading = false;
//   bool isLocationFetched = false;
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       isLoading = true;
//     });
//     _getCurrentLocation();
//   }
//
//   void moveToLocation() {
//     if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
//       double latitude = double.tryParse(AppLat) ?? 0.0;
//       double longitude = double.tryParse(AppLon) ?? 0.0;
//
//       if (latitude != 0.0 && longitude != 0.0) {
//         mapController.animateCamera(
//           CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 20.0),
//         );
//       } else {}
//     } else {}
//   }
//
//   getlikeapi() {
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           final response = await CommunityProvider().getLikeBusinessApi(
//             (loginModel?.data?.user?.id).toString(),
//             AppLat,
//             AppLon,
//           );
//           EasyLoading.dismiss();
//           if (response.statusCode == 200) {
//             setState(() {
//               isLoading = false;
//               getlikeModal = GetLikeModal.fromJson(response.data);
//             });
//           }
//         } catch (e) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       } else {
//         EasyLoading.dismiss();
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   unlikeBusiness(int index) {
//     final Map<String, String> data = {
//       'user_id': (loginModel?.data?.user?.id).toString(),
//       'business_id': (getlikeModal?.data?[index].businessId).toString(),
//       'is_like': "0",
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CommunityProvider()
//             .businessLikeApi(data)
//             .then((response) async {
//               if (response.statusCode == 200) {
//                 setState(() {
//                   getlikeModal?.data?.removeAt(index);
//                 });
//
//                 setState(() {
//                   isLoading = false;
//                 });
//                 getlikeapi();
//               } else {
//                 setState(() {
//                   isLoading = false;
//                 });
//               }
//             })
//             .catchError((error) {
//               EasyLoading.dismiss();
//               EasyLoading.showError("Something went wrong");
//             });
//       } else {
//         EasyLoading.dismiss();
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   BussinessViewProfile(String id) {
//     setState(() {
//       isSending = true;
//     });
//     checkInternet().then((internet) async {
//       if (internet) {
//         CommunityProvider().businessProfileViewApi(id, AppLat, AppLon).then((
//           response,
//         ) async {
//           busnessviewmodal = BusnessViewModal.fromJson(response.data);
//           if (response.statusCode == 200) {
//             setState(() {
//               isSending = false;
//             });
//             Get.to(() {
//               return BusinessDetailScreen(busnessviewmodal: busnessviewmodal);
//             });
//           } else if (response.statusCode == 422) {
//             setState(() {
//               isSending = false;
//             });
//           } else {
//             setState(() {
//               isSending = false;
//             });
//           }
//         });
//       } else {
//         setState(() {});
//
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
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
//         getlikeapi();
//
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<ScaffoldState> scaffoldKeyParcel =
//         GlobalKey<ScaffoldState>();
//     return Scaffold(
//       backgroundColor: AppColors.white,
//
//       body: Stack(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 4.h),
//                 TitleBar(
//                   back: () {
//                     Get.to(HomePage(selected: 1, userName: ''));
//                   },
//                   title: 'Favourites',
//                   drawerCallback: () {},
//                 ),
//                 SizedBox(height: 3.h),
//                 Expanded(
//                   child:
//                       isLoading
//                           ? const Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.maincolor,
//                             ),
//                           )
//                           : (getlikeModal?.data == null ||
//                               getlikeModal!.data!.isEmpty)
//                           ? const Center(
//                             child: Text(
//                               "No Favourites Added!",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           )
//                           : ListView.builder(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 5,
//                             ),
//                             itemCount: getlikeModal?.data?.length ?? 0,
//                             itemBuilder: (context, index) {
//                               return InkWell(
//                                 onTap: () {
//                                   BussinessViewProfile(
//                                     (getlikeModal?.data?[index].businessId)
//                                         .toString(),
//                                   );
//                                 },
//                                 child: Container(
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     color: Colors.white,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 30,
//                                         backgroundColor: Colors.grey[200],
//                                         backgroundImage: CachedNetworkImageProvider(
//                                           (getlikeModal
//                                                       ?.data?[index]
//                                                       .business
//                                                       ?.logo
//                                                       ?.isEmpty ==
//                                                   true)
//                                               ? "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600"
//                                               : getlikeModal
//                                                       ?.data?[index]
//                                                       .business
//                                                       ?.logo ??
//                                                   "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600",
//                                         ),
//                                       ),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               getlikeModal
//                                                       ?.data?[index]
//                                                       .business
//                                                       ?.businessName ??
//                                                   "N/A",
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black87,
//                                               ),
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             const SizedBox(height: 3),
//                                             Text(
//                                               "${(getlikeModal?.data?[index].distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.black54,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       GestureDetector(
//                                         onTap: () => unlikeBusiness(index),
//                                         child: const Icon(
//                                           Icons.favorite,
//                                           color: Colors.red,
//                                           size: 28,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                 ),
//               ],
//             ),
//           ),
//           if (isSending)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 child: Center(child: Loader()),
//               ),
//             ),
//         ],
//       ),
//       // floatingActionButton: isLoading
//       //     ? Container()
//       //     : FloatingActionButton.extended(
//       //         shape: RoundedRectangleBorder(
//       //             borderRadius: BorderRadius.circular(900)),
//       //         backgroundColor: Colors.white,
//       //         onPressed: () {
//       //           Get.to(() => const ChatBotScreen());
//       //         },
//       //         icon: Icon(
//       //           CupertinoIcons.chat_bubble_2,
//       //           color: Colors.black,
//       //         ),
//       //         label: Text(
//       //           "Ai Concierge",
//       //           style: TextStyle(
//       //             color: Colors.black,
//       //             fontWeight: FontWeight.w600,
//       //             fontSize: 16.sp,
//       //             fontFamily: AppConstants.manrope,
//       //           ),
//       //         ),
//       //       ),
//     );
//   }
// }
