import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/Screen/viewProfile/Model/profile_model.dart';
import 'package:wavee/Screen/viewProfile/Provider/profile_provider.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/custom_batan.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_snack_bar.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/input_decoration.dart';
import '../provider/waveePetProvider.dart';

class SignUpScreen extends StatefulWidget {
  String? loginId;

  SignUpScreen({super.key, this.loginId});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController address = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  bool isLoading1 = false;
  Map<String, String> fieldErrors = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading1 = true;
    });
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child:
              isLoading1
                  ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.maincolor,
                    ),
                  ).paddingOnly(top: 40.h)
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleBar(title: "Wavee Pet", drawerCallback: () {}),
                      SizedBox(height: 2.h),

                      Center(
                        child: Image.asset(
                          "assets/images/waveePetsShort.png",
                          height: 20.h,
                          width: 80.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      Center(
                        child: Text(
                          "Create a new account",
                          style: TextStyle(
                            color: AppColors.maincolor,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: fullName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Full Name',
                          searchIcon: Icon(
                            Icons.person,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }

                          bool isEmail = RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$",
                          ).hasMatch(value);

                          if (!isEmail) {
                            return "Please enter a valid email";
                          }

                          return null;
                        },

                        decoration: inputDecoration(
                          hintText: 'Email',
                          searchIcon: Icon(
                            Icons.email,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      TextFormField(
                        controller: password,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Password',
                          searchIcon: Icon(
                            Icons.lock,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                          ico: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: confirmPassword,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value != password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Confirm Password',
                          searchIcon: Icon(
                            Icons.lock,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                          ico: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),

                      isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.maincolor,
                            ),
                          )
                          : batan(
                            title: "Sign Up",
                            route: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  isLoading = true;
                                });
                                SignupApi();
                              }
                            },
                            color: AppColors.maincolor,
                            fontcolor: AppColors.white,
                            height: 5.5.h,
                            width: double.infinity,
                            fontsize: 18.sp,
                          ),
                      SizedBox(height: 2.h),
                    ],
                  ).paddingOnly(right: 3.w, left: 3.w, top: 6.h),
        ),
      ),
    );
  }

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void GetProfile() {
    final Map<String, String> data = {'id': widget.loginId.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            var profileModel = ProfileModel.fromJson(response.data);
            if (profileModel.status == 200) {
              var user = profileModel.data?.user;
              print("Response ave che ${response.data}");
              if (user != null) {
                fullName.text =
                    "${capitalize(user.name?.firstName)} ${capitalize(user.name?.lastName)}";
                email.text = user.email == null ? "N/A" : user.email.toString();

                // var address = user.address;
                // if (address != null) {
                //   fullAddressController.text =
                //   "${address.address ?? ""}, ${address.city ?? ""}, ${address.country ?? ""}";
                //   zipCodeController.text = address.zipCode ?? "";
                // } else {
                //   fullAddressController.text = "";
                //   zipCodeController.text = "";
                // }
              } else {
                fullName.text = "";
                email.text = "";
              }
            }

            setState(() {
              isLoading1 = false;
            });
          } else {
            setState(() {
              isLoading1 = false;
            });
          }
        });
      } else {
        setState(() {
          isLoading1 = false;
        });
      }
    });
  }

  void SignupApi() {
    final Map<String, String> data = {
      'name': fullName.text.trim(),
      'email': email.text.trim(),
      'password': password.text.trim(),
      'role': '4',
    };

    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await AuthProvider1().SignUpApi(data);

          Map<String, dynamic> responseData;
          try {
            responseData = jsonDecode(response.body);

            int apiStatus = responseData['status'] ?? 0;
            String apiMessage = responseData['message'] ?? "Unknown error";

            if (response.statusCode == 200 && apiStatus == 200) {
              showSnackBar(
                title: "SignUp",
                message: "Registration Successful.",
                backgoundColor: AppColors.maincolor,
                ColorText: AppColors.white,
                IconColor: AppColors.white,
                IconName: Icons.check_circle,
              );
              launchStore();
              // openAppB();
              fullName.clear();
              email.clear();
              phone.clear();
              address.clear();
              password.clear();
              confirmPassword.clear();
            } else {
              if (responseData.containsKey('data') &&
                  responseData['data'] is Map) {
                Map<String, dynamic> errorData = responseData['data'];

                String errorMessage = apiMessage;
                if (errorData.containsKey('email') &&
                    errorData['email'] is List &&
                    errorData['email'].isNotEmpty) {
                  errorMessage = errorData['email'][0];
                } else if (errorData.containsKey('name') &&
                    errorData['name'] is List &&
                    errorData['name'].isNotEmpty) {
                  errorMessage = errorData['name'][0];
                } else if (errorData.containsKey('password') &&
                    errorData['password'] is List &&
                    errorData['password'].isNotEmpty) {
                  errorMessage = errorData['password'][0];
                }

                showSnackBar(
                  title: "Sorry",
                  message: errorMessage,
                  backgoundColor: AppColors.redColor,
                  ColorText: AppColors.white,
                );
              } else {
                showSnackBar(
                  title: "Sorry",
                  message: apiMessage,
                  backgoundColor: AppColors.redColor,
                  ColorText: AppColors.white,
                );
              }
            }
          } catch (jsonError) {
            showSnackBar(
              title: "Sorry",
              message: "Invalid response from server. Please try again.",
              backgoundColor: AppColors.redColor,
              ColorText: AppColors.white,
            );
          }
        } catch (e) {
          if (e.toString().contains("No Internet connection")) {
            showSnackBar(
              title: "Sorry",
              message: "No internet connection. Please check your network.",
              backgoundColor: Colors.red.shade400,
              ColorText: Colors.white,
            );
          } else {
            showSnackBar(
              title: "Sorry",
              message: "Registration failed. Please try again.",
              backgoundColor: Colors.red.shade400,
              ColorText: Colors.white,
            );
          }
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void launchStore() async {
    final Uri url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/in/app/wavee-pet/id6746203457'
          : 'https://play.google.com/store/apps/details?id=com.pets.wavee',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

}
