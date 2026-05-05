import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';
import 'package:wavee/utils/customBatan.dart';
import 'package:wavee/utils/customDialog.dart';

class ViewAccommodation extends StatefulWidget {
  const ViewAccommodation({super.key});

  @override
  State<ViewAccommodation> createState() => _ViewAccommodationState();
}

class _ViewAccommodationState extends State<ViewAccommodation> {
  final Color kDarkBackground = const Color(0xFF1E1E1E);
  final Color kDarkBorder = const Color(0xFF333333);

  final TextEditingController guestsName = TextEditingController();
  final TextEditingController numberOfRooms = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController link = TextEditingController();

  List<TextEditingController> guestControllers = [TextEditingController()];

  List<Accommodation> files = [
    Accommodation(
      title: "tesin",
      note: "testing jbo",
      link: "www.link.com",
      roomNum: "250",
    ),
    Accommodation(
      title: "hdjcd",
      note: "testing jbo",
      link: "www.link.com",
      roomNum: "250",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      floatingActionButton: Row(
        children: [
          Spacer(),
          FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(900),
            ),
            backgroundColor: theme.isDark ? Color(0xffCBB88C) : Colors.white,
            onPressed: () {
              addAccommodation(context);
            },
            label: SizedBox(
              width: 30.w,
              child: Text(
                "Add Accommodation",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.5.sp,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () => Get.back(),
                title: "Accommodation",
                drawerCallback: () {},
              ),
              SizedBox(height: 2.h),

              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final item = files[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.white10
                                  : Colors.grey.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.05,
                            ),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Left Side Icon Container ---
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            isDark
                                                ? [
                                                  Color(
                                                    0xFFCFB583,
                                                  ).withOpacity(0.2),
                                                  Color(
                                                    0xFFCFB583,
                                                  ).withOpacity(0.05),
                                                ]
                                                : [
                                                  Color(
                                                    0xFF4C5588,
                                                  ).withOpacity(0.15),
                                                  Color(
                                                    0xFF4C5588,
                                                  ).withOpacity(0.05),
                                                ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.apartment_rounded,
                                      color:
                                          isDark
                                              ? Color(0xFFCFB583)
                                              : Color(0xFF4C5588),
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 15),

                                  // --- Content Section ---
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontFamily:
                                                AppConstants.manropeBold,
                                            fontSize: 15.sp,
                                            letterSpacing: 0.5,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.note,
                                              size: 18.sp,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              item.note,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey,
                                                fontFamily:
                                                    AppConstants
                                                        .manropeSemiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return LogoutDialogWidget(
                                            title: "Delete Accommodation",
                                            message:
                                                "Are you sure you want to delete this Accommodation?",
                                            yesText: "Delete",
                                            noText: "Cancel",

                                            onNoTap: () {
                                              Navigator.pop(context);
                                            },

                                            onYesTap: () async {
                                              log("Deleted");

                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- Bottom Info Bar (Premium Look) ---
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.03)
                                        : Colors.grey.withOpacity(0.05),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildBottomInfo(
                                      Icons.meeting_room_outlined,
                                      "Room: ${item.roomNum}",
                                      isDark,
                                    ),
                                    VerticalDivider(
                                      color: Colors.grey.withOpacity(0.2),
                                      thickness: 1,
                                    ),
                                    _buildBottomInfo(
                                      Icons.link_rounded,
                                      "View Link",
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(IconData icon, String text, bool isDark) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isDark ? Color(0xFFCFB583) : Color(0xFF4C5588),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppConstants.manropeSemiBold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addAccommodation(BuildContext parentContext) {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.isDark ? const Color(0xFF252525) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),

              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color:
                              theme.isDark
                                  ? Color(0xffCBB88C)
                                  : AppColors.maincolor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Add Accommodation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Guests Name",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1.h),

                            Column(
                              children: List.generate(guestControllers.length, (
                                index,
                              ) {
                                return Row(
                                  children: [
                                    /// ✅ TextField
                                    Expanded(
                                      child: _buildTextField(
                                        context: context,
                                        controller: guestControllers[index],
                                        hint: "Enter Guests Name",
                                        iconPath: AppConstants.guests,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Guests Name required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    SizedBox(width: 2.w),

                                    GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (index == 0) {
                                            guestControllers.add(
                                              TextEditingController(),
                                            );
                                          } else {
                                            guestControllers.removeAt(index);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        // circle size control
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              theme.isDark
                                                  ? Color(0xffCBB88C)
                                                  : AppColors
                                                      .lightText, // ❌ background
                                        ),
                                        child: Icon(
                                          index == 0
                                              ? Icons.add_circle_outline
                                              : Icons.remove_circle_outline,
                                          color:
                                              theme.isDark
                                                  ? Colors.black
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).paddingOnly(bottom: 2.h);
                              }),
                            ),

                            Text(
                              "Number of Rooms",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildTextField(
                              context: context,
                              controller: numberOfRooms,
                              hint: "Enter Your Rooms",
                              keyboardType: TextInputType.number,
                              iconPath: AppConstants.rooms,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Your Rooms required";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 2.h),
                            Text(
                              "Note",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildTextField(
                              context: context,
                              controller: note,
                              maxLines: 3,
                              hint: "Enter Your Note",
                              keyboardType: TextInputType.text,
                              iconPath: AppConstants.note,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Your Note required";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 1.h),

                            Text(
                              "Link",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? Colors.white70
                                        : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildTextField(
                              context: context,
                              controller: link,
                              hint: "Enter Your Link",
                              keyboardType: TextInputType.text,
                              iconPath: AppConstants.link,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Your Link required";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // addFitnessProgrammeApi();
                          Get.back();
                        } else {
                          print("Form Invalid");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.isDark
                                ? const Color(0xffCBB88C)
                                : AppColors.lightText,
                        foregroundColor:
                            theme.isDark ? Colors.black : Colors.white,
                        minimumSize: Size(double.infinity, 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Add Accommodation",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

class Accommodation {
  String title;
  String roomNum;
  String note;
  String link;

  Accommodation({
    required this.title,
    required this.roomNum,
    required this.note,
    required this.link,
  });
}
