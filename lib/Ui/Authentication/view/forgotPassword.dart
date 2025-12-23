import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customSnackBars.dart';
import '../../../Utils/errorDialog.dart';
import '../View/loginscreen.dart';
import '../modal/forgotPasswordModel.dart';
import '../provider/authenticationProvider.dart';

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
            ).paddingOnly(bottom: 0.h, top: 3.h),
            SizedBox(height: 5.h),

            Center(
              child: Image.asset(
                "assets/images/Applogo_remove_background.png",
                height: 25.h,
                // width: 65.w,
                // fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 100.w,
              child: Text(
                "To reset your password, please get in touch with your concierge team.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.manropeBold,
                  color: AppColors.maincolor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.maincolor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  Get.to(const LoginScreen());
                },
                borderRadius: BorderRadius.circular(5),
                child: const Center(
                  child: Text(
                    "Back To Log in",
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
      ).paddingOnly(top: 4.h, left: 3.w, right: 3.w),
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
              context: context,
              title: "Forget",
              message: forgotpasswordmodel?.message ?? '',
              backgoundColor: AppColors.maincolor,
              ColorText: AppColors.white,
              IconColor: AppColors.white,
              IconName: Icons.check_circle,
            );
            await Get.offAll(() => const LoginScreen());
            setState(() {
              isLoading = false;
            });
            emailController.clear();
            // password.clear();
          } else if (response.statusCode == 422) {
            showSnackBar(    context: context,
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
          showSnackBar(    context: context,
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
