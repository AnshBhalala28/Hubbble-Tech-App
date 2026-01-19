import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/customInputDecoration.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../Provider/maintenanceProvider.dart';
import '../modal/maintenanceDetailsModel.dart';
import '../modal/maintenance_modal.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final GlobalKey<ScaffoldState> maintanceKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  List<String> categories = ['Pending', 'In Review', 'Completed'];
  int selectedCategory = 0;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? dateErrorText;
  bool isDetailLoading = false;

  // bool theme.isDark = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    AllMaintenanceApi();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.isDark ? Color(0xff1A1A1A) : AppColors.white,

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TitleBar(
                  back: () {
                    Get.back();
                  },
                  title: 'Maintenance',
                  drawerCallback: () {},
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 5.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final isSelected = selectedCategory == index;

                        return GestureDetector(
                          onTap: () {
                            if (!isSelected) {
                              setState(() {
                                selectedCategory = index;
                                isLoading = true;
                              });
                              AllMaintenanceApi();
                            }
                          },
                          child: Container(
                            height: 6.h,
                            padding: EdgeInsets.symmetric(
                              vertical: 1.h,
                              horizontal: 5.w,
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 1.2.w),
                            decoration: BoxDecoration(
                              color:
                              theme.isDark
                                  ? isSelected
                                  ? AppColors.white
                                  : const Color(0xFF212121)
                                  : isSelected
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.grey.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(
                                25,
                              ), // image ma more round
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 16.sp,
                                color:
                                    theme.isDark
                                        ? (isSelected
                                            ? Colors.black
                                            : Colors.grey.shade300)
                                        : (isSelected
                                            ? Colors.white
                                            : Colors.black),
                                fontFamily:
                                    isSelected
                                        ? AppConstants.manropeBold
                                        : AppConstants.manrope,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                isLoading
                    ? Loader().paddingOnly(top: 20.h)
                    : maintenanceModel?.data?.data?.length == null ||
                        maintenanceModel?.data?.data?.length == 0
                    ? Center(
                      child: Text(
                        "No Maintenance Available",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color:theme.isDark? AppColors.white:AppColors.black,
                          fontFamily: AppConstants.manrope,
                        ),
                      ).paddingOnly(top: 30.h),
                    )
                    : SizedBox(
                      child: Column(
                        children: [
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   scrollDirection: Axis.vertical,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   padding: EdgeInsets.zero,
                          //   itemCount:
                          //       maintenanceModel?.data?.data?.length ?? 0,
                          //   itemBuilder: (context, index) {
                          //     var booking =
                          //         maintenanceModel?.data?.data?[index];
                          //     return GestureDetector(
                          //       onTap: () {
                          //         MaintenanceDetailApi(
                          //           booking?.id.toString() ?? "",
                          //         );
                          //       },
                          //       child: Container(
                          //         decoration: BoxDecoration(
                          //           color:
                          //               theme.isDark
                          //                   ? Color(0xff242424)
                          //                   : Colors.white,
                          //           borderRadius: BorderRadius.circular(20),
                          //           boxShadow:
                          //               theme.isDark
                          //                   ? [] // Dark mode ma box shadow nahi aavse
                          //                   : [
                          //                     BoxShadow(
                          //                       color: Colors.grey.withValues(
                          //                         alpha: 0.2,
                          //                       ),
                          //                       spreadRadius: 2,
                          //                       blurRadius: 5,
                          //                       offset: const Offset(0, 3),
                          //                     ),
                          //                   ],
                          //         ),
                          //         margin: EdgeInsets.symmetric(
                          //           horizontal: 1.w,
                          //           vertical: 1.h,
                          //         ),
                          //         padding: const EdgeInsets.all(12),
                          //         child: Row(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             SizedBox(width: 2.h),
                          //             Expanded(
                          //               child: Stack(
                          //                 children: [
                          //                   Align(
                          //                     alignment: Alignment.centerLeft,
                          //                     child: Column(
                          //                       crossAxisAlignment:
                          //                           CrossAxisAlignment.start,
                          //                       children: [
                          //                         Text(
                          //                           formatDateTime(
                          //                             booking?.createdAt ?? "",
                          //                           ),
                          //                           style: TextStyle(
                          //                             fontSize: 13,
                          //                             fontWeight:
                          //                                 FontWeight.w600,
                          //                             color:
                          //                                 theme.isDark
                          //                                     ? Colors.white
                          //                                     : Colors.black54,
                          //                             fontFamily:
                          //                                 AppConstants
                          //                                     .manropeBold,
                          //                           ),
                          //                         ),
                          //                         const SizedBox(height: 4),
                          //                         SizedBox(
                          //                           width: 70.w,
                          //
                          //                           child: Text(
                          //                             booking
                          //                                     ?.subject
                          //                                     ?.capitalizeFirst ??
                          //                                 '',
                          //                             maxLines: 2,
                          //                             style: TextStyle(
                          //                               fontSize: 16.sp,
                          //                               fontWeight:
                          //                                   FontWeight.w500,
                          //                               fontFamily:
                          //                                   AppConstants
                          //                                       .manropeBold,
                          //                               color:
                          //                                   theme.isDark
                          //                                       ? Colors.white
                          //                                       : Colors
                          //                                           .black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                         const SizedBox(height: 4),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                   Align(
                          //                     alignment: Alignment.topRight,
                          //                     child: Row(
                          //                       mainAxisSize: MainAxisSize.min,
                          //                       children: [
                          //                         Container(
                          //                           padding:
                          //                               EdgeInsets.symmetric(
                          //                                 horizontal: 10,
                          //                                 vertical: 4,
                          //                               ),
                          //                           decoration: BoxDecoration(
                          //                             color:
                          //                                 theme.isDark
                          //                                     ? Color(
                          //                                       0xff3f3c35,
                          //                                     )
                          //                                     : getStatusColor(
                          //                                       booking?.status ??
                          //                                           '',
                          //                                     ),
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                   10,
                          //                                 ),
                          //                           ),
                          //                           child: Text(
                          //                             booking?.status ==
                          //                                     "status_in_review"
                          //                                 ? "In Review"
                          //                                 : booking?.status
                          //                                         .toString()
                          //                                         .capitalizeFirst ??
                          //                                     "",
                          //                             style: TextStyle(
                          //                               fontSize: 13,
                          //                               fontWeight:
                          //                                   FontWeight.bold,
                          //                               color:
                          //                                   theme.isDark
                          //                                       ? Color(
                          //                                         0xffCBB88C,
                          //                                       )
                          //                                       : Colors.white,
                          //                               fontFamily:
                          //                                   AppConstants
                          //                                       .manrope,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount:
                                maintenanceModel?.data?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              var booking =
                                  maintenanceModel?.data?.data?[index];
                              Color statusColor = getStatusColor(
                                booking?.status ?? '',
                              );

                              return GestureDetector(
                                onTap: () {
                                  MaintenanceDetailApi(
                                    booking?.id.toString() ?? "",
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 1.w,
                                    vertical: 1.h,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.isDark
                                            ? const Color(0xff252525)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow:
                                        theme.isDark
                                            ? []
                                            : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Status Icon with background
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: .2,
                                          ),
                                          // borderRadius: BorderRadius.circular(15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getStatusIcon(booking?.status ?? ''),
                                          color: statusColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  formatDate(
                                                    booking?.createdAt,
                                                  ),
                                                  // Updated Date Helper
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                                _buildMiniBadge(
                                                  booking?.status ?? '',
                                                  theme,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              booking
                                                      ?.subject
                                                      ?.capitalizeFirst ??
                                                  '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15.5.sp,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manropeBold,
                                                color:
                                                    theme.isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "ID: #${booking?.id ?? '00'}",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontFamily:
                                                    AppConstants.manrope,

                                                color:
                                                    theme.isDark
                                                        ? Colors.white54
                                                        : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color:
                                            theme.isDark
                                                ? Colors.white24
                                                : Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
              ],
            ).paddingSymmetric(horizontal: 3.w),
          ),
          if (isDetailLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      floatingActionButton:
          isLoading
              ? Container()
              : Row(
                children: [
                  const Spacer(),
                  FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(900),
                    ),
                    backgroundColor:
                        theme.isDark ? Color(0xffCBB88C) : Colors.white,
                    onPressed: () {
                      showAddRequestBottomSheet(context);
                    },
                    label: SizedBox(
                      width: 44.w,
                      child: Text(
                        "Add Maintenance Request ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // FloatingActionButton.extended(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(900)),
                  //   backgroundColor: Colors.white,
                  //   onPressed: () {
                  //     Get.to(() => const ChatBotScreen());
                  //   },
                  //   icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
                  //   label: Text(
                  //     "Ai Concierge",
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 15.sp,
                  //         fontFamily: AppConstants.manrope),
                  //   ),
                  // ),
                ],
              ),
    );
  }

  IconData _getStatusIcon(String status) {
    status = status.toLowerCase();
    if (status.contains('pending')) return Icons.hourglass_top_rounded;
    if (status.contains('review')) return Icons.find_in_page_rounded;
    if (status.contains('completed')) return Icons.check_circle_rounded;
    return Icons.build_circle_rounded;
  }

  Widget _buildMiniBadge(String status, var theme) {
    Color sColor = getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color:
            theme.isDark
                ? Colors.white.withOpacity(0.05)
                : sColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status == "status_in_review"
            ? "In Review"
            : status.capitalizeFirst ?? "",
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppConstants.manropeBold,
          color: theme.isDark ? const Color(0xffCBB88C) : sColor,
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    return status == "pending" || status == "Pending"
        ? Color(0xf0BEAC84)
        : status == "Status_in_review" || status == "status_in_review"
        ? Colors.green
        : status == "completed" || status == "Completed"
        ? theme.isDark
            ? Colors.green
            : AppColors.maincolor
        : status == "rejected"
        ? Colors.orange
        : Colors.black;
  }

  String getStatusFromTab(int index) {
    switch (index) {
      case 0:
        return "pending";
      case 1:
        return "status_in_review";
      case 2:
        return "completed";
      default:
        return "";
    }
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  File? selectedImage;

  void showAddRequestBottomSheet(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    final theme = Provider.of<ThemeController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    left: 20,
                    right: 20,
                    top: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        theme.isDark
                            ? const Color(0xff1A1A1A).withOpacity(0.85)
                            : Colors.white.withOpacity(0.9),
                    border: Border(
                      top: BorderSide(
                        color: theme.isDark ? Colors.white10 : Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      // Make sure _formKey is defined in your class
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Top Handle ---
                          Container(
                            width: 45,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // --- Title ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.build_circle_outlined,
                                color:
                                    theme.isDark
                                        ? const Color(0xffCBB88C)
                                        : AppColors.maincolor,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Add Maintenance',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstants.manropeBold,
                                  color:
                                      theme.isDark
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),

                          // --- Subject Field ---
                          _buildCustomField(
                            label: "Subject",
                            hint: "Enter Subject",
                            controller: subjectController,
                            icon: Icons.title_rounded,
                            theme: theme,
                          ),
                          SizedBox(height: 2.h),

                          // --- Note Field ---
                          _buildCustomField(
                            label: "Note",
                            hint: "Enter detailed description",
                            controller: noteController,
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                            theme: theme,
                          ),
                          SizedBox(height: 2.5.h),

                          // --- Image Picker ---
                          _buildImagePickerUI(theme, setState, picker),

                          SizedBox(height: 4.h),

                          // --- Submit Button ---
                          isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.maincolor,
                                ),
                              )
                              : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => isLoading = true);
                                    // Call your function
                                    AddMaintenance(selectedImage);
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.isDark
                                          ? const Color(0xffCBB88C)
                                          : AppColors.lightText,
                                  foregroundColor:
                                      theme.isDark
                                          ? Colors.black
                                          : Colors.white,
                                  minimumSize: Size(double.infinity, 6.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Submit Request",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    // fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manropeBold,
                                  ),
                                ),
                              ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    required var theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'This field is required'
                      : null,
          style: TextStyle(
            color: theme.isDark ? Colors.white : Colors.black,
            fontFamily: AppConstants.manrope,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: theme.isDark ? AppColors.white : AppColors.maincolor,
              size: 20,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.isDark ? AppColors.white : Colors.black,
              fontSize: 15.sp,
              fontFamily: AppConstants.manrope,
            ),
            filled: true,
            fillColor:
                theme.isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColors.maincolor.withOpacity(0.5),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1.h),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerUI(theme, setState, picker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Attach Evidence (Optional)",
            style: TextStyle(
              fontFamily: AppConstants.manropeBold,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (pickedFile != null) {
              setState(() => selectedImage = File(pickedFile.path));
            }
          },
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color:
                  theme.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade50,
              border: Border.all(
                color: theme.isDark ? Colors.white12 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child:
                selectedImage != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedImage = null),
                            child: CircleAvatar(
                              backgroundColor: Colors.red.shade600,
                              radius: 15,
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color:
                              theme.isDark
                                  ? Colors.white
                                  : AppColors.maincolor.withOpacity(0.7),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tap to upload image",
                          style: TextStyle(
                            color:
                                theme.isDark
                                    ? Colors.white
                                    : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  void AddMaintenance(File? file) {
    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        MaintenanceProvider()
            .addMaintanceRequestApi(
              userId: loginModel?.data?.user?.id.toString() ?? '',
              subject: subjectController.text.trim(),
              note: noteController.text.trim(),
              file: file,
            )
            .then((response) async {
              if (response.statusCode == 200) {
                AllMaintenanceApi();
                setState(() {
                  subjectController.clear();
                  noteController.clear();
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void AllMaintenanceApi() {
    String status = getStatusFromTab(selectedCategory);

    final Map<String, String> data = {
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
    };

    if (status.isNotEmpty) {
      data['status'] = status;
    }

    checkInternet().then((internet) async {
      if (internet) {
        MaintenanceProvider().getMaintanceApi(data).then((response) async {
          maintenanceModel = MaintenanceModel.fromJson(response.data);

          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void MaintenanceDetailApi(String detailId) async {
    setState(() {
      isDetailLoading = true;
    });

    final Map<String, String> data = {
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
      'id': detailId,
    };

    bool hasInternet = await checkInternet();

    if (!hasInternet) {
      setState(() {
        isDetailLoading = false;
      });
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      var response = await MaintenanceProvider().getMaintanceApi(data);

      if (response.statusCode == 200) {
        maintenanceDetailModel = MaintenanceDetailModel.fromJson(response.data);

        if (mounted) {
          setState(() {
            isDetailLoading = false;
          });

          showMaintenanceDetailBottomSheet(context, maintenanceDetailModel!);
        }
      } else {
        if (mounted) {
          setState(() {
            isDetailLoading = false;
          });
        }
      }
    } catch (e, stacktrace) {
      log("errererer$stacktrace");
      if (mounted) {
        setState(() {
          isDetailLoading = false;
        });
      }
    }
  }

  void showMaintenanceDetailBottomSheet(
    BuildContext context,
    MaintenanceDetailModel detail,
  ) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.isDark ? Color(0xff1A1A1A) : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.30,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top handle bar
                  Center(
                    child: Container(
                      height: 4,
                      width: 20.w,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  /// Title
                  Text(
                    "Maintenance Details",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manropeBold,
                      color: theme.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  /// Details
                  _detailRow("Subject", detail.data?.subject ?? "-"),
                  _detailRow("Note", detail.data?.note ?? "-"),
                  _detailRow(
                    "Status",
                    detail.data?.status == "status_in_review"
                        ? "In Review"
                        : detail.data?.status.toString().capitalizeFirst ?? "-",
                    color: getStatusColor(detail.data?.status.toString() ?? ""),
                  ),
                  _detailRow(
                    "Created",
                    detail.data?.createdAt != null
                        ? DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(DateTime.parse(detail.data!.createdAt!))
                        : "-",
                  ),

                  const SizedBox(height: 16),

                  /// Image Preview
                  if (detail.data?.file != null &&
                      detail.data!.file!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attached Image",
                          style: TextStyle(
                            fontFamily: AppConstants.manropeBold,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: detail.data!.file!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  /// Close Button
                  batan(
                    title: "Close",
                    route: () {
                      Get.back();
                    },
                    color:
                        theme.isDark ? Color(0xffCBB88C) : AppColors.maincolor,
                    fontcolor: theme.isDark ? Colors.black : Colors.white,
                    height: 5.h,
                    width: double.infinity,
                    fontsize: 18.sp,
                    radius: 12.0,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String title, String value, {Color? color}) {
    final isExpandable =
        title.toLowerCase().contains('subject') ||
        title.toLowerCase().contains('note');
    final theme = context.watch<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.manropeBold,
                fontSize: 15.sp,
                color: theme.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child:
                isExpandable
                    ? ReadMoreText(
                      value.isNotEmpty
                          ? '${value[0].toUpperCase()}${value.substring(1)}'
                          : '',
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' Show More',
                      trimExpandedText: ' Show Less',
                      style: TextStyle(
                        color:
                            theme.isDark
                                ? Colors.white
                                : (color ?? Colors.black),
                        fontSize: 15,
                        fontFamily: AppConstants.manrope,
                      ),
                      moreStyle: const TextStyle(
                        color: AppColors.maincolor,
                        fontWeight: FontWeight.bold,
                      ),
                      lessStyle: const TextStyle(
                        color: AppColors.maincolor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        color:
                            theme.isDark
                                ? Colors.white
                                : (color ?? Colors.black),
                        fontSize: 15,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
