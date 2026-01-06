// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide FormData, MultipartFile;
// import 'package:sizer/sizer.dart';
//
// import '../../../Utils/apiConfig.dart';
// import '../../../Utils/apiEndpoint.dart';
// import '../../../Utils/checkInternetConnection.dart';
// import '../../../Utils/colors.dart';
// import '../../../Utils/const.dart';
// import '../../../Utils/customAppBar.dart';
// import '../../../Utils/customInputDecoration.dart';
// import '../../../Utils/customSnackBars.dart';
// import '../../../Utils/errorDialog.dart';
// import '../../../Utils/storeUserData.dart';
// import '../View/loginscreen.dart';
// import '../provider/authenticationProvider.dart';
//
// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({super.key});
//
//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final TextEditingController oldPassword = TextEditingController();
//   final TextEditingController newPassword = TextEditingController();
//   final TextEditingController confirmPassword = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//
//   bool oldVisible = false;
//   bool newVisible = false;
//   bool confirmVisible = false;
//   String? generalError;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // SizedBox(height: 6.h),
//               TitleBar(title: "Change Your Password", drawerCallback: () {}),
//               SizedBox(height: 5.h),
//               Center(
//                 child: Image.asset(
//                   "assets/images/Applogo_remove_background.png",
//                   height: 25.h,
//                 ),
//               ),
//
//               SizedBox(height: 3.h),
//               TextFormField(
//                 controller: oldPassword,
//                 obscureText: !oldVisible,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return "Please enter old password";
//                   }
//                   return null;
//                 },
//                 decoration: inputDecoration(
//                   hintText: "Enter Old Password",
//                   searchIcon: Icon(
//                     Icons.lock,
//                     size: 20.sp,
//                     color: AppColors.black,
//                   ),
//                   ico: IconButton(
//                     onPressed: () {
//                       setState(() => oldVisible = !oldVisible);
//                     },
//                     icon: Icon(
//                       oldVisible ? Icons.visibility_off : Icons.visibility,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.5.h),
//
//               // ---------------------------------------------
//               // UPDATED NEW PASSWORD FIELD VALIDATOR
//               // ---------------------------------------------
//               TextFormField(
//                 controller: newPassword,
//                 obscureText: !newVisible,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return "Please enter new password";
//                   } else if (val.length < 6) {
//                     return "Password must be at least 6 characters";
//                   } else if (val == '12345678' ||
//                       val == '123456' ||
//                       val == '1234567890') {
//                     // 🔴 Added validation to block '12345678'
//                     return "Password cannot be $val";
//                   }
//                   return null;
//                 },
//                 decoration: inputDecoration(
//                   hintText: "Enter New Password",
//                   searchIcon: Icon(
//                     Icons.lock_outline,
//                     size: 20.sp,
//                     color: AppColors.black,
//                   ),
//                   ico: IconButton(
//                     onPressed: () {
//                       setState(() => newVisible = !newVisible);
//                     },
//                     icon: Icon(
//                       newVisible ? Icons.visibility_off : Icons.visibility,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 2.5.h),
//               TextFormField(
//                 controller: confirmPassword,
//                 obscureText: !confirmVisible,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return "Please confirm your password";
//                   } else if (val != newPassword.text) {
//                     return "Passwords do not match";
//                   }
//                   return null;
//                 },
//                 decoration: inputDecoration(
//                   hintText: "Confirm New Password",
//                   searchIcon: Icon(
//                     Icons.lock_reset,
//                     size: 20.sp,
//                     color: AppColors.black,
//                   ),
//                   ico: IconButton(
//                     onPressed: () {
//                       setState(() => confirmVisible = !confirmVisible);
//                     },
//                     icon: Icon(
//                       confirmVisible ? Icons.visibility_off : Icons.visibility,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//
//               if (generalError != null)
//                 Padding(
//                   padding: EdgeInsets.only(top: 1.h, left: 3.w),
//                   child: Text(
//                     generalError!,
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 14.sp,
//                       fontFamily: AppConstants.manrope,
//                     ),
//                   ),
//                 ),
//
//               SizedBox(height: 4.h),
//               Container(
//                 height: 5.h,
//                 decoration: BoxDecoration(
//                   color: AppColors.maincolor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child:
//                     isLoading
//                         ? const Center(
//                           child: CircularProgressIndicator(
//                             color: AppColors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                         : InkWell(
//                           onTap: () {
//                             if (_formKey.currentState!.validate()) {
//                               setState(() {
//                                 isLoading = true;
//                                 generalError = null;
//                               });
//                               FocusScope.of(context).unfocus();
//                               _changePasswordApi();
//                             }
//                           },
//                           borderRadius: BorderRadius.circular(5),
//                           child: const Center(
//                             child: Text(
//                               "Change Password",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: AppConstants.manropeBold,
//                               ),
//                             ),
//                           ),
//                         ),
//               ),
//               SizedBox(height: 2.h),
//             ],
//           ).paddingOnly(left: 3.w, right: 3.w, top: 5.h),
//         ),
//       ),
//     );
//   }
//
//   void _changePasswordApi() async {
//     try {
//       setState(() => isLoading = true);
//
//       // 🔹 Prepare request data
//       final Map<String, dynamic> data = {
//         'user_id': loginModel?.data?.user?.id.toString() ?? "",
//         'old_password': oldPassword.text.trim(),
//         'new_password': newPassword.text.trim(),
//         'confirm_password': confirmPassword.text.trim(),
//       };
//
//       // 🔹 Check Internet Connection
//       bool internet = await checkInternet();
//       if (!internet) {
//         setState(() {
//           isLoading = false;
//           generalError = "Internet connection required";
//         });
//         return;
//       }
//
//       // 🔹 API Call using DioHelper (pinned)
//       final dio = await DioHelper.getDio();
//       final response = await dio.post(
//         ApiEndpoint.changePassword,
//         data: FormData.fromMap(data),
//         options: Options(headers: {"Accept": "application/json"}),
//       );
//
//       // 🔹 Handle API Response (Success Case)
//       if (response.statusCode == 200) {
//         final res = response.data;
//         if (res['status'] == true || res['status'] == 200) {
//           showSnackBar(
//             context: context,
//             title: "Success",
//             message: res['message'] ?? "Password changed successfully",
//             backgoundColor: AppColors.maincolor,
//             ColorText: AppColors.white,
//             IconColor: AppColors.white,
//             IconName: Icons.check_circle,
//           );
//           Logout();
//           await SaveDataLocal.clearUserData();
//
//           await Future.delayed(const Duration(seconds: 1));
//           Get.offAll(() => const LoginScreen());
//         } else {
//           // ❌ General success-false message (if status code was 200 but status:false)
//           setState(() {
//             generalError = res['message'] ?? "Password change failed";
//           });
//         }
//       } else {
//         // ❌ Handle non-200 status codes that Dio didn't throw (less common)
//         setState(() {
//           generalError =
//               "Something went wrong (${response.statusCode}). Please try again.";
//         });
//       }
//     } catch (e) {
//       String errorMessage = "Unable to change password. Please try again.";
//
//       // Check if the error is from Dio and has a response from the server
//       if (e is DioException && e.response != null && e.response!.data != null) {
//         try {
//           final responseData = e.response!.data;
//
//           if (responseData is Map<String, dynamic> &&
//               responseData.containsKey('message')) {
//             // Set the specific error message from the API
//             errorMessage = responseData['message'];
//           } else {
//             errorMessage =
//                 "Server returned an error: (${e.response!.statusCode})";
//           }
//         } catch (parseError) {
//           errorMessage = "An unknown error occurred while reading the error.";
//         }
//       }
//
//       setState(() {
//         generalError = errorMessage;
//       });
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }
//
//   void Logout() {
//     final Map<String, String> data = {};
//     data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await AuthProvider().logoutApi(data);
//           if (response.statusCode == 200) {
//             setState(() {
//               isLoading = false;
//             });
//             handleDataClear();
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

// --- Imports from your project structure ---
import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
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

  // --- Password Validation State ---
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool isMatched = false;
  double strengthLevel = 0.0; // 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    // Add listeners to update state in real-time
    oldPassword.addListener(
      _refreshState,
    ); // Listen to old pass to enable button
    newPassword.addListener(_updatePasswordStatus);
    confirmPassword.addListener(_updatePasswordStatus);
  }

  @override
  void dispose() {
    oldPassword.removeListener(_refreshState);
    newPassword.removeListener(_updatePasswordStatus);
    confirmPassword.removeListener(_updatePasswordStatus);
    super.dispose();
  }

  void _refreshState() {
    setState(() {});
  }

  void _updatePasswordStatus() {
    final val = newPassword.text;
    final confirm = confirmPassword.text;

    setState(() {
      // 1. Check individual requirements
      hasMinLength = val.length >= 8;
      hasUppercase = val.contains(RegExp(r'[A-Z]'));
      hasNumber = val.contains(RegExp(r'[0-9]'));
      hasSpecial = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      // 2. Calculate Strength (0 to 4 points)
      int points = 0;
      if (hasMinLength) points++;
      if (hasUppercase) points++;
      if (hasNumber) points++;
      if (hasSpecial) points++;

      strengthLevel = points / 4;

      // 3. Check Match
      isMatched = val.isNotEmpty && val == confirm;
    });
  }

  Color _getStrengthColor() {
    if (strengthLevel <= 0.25) return Colors.red;
    if (strengthLevel <= 0.50) return Colors.orange;
    if (strengthLevel <= 0.75) return Colors.blue;
    return const Color(0xFF00C853); // Green for strong
  }

  String _getStrengthText() {
    if (strengthLevel <= 0.25) return "WEAK";
    if (strengthLevel <= 0.50) return "FAIR";
    if (strengthLevel <= 0.75) return "GOOD";
    return "STRONG";
  }

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------
    // THEME CONFIGURATION
    // -----------------------------------------------------------------
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDark;

    // -- Dynamic Colors --
    final Color scaffoldBgColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F7FA);
    final Color cardBgColor = isDark ? const Color(0xFF212121) : Colors.white;
    final Color titleColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final Color labelColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final Color inputFillColor =
        isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final Color inputBorderColor =
        isDark ? Colors.transparent : Colors.grey.shade200;
    final Color inputTextColor = isDark ? Colors.white : Colors.black;
    final Color hintTextColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    // Accent: Dark Mode = Gold, Light Mode = Dark Blue
    final Color accentColor =
        isDark ? const Color(0xFFCFB583) : const Color(0xFF4C5588);
    final Color disabledButtonColor =
        isDark ? AppColors.black12 : Colors.grey.shade200;
    final Color disabledTextColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    final Color buttonTextColor = isDark ? Colors.black : Colors.white;

    // Requirements Box
    final Color reqBoxColor =
        isDark ? Color(0xf0282623) : const Color(0xFFE9EEF5);
    final Color reqDefaultTextColor =
        isDark ? const Color(0xFFCFB583) : Colors.blue.shade900;
    final BoxBorder? reqBoxBorder =
        isDark ? Border.all(color: const Color(0xFF333333)) : null;

    // Success Color (Green)
    final Color successColor = const Color(0xFF00C853);

    // -----------------------------------------------------------------
    // BUTTON LOGIC CHECK
    // -----------------------------------------------------------------
    bool canSubmit =
        !isLoading &&
        oldPassword.text.isNotEmpty &&
        hasMinLength &&
        hasUppercase &&
        hasNumber &&
        hasSpecial &&
        isMatched;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 2.h),

              TitleBar(title: "Security", drawerCallback: () {}),

              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF34312B)
                                : AppColors.lightText.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 25.sp,
                        color: isDark ? Color(0xf0B6A57F) : AppColors.lightText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: titleColor,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                    Text(
                      "Keep your account secure",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: subtitleColor,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // Main Form Card
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OLD PASSWORD
                    _buildLabel("CURRENT PASSWORD", labelColor),
                    _buildTextField(
                      controller: oldPassword,
                      hint: "Enter current password",
                      isVisible: oldVisible,
                      toggle: () => setState(() => oldVisible = !oldVisible),
                      fillColor: inputFillColor,
                      borderColor: inputBorderColor,
                      textColor: inputTextColor,
                      hintColor: hintTextColor,
                      focusColor: accentColor,
                      iconColor: isDark ? Colors.grey : AppColors.lightText,
                    ),

                    SizedBox(height: 2.h),

                    // NEW PASSWORD
                    _buildLabel("NEW PASSWORD", labelColor),
                    _buildTextField(
                      controller: newPassword,
                      hint: "Enter new password",
                      isVisible: newVisible,
                      toggle: () => setState(() => newVisible = !newVisible),
                      fillColor: inputFillColor,
                      borderColor: inputBorderColor,
                      textColor: inputTextColor,
                      hintColor: hintTextColor,
                      focusColor: accentColor,
                      iconColor: isDark ? Colors.grey : AppColors.lightText,
                    ),

                    // Strength Bar Indicator - HIDDEN IF EMPTY
                    if (newPassword.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 1.5.h, bottom: 0.5.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: strengthLevel,
                                  backgroundColor:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  color: _getStrengthColor(),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              _getStrengthText(),
                              style: TextStyle(
                                color: _getStrengthColor(),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 2.h),

                    // CONFIRM PASSWORD
                    _buildLabel("CONFIRM PASSWORD", labelColor),
                    _buildTextField(
                      controller: confirmPassword,
                      hint: "Confirm new password",
                      isVisible: confirmVisible,
                      toggle:
                          () =>
                              setState(() => confirmVisible = !confirmVisible),
                      fillColor: inputFillColor,
                      borderColor: inputBorderColor,
                      textColor: inputTextColor,
                      hintColor: hintTextColor,
                      focusColor: accentColor,
                      iconColor: isDark ? Colors.grey : AppColors.lightText,
                    ),

                    // Matches Indicator - HIDDEN IF EMPTY
                    if (confirmPassword.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Row(
                          children: [
                            Icon(
                              isMatched ? Icons.check_circle : Icons.cancel,
                              color: isMatched ? successColor : Colors.red,
                              size: 16.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              isMatched
                                  ? "Passwords match"
                                  : "Passwords do not match",
                              style: TextStyle(
                                color: isMatched ? successColor : Colors.red,
                                fontSize: 14.sp,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 3.h),

                    // Update Button (With Disabled Logic)
                    SizedBox(
                      width: double.infinity,
                      height: 5.h,
                      child: ElevatedButton(
                        // If canSubmit is false, onPressed is null -> Button Disabled
                        onPressed: canSubmit ? _validateAndSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          disabledBackgroundColor: disabledButtonColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            isLoading
                                ? CircularProgressIndicator(
                                  color: buttonTextColor,
                                )
                                : Text(
                                  "Update Password",
                                  style: TextStyle(
                                    color:
                                        canSubmit
                                            ? buttonTextColor
                                            : disabledTextColor,
                                    fontSize: 15.sp,
                                    fontFamily: AppConstants.manropeBold,
                                  ),
                                ),
                      ),
                    ),

                    // General Error Text
                    if (generalError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Center(
                          child: Text(
                            generalError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.5.sp,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Password Requirements Section (Dynamic Pills)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: reqBoxColor,
                  border: reqBoxBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PASSWORD REQUIREMENTS",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: reqDefaultTextColor,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 1.5.h),

                    // Dynamic Requirement Rows
                    _buildRequirementRow(
                      "At least 8 characters",
                      reqDefaultTextColor,
                      successColor,
                      hasMinLength,
                    ),
                    _buildRequirementRow(
                      "Uppercase letter",
                      reqDefaultTextColor,
                      successColor,
                      hasUppercase,
                    ),
                    _buildRequirementRow(
                      "Number",
                      reqDefaultTextColor,
                      successColor,
                      hasNumber,
                    ),
                    _buildRequirementRow(
                      "Special character",
                      reqDefaultTextColor,
                      successColor,
                      hasSpecial,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ).paddingOnly(left: 3.w, right: 3.w, top: 5.h),
        ),
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: 2.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: AppConstants.manrope,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback toggle,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
    required Color focusColor,
    required Color iconColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: textColor),
      cursorColor: focusColor,
      onChanged: (val) {
        // Trigger rebuild for realtime feedback is handled by controller listener
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 13.sp,
          fontFamily: AppConstants.manrope,
        ),

        // --- PREFIX ICON (LOCK) ---
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppConstants.securityIcon, // Your Lock SVG path
            height: 5.w,
            // Adjusted size (2.w might be too small, usually 5-6.w or 20-24px)
            width: 5.w,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),

        // --- UPDATED SUFFIX ICON (EYE) ---
        suffixIcon: IconButton(
          onPressed: toggle,

          icon: SvgPicture.asset(
            !isVisible
                ? "assets/bottomSvgs/eye.svg"
                : "assets/bottomSvgs/eye-closed.svg",
            height: 5.w,
            width: 5.w,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
        ),

        // ---------------------------------
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }

  // Helper Widget for Requirements Row (Updated for Dynamic State)
  Widget _buildRequirementRow(
    String text,
    Color defaultColor,
    Color activeColor,
    bool isMet,
  ) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            isMet
                ? 'assets/bottomSvgs/check.svg'
                : isDark
                ? 'assets/bottomSvgs/checkout-dark.svg'
                : 'assets/bottomSvgs/checkout-light.svg',
            height: 18, // Matches the previous Icon size: 18
            width: 18,
            // This tints the SVG dynamically based on the state
            colorFilter: ColorFilter.mode(
              isMet ? activeColor : defaultColor.withOpacity(0.5),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isMet ? activeColor : defaultColor,
              fontSize: 13.5.sp,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // LOGIC & API CALLS
  // -----------------------------------------------------------------

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // Custom validation for strength
      if (!hasMinLength || !hasUppercase || !hasNumber || !hasSpecial) {
        setState(() {
          generalError = "Please meet all password requirements";
        });
        return;
      }

      if (!isMatched) {
        setState(() {
          generalError = "Passwords do not match";
        });
        return;
      }

      setState(() => generalError = null);
      _changePasswordApi();
    }
  }

  void _changePasswordApi() async {
    try {
      setState(() => isLoading = true);
      final Map<String, dynamic> data = {
        'user_id': loginModel?.data?.user?.id.toString() ?? "",
        'old_password': oldPassword.text.trim(),
        'new_password': newPassword.text.trim(),
        'confirm_password': confirmPassword.text.trim(),
      };

      bool internet = await checkInternet();
      if (!internet) {
        setState(() {
          isLoading = false;
          generalError = "Internet connection required";
        });
        return;
      }

      final dio = await DioHelper.getDio();

      final response = await dio.post(
        ApiEndpoint.changePassword,
        data: FormData.fromMap(data),
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res['status'] == true || res['status'] == 200) {
          showSnackBar(
            context: context,
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
          setState(() {
            generalError = res['message'] ?? "Password change failed";
          });
        }
      } else {
        setState(() {
          generalError =
              "Something went wrong (${response.statusCode}). Please try again.";
        });
      }
    } catch (e, stackTrace) {
      // <--- Added stackTrace capture here

      if (e is DioException) {
        if (e.response != null) {}
      }
      // --- ERROR LOGGING END ---

      String errorMessage = "Unable to change password. Please try again.";

      if (e is DioException && e.response != null && e.response!.data != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage =
                "Server returned an error: (${e.response!.statusCode})";
          }
        } catch (parseError) {
          errorMessage = "An unknown error occurred while reading the error.";
        }
      }
      setState(() {
        generalError = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
            setState(() => isLoading = false);
            if (mounted) {
              await handleDataClear(context);
            }
          } else {
            setState(() => isLoading = false);
          }
        } catch (e) {
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      } else {
        setState(() => isLoading = false);
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
