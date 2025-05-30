import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/colors.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/const.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import '../Model/profile_model.dart';
import '../Provider/profile_provider.dart';
import 'Mybuilding_Screen.dart';
import 'my_profile_screen.dart';
import 'myhome_screen.dart';

class ViewProfile extends StatefulWidget {
  final int? id;

  ViewProfile({super.key, this.id});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  final GlobalKey<ScaffoldState> profileScreen = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isEditing = false;
  String profileImage = "";
  File? selectedImage;
  bool isImageLoading = true;

  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              var profileModel = ProfileModel.fromJson(
                jsonDecode(response.body),
              );
              if (profileModel.status == 200) {
                var user = profileModel.data?.user;
                if (user != null) {
                  nameController.text =
                      "${user.name?.firstName ?? ""} ${user.name?.lastName ?? ""}";
                  emailController.text = user.email ?? "";
                  phoneController.text = user.mobileNo.toString();
                  genderController.text = user.gender ?? "";

                  var address = user.address;
                  if (address != null) {
                    fullAddressController.text =
                        "${address.address ?? ""}, ${address.city ?? ""}, ${address.country ?? ""}";
                    zipCodeController.text = address.zipCode ?? "";
                  }

                  if (user.profile != null && user.profile!.isNotEmpty) {
                    profileImage = user.profile!;
                  }
                }
              }

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
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      isEditing = true; // 🔹 Always open in edit mode
    });
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideMenu(),
      key: profileScreen,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              TitleBar(
                back: () {
                  Get.back();
                },
                title: "Edit Profile",
                drawerCallback: () => profileScreen.currentState?.openDrawer(),
              ),

              SizedBox(height: 3.h),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 35.sp,
                    backgroundColor: Colors.grey.shade300,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profileImage,
                        width: 70.sp,
                        height: 70.sp,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.maincolor,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Image.asset(
                              "assets/images/waveeLogoShort.png",
                              width: 70.sp,
                              height: 70.sp,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),

                  // Camera icon
                ],
              ),

              SizedBox(height: 4.h),

              InkWell(
                onTap: () {
                  Get.to(Myprofile_Screen(id: loginModel?.data?.user?.id));
                },
                child: Container(
                  width: 55.w,
                  height: 5.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.maincolor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: AppConstants.manrope,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              SizedBox(height: 2.h),
              menuItem(
                Icons.home,
                "My Home",
                "Details about your home",
                context,
                MyHome_Screen(id: loginModel?.data?.user?.id),
              ),
              SizedBox(height: 10),
              menuItem(
                Icons.apartment,
                "My Building",
                "Details about your building",
                context,
                MyBuilding_Screen(id: loginModel?.data?.user?.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem(
    IconData icon,
    String title,
    String description,
    BuildContext context,
    Widget screen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.maincolor, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.manrope,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: AppConstants.manrope,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: () {
          // Navigate to respective screen
          Get.to(screen);
        },
      ),
    );
  }

  Future<void> pickImage() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request(); // For Android
      if (!status.isGranted) {
        Get.snackbar(
          "Permission Denied",
          "Please enable storage permission from settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() {
      isLoading = true; // Set loading to true when picking the image
    });

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        isLoading = false; // Set loading to false when image is picked
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no image is picked
      });
    }
  }

  // Future<void> pickImage() async {
  //   if (Platform.isAndroid) {
  //     var status = await Permission.storage.request(); // For Android
  //     if (!status.isGranted) {
  //       Get.snackbar("Permission Denied",
  //           "Please enable storage permission from settings",
  //           backgroundColor: Colors.red, colorText: Colors.white);
  //       return;
  //     }
  //   }
  //
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       selectedImage = File(pickedFile.path);
  //     });
  //   }
  // }

  void toggleEdit() {
    if (isEditing) {
      EditProfile();
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  void EditProfile() {
    List<String> addressParts = fullAddressController.text.trim().split(",");
    String address = addressParts.isNotEmpty ? addressParts[0] : "";
    String city = addressParts.length > 1 ? addressParts[1].trim() : "";
    String country = addressParts.length > 2 ? addressParts[2].trim() : "";
    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      'apartment_number': "15",
      "member_type": "tenant",
      'gender': genderController.text.trim(),
      'frist_name': nameController.text.trim().split(" ").first,
      'last_name': nameController.text.trim().split(" ").last,
      'contact_no': phoneController.text.trim(),
      // 'address': addressController.text.trim(),
      // 'city': cityController.text.trim(),
      // 'country': countryController.text.trim(),
      'address': address,
      'city': city,
      'country': country,
      'zip_code': zipCodeController.text.trim(),
    };
    log("data shwoewe$data");
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileEdit(data, selectedImage).then((
          response,
        ) async {
          if (response.statusCode == 200) {
            var profileModel = ProfileModel.fromJson(jsonDecode(response.body));

            if (profileModel.status == 200) {
              log("Profile Updated: ${response.body}");
              Get.snackbar(
                "Success",
                "Profile updated successfully",
                backgroundColor: AppColors.maincolor,
                colorText: Colors.white,
              );

              setState(() {
                isEditing = false;
              });
              Future.delayed(Duration(microseconds: 100), () {
                Get.offAll(HomeNewPage(userName: ""));
              });
            } else {
              Get.snackbar(
                "Error",
                "Failed to update profile",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              "Error",
              "Server error, please try again",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
      } else {
        Get.snackbar(
          "Error",
          "Internet Required",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}
