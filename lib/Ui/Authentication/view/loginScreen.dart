import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// --- Keep your existing imports ---
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/const.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool isLoading = false;
  bool canSubmit = false; // Controls button disabled state

  String? emailError;
  String? generalError;
  String? usertoken, userrole, userId;

  // Dark Theme Colors
  final Color kDarkBackground = const Color(0xFF1E1E1E);
  final Color kDarkBorder = const Color(0xFF333333);
  final Color kWhiteText = Colors.white;
  final Color kHintText = Colors.grey;
  final Color kAccentColor = const Color(0xFFCFB583);

  @override
  void initState() {
    super.initState();
    // Add listeners to update button state when text changes
    email.addListener(_updateSubmitState);
    password.addListener(_updateSubmitState);
  }

  @override
  void dispose() {
    email.removeListener(_updateSubmitState);
    password.removeListener(_updateSubmitState);
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _updateSubmitState() {
    setState(() {
      // Button is enabled only if both fields have text
      canSubmit = email.text.isNotEmpty && password.text.isNotEmpty;
    });
  }

  void _validateAndSubmit() {
    FocusScope.of(context).unfocus(); // Close keyboard
    if (_formKey.currentState!.validate()) {
      LoginApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Define Button Colors locally or from AppColors ---
    final Color accentColor = kAccentColor;
    final Color disabledButtonColor = Colors.white10; // Dimmed for dark mode
    final Color buttonTextColor = Colors.black;
    final Color disabledTextColor = Colors.white38;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                      'assets/initLogo.png',
                      height: 20.h,
                      width: 55.w,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Center(
                  child: Text(
                    "Log in to your application",
                    style: TextStyle(
                      color: kAccentColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                      fontSize: 16.5.sp,
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                // --- EMAIL FIELD ---
                _buildTextField(
                  controller: email,
                  hint: 'Enter Your Email',
                  iconPath: "assets/bottomSvgs/person.svg",
                  keyboardType: TextInputType.emailAddress,
                  isPassword: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),

                // --- Custom Email Error ---
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

                SizedBox(height: 2.h),

                // --- PASSWORD FIELD ---
                _buildTextField(
                  controller: password,
                  hint: 'Enter Your Password',
                  iconPath: AppConstants.securityIcon,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                  isVisible: !_obscurePassword,
                  toggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),

                // --- General Error ---
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
                        fontFamily: AppConstants.manropeBold,
                        color: kAccentColor,
                        fontSize: 15.5.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // --- UPDATED BUTTON IMPLEMENTATION ---
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    // If canSubmit is false OR loading, disable the press
                    onPressed:
                        (canSubmit && !isLoading) ? _validateAndSubmit : null,
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
                            ? SizedBox(
                              height: 23.sp,
                              width: 23.sp,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(
                              "Log in",
                              style: TextStyle(
                                color:
                                    canSubmit
                                        ? buttonTextColor
                                        : disabledTextColor,
                                fontSize: 16.sp,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                  ),
                ),

                // -------------------------------------
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE TEXT FIELD WIDGET ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? toggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      keyboardType: keyboardType,
      validator: validator,

      style: TextStyle(color: kWhiteText,fontFamily: AppConstants.manrope),
      cursorColor: kAccentColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kHintText, fontSize: 14.sp),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            iconPath,
            height: 5.w,
            width: 5.w,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
        ),

        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: toggle,
                  icon: SvgPicture.asset(
                    !isVisible
                        ? "assets/bottomSvgs/eye.svg"
                        : "assets/bottomSvgs/eye-closed.svg",
                    height: 5.w,
                    width: 5.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                )
                : null,

        filled: true,
        fillColor: kDarkBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(color: kDarkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(color: kAccentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  // --- API LOGIC ---
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

      bool internet = await checkInternet();

      if (!internet) {
        setState(() {
          isLoading = false;
          generalError = "Internet connection required";
        });
        return;
      }

      var response = await AuthProvider().loginApi(data);

      Map<String, dynamic> responseData =
          response.data is Map ? response.data : {};

      if (response.statusCode == 200) {
        loginModel = LoginModel.fromJson(responseData);

        if (loginModel?.status == 200 && loginModel?.data?.user?.role == 4) {
          await SaveDataLocal.saveLogInData(loginModel!, email: email.text);
          showSnackBar(
            context: context,
            title: "Welcome",
            message: "You have successfully logged in.",
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
    } catch (e) {
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
