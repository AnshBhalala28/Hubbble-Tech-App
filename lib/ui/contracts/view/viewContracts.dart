import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';
import 'package:wavee/utils/customDialog.dart';

class ViewContracts extends StatefulWidget {
  const ViewContracts({super.key});

  @override
  State<ViewContracts> createState() => _ViewContractsState();
}

class _ViewContractsState extends State<ViewContracts> {
  final Color kDarkBackground = const Color(0xFF1E1E1E);
  final Color kDarkBorder = const Color(0xFF333333);

  final TextEditingController contractsTitle = TextEditingController();

  File? selectedImage;

  Future<void> pickImage(Function setModalState) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setModalState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  List<ContractFile> files = [
    ContractFile(title: "tesin", fileName: "Screenshot_2026-05-01.jpg"),
    ContractFile(title: "hdjcd", fileName: "Screenshot_2026-05-01.jpg"),
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
              addContracts(context);
            },
            label: SizedBox(
              width: 30.w,
              child: Text(
                "Add Contracts",
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
                title: "Contracts",
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
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xf0252525) : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                              isDark
                                  ? Color(
                                0xFFCFB583,
                              ).withValues(alpha: 0.2)
                                  : Color(
                                0xFF4C5588,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              color:
                              isDark
                                  ? const Color(0xFFCFB583)
                                  : const Color(0xFF4C5588),
                              size: 20.sp,
                            ),
                          ),

                          SizedBox(width: 3.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                  fontFamily: AppConstants.manropeBold,
                                    fontSize: 15.sp,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),

                                SizedBox(height: 0.5.h),

                                Text(
                                  item.fileName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                    fontFamily: AppConstants.manropeSemiBold,
                                  ),
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {

                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            size: 18.sp,
                                            color:
                                                theme.isDark
                                                    ? Color(0xffCBB88C)
                                                    : AppColors.lightText,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            "View",
                                            style: TextStyle(
                                              color:
                                                  theme.isDark
                                                      ? Color(0xffCBB88C)
                                                      : AppColors.lightText,
                                              fontFamily: AppConstants.manropeSemiBold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 6.w),

                                    GestureDetector(
                                      onTap: () {

                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.download,
                                            size: 18.sp,
                                            color: theme.isDark ? Color(0xffCBB88C) : AppColors.lightText,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            "Download",
                                            style: TextStyle(
                                              color: theme.isDark ? Color(0xffCBB88C) : AppColors.lightText,
                                              fontSize: 14.sp,
                                              fontFamily: AppConstants.manropeSemiBold,
                                            ),
                                          ),
                                        ],
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
                                    title: "Delete Contract",
                                    message: "Are you sure you want to delete this contract?",
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
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20.sp,
                            ),
                          ),
                        ],
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

  void addContracts(BuildContext parentContext) {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final isDark = theme.isDark;

    selectedImage = null;
    contractsTitle.clear();

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
                          Icons.description,
                          color:
                              theme.isDark
                                  ? Color(0xffCBB88C)
                                  : AppColors.maincolor,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Add Contracts",
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
                              "Title",
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
                              controller: contractsTitle,
                              hint: "Enter Title",
                              iconPath: AppConstants.title,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Title required";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 2.h),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Upload Image",
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

                                GestureDetector(
                                  onTap: () => pickImage(setModalState),
                                  child: Container(
                                    height: 18.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Color(0xFF1E1E1E)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child:
                                        selectedImage == null
                                            ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  size: 24.sp,
                                                  color:
                                                      isDark
                                                          ? Colors.white54
                                                          : Colors.grey,
                                                ),
                                                SizedBox(height: 1.h),
                                                Text(
                                                  "Tap to upload image",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white70
                                                            : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.file(
                                                selectedImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                  ),
                                ),

                                SizedBox(height: 2.h),
                              ],
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
                                ? Color(0xffCBB88C)
                                : AppColors.lightText,
                        foregroundColor:
                            theme.isDark ? Colors.black : Colors.white,
                        minimumSize: Size(double.infinity, 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Add Contract",
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

class ContractFile {
  String title;
  String fileName;

  ContractFile({required this.title, required this.fileName});
}
