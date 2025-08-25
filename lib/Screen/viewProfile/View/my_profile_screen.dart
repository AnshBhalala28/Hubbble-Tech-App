import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/custom_batan.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/input_decoration.dart';
import '../../homePage/View/homenewpage.dart';
import '../Model/profile_model.dart';
import '../Provider/profile_provider.dart';

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
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  File? selectedImage;
  bool isLoading = true;
  bool isEditing = false;
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
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
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  // +
                  TitleBar(
                    back: () {
                      Get.back();
                    },
                    title: "My Profile",
                    drawerCallback: () {},
                  ),
                  SizedBox(height: 3.h),
                  GestureDetector(
                    onTap: () {
                      log('adadaadad');
                      pickImage();
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 35.sp,
                          backgroundColor: Colors.grey.shade300,
                          child: ClipOval(
                            child:
                                selectedImage != null
                                    ? Image.file(
                                      selectedImage!,
                                      width: 70.sp,
                                      height: 70.sp,
                                      fit: BoxFit.cover,
                                    )
                                    : profileImage.isNotEmpty
                                    ? Image.network(
                                      profileImage,
                                      width: 70.sp,
                                      height: 70.sp,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          Future.delayed(
                                            Duration(milliseconds: 300),
                                            () {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                          );
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.maincolor,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return Image.asset(
                                          'assets/images/waveeLogoShort.png',
                                          width: 70.sp,
                                          height: 70.sp,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                    : Image.asset(
                                      'assets/images/waveeLogoShort.png',
                                      width: 70.sp,
                                      height: 70.sp,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.maincolor,
                          ),
                          padding: EdgeInsets.all(8),
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
                    nameController.text ?? "",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  profileField("Full Name", nameController, Icons.person, false),
                  profileField("Email", emailController, Icons.email, false),
                  SizedBox(height: 2.h),
                  batan(
                    title: "Update Profile",
                    route: () {
                      EditProfile();
                    },
                    color: AppColors.maincolor,
                    fontcolor: Colors.white,
                    height: 5.h,
                    width: double.infinity,
                    radius: 30.0,
                    fontsize: 18.sp,
                  ),
                ],
              ),
            ).paddingOnly(right: 3.w, left: 3.w),
          if (isEditing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  Widget profileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditable, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: controller,
          readOnly: !isEditable,
          textCapitalization: TextCapitalization.words,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: inputDecoration(hintText: label).copyWith(
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(icon, size: 20.sp, color: AppColors.maincolor),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  String formatBirthdate(String? dob) {
    if (dob == null || dob.isEmpty) {
      return "";
    }
    try {
      DateTime parsedDate = DateTime.parse(dob);

      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return dob;
    }
  }

  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            var profileModel = ProfileModel.fromJson(response.data);
            if (profileModel.status == 200) {
              var user = profileModel.data?.user;
              if (user != null) {
                nameController.text =
                    "${capitalize(user.name?.firstName)} ${capitalize(user.name?.lastName)}";
                emailController.text =
                    user.email == null ? "N/A" : user.email.toString();
                phoneController.text =
                    user.mobileNo == null ? 'N/A' : user.mobileNo.toString();

                var address = user.address;
                if (address != null) {
                  fullAddressController.text =
                      "${address.address ?? ""}, ${address.city ?? ""}, ${address.country ?? ""}";
                  zipCodeController.text = address.zipCode ?? "";
                } else {
                  fullAddressController.text = "";
                  zipCodeController.text = "";
                }

                if (user.profile != null && user.profile!.isNotEmpty) {
                  profileImage = user.profile!;
                } else {
                  profileImage = "";
                }
              } else {
                nameController.text = "";
                emailController.text = "";
                phoneController.text = "";
                genderController.text = "";
                birthdateController.text = "";
                fullAddressController.text = "";
                zipCodeController.text = "";
                profileImage = "";
              }
            }

            setState(() {
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

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Future<void> pickImage() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      if (androidVersion >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        Get.snackbar(
          "Permission Denied",
          "Please enable photo permission from settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // No permission required for iOS if Info.plist is set
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

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


  void EditProfile() {


    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      "apartment_number": profileModel?.data?.unitsId.toString() ?? '',

    };
    setState(() {
      isEditing = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileEdit(data, selectedImage).then((
          response,
        ) async {
          if (response.statusCode == 200) {
            var profileModel = ProfileModel.fromJson(response.data);

            if (profileModel.status == 200) {
              Future.delayed(Duration(microseconds: 100), () {
                Get.offAll(HomePage(userName: ""));
              });

              Get.snackbar(
                "Success",
                "Profile updated successfully",
                backgroundColor: AppColors.maincolor,
                colorText: Colors.white,
              );

              setState(() {
                isEditing = false;
              });
            } else {
              Get.snackbar(
                "Error",
                "Failed to update profile",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              setState(() {
                isEditing = false;
              });
            }
          } else {
            Get.snackbar(
              "Error",
              "Server error, please try again",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            setState(() {
              isEditing = false;
            });
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
