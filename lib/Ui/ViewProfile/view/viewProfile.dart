import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Utils/customSnackBars.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/storeUserData.dart';
import '../../Authentication/View/loginscreen.dart';
import '../../Authentication/provider/authenticationProvider.dart';
import '../Provider/profileProvider.dart';
import '../modal/profile_model.dart';
import 'myBuildingScreen.dart';
import 'myHomeScreen.dart';
import 'myProfileScreen.dart';

class ViewProfile extends StatefulWidget {
  final int? id;

  const ViewProfile({super.key, this.id});

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
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              var profileModel = ProfileModel.fromJson(response.data);
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
      isEditing = true;
    });
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 6.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: "My Profile",
              drawerCallback: () {},
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
                          (context, url) => const Center(
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
                decoration: const BoxDecoration(
                  color: AppColors.maincolor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    "View Profile",
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
            const SizedBox(height: 10),
            menuItem(
              Icons.apartment,
              "My Building",
              "Details about your building",
              context,
              MyBuilding_Screen(id: loginModel?.data?.user?.id),
            ),
            SizedBox(height: 2.h),
            batan(
              title: "Log out",
              route: () {
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
                                  "Log out",
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
                                  'Are you sure you want to log out of your account?',
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
                                          route: () {
                                            Navigator.of(context).pop();
                                          },
                                          color: AppColors.white,
                                          fontcolor: Colors.black,
                                          height: 5.h,
                                          width: 20.w,
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
                                          width: 20.w,
                                          route: () async {
                                            await SaveDataLocal.clearUserData();
                                            Get.offAll(
                                              () => const LoginScreen(),
                                            );
                                            Logout();
                                          },
                                          color: AppColors.maincolor,
                                          fontcolor: Colors.white,
                                          height: 5.h,
                                          fontsize: 16.sp,
                                          radius: 12.0,
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
              },
              color: AppColors.maincolor,
              fontcolor: AppColors.white,
              height: 5.h,
              width: 40.w,
              fontsize: 18.sp,
              radius: 12.0,
            ),
          ],
        ),
      ).paddingOnly(right: 3.w, left: 3.w),
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
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.manropeBold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: AppConstants.manrope,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          Get.to(screen);
        },
      ),
    );
  }

  Future<void> pickImage() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        showSnackBar(
          context: context,
          title: "Permission Denied",
          message: "Please enable storage permission from settings",
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );

        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleEdit() {
    if (isEditing) {
      // EditProfile();
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  void Logout() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().logoutApi(data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
            handleDataClear();
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
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
