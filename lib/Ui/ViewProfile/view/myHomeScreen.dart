import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/customSnackBars.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/loader.dart';
import '../../../Utils/viewPdfFunction.dart';
import '../Provider/profileProvider.dart';
import '../modal/profile_model.dart';

class MyHome_Screen extends StatefulWidget {
  final int? id;

  const MyHome_Screen({super.key, this.id});

  @override
  State<MyHome_Screen> createState() => _MyHome_ScreenState();
}

class _MyHome_ScreenState extends State<MyHome_Screen> {
  final GlobalKey<ScaffoldState> Myhome = GlobalKey<ScaffoldState>();
  TextEditingController keyWaiversController = TextEditingController();
  bool isLoading = true;
  bool isEditing = false;
  ProfileModel? profileModel;
  String fullAddress = "";
  String propertyDetails = "";

  List<Map<String, String>> _getFilteredDocuments(
    List<String>? documents,
    List<String>? labels,
  ) {
    if (documents == null) return [];

    List<Map<String, String>> filteredDocs = [];
    for (int i = 0; i < documents.length; i++) {
      if (documents[i].isNotEmpty) {
        String label =
            (labels != null && i < labels.length && labels[i].isNotEmpty)
                ? labels[i]
                : 'Document ${filteredDocs.length + 1}';
        filteredDocs.add({'url': documents[i], 'label': label});
      }
    }
    return filteredDocs;
  }

  @override
  void initState() {
    super.initState();
    GetProfile();
  }

  Future<void> GetProfile() async {
    setState(() => isLoading = true);
    final Map<String, String> data = {'id': widget.id.toString()};

    checkInternet().then((internet) async {
      if (!internet) {
        setState(() => isLoading = false);
        showSnackBar(
          context: context,
          title: 'Error',
          message: 'Internet Required',
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );
        return;
      }

      final response = await ProfileProvider().profileApi(data);
      if (response.statusCode == 200) {
        setState(() {
          profileModel = ProfileModel.fromJson(response.data);
          if (profileModel?.status == 200) {
            var user = profileModel?.data?.user;
            var unit = profileModel?.data?.unit;

            bool isValid(String? value) =>
                value != null && value.trim().isNotEmpty && value != "N/A";

            List<String> addressParts = [];
            if (isValid(unit?.blockNumber)) {
              addressParts.add(unit!.blockNumber!);
            }
            if (isValid(unit?.flatNumber)) addressParts.add(unit!.flatNumber!);
            if (isValid(user?.address?.address)) {
              addressParts.add(user!.address!.address!);
            }
            if (isValid(user?.address?.city)) {
              addressParts.add(user!.address!.city!);
            }
            if (isValid(user?.address?.country)) {
              addressParts.add(user!.address!.country!);
            }
            if (isValid(user?.address?.zipCode)) {
              addressParts.add(user!.address!.zipCode!);
            }

            fullAddress = addressParts.join(', ');
            propertyDetails = [
              if (isValid(unit?.blockNumber)) unit!.blockNumber!,
              if (isValid(unit?.flatNumber)) unit!.flatNumber!,
            ].join(" - ");

            keyWaiversController.text =
                isValid(unit?.keyWaiver) ? unit!.keyWaiver! : "";
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  void EditProfile() async {
    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      "keywaivers": keyWaiversController.text.trim(),
      "apartment_number": profileModel?.data?.unitsId.toString() ?? '',
    };

    checkInternet().then((internet) async {
      if (!internet) {
        showSnackBar(
          context: context,
          title: 'Error',
          message: 'Internet Required',
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );

        return;
      }

      setState(() => isEditing = true);
      try {
        final response = await ProfileProvider().updateProfile(data);

        if (response.statusCode == 200) {
          var updatedModel = ProfileModel.fromJson(response.data);
          if (updatedModel.status == 200) {
            showSnackBar(
              context: context,
              title: 'Success',
              message: 'Key waivers updated successfully',
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );

            GetProfile();
            // Get.offAll(HomePage(userName: ""));
          } else {
            showSnackBar(
              context: context,
              title: 'Error',
              message: updatedModel.message ?? "Update failed",
              backgoundColor: AppColors.redColor,
              ColorText: Colors.white,
            );
          }
        } else {
          showSnackBar(
            context: context,
            title: 'Error',
            message: 'Server Error',
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
          );
        }
      } catch (e) {
        showSnackBar(
          context: context,
          title: 'Error',
          message: 'An error occurred: $e',
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );
      } finally {
        setState(() => isEditing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apartmentDocs = _getFilteredDocuments(
      profileModel?.data?.unit?.documentsFiles,
      profileModel?.data?.unit?.documentsFilesLabel,
    );

    final buildingDocs = _getFilteredDocuments(
      profileModel?.data?.buildingDocument?.documentsFiles,
      profileModel?.data?.buildingDocument?.documentsFilesLabel,
    );

    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    final Color backgroundColor =
        isDark ? const Color(0xFF111214) : const Color(0xFFF2F4F7);
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
    final Color iconColor = isDark ? goldColor : blueColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 7.h),
                  TitleBar(
                    back: () => Get.back(),
                    title: "My Home",
                    drawerCallback: () {},
                  ),
                  SizedBox(height: 3.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSingleInfoCard(
                            icon: Icons.location_on,
                            label: "Property Address",
                            value: fullAddress,
                            iconBg:
                                theme.isDark
                                    ? Color(0xf036342F)
                                    : Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                          _buildSingleInfoCard(
                            icon: Icons.apartment,
                            label: "Property Details",
                            value: propertyDetails,
                            iconBg:
                                theme.isDark
                                    ? Color(0xf036342F)
                                    : Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),

                          // 🔑 Key Waivers (Premium Editable Card)
                          Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(16),

                            child: Container(
                              // margin: EdgeInsets.only(bottom: 2.h),
                              decoration: BoxDecoration(
                                color: cardBackgroundColor,
                                border: Border.all(color: iconBgColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.5.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 11.w,
                                          height: 11.w,
                                          decoration: BoxDecoration(
                                            color:
                                                theme.isDark
                                                    ? Color(0xf036342F)
                                                    : Color(0xf0E9EAEF),

                                            borderRadius: BorderRadius.circular(
                                              90,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.vpn_key_rounded,
                                            color: iconColor,
                                            size: 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          "Key Waivers",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 16.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                theme.isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "You can edit your key waiver information below:",
                                      style: TextStyle(
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 15.sp,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: iconBgColor.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: keyWaiversController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        maxLines: 2,
                                        cursorColor: AppColors.maincolor,
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 15.sp,
                                          color: iconColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              "Enter your key waiver details...",
                                          hintStyle: TextStyle(
                                            color: titleColor,
                                            fontSize: 15.sp,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: EditProfile,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.w,
                                            vertical: 1.2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: iconColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.save_rounded,
                                                color: backgroundColor,
                                                size: 16.sp,
                                              ),
                                              SizedBox(width: 1.w),
                                              Text(
                                                "Save",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontSize: 15.sp,
                                                  color: backgroundColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).marginOnly(bottom: 1.h),

                          SizedBox(height: 1.h),
                          if (apartmentDocs.isNotEmpty) ...[
                            Text(
                              "Apartment Documents",
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    theme.isDark ? Colors.white : Colors.black,

                                fontFamily: AppConstants.manrope,
                              ),
                            ).paddingOnly(bottom: 1.h),

                            GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: apartmentDocs.length,
                              itemBuilder: (context, index) {
                                final doc = apartmentDocs[index];
                                return GestureDetector(
                                  onTap:
                                      () => Get.to(PdfView(link: doc['url']!)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 8.5.h,
                                        width: 18.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: iconBgColor.withValues(
                                            alpha: 0.05,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: iconColor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: iconColor,
                                          size: 30.sp,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Expanded(
                                        child: Text(
                                          doc['label']!,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: iconColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],

                          /// 🏢 Building Documents
                          if (buildingDocs.isNotEmpty) ...[
                            Text(
                              "Building Documents",
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    theme.isDark ? Colors.white : Colors.black,

                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,

                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: buildingDocs.length,
                              itemBuilder: (context, index) {
                                final doc = buildingDocs[index];
                                return GestureDetector(
                                  onTap:
                                      () => Get.to(PdfView(link: doc['url']!)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 8.5.h,
                                        width: 18.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: iconBgColor.withValues(
                                            alpha: 0.05,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: iconColor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: iconColor,
                                          size: 30.sp,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Expanded(
                                        child: Text(
                                          doc['label']!,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: iconColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  /// 💾 Save Button
                  SizedBox(height: 5.h),
                ],
              ).paddingOnly(left: 3.w, right: 3.w),
          if (isEditing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

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
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
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
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: labelColor,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value == '' ? "--" : value,
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

  Widget infoCard(String label, String value, IconData icon) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.maincolor,
              ),
              child: Icon(icon, size: 18.sp, color: Colors.white),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.8.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    value.isNotEmpty ? value : "—",
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      fontSize: 15.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).marginOnly(bottom: 1.5.h);
  }
}
