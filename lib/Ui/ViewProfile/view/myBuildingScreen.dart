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
    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: Column(
                    children: [
                      infoCard(
                        "Building Name",
                        myBuilingname.text,
                        Icons.apartment,
                      ),
                      infoCard(
                        "Address",
                        addressController.text,
                        Icons.location_on,
                      ),
                      infoCard("Landline Number", landline.text, Icons.phone),
                      infoCard("Additional Number", number.text, Icons.phone),
                      infoCard(
                        "Parking Info",
                        parkingInfoController.text,
                        Icons.local_parking,
                      ),
                      infoCard(
                        "Concierge Info",
                        conciergeInfoController.text,
                        Icons.support_agent,
                      ),
                      infoCard(
                        "Fitness Centre",
                        fitnessController.text,
                        Icons.fitness_center,
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
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
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
                                return infoCard(caption, number, Icons.phone);
                              },
                            ),
                          ],
                        ),

                      if (profileModel
                                  ?.data
                                  ?.buildingDocument
                                  ?.documentsFiles !=
                              null &&
                          profileModel!.data!.buildingDocument!.documentsFiles!
                              .any((url) => url.isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 3.h),
                            Text(
                              "Building Documents",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 19.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            GridView.builder(
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
                                      () => Get.to(PdfView(link: documentUrl)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.maincolor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: AppColors.maincolor,
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
        ],
      ).paddingOnly(left: 3.w, right: 3.w),
    );
  }

  // ========== REUSABLE INFO CARD ==============
  Widget infoCard(String label, String value, IconData icon) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 0.5,
      child: Container(
        // margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon box
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

            // Label and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppConstants.manropeBold,
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    value.isNotEmpty
                        ? '${value[0].toUpperCase()}${value.substring(1)}'
                        : "—",
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      fontSize: 16.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).marginOnly(bottom: 1.h);
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
}
