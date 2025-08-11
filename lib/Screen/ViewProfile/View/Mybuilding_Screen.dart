import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/loader.dart';
import 'package:wavee/comman/viewPdfFunction.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/input_decoration.dart';
import '../Model/profile_model.dart';
import '../Provider/profile_provider.dart';

class MyBuilding_Screen extends StatefulWidget {
  final int? id;

  const MyBuilding_Screen({super.key, this.id});

  @override
  State<MyBuilding_Screen> createState() => _MyBuilding_ScreenState();
}

class _MyBuilding_ScreenState extends State<MyBuilding_Screen> {
  final GlobalKey<ScaffoldState> Mybuilding = GlobalKey<ScaffoldState>();
  TextEditingController myBuilingname = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  bool isLoading = false;
  String profileImage = "";
  bool isEditing = false;
  File? selectedPdf;
  String? pdfFileName;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 6.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: "My Building",
              drawerCallback: () {},
            ),
            SizedBox(height: 2.h),
            isLoading
                ? Center(child: Loader().paddingOnly(top: 25.h))
                : profileModel?.data?.buildingDocument == null
                ? SizedBox()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    profileField(
                      "Building Name",
                      TextEditingController(
                        text:
                            profileModel?.data?.buildingDocument?.buildingName
                                .toString()
                                .capitalizeFirst ??
                            "",
                      ),
                      Icons.apartment,
                      false,
                    ),
                    profileField(
                      "Address",
                      TextEditingController(
                        text:
                            profileModel?.data?.buildingDocument?.address ?? "",
                      ),
                      Icons.location_on,
                      false,
                    ),
                    // profileField(
                    //   "Total Floors",
                    //   TextEditingController(
                    //     text:
                    //         profileModel?.data?.buildingDocument?.totalFloors
                    //             ?.toString() ??
                    //         "",
                    //   ),
                    //   Icons.stairs,
                    //   false,
                    // ),
                    // profileField(
                    //   "Total Units",
                    //   TextEditingController(
                    //     text:
                    //         profileModel?.data?.buildingDocument?.totalUnits
                    //             ?.toString() ??
                    //         "",
                    //   ),
                    //   Icons.house,
                    //   false,
                    // ),
                    profileField(
                      "Parking Info",
                      TextEditingController(
                        text:
                            profileModel
                                ?.data
                                ?.buildingDocument
                                ?.parkingInformation ??
                            "",
                      ),
                      Icons.local_parking,
                      false,
                    ),
                    profileField(
                      "Concierge Info",
                      TextEditingController(
                        text:
                            profileModel
                                ?.data
                                ?.buildingDocument
                                ?.conciergeInformation ??
                            "",
                      ),
                      Icons.support_agent,
                      false,
                    ),
                    profileField(
                      "Fitness Centre",
                      TextEditingController(
                        text:
                            profileModel
                                ?.data
                                ?.buildingDocument
                                ?.fitnessCentreInformation ??
                            "",
                      ),
                      Icons.fitness_center,
                      false,
                    ),
                    if ((profileModel!
                            .data!
                            .buildingDocument!
                            .emergencyNumbers
                            ?.isNotEmpty ??
                        false))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency Numbers",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                profileModel!
                                    .data!
                                    .buildingDocument!
                                    .emergencyNumbers!
                                    .length,
                            itemBuilder: (context, index) {
                              final number =
                                  profileModel!
                                      .data!
                                      .buildingDocument!
                                      .emergencyNumbers![index];
                              final caption =
                                  profileModel!
                                                  .data!
                                                  .buildingDocument!
                                                  .emergencyCaptions !=
                                              null &&
                                          index <
                                              profileModel!
                                                  .data!
                                                  .buildingDocument!
                                                  .emergencyCaptions!
                                                  .length
                                      ? profileModel!
                                          .data!
                                          .buildingDocument!
                                          .emergencyCaptions![index]
                                      : "Emergency ${index + 1}";
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text("$caption: $number"),
                              );
                            },
                          ),
                        ],
                      ),
                    SizedBox(height: 2.h),
                    if (profileModel!.data!.buildingDocument!.documentsFiles !=
                            null &&
                        profileModel!.data!.buildingDocument!.documentsFiles!
                            .any((url) => url != null && url.isNotEmpty))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Building Documents",
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount:
                                profileModel
                                    ?.data
                                    ?.buildingDocument
                                    ?.documentsFiles
                                    ?.length ??
                                0,
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

                              if (documentUrl == null || documentUrl.isEmpty)
                                return SizedBox();

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
                                onTap: () {
                                  Get.to(PdfView(link: documentUrl));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 7.h,
                                      width: 15.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        finalLabel,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 15.sp),
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
          ],
        ),
      ).paddingOnly(right: 3.w, left: 3.w),
    );
  }

  Widget profileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditable, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: controller,
          readOnly: !isEditable,
          textCapitalization: TextCapitalization.words,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: inputDecoration(hintText: label).copyWith(
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(icon, size: 20.sp, color: AppColors.maincolor),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              var profileModel = ProfileModel.fromJson(response.data);
              if (profileModel.status == 200) {
                var user = profileModel.data?.user;
                var building = profileModel.data?.buildingDocument;
                if (user != null) {
                  myBuilingname.text = building?.buildingName ?? "";
                }
              }
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
      }
    });
  }
}
