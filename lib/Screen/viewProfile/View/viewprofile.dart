import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Authcation/View/loginscreen.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/custom_batan.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/store_local.dart';
import '../../Authcation/Provider/authcation_provider.dart';
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
            SizedBox(height: 10),
            menuItem(
              Icons.apartment,
              "My Building",
              "Details about your building",
              context,
              MyBuilding_Screen(id: loginModel?.data?.user?.id),
            ),
            SizedBox(height: 2.h),
            batan(
              title: "Logout",
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
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 2.h),
                                Text(
                                  "Logout",
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
                                  'Are You Sure Want to Logout Your Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.grey.shade800,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                isLoading
                                    ? Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2.h,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: AppColors.maincolor,
                                      ),
                                    )
                                    : Row(
                                      children: [
                                        Expanded(
                                          child: Material(
                                            elevation: 2,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: batan(
                                              title: "Yes",
                                              width: 20.w,
                                              route: () async {
                                                await SaveDataLocal.clearUserData();
                                                Get.offAll(() => LoginScreen());
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
          Get.to(screen);
        },
      ),
    );
  }

  Future<void> pickImage() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
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

  // void EditProfile() {
  //   List<String> addressParts = fullAddressController.text.trim().split(",");
  //   String address = addressParts.isNotEmpty ? addressParts[0] : "";
  //   String city = addressParts.length > 1 ? addressParts[1].trim() : "";
  //   String country = addressParts.length > 2 ? addressParts[2].trim() : "";
  //   final Map<String, String> data = {
  //     'update_id': profileModel?.data?.id.toString() ?? '',
  //     'apartment_number': "15",
  //     "member_type": "tenant",
  //     'gender': genderController.text.trim(),
  //     'frist_name': nameController.text.trim().split(" ").first,
  //     'last_name': nameController.text.trim().split(" ").last,
  //     'contact_no': phoneController.text.trim(),
  //     'address': address,
  //     'city': city,
  //     'country': country,
  //     'zip_code': zipCodeController.text.trim(),
  //   };
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       ProfileProvider().ProfileEdit(data, selectedImage).then((
  //         response,
  //       ) async {
  //         if (response.statusCode == 200) {
  //           var profileModel = ProfileModel.fromJson(jsonDecode(response.body));
  //           if (profileModel.status == 200) {
  //             log("Profile Updated: ${response.body}");
  //             Get.snackbar(
  //               "Success",
  //               "Profile updated successfully",
  //               backgroundColor: AppColors.maincolor,
  //               colorText: Colors.white,
  //             );
  //             setState(() {
  //               isEditing = false;
  //             });
  //             Future.delayed(Duration(microseconds: 100), () {
  //               Get.offAll(HomePage(userName: ""));
  //             });
  //           } else {
  //             Get.snackbar(
  //               "Error",
  //               "Failed to update profile",
  //               backgroundColor: Colors.red,
  //               colorText: Colors.white,
  //             );
  //           }
  //         } else {
  //           Get.snackbar(
  //             "Error",
  //             "Server error, please try again",
  //             backgroundColor: Colors.red,
  //             colorText: Colors.white,
  //           );
  //         }
  //       });
  //     } else {
  //       Get.snackbar(
  //         "Error",
  //         "Internet Required",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   });
  // }

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
