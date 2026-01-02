import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/loader.dart';
import '../../../Utils/viewPdfFunction.dart';
import '../Provider/profileProvider.dart';
import '../modal/profile_model.dart';

class MyBuilding_Screen extends StatefulWidget {
  final int? id;

  const MyBuilding_Screen({super.key, this.id});

  @override
  State<MyBuilding_Screen> createState() => _MyBuilding_ScreenState();
}

class _MyBuilding_ScreenState extends State<MyBuilding_Screen> {
  final GlobalKey<ScaffoldState> Mybuilding = GlobalKey<ScaffoldState>();
  TextEditingController myBuilingname = TextEditingController();
  TextEditingController conciergeInfoController = TextEditingController();
  TextEditingController parkingInfoController = TextEditingController();
  TextEditingController fitnessController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController landline = TextEditingController();
  TextEditingController number = TextEditingController();
  bool isLoading = false;
  ProfileModel? profileModel;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    final Color backgroundColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F4F7);
    final Color cardBackgroundColor =
        isDark ? const Color(0xFF252525) : Colors.white;

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
        isDark ? Color(0xf02F2F2F) : blueColor.withValues(alpha: 0.15);

    final Color iconColor = isDark ? Color(0xf0CBB88C) : blueColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          TitleBar(
            back: () => Get.back(),
            title: "My Building",
            drawerCallback: () {},
          ),
          SizedBox(height: 2.h),

          isLoading
              ? Center(child: Loader().paddingOnly(top: 20.h))
              : Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: iconBgColor),
                    ),
                    child: Column(
                      children: [
                        _buildSingleInfoCard(
                          icon: Icons.apartment,
                          label: "Building Name",
                          value: capitalize(myBuilingname.text),
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
                          icon: Icons.location_on,
                          label: "Address",
                          value: addressController.text,
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
                          icon: Icons.phone_enabled_rounded,
                          label: "Landline Number",
                          value: landline.text,
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
                          icon: Icons.phone,
                          label: "Additional Number",
                          value: number.text,
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
                          icon: Icons.local_parking,
                          label: "Parking Info",
                          value: parkingInfoController.text,
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
                          icon: Icons.support_agent,
                          label: "Concierge Info",
                          value: conciergeInfoController.text,
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
                          icon: Icons.fitness_center,
                          label: "Fitness Centre",
                          value: fitnessController.text,
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

                        if ((profileModel
                                ?.data
                                ?.buildingDocument
                                ?.emergencyNumbers
                                ?.isNotEmpty ??
                            false))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),
                              Text(
                                "Emergency Numbers",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              ...List.generate(
                                profileModel!
                                    .data!
                                    .buildingDocument!
                                    .emergencyNumbers!
                                    .length,
                                (index) {
                                  final number =
                                      profileModel!
                                          .data!
                                          .buildingDocument!
                                          .emergencyNumbers![index];
                                  final caption =
                                      (profileModel!
                                                      .data!
                                                      .buildingDocument!
                                                      .emergencyCaptions !=
                                                  null &&
                                              index <
                                                  profileModel!
                                                      .data!
                                                      .buildingDocument!
                                                      .emergencyCaptions!
                                                      .length)
                                          ? profileModel!
                                              .data!
                                              .buildingDocument!
                                              .emergencyCaptions![index]
                                          : "Emergency ${index + 1}";
                                  return _buildSingleInfoCard(
                                    icon: Icons.phone_paused_rounded,
                                    label: caption,
                                    value: number,
                                    iconBg:
                                        theme.isDark
                                            ? Color(0xf036342F)
                                            : Color(0xf0E9EAEF),

                                    iconColor: iconColor,
                                    labelColor: subtitleColor,
                                    valueColor: titleColor,
                                    cardColor: cardBackgroundColor,
                                    isDark: isDark,
                                  );
                                },
                              ),
                            ],
                          ),

                        if (profileModel
                                    ?.data
                                    ?.buildingDocument
                                    ?.documentsFiles !=
                                null &&
                            profileModel!
                                .data!
                                .buildingDocument!
                                .documentsFiles!
                                .any((url) => url.isNotEmpty))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 3.h),
                              Text(
                                "Building Documents",
                                style: TextStyle(
                                  fontFamily: AppConstants.manropeBold,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount:
                                    profileModel!
                                        .data!
                                        .buildingDocument!
                                        .documentsFiles!
                                        .length,
                                itemBuilder: (context, index) {
                                  final documentUrl =
                                      profileModel!
                                          .data!
                                          .buildingDocument!
                                          .documentsFiles![index];
                                  final labels =
                                      profileModel!
                                          .data!
                                          .buildingDocument!
                                          .documentsFilesLabel;
                                  if (documentUrl.isEmpty) {
                                    return const SizedBox();
                                  }

                                  String label =
                                      (labels != null && index < labels.length)
                                          ? labels[index]
                                          : 'Document ${index + 1}';
                                  String finalLabel =
                                      label.isNotEmpty
                                          ? label[0].toUpperCase() +
                                              label.substring(1)
                                          : 'Document ${index + 1}';

                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            Get.to(PdfView(link: documentUrl)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 7.h,
                                          width: 15.w,
                                          decoration: BoxDecoration(
                                            color: iconBgColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  theme.isDark
                                                      ? Color(0xf036342F)
                                                      : AppColors.maincolor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.picture_as_pdf,
                                            color: iconColor,
                                            size: 26.sp,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          finalLabel,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: iconColor,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ).paddingOnly(left: 3.w, right: 3.w),
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
                    fontSize: 16.sp,
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

  // ========== FETCH PROFILE DATA ==========
  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                profileModel = ProfileModel.fromJson(response.data);
                final building = profileModel?.data?.buildingDocument;

                myBuilingname.text = building?.buildingName ?? "";
                addressController.text = building?.address ?? "";
                parkingInfoController.text = building?.parkingInformation ?? "";
                conciergeInfoController.text =
                    building?.conciergeInformation ?? "";
                fitnessController.text =
                    building?.fitnessCentreInformation ?? "";
                landline.text = profileModel?.data?.building?.landline ?? "";
                number.text = profileModel?.data?.building?.mobile ?? "";
                isLoading = false;
              });
            }
          } else {
            isLoading = false;
          }
        });
      } else {
        isLoading = false;
      }
    });
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
