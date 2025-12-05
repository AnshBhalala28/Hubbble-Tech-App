import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customInputDecoration.dart';
import '../../../Utils/customSnackBars.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/storeUserData.dart';
import '../View/loginscreen.dart';
import '../provider/authenticationProvider.dart';

class ChangePasswordScreen extends StatefulWidget {

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  bool oldVisible = false;
  bool newVisible = false;
  bool confirmVisible = false;
  String? generalError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 6.h),
              TitleBar(title: "Change Your Password", drawerCallback: () {}),
              SizedBox(height: 5.h),
              Center(
                child: Image.asset(
                  "assets/images/Applogo_remove_background.png",
                  height: 25.h,
                ),
              ),

              SizedBox(height: 3.h),
              TextFormField(
                controller: oldPassword,
                obscureText: !oldVisible,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter old password";
                  }
                  return null;
                },
                decoration: inputDecoration(
                  hintText: "Enter Old Password",
                  searchIcon: Icon(
                    Icons.lock,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                  ico: IconButton(
                    onPressed: () {
                      setState(() => oldVisible = !oldVisible);
                    },
                    icon: Icon(
                      oldVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              TextFormField(
                controller: newPassword,
                obscureText: !newVisible,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter new password";
                  } else if (val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                decoration: inputDecoration(
                  hintText: "Enter New Password",
                  searchIcon: Icon(
                    Icons.lock_outline,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                  ico: IconButton(
                    onPressed: () {
                      setState(() => newVisible = !newVisible);
                    },
                    icon: Icon(
                      newVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              TextFormField(
                controller: confirmPassword,
                obscureText: !confirmVisible,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please confirm your password";
                  } else if (val != newPassword.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                decoration: inputDecoration(
                  hintText: "Confirm New Password",
                  searchIcon: Icon(
                    Icons.lock_reset,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                  ico: IconButton(
                    onPressed: () {
                      setState(() => confirmVisible = !confirmVisible);
                    },
                    icon: Icon(
                      confirmVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),

              if (generalError != null)
                Padding(
                  padding: EdgeInsets.only(top: 1.h, left: 3.w),
                  child: Text(
                    generalError!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ),

              SizedBox(height: 4.h),
              Container(
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.maincolor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                                generalError = null;
                              });
                              FocusScope.of(context).unfocus();
                              _changePasswordApi();
                            }
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: const Center(
                            child: Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                          ),
                        ),
              ),
              SizedBox(height: 2.h),
            ],
          ).paddingOnly(left: 3.w, right: 3.w, top: 5.h),
        ),
      ),
    );
  }

  void _changePasswordApi() async {
    try {
      setState(() => isLoading = true);

      // 🔹 Prepare request data
      final Map<String, dynamic> data = {
        'user_id': loginModel?.data?.user?.id.toString() ?? "",
        'old_password': oldPassword.text.trim(),
        'new_password': newPassword.text.trim(),
        'confirm_password': confirmPassword.text.trim(),
      };

      log("Change Password Request Data: $data");

      // 🔹 Check Internet Connection
      bool internet = await checkInternet();
      if (!internet) {
        setState(() {
          isLoading = false;
          generalError = "Internet connection required";
        });
        return;
      }

      // 🔹 API Call using Dio
      final dio = Dio();
      final response = await dio.post(
        "https://portal.wavee.ai/api/changePasswordApp",
        data: FormData.fromMap(data),
        options: Options(
          headers: {"Accept": "application/json"},
          method: "POST",
        ),
      );

      log("Change Password Response: ${response.data}");

      // 🔹 Handle API Response (Success Case)
      if (response.statusCode == 200) {
        final res = response.data;
        if (res['status'] == true || res['status'] == 200) {
          showSnackBar(
            title: "Success",
            message: res['message'] ?? "Password changed successfully",
            backgoundColor: AppColors.maincolor,
            ColorText: AppColors.white,
            IconColor: AppColors.white,
            IconName: Icons.check_circle,
          );
          Logout();
          await SaveDataLocal.clearUserData();

          await Future.delayed(const Duration(seconds: 1));
          Get.offAll(() => const LoginScreen());
        } else {
          // ❌ General success-false message (if status code was 200 but status:false)
          setState(() {
            generalError = res['message'] ?? "Password change failed";
          });
        }
      } else {
        // ❌ Handle non-200 status codes that Dio didn't throw (less common)
        setState(() {
          generalError =
              "Something went wrong (${response.statusCode}). Please try again.";
        });
      }
    } catch (e, s) {
      // 🔴 === START OF THE FIX === 🔴
      // This block catches errors, including 400 Bad Request

      log("Change Password Error: $e");
      log("Stack Trace: $s");

      String errorMessage = "Unable to change password. Please try again.";

      // Check if the error is from Dio and has a response from the server
      if (e is DioException && e.response != null && e.response!.data != null) {
        try {
          // Try to parse the error message from the API response
          // e.g., {"status": false, "message": "Old password is incorrect."}
          final responseData = e.response!.data;

          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            // Set the specific error message from the API
            errorMessage = responseData['message'];
          } else {
            // If the response data is not in the expected format
            errorMessage =
                "Server returned an error: (${e.response!.statusCode})";
          }
        } catch (parseError) {
          log("Error parsing Dio error response: $parseError");
          errorMessage = "An unknown error occurred while reading the error.";
        }
      }

      // Show the (now specific) error message on the screen
      setState(() {
        generalError = errorMessage;
      });

      // 🔴 === END OF THE FIX === 🔴
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void Logout() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    log("dasdadadadadadasdadadsa$data");
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
