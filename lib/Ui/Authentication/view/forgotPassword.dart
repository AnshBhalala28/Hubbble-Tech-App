import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/ui/authentication/modal/forgotPasswordModel.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customSnackBars.dart';
import '../../../utils/errorDialog.dart';
import '../view/loginscreen.dart';
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
    final Color kDarkBackground = const Color(0xFF1E1E1E);
    final Color kDarkBorder = const Color(0xFF333333);
    final Color kWhiteText = Colors.white;
    final Color kHintText = Colors.grey;
    final Color kAccentColor = const Color(0xFFCFB583);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                      color: kAccentColor.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: kAccentColor,
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 0.h, top: 4.h),
            SizedBox(height: 1.h),

            Center(
              child: Image.asset(
                "assets/initLogo.png",
                height: 20.h,
                width: 55.w,
              ),
            ),
            SizedBox(height: 5.h),
            SizedBox(
              width: 100.w,
              child: Text(
                "To reset your password, please get in touch with your concierge team.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.manropeBold,
                  color: kAccentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: kAccentColor,
                borderRadius: BorderRadius.circular(90),
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
                      color: Colors.black,
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
            showSnackBar(
              context: context,
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
            context: context,
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
