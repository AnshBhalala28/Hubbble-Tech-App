import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customInputDecoration.dart';
import '../../../Utils/customSnackBars.dart';
import '../../../Utils/storeUserData.dart';
import '../../HomeScreen/View/homePage.dart';
import '../modal/login_model.dart';
import '../provider/authenticationProvider.dart';
import 'forgotPassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? emailError;
  String? generalError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 7.h),
                Center(
                  child: Container(
                    child: Image.asset(
                      "assets/images/Applogo_remove_background.png",
                      height: 25.h,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    "Log in to your application",
                    style: TextStyle(
                      color: AppColors.maincolor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        cursorColor: AppColors.black,
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Your Email',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    if (emailError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 0.5.h, left: 3.w),
                        child: Text(
                          emailError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        cursorColor: AppColors.maincolor,
                        controller: password,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                        decoration: inputDecoration(
                          hintText: 'Enter Your Password',
                          searchIcon: Icon(
                            Icons.key,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                          ico: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon:
                                _obscurePassword
                                    ? Icon(
                                      Icons.visibility,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    )
                                    : Icon(
                                      Icons.visibility_off,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // General error message (for both email and password errors)
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
                SizedBox(height: 3.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.to(const ForgotPasswordScreen());
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.maincolor,
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.maincolor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      isLoading == true
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
                                  // Clear previous errors
                                  emailError = null;
                                  generalError = null;
                                });
                                FocusScope.of(context).unfocus();
                                LoginApi();
                              }
                            },
                            borderRadius: BorderRadius.circular(5),
                            child: const Center(
                              child: Text(
                                "Log in",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? usertoken, userrole, userId;

  void LoginApi() async {
    try {
      setState(() {
        isLoading = true;
        emailError = null;
        generalError = null;
      });

      // Fetch the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        setState(() {
          isLoading = false;
          generalError = "Unable to fetch FCM token";
        });
        return;
      }

      final Map<String, String> data = {
        'email': email.text.trim(),
        'password': password.text.trim(),
        'role': '4',
        "fcm_token": fcmToken,
      };

      log('Login data: $data');

      bool internet = await checkInternet();

      if (!internet) {
        setState(() {
          isLoading = false;
          generalError = "Internet connection required";
        });
        return;
      }

      var response = await AuthProvider().loginApi(data);
      log('Login response status: ${response.statusCode}');
      log('Login response data: ${response.data}');
      Map<String, dynamic> responseData =
          response.data is Map ? response.data : {};

      if (response.statusCode == 200) {
        loginModel = LoginModel.fromJson(responseData);

        if (loginModel?.status == 200 && loginModel?.data?.user?.role == 4) {
          await SaveDataLocal.saveLogInData(
            loginModel!,
            email: email.text,
            password: password.text,
          );
          showSnackBar(
            title: "Login",
            message: "Login Successful.",
            backgoundColor: AppColors.maincolor,
            ColorText: AppColors.white,
            IconColor: AppColors.white,
            IconName: Icons.check_circle,
          );
          await Get.offAll(() => HomePage(selected: 1, userName: ""));
          email.clear();
          password.clear();
        } else {
          setState(() {
            generalError = loginModel?.message ?? "Login failed";
          });
        }
      } else if (response.statusCode == 422) {
        // Handle validation errors
        log('Validation error response: $responseData');

        if (responseData['data'] != null && responseData['data'] is Map) {
          Map<String, dynamic> errorData = responseData['data'];

          if (errorData.containsKey('email')) {
            // Email validation error
            String emailErrorMsg =
                errorData['email'] is List
                    ? errorData['email'][0]
                    : "The selected email is invalid.";

            setState(() {
              emailError = emailErrorMsg;
            });
          } else {
            // General validation error
            setState(() {
              generalError = responseData['message'] ?? "Invalid credentials";
            });
          }
        } else if (responseData['message'] == "Invalid Credentials") {
          // Invalid credentials error
          setState(() {
            generalError = "Invalid credentials for email or password";
          });
        } else {
          // Other validation errors
          setState(() {
            generalError = responseData['message'] ?? "Validation failed";
          });
        }
      } else {
        // Other status codes
        setState(() {
          generalError =
              responseData['message'] ?? "Login failed. Please try again.";
        });
      }
    } catch (e, stackTrace) {
      log("Error during login: $e");
      log("Stack trace: $stackTrace");
      setState(() {
        generalError = "Something went wrong during login";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
