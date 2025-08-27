import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_snack_bar.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/input_decoration.dart';
import '../../../comman/store_local.dart';
import '../../homePage/View/homenewpage.dart';
import '../Model/login_model.dart';
import '../Provider/authcation_provider.dart';
import 'forgotpassword.dart';

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

  // rtfgvb
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
                Center(
                  child: Container(
                    child: Image.asset(
                      "assets/images/Applogo_remove_background.png",
                      height: 30.h,
                      width: 65.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                // Center(
                //   child: Text(
                //     "Wavee",
                //     style: TextStyle(
                //       color: AppColors.maincolor,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: AppConstants.manrope,
                //       fontSize: 24.sp,
                //     ),
                //   ),
                // ),
                Center(
                  child: Text(
                    "Login to your application",
                    style: TextStyle(
                      color: AppColors.maincolor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    cursorColor: AppColors.black,
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }

                      // Check if it's a valid email
                      bool isEmail = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
                      ).hasMatch(value);
                      if (!isEmail) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    decoration: inputDecoration(
                      hintText: 'Enter your Email',
                      searchIcon: Icon(
                        Icons.contact_mail,
                        size: 20.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
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
                      hintText: 'Enter your Password',
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
                isLoading == true
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.maincolor,
                      ),
                    )
                    : Container(
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: AppColors.maincolor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            FocusScope.of(context).unfocus();
                            LoginApi();
                          }
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Center(
                          child: Text(
                            "Login",
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
                // Center(
                //   child: RichText(
                //     text: TextSpan(
                //       text: "Don't have any account? ",
                //       style: TextStyle(
                //         fontSize: 17.sp,
                //         color: Colors.black87,
                //         fontWeight: FontWeight.bold,
                //         fontFamily: AppConstants.manrope,
                //       ),
                //       children: [
                //         TextSpan(
                //           text: "Sign in",
                //           style: TextStyle(
                //             color: Colors.blue,
                //             fontWeight: FontWeight.bold,
                //             fontFamily: AppConstants.manrope,
                //           ),
                //           recognizer: TapGestureRecognizer()
                //             ..onTap = () {
                //               Get.to(SignInScreen());
                //             },
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? usertoken, userrole, userId;

  // 267VQLZD49  Key id
  // LWK9CT582 team
  // void LoginApi() async {
  //   // await FirebaseMessaging.instance.requestPermission(provisional: true);
  //   // if (Platform.isIOS) {
  //   //   // Get APNS token
  //   //   String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  //   //   log(apnsToken);
  //   //   // final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
  //   //   if (apnsToken == null) {
  //   //     log(
  //   //       "APNS Token not set. Please ensure Push Notifications are enabled.",
  //   //     );
  //   //     return;
  //   //   }
  //   // }
  //   // String? fcmToken = await FirebaseMessaging.instance.getToken();
  //   // if (fcmToken == null) {
  //   //   // Handle error if FCM token is not available
  //   //   log("FCM Token not available.");
  //   //   return;
  //   // }
  //   // log("FCM TOKEN AVE CHE $fcmToken");
  //   final Map<String, String> data = {
  //     'email': email.text.trim(),
  //     'password': password.text.trim(),
  //     'role': '4',
  //     // "fcm_token": fcmToken,
  //   };
  //
  //   log("Request data sending: $data");
  //
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       try {
  //         var response = await AuthProvider().LoginApi(data);
  //         log("Response status: ${response.statusCode}");
  //         log("Response body: ${response.body}");
  //         loginModel = LoginModel.fromJson(jsonDecode(response.body));
  //         if (response.statusCode == 200 && loginModel?.status == 200) {
  //           if (loginModel?.data?.user?.role == 4) {
  //             await SaveDataLocal.saveLogInData(loginModel!);
  //             showSnackBar(
  //               title: "Login",
  //               message: "Login Successful.",
  //               backgoundColor: AppColors.maincolor,
  //               ColorText: AppColors.white,
  //               IconColor: AppColors.white,
  //               IconName: Icons.check_circle,
  //             );
  //             await Get.offAll(() => HomePage(selected: 1, userName: ""));
  //             setState(() {
  //               isLoading = false;
  //             });
  //             email.clear();
  //             password.clear();
  //           }
  //         } else if (response.statusCode == 422) {
  //           showSnackBar(
  //             title: "Sorry",
  //             message: "Please Enter valid email and password",
  //             backgoundColor: AppColors.redColor,
  //             ColorText: AppColors.white,
  //           );
  //           setState(() {
  //             isLoading = false;
  //           });
  //         } else {
  //           throw Exception(
  //             "Failed to login with status code: ${response.statusCode}",
  //           );
  //         }
  //       } catch (e) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         showSnackBar(
  //           title: "Sorry",
  //           message: "Please enter valid email and password",
  //           backgoundColor: Colors.red.shade400,
  //           ColorText: Colors.white,
  //           IconColor: Colors.white,
  //         );
  //         log("Error: $e");
  //       }
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }
  void LoginApi() async {
    setState(() {
      isLoading = true;
    });

    // Fetch the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      showSnackBar(
        title: "FCM Error",
        message: "Unable to fetch FCM token",
        backgoundColor: Colors.red,
        ColorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final Map<String, String> data = {
      'email': email.text.trim(),
      'password': password.text.trim(),
      'role': '4',
      "fcm_token": fcmToken,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().loginApi(data);

          loginModel = LoginModel.fromJson(response.data);

          if (response.statusCode == 200 && loginModel?.status == 200) {
            if (loginModel?.data?.user?.role == 4) {
              await SaveDataLocal.saveLogInData(loginModel!);
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
            }
          } else if (response.statusCode == 422) {
            showSnackBar(
              title: "Sorry",
              message: "Please Enter valid email and password",
              backgoundColor: AppColors.redColor,
              ColorText: AppColors.white,
            );
          } else {
            throw Exception(
              "Failed to login with status code: ${response.statusCode}",
            );
          }
        } catch (e) {
          showSnackBar(
            title: "Error",
            message: "Something went wrong during login",
            backgoundColor: Colors.red,
            ColorText: Colors.white,
          );
        } finally {
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
