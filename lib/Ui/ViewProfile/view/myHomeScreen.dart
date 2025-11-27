import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

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
        Get.snackbar(
          "Error",
          "Internet Required",
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
        Get.snackbar(
          "Error",
          "Internet Required",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => isEditing = true);
      try {
        final response = await ProfileProvider().updateProfile(data);

        if (response.statusCode == 200) {
          var updatedModel = ProfileModel.fromJson(response.data);
          if (updatedModel.status == 200) {
            Get.snackbar(
              "Success",
              "Home Updated Successfully",
              backgroundColor: AppColors.maincolor,
              colorText: Colors.white,
            );
            GetProfile();
            // Get.offAll(HomePage(userName: ""));
          } else {
            Get.snackbar(
              "Error",
              updatedModel.message ?? "Update failed",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            "Error",
            "Server Error",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "An error occurred: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
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
                          infoCard(
                            "Property Address",
                            fullAddress,
                            Icons.location_on,
                          ),
                          infoCard(
                            "Property Details",
                            propertyDetails,
                            Icons.apartment,
                          ),

                          // 🔑 Key Waivers (Premium Editable Card)
                          Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(16),

                            child: Container(
                              // margin: EdgeInsets.only(bottom: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                            color: AppColors.maincolor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.vpn_key_rounded,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          "Key Waivers",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.maincolor,
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
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
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
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              "Enter your key waiver details...",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
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
                                            color: AppColors.maincolor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.save_rounded,
                                                color: Colors.white,
                                                size: 16.sp,
                                              ),
                                              SizedBox(width: 1.w),
                                              Text(
                                                "Save",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontSize: 15.sp,
                                                  color: Colors.white,
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
                                fontFamily: AppConstants.manrope,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

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
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: AppColors.maincolor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: AppColors.maincolor,
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
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).paddingOnly(top: 1.5.h);
                              },
                            ),
                          ],

                          /// 🏢 Building Documents
                          if (buildingDocs.isNotEmpty) ...[
                            Text(
                              "Building Documents",
                              style: TextStyle(
                                fontFamily: AppConstants.manropeBold,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
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
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: AppColors.maincolor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: AppColors.maincolor,
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
                                          style: TextStyle(fontSize: 14.sp),
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
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
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
