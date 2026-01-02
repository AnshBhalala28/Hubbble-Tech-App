import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/customAppBar.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customSnackBars.dart';
import '../../../Utils/loader.dart';
import '../../Authentication/View/loginscreen.dart';
import '../../Authentication/provider/authenticationProvider.dart';
import '../Provider/profileProvider.dart';
import '../modal/profile_model.dart';
import 'myBuildingScreen.dart';
import 'myHomeScreen.dart';

class ViewProfile extends StatefulWidget {
  final int? id;

  const ViewProfile({super.key, required this.id});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  // State
  bool isLoading = true;
  String profileImage = "";
  File? selectedImage;
  ProfileModel? profileModel;
  bool isEditing = false;

  // Helper to get user data safely
  User? get userData => profileModel?.data?.user;

  Unit? get unitData => profileModel?.data?.unit;

  @override
  void initState() {
    super.initState();
    GetProfile();
  }

  // ---------------------------------------------------------------------------
  // API LOGIC
  // ---------------------------------------------------------------------------
  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};

    checkInternet().then((internet) {
      if (!internet) {
        if (mounted) {
          setState(() => isLoading = false);
          showSnackBar(
            context: context,
            title: "Error",
            message: "No Internet",
          );
        }
        return;
      }

      ProfileProvider()
          .profileApi(data)
          .then((response) {
            try {
              if (response.statusCode == 200) {
                // --- START PRETTY PRINT LOGIC ---
                try {
                  // This converts the response data into a pretty indented string
                  // String prettyJson = const JsonEncoder.withIndent(
                  //   '  ',
                  // ).convert(response.data);
                  // log("FULL API RESPONSE:\n$prettyJson");
                } catch (e) {
                  debugPrint("Could not pretty print JSON: $e");
                }
                // --- END PRETTY PRINT LOGIC ---

                if (mounted) {
                  setState(() {
                    profileModel = ProfileModel.fromJson(response.data);

                    // Update local image var if API has one
                    if (userData?.profile != null &&
                        userData!.profile!.isNotEmpty) {
                      profileImage = userData!.profile!;
                    }
                  });
                }
              }
            } catch (e) {
              debugPrint("Parse Error: $e");
            } finally {
              if (mounted) {
                setState(() => isLoading = false);
              }
            }
          })
          .catchError((e) {
            debugPrint("API Error: $e");
            if (mounted) setState(() => isLoading = false);
          });
    });
  }

  Future<void> EditProfile() async {
    // Guard: Don't run if no image
    if (selectedImage == null) {
      showSnackBar(
        context: context,
        title: "Required",
        message: "Please select an image first",
        backgoundColor: Colors.orange,
        ColorText: Colors.white,
      );
      return;
    }

    // 1. Start Local Loader (Only the button spins)
    setState(() => isEditing = true);

    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      "apartment_number": profileModel?.data?.unitsId.toString() ?? '',
    };
    log(data.toString());
    log(selectedImage?.path ?? '');
    try {
      bool hasInternet = await checkInternet();

      if (!hasInternet) {
        if (mounted) {
          showSnackBar(
            context: context,
            title: "Error",
            message: "Internet Required",
            backgoundColor: AppColors.maincolor,
            ColorText: Colors.white,
          );
        }
        return; // Stop here
      }

      // 2. Call API
      final response = await ProfileProvider().profileEdit(data, selectedImage);

      if (response.statusCode == 200) {
        var result = ProfileModel.fromJson(response.data);

        if (result.status == 200) {
          // 3. Success Logic
          if (mounted) {
            // Clear image selection
            setState(() {
              selectedImage = null;
            });

            showSnackBar(
              context: context,
              title: "Success",
              message: "Profile updated successfully",
            );

            GetProfile();
          }
        } else {
          if (mounted) {
            showSnackBar(
              context: context,
              title: "Error",
              message: "Failed to update profile",
              backgoundColor: AppColors.redColor,
              ColorText: Colors.white,
            );
          }
        }
      } else {
        if (mounted) {
          showSnackBar(
            context: context,
            title: "Error",
            message: "Server error, please try again",
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint("Edit Error: $e");
      if (mounted) {
        showSnackBar(
          context: context,
          title: "Submission Failed",
          // This will show the server's validation message if you threw it correctly above
          message: e.toString().replaceAll("Exception:", ""),
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // THEME CONFIGURATION
    // ---------------------------------------------------------
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    // Screenshot Exact Colors
    final Color backgroundColor =
        isDark ? const Color(0xFF111214) : Colors.white;
    final Color cardBackgroundColor =
        isDark ? const Color(0xFF1D1D1F) : Colors.white;

    // Text Colors
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    // Accent/Button Colors
    final Color goldColor = const Color(0xFFC7B283);
    final Color blueColor = const Color(0xFF5A6385);

    final Color primaryButtonColor = isDark ? goldColor : blueColor;

    // Icon Containers
    final Color iconBgColor =
        isDark
            ? goldColor.withValues(alpha: 0.2)
            : blueColor.withValues(alpha: 0.15);
    final Color iconColor = isDark ? Color(0xf0B8A780) : blueColor;

    // Logout Colors
    final Color logoutBgColor =
        isDark ? const Color(0xFF2C1F1F) : const Color(0xFFFBE8EB);
    final Color logoutTextColor =
        isDark ? const Color(0xFFC83939) : const Color(0xFFD32F2F);

    // Dynamic String Data Construction
    String displayName = "Guest User";
    String displayAddress = "No Address Set";
    String displaySubText = "No Room Set";
    String displayEmail = "No Email";

    if (userData != null) {
      displayName =
          "${capitalize(userData?.name?.firstName)} ${capitalize(userData?.name?.lastName)}"
              .trim();
      if (displayName.isEmpty) displayName = "User Name";
      displaySubText =
          "${unitData?.blockNumber ?? ''} - ${unitData?.flatNumber}";
      displayEmail = userData?.email ?? "No Email";

      String addr = userData?.address?.address ?? "";
      String city = userData?.address?.city ?? "";
      if (addr.isNotEmpty) {
        displayAddress = addr;
      } else if (city.isNotEmpty) {
        displayAddress = city;
      }
    }

    return Scaffold(
      backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body:
          isLoading
              ? Center(child: Loader())
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    SizedBox(height: 7.h),
                    TitleBar(title: 'My Profile', drawerCallback: () {}),
                    SizedBox(height: 3.h),
                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Color(0xf0C2B086) : blueColor,
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

                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppConstants.manropeBold,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      displaySubText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontFamily: AppConstants.manrope,
                        color: subtitleColor,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              theme.isDark
                                  ? Color(0xf02F2F2F)
                                  : Colors.grey.withValues(alpha: .2),
                        ),
                        color: theme.isDark ? Color(0xf0212121) : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        children: [
                          _buildSingleInfoCard(
                            icon: Icons.email_outlined,
                            label: "EMAIL",
                            value: displayEmail,
                            iconBg:
                                theme.isDark
                                    ? Color(0xf036342F)
                                    : Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                                theme.isDark ? Color(0xf0252525) : Colors.white,
                            isDark: isDark,
                          ),

                          SizedBox(height: 1.h), // Gap between containers

                          _buildSingleInfoCard(
                            icon: Icons.location_on_outlined,
                            label: "RESIDENCE",
                            value: displayAddress,
                            iconBg:
                                theme.isDark
                                    ? Color(0xf036342F)
                                    : Color(0xf0E9EAEF),
                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                                theme.isDark ? Color(0xf0252525) : Colors.white,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        // This makes the button slide up and fade in
                        return SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child:
                          selectedImage != null
                              ? SizedBox(
                                key: const ValueKey(
                                  "EditButton",
                                ), // Important for animation
                                width: double.infinity,
                                height: 5.h,
                                child: ElevatedButton(
                                  onPressed:
                                      isEditing ? null : () => EditProfile(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryButtonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                  ),
                                  child:
                                      isEditing
                                          ? CircularProgressIndicator(
                                            color: backgroundColor,
                                          )
                                          : Text(
                                            "Update Profile Image",
                                            style: TextStyle(
                                              color: backgroundColor,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AppConstants.manropeBold,
                                            ),
                                          ),
                                ),
                              )
                              : const SizedBox.shrink(), // Hides it when null
                    ),

                    selectedImage != null
                        ? SizedBox(height: 2.h)
                        : SizedBox.shrink(),

                    // 6. MENU SECTION
                    Container(
                      decoration: BoxDecoration(
                        color: theme.isDark ? Color(0xf0252525) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              theme.isDark
                                  ? Color(0xf0313131)
                                  : Colors.grey.withValues(alpha: .2),
                        ),
                        boxShadow:
                            isDark
                                ? []
                                : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                      ),
                      child: Column(
                        children: [
                          _buildNavTile(
                            icon: Icons.home_outlined,
                            title: "My Home",
                            subtitle: "Property details & key waivers",
                            iconBg: iconBgColor,
                            iconColor: iconColor,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            onTap: () {
                              Get.to(() => MyHome_Screen(id: widget.id));
                            },
                          ),
                          Divider(
                            color:
                                theme.isDark
                                    ? Color(0xf0313131)
                                    : Colors.grey.withValues(alpha: .2),
                            height: 1,
                            thickness: 1,
                          ),
                          _buildNavTile(
                            icon: Icons.business_outlined,
                            title: "My Building",
                            subtitle: "Building info & amenities",
                            iconBg: iconBgColor,
                            iconColor: iconColor,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            onTap: () {
                              Get.to(() => MyBuilding_Screen(id: widget.id));
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // 7. LOGOUT BUTTON
                    InkWell(
                      onTap: () => _showLogoutDialog(context),
                      borderRadius: BorderRadius.circular(90),
                      child: Container(
                        width: double.infinity,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: logoutBgColor,
                          borderRadius: BorderRadius.circular(90),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: logoutTextColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "Log Out",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppConstants.manrope,
                                color: logoutTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildSingleInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconBg),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 19.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: labelColor,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                    fontFamily: AppConstants.manrope,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 19.sp),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: subtitleColor,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.5.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FUNCTIONALITY
  // ---------------------------------------------------------------------------

  void _showLogoutDialog(BuildContext context) {
    showLogoutDialog(
      context,
      onLogoutAPI: () async {
        await Logout(); // Wait for logout to finish
      },
    );
  }

  Future<void> Logout() async {
    // 1. Check Internet
    bool internet = await checkInternet();

    if (!internet) {
      if (mounted) {
        Navigator.pop(context); // Close the dialog manually if error
        showSnackBar(
          context: context,
          title: "Error",
          message: "Internet Required",
          backgoundColor: Colors.red,
          ColorText: Colors.white,
        );
      }
      return;
    }

    // 2. Prepare Data
    final Map<String, String> data = {};
    if (loginModel?.data?.user?.id != null) {
      data["user_id"] = loginModel!.data!.user!.id.toString();
    }

    try {
      // 3. Call API
      await AuthProvider().logoutApi(data);

      // 4. Clear Data
      if (mounted) {
        await handleDataClear(context);
      }

      // 5. Navigate
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      if (mounted) {
        await handleDataClear(context);
      }
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        // showButton = true;
      });
    } else {
      showSnackBar(
        context: context,
        title: "No Image Selected",
        message: "Please choose an image.",
        backgoundColor: Colors.orange,
        ColorText: Colors.white,
      );
    }
  }

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }
}

// -----------------------------------------------------------------------------
// REUSABLE LOGOUT DIALOG FUNCTION
// -----------------------------------------------------------------------------
void showLogoutDialog(
  BuildContext context, {
  required Future<void> Function() onLogoutAPI, // Changed to Future
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LogoutDialogWidget(onLogoutAPI: onLogoutAPI),
  );
}

// -----------------------------------------------------------------------------
// LOGOUT DIALOG WIDGET (Now Stateful to handle loading)
// -----------------------------------------------------------------------------
class _LogoutDialogWidget extends StatefulWidget {
  final Future<void> Function() onLogoutAPI;

  const _LogoutDialogWidget({required this.onLogoutAPI});

  @override
  State<_LogoutDialogWidget> createState() => _LogoutDialogWidgetState();
}

class _LogoutDialogWidgetState extends State<_LogoutDialogWidget> {
  bool isDialogLoading = false; // Local state for the button loader

  @override
  Widget build(BuildContext context) {
    // 1. Theme Configuration
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    // Colors for Dialog
    final Color dialogBgColor = isDark ? const Color(0xFF1D1D1F) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade800;

    // Button Colors
    final Color yesBtnColor =
        isDark
            ? const Color(0xFFC7B283) // Gold
            : const Color(0xFF5A6385); // Blue
    final Color yesBtnTextColor = isDark ? Colors.black : Colors.white;

    final Color noBtnBgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color noBtnTextColor = isDark ? Colors.white : Colors.black;
    final Color noBtnBorderColor =
        isDark ? Colors.transparent : Colors.grey.shade300;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: PopScope(
        canPop: !isDialogLoading, // Prevent back button while loading
        child: Container(
          width: 73.w,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dialogBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 1.h),

              // TITLE
              Text(
                "Log Out",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontFamily: AppConstants.manrope,
                ),
              ),

              SizedBox(height: 1.5.h),

              // SUBTITLE
              Text(
                "Are you sure you wish to log out from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                  fontFamily: AppConstants.manrope,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 3.h),

              // BUTTONS ROW
              Row(
                children: [
                  // NO BUTTON
                  Expanded(
                    child: _buildDialogButton(
                      label: "No",
                      bgColor: noBtnBgColor,
                      textColor: noBtnTextColor,
                      borderColor: noBtnBorderColor,
                      onTap: () {
                        if (!isDialogLoading) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // YES BUTTON
                  Expanded(
                    child: _buildDialogButton(
                      label: "Yes",
                      bgColor: yesBtnColor,
                      textColor: yesBtnTextColor,
                      borderColor: Colors.transparent,
                      isLoading: isDialogLoading,
                      // Pass loading state
                      onTap: () async {
                        // 1. Start Loading
                        setState(() {
                          isDialogLoading = true;
                        });

                        // 2. Call API and Wait
                        await widget.onLogoutAPI();

                        // 3. Stop Loading (if the API failed and we are still here)
                        if (mounted) {
                          setState(() {
                            isDialogLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap, // Disable tap while loading
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 4.5.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              if (borderColor == Colors.transparent)
                BoxShadow(
                  color: bgColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child:
              isLoading
                  ? SizedBox(
                    height: 18.sp,
                    width: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                  : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
        ),
      ),
    );
  }
}

// import 'dart:developer';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Utils/customSnackBars.dart';
//
// import '../../../Utils/checkInternetConnection.dart';
// import '../../../Utils/colors.dart';
// import '../../../Utils/const.dart';
// import '../../../Utils/customAppBar.dart';
// import '../../../Utils/customBatan.dart';
// import '../../../Utils/errorDialog.dart';
// import '../../../Utils/storeUserData.dart';
// import '../../Authentication/View/loginscreen.dart';
// import '../../Authentication/provider/authenticationProvider.dart';
// import '../Provider/profileProvider.dart';
// import '../modal/profile_model.dart';
// import 'myBuildingScreen.dart';
// import 'myHomeScreen.dart';
// import 'myProfileScreen.dart';
//
// class ViewProfile extends StatefulWidget {
//   final int? id;
//
//   const ViewProfile({super.key, this.id});
//
//   @override
//   State<ViewProfile> createState() => _ViewProfileState();
// }
//
// class _ViewProfileState extends State<ViewProfile> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController genderController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController countryController = TextEditingController();
//   TextEditingController zipCodeController = TextEditingController();
//   TextEditingController fullAddressController = TextEditingController();
//   final GlobalKey<ScaffoldState> profileScreen = GlobalKey<ScaffoldState>();
//   bool isLoading = true;
//   bool isEditing = false;
//   String profileImage = "";
//   File? selectedImage;
//   bool isImageLoading = true;
//
//   void GetProfile() {
//     final Map<String, String> data = {'id': widget.id.toString()};
// log(widget.id.toString());
//     checkInternet().then((internet) async {
//       if (internet) {
//         ProfileProvider().profileApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             setState(() {
//               var profileModel = ProfileModel.fromJson(response.data);
//               if (profileModel.status == 200) {
//                 var user = profileModel.data?.user;
//                 if (user != null) {
//                   nameController.text =
//                       "${user.name?.firstName ?? ""} ${user.name?.lastName ?? ""}";
//                   emailController.text = user.email ?? "";
//                   phoneController.text = user.mobileNo.toString();
//                   genderController.text = user.gender ?? "";
//                   log('name : ${nameController.text}');
//                   var address = user.address;
//                   if (address != null) {
//                     fullAddressController.text =
//                         "${address.address ?? ""}, ${address.city ?? ""}, ${address.country ?? ""}";
//                     zipCodeController.text = address.zipCode ?? "";
//                   }
//
//                   if (user.profile != null && user.profile!.isNotEmpty) {
//                     profileImage = user.profile!;
//                   }
//                 }
//               }
//
//               isLoading = false;
//             });
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       isLoading = true;
//       isEditing = true;
//     });
//     GetProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 6.h),
//             TitleBar(
//               back: () {
//                 Get.back();
//               },
//               title: "My Profile",
//               drawerCallback: () {},
//             ),
//             SizedBox(height: 3.h),
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CircleAvatar(
//                   radius: 35.sp,
//                   backgroundColor: Colors.grey.shade300,
//                   child: ClipOval(
//                     child: CachedNetworkImage(
//                       imageUrl: profileImage,
//                       width: 70.sp,
//                       height: 70.sp,
//                       fit: BoxFit.cover,
//                       placeholder:
//                           (context, url) => const Center(
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 AppColors.maincolor,
//                               ),
//                             ),
//                           ),
//                       errorWidget:
//                           (context, url, error) => Image.asset(
//                             "assets/images/waveeLogoShort.png",
//                             width: 70.sp,
//                             height: 70.sp,
//                             fit: BoxFit.cover,
//                           ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 4.h),
//             InkWell(
//               onTap: () {
//                 Get.to(Myprofile_Screen(id: loginModel?.data?.user?.id));
//               },
//               child: Container(
//                 width: 55.w,
//                 height: 5.5.h,
//                 decoration: const BoxDecoration(
//                   color: AppColors.maincolor,
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "View Profile",
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontFamily: AppConstants.manrope,
//                       fontSize: 18.sp,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 3.h),
//             SizedBox(height: 2.h),
//             menuItem(
//               Icons.home,
//               "My Home",
//               "Details about your home",
//               context,
//               MyHome_Screen(id: loginModel?.data?.user?.id),
//             ),
//             const SizedBox(height: 10),
//             menuItem(
//               Icons.apartment,
//               "My Building",
//               "Details about your building",
//               context,
//               MyBuilding_Screen(id: loginModel?.data?.user?.id),
//             ),
//             SizedBox(height: 2.h),
//             batan(
//               title: "Log out",
//               route: () {
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (BuildContext context) {
//                     bool isLoading = false;
//
//                     return StatefulBuilder(
//                       builder: (context, setState) {
//                         return Dialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           backgroundColor: Colors.transparent,
//                           child: Container(
//                             width: 73.w,
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: AppColors.white,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(height: 2.h),
//                                 Text(
//                                   "Log out",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 18.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.black,
//                                     fontFamily: AppConstants.manrope,
//                                   ),
//                                 ),
//                                 SizedBox(height: 1.5.h),
//                                 Text(
//                                   'Are you sure you want to log out of your account?',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     color: Colors.grey.shade800,
//                                     fontFamily: AppConstants.manrope,
//                                   ),
//                                 ),
//                                 SizedBox(height: 2.h),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Material(
//                                         elevation: 2,
//                                         borderRadius: BorderRadius.circular(12),
//                                         child: batan(
//                                           title: "No",
//                                           route: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           color: AppColors.white,
//                                           fontcolor: Colors.black,
//                                           height: 5.h,
//                                           width: 20.w,
//                                           fontsize: 16.sp,
//                                           radius: 12.0,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 2.w),
//                                     Expanded(
//                                       child: Material(
//                                         elevation: 2,
//                                         borderRadius: BorderRadius.circular(12),
//                                         child: batan(
//                                           title: "Yes",
//                                           width: 20.w,
//                                           route: () async {
//                                             await SaveDataLocal.clearUserData();
//                                             Get.offAll(
//                                               () => const LoginScreen(),
//                                             );
//                                             Logout();
//                                           },
//                                           color: AppColors.maincolor,
//                                           fontcolor: Colors.white,
//                                           height: 5.h,
//                                           fontsize: 16.sp,
//                                           radius: 12.0,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 1.h),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//               color: AppColors.maincolor,
//               fontcolor: AppColors.white,
//               height: 5.h,
//               width: 40.w,
//               fontsize: 18.sp,
//               radius: 12.0,
//             ),
//           ],
//         ),
//       ).paddingOnly(right: 3.w, left: 3.w),
//     );
//   }
//
//   Widget menuItem(
//     IconData icon,
//     String title,
//     String description,
//     BuildContext context,
//     Widget screen,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: AppColors.maincolor, size: 30),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 17.sp,
//             fontWeight: FontWeight.w600,
//             fontFamily: AppConstants.manropeBold,
//           ),
//         ),
//         subtitle: Text(
//           description,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.grey,
//             fontFamily: AppConstants.manrope,
//           ),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           size: 18,
//           color: Colors.grey,
//         ),
//         onTap: () {
//           Get.to(screen);
//         },
//       ),
//     );
//   }
//
//   Future<void> pickImage() async {
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         showSnackBar(
//           context: context,
//           title: "Permission Denied",
//           message: "Please enable storage permission from settings",
//           backgoundColor: AppColors.redColor,
//           ColorText: Colors.white,
//         );
//
//         return;
//       }
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//
//     if (pickedFile != null) {
//       setState(() {
//         selectedImage = File(pickedFile.path);
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void toggleEdit() {
//     if (isEditing) {
//       // EditProfile();
//     } else {
//       setState(() {
//         isEditing = true;
//       });
//     }
//   }
//
//   void Logout() {
//     final Map<String, String> data = {};
//     data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await AuthProvider().logoutApi(data);
//           if (response.statusCode == 200) {
//             setState(() {
//               isLoading = false;
//             });
//             handleDataClear(context);
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
