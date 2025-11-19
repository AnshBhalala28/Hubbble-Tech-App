import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/loader.dart';
import '../../HomeScreen/View/homePage.dart';
import '../Provider/profileProvider.dart';
import '../modal/profile_model.dart';

class Myprofile_Screen extends StatefulWidget {
  final int? id;

  const Myprofile_Screen({super.key, this.id});

  @override
  State<Myprofile_Screen> createState() => _Myprofile_ScreenState();
}

class _Myprofile_ScreenState extends State<Myprofile_Screen> {
  final GlobalKey<ScaffoldState> Myprofile = GlobalKey<ScaffoldState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  File? selectedImage;
  bool isLoading = true;
  bool isEditing = false;

  String profileImage = "";
  ProfileModel? profileModel;

  @override
  void initState() {
    super.initState();
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (isLoading)
             Center(child: Loader())
          else
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  TitleBar(
                    back: () => Get.back(),
                    title: "My Profile",
                    drawerCallback: () {},
                  ),
                  SizedBox(height: 3.h),

                  /// Profile Image
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 35.sp,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage(
                            'assets/images/waveeLogoShort.png',
                          ))
                          as ImageProvider,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.maincolor,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    nameController.text,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  SizedBox(height: 3.h),

                  infoCard("Full Name", nameController.text, Icons.person),
                  infoCard("Email", emailController.text, Icons.email),

                  SizedBox(height: 2.h),
                  batan(
                    title: "Update Profile Image",
                    route: () {
                      EditProfile();
                    },
                    color: AppColors.maincolor,
                    fontcolor: Colors.white,
                    height: 5.h,
                    width: double.infinity,
                    radius: 12.0,
                    fontsize: 18.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),

          if (isEditing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child:  Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  /// Reusable Info Card
  Widget infoCard(String label, String value, IconData icon) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon box
            Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.maincolor,
              ),
              child: Icon(icon, size: 18.sp, color: Colors.white),
            ),
            SizedBox(width: 3.w),

            // Label + Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    value.isNotEmpty ? value : "—",
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      fontSize: 16.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).marginOnly(bottom: 1.h);
  }

  /// Get Profile API
  void GetProfile() {
    final Map<String, String> data = {"id": widget.id.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(response.data);

          if (response.statusCode == 200) {
            var user = profileModel?.data?.user;

            nameController.text =
            "${capitalize(user?.name?.firstName)} ${capitalize(user?.name?.lastName)}";
            emailController.text = user?.email ?? "N/A";
            profileImage = user?.profile ?? "";
          }

          setState(() => isLoading = false);
        });
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  /// PICK IMAGE (NO PERMISSIONS NEEDED)
  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    } else {
      Get.snackbar(
        "No Image Selected",
        "Please choose an image.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// UPDATE PROFILE API
  void EditProfile() {
    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      "apartment_number": profileModel?.data?.unitsId.toString() ?? '',
    };

    setState(() => isEditing = true);

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileEdit(data, selectedImage).then((response) {
          if (response.statusCode == 200) {
            var result = ProfileModel.fromJson(response.data);

            if (result.status == 200) {
              Get.offAll(HomePage(userName: ""));
              Get.snackbar(
                "Success",
                "Profile image updated successfully",
                backgroundColor: AppColors.maincolor,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar("Error", "Failed to update profile",
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          } else {
            Get.snackbar("Error", "Server error, please try again",
                backgroundColor: Colors.red, colorText: Colors.white);
          }

          setState(() => isEditing = false);
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

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }
}
