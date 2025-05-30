import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/open_ai_chatbot/view/open_ai_screen.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../Community Screen/Community Screen/Model/BusnessViewModal.dart';
import '../../Community Screen/Community Screen/Model/GetLikeModal.dart';
import '../../Community Screen/Community Screen/Provider/community_provider.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import 'BusinessDetailScreen.dart';

class FavouriteBusinessesPage extends StatefulWidget {
  const FavouriteBusinessesPage({Key? key}) : super(key: key);

  @override
  State<FavouriteBusinessesPage> createState() =>
      _FavouriteBusinessesPageState();
}

class _FavouriteBusinessesPageState extends State<FavouriteBusinessesPage> {
  String AppLat = '';
  String AppLon = '';
  bool isLoading = false;
  bool _isBottomSheetOpen = false;
  bool isSending = false;
  String selectedUserId = '';
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getlikeapi();
  }

  void moveToLocation() {
    if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
      double latitude = double.tryParse(AppLat) ?? 0.0;
      double longitude = double.tryParse(AppLon) ?? 0.0;

      if (latitude != 0.0 && longitude != 0.0) {
        // પહેલા કેમેરા એનિમેશન કરો
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(latitude, longitude),
            20.0, // Large zoom for close-up effect
          ),
        );
        print("Moved to Location: Lat: $latitude, Lon: $longitude");

        // ખાસ કરીને પસંદ કરેલા યુઝરને દેખાડવા માટે માર્કર લોડ કરો
        //_loadSelectedUserMarker();
      } else {
        print("Invalid stored location.");
      }
    } else {
      print("AppLat or AppLon is empty.");
    }
  }

  // Future<void> _loadSelectedUserMarker() async {
  //   if (businessprofileModel?.data == null ||
  //       businessprofileModel!.data!.isEmpty ||
  //       selectedUserId == null ||
  //       selectedUserId!.isEmpty) {
  //     setState(() => isMapLoading = false);
  //     return;
  //   }
  //
  //   // પસંદ કરેલા યુઝરને શોધો
  //   Data1? selectedUser;
  //   for (var data in businessprofileModel!.data!) {
  //     if (data.id.toString() == selectedUserId) {
  //       selectedUser = data;
  //       break;
  //     }
  //   }
  //
  //   if (selectedUser == null ||
  //       selectedUser.latitude == null ||
  //       selectedUser.longitude == null) {
  //     // જો પસંદ કરેલો યુઝર ન મળે તો સામાન્ય _loadMarkers કૉલ કરો
  //     _loadMarkers();
  //     return;
  //   }
  //
  //   // સિલેક્ટેડ યુઝરનો માર્કર બનાવો
  //   double lat = double.parse(selectedUser.latitude!);
  //   double lon = double.parse(selectedUser.longitude!);
  //   String profileImage = selectedUser.profile?.isNotEmpty == true
  //       ? selectedUser.profile!
  //       : "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg";
  //
  //   // કસ્ટમ માર્કર આઇકોન મેળવો - મોટા સાઇઝ સાથે દર્શાવો
  //   BitmapDescriptor icon = await getCustomMarker(profileImage, size: 120);
  //
  //   // માર્કર સેટ અપડેટ કરો - ફક્ત સિલેક્ટેડ યુઝરનો માર્કર બતાવો
  //   setState(() {
  //     _markers = {
  //       Marker(
  //         markerId: MarkerId("selected_$selectedUserId"),
  //         position: LatLng(lat, lon),
  //         icon: icon,
  //         onTap: () {
  //           // સિલેક્ટેડ યુઝર પર ટેપ કરવા પર બોટમ શીટ ખોલો
  //           _showUserProfile(selectedUser);
  //         },
  //       )
  //     };
  //     isMapLoading = false;
  //   });
  // }

  getlikeapi() {
    // EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().GetLikeApi(
            (loginModel?.data?.user?.id).toString(),
            AppLat,
            AppLon,
          );
          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
              getlikeModal = GetLikeModal.fromJson(json.decode(response.body));
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          // EasyLoading.dismiss();
        }
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  unlikeBusiness(int index) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (getlikeModal?.data?[index].businessId).toString(),
      'is_like': "0", // 0 for unlike
    };

    // EasyLoading.show(status: "Removing...");

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .IsLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                print("Unlike successful: ${response.body}");

                // Then remove from UI list
                setState(() {
                  getlikeModal?.data?.removeAt(index);
                });
                // EasyLoading.dismiss();
                // EasyLoading.showSuccess("Removed from favorites!");
                setState(() {
                  isLoading = false;
                });
                getlikeapi();
              } else {
                // EasyLoading.dismiss();
                // EasyLoading.showError("Failed to remove. Try again.");
                setState(() {
                  isLoading = false;
                });
              }
            })
            .catchError((error) {
              EasyLoading.dismiss();
              EasyLoading.showError("Something went wrong");
              print("Error in unlike API: $error");
            });
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  BussinessViewProfile(String id) {
    // EasyLoading.show();
    setState(() {
      isSending = true; // Show Loader
    });
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .projectlistapi(
              (loginModel?.data?.user?.id).toString(),
              id,
              AppLat,
              AppLon,
            )
            .then((response) async {
              busnessviewmodal = BusnessViewModal.fromJson(
                json.decode(response.body),
              );
              if (response.statusCode == 200) {
                print("done LIst");
                //log("data ave che che ${response.body}");
                // EasyLoading.dismiss();
                setState(() {
                  isSending = false; // Show Loader
                });
                Get.to(
                  () =>
                      BusinessDetailScreen(busnessviewmodal: busnessviewmodal),
                );
              } else if (response.statusCode == 422) {
                setState(() {
                  isSending = false; // Show Loader
                });
              } else {
                setState(() {
                  isSending = false; // Show Loader
                });
              }
            });
      } else {
        setState(() {});
        //  EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
        GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      drawer: const SideMenu(),
      key: _scaffoldKeyParcel,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                TitleBar(
                  back: () {
                    Get.to(HomeNewPage(selected: 1, userName: ''));
                  },
                  title: 'Favourites',
                  drawerCallback: () {
                    _scaffoldKeyParcel.currentState?.openDrawer();
                  },
                ),
                SizedBox(height: 3.h),
                Expanded(
                  child:
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.maincolor,
                            ),
                          )
                          : (getlikeModal?.data == null ||
                              getlikeModal!.data!.isEmpty)
                          ? Center(
                            child: Text(
                              "No Favourites Added!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            itemCount: getlikeModal?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  print("id tap");
                                  print(
                                    "Liked Business ID: ${getlikeModal?.data?[index].businessId}",
                                  );

                                  BussinessViewProfile(
                                    (getlikeModal?.data?[index].businessId)
                                        .toString(),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: CachedNetworkImageProvider(
                                          (getlikeModal
                                                      ?.data?[index]
                                                      .business
                                                      ?.logo
                                                      ?.isEmpty ==
                                                  true)
                                              ? "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600"
                                              : getlikeModal
                                                      ?.data?[index]
                                                      .business
                                                      ?.logo ??
                                                  "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600",
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getlikeModal
                                                      ?.data?[index]
                                                      .business
                                                      ?.businessName ??
                                                  "N/A",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              getlikeModal
                                                      ?.data?[index]
                                                      .business
                                                      ?.subStatus ??
                                                  "Unknown",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => unlikeBusiness(index),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),

          ///  Positioned Loader overlay
          if (isSending)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(child: Loader()),
              ),
            ),
        ],
      ),
      floatingActionButton:
          isLoading
              ? Container()
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
}
