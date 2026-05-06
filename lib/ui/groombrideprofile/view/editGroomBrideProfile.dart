import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';
import 'package:wavee/utils/customBatan.dart';
import 'package:wavee/utils/customSnackBars.dart';

class EditGroomBrideProfile extends StatefulWidget {
  const EditGroomBrideProfile({super.key});

  @override
  State<EditGroomBrideProfile> createState() => _EditGroomBrideProfileState();
}

class _EditGroomBrideProfileState extends State<EditGroomBrideProfile> {
  final TextEditingController groomName = TextEditingController();
  final TextEditingController brideName = TextEditingController();
  final TextEditingController quotation = TextEditingController();
  final TextEditingController bookings = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();

  final Color kDarkBackground = const Color(0xFF1E1E1E);
  final Color kDarkBorder = const Color(0xFF333333);

  File? selectedImage;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        // showButton = true;
      });
    }
  }

  String profileImage = "";

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    final Color goldColor = const Color(0xFFC7B283);
    final Color blueColor = const Color(0xFF5A6385);
    final Color primaryButtonColor = isDark ? goldColor : blueColor;
    final Color backgroundColor =
        isDark ? const Color(0xFF111214) : Colors.white;
    final Color iconBgColor =
        isDark
            ? goldColor.withValues(alpha: 0.2)
            : blueColor.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () => Get.back(),
                title: "Profile",
                drawerCallback: () {},
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isDark
                                          ? const Color(0xf0C2B086)
                                          : blueColor,
                                  width: 2,
                                ),
                              ),
                              // FIX 1: Increased radius to 38 (38 * 2 = 76) to match your image width
                              child: CircleAvatar(
                                radius: 30.sp,
                                backgroundColor: Colors.grey.shade300,
                                child: ClipOval(
                                  child:
                                      selectedImage != null
                                          ? Image.file(
                                            selectedImage!,
                                            width: 60.sp,
                                            height: 60.sp,
                                            fit: BoxFit.cover,
                                          )
                                          : CachedNetworkImage(
                                            imageUrl: profileImage,
                                            width: 60.sp,
                                            height: 60.sp,
                                            fit: BoxFit.cover,
                                            // FIX 2: Wrapped in Center and SizedBox to prevent layout issues
                                            placeholder:
                                                (context, url) => Center(
                                                  child: SizedBox(
                                                    width: 15.sp,
                                                    height: 15.sp,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              primaryButtonColor,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Image.asset(
                                                  "assets/images/waveeLogoShort.png",
                                                  fit: BoxFit.cover,
                                                ),
                                          ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryButtonColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: iconBgColor,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16.sp,
                                  color: backgroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildTextField(
                        context: context,
                        controller: groomName,
                        hint: "Groom Name",
                        iconPath: AppConstants.profile,
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 2.h),
                      _buildTextField(
                        context: context,
                        controller: brideName,
                        hint: "Bride Name",
                        iconPath: AppConstants.profile,
                        keyboardType: TextInputType.name,
                      ),

                      SizedBox(height: 2.h),
                      _buildTextField(
                        context: context,
                        controller: phone,
                        hint: "Phone Number",
                        iconPath: AppConstants.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 2.h),
                      _buildTextField(
                        context: context,
                        controller: address,
                        hint: "Address",
                        iconPath: AppConstants.home,
                        keyboardType: TextInputType.streetAddress,
                      ),
                      SizedBox(height: 3.h),

                      batan(
                        title: "Edit Profile",
                        color: isDark ? const Color(0xFFC7B283) : AppColors.lightText,
                        fontcolor: Colors.white,
                        fontsize: 15.sp,
                        fontFamily: AppConstants.manropeSemiBold,
                        route: () {

                        },
                        height: 5.h,
                        width: 50.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 3.w),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    VoidCallback? onTap,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? toggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool expands = false,
    bool readOnly = false,
  }) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    final textColor = isDark ? const Color(0xffCBB88C) : AppColors.lightText;

    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    onTap:
    onTap;
    final fillColor = isDark ? kDarkBackground : Colors.white;

    final borderColor = isDark ? kDarkBorder : Colors.grey.shade300;
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,

      maxLines: expands ? null : maxLines,
      expands: expands,

      style: TextStyle(color: textColor, fontFamily: AppConstants.manrope),

      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14.sp),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            iconPath,
            height: 5.w,
            width: 5.w,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
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
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  ),
                )
                : null,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(300),
          borderSide: BorderSide(
            color: isDark ? const Color(0xffCBB88C) : borderColor,
            width: 1,
          ),
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
}
