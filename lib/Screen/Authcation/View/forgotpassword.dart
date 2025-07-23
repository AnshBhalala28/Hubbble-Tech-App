import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Authcation/Provider/authcation_provider.dart';
import 'package:wavee/Screen/Authcation/View/loginscreen.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/error_dialog.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_snack_bar.dart';
import '../Model/forgotPasswordModel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 12.w,
                      width: 12.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.maincolor,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 2.h, top: 0.h),
              Center(
                child: Image.asset(
                  "assets/images/Applogo_remove_background.png",
                  height: 30.h,
                  width: 65.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: 100.w,
                child: Text(
                  "To reset your password, please get in touch with your concierge team.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.manrope,
                    color: AppColors.maincolor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                height: 7.h,
                decoration: BoxDecoration(
                  color: AppColors.maincolor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(const LoginScreen());
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Center(
                    child: Text(
                      "Back To Login",
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
            ],
          ),
        ),
      ),
    );
  }

  void ForgotPasswordApi() {
    final Map<String, String> data = {
      'email': emailController.text.trim(),
      // 'password': password.text.trim(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().forgetPasswordApi(data);

          forgotpasswordmodel = Forgotpasswordmodel.fromJson(response.data);
          if (response.statusCode == 200 &&
              forgotpasswordmodel?.status == 200) {
            // await SaveDataLocal.saveLogInData(loginModel!);
            showSnackBar(
              title: "Forget",
              message: forgotpasswordmodel?.message ?? '',
              backgoundColor: AppColors.maincolor,
              ColorText: AppColors.white,
              IconColor: AppColors.white,
              IconName: Icons.check_circle,
            );
            await Get.offAll(() => LoginScreen());
            setState(() {
              isLoading = false;
            });
            emailController.clear();
            // password.clear();
          } else if (response.statusCode == 422) {
            showSnackBar(
              title: "Faild",
              message: "The selected email is invalid.",
              backgoundColor: AppColors.redColor,
              ColorText: AppColors.white,
            );
            setState(() {
              isLoading = false;
            });
          } else {
            throw Exception(
              "Failed to login with status code: ${response.statusCode}",
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            title: "Faild",
            message: "The selected email is invalid.",
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
            IconColor: Colors.white,
          );
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
