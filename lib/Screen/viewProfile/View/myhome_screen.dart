import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/custom_button.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/input_decoration.dart';
import '../../../comman/loader.dart';
import '../../../comman/viewPdfFunction.dart';
import '../../homePage/View/homenewpage.dart';
import '../Model/profile_model.dart';
import '../Provider/profile_provider.dart';

class MyHome_Screen extends StatefulWidget {
  final int? id;

  const MyHome_Screen({super.key, this.id});

  @override
  State<MyHome_Screen> createState() => _MyHome_ScreenState();
}

class _MyHome_ScreenState extends State<MyHome_Screen> {
  final GlobalKey<ScaffoldState> Myhome = GlobalKey<ScaffoldState>();
  TextEditingController fullAddressController = TextEditingController();
  TextEditingController propertydetailsController = TextEditingController();
  TextEditingController KeyWaiversController = TextEditingController();
  TextEditingController documentsController = TextEditingController();
  bool isLoading = true;
  File? selectedImage;
  String profileImage = "";
  bool isEditing = false;
  File? selectedPdf;
  String? pdfFileName;

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedPdf = File(result.files.single.path!);
        pdfFileName = result.files.single.name;
      });
    }
  }

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

      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 6.h),
                    TitleBar(
                      back: () {
                        Get.back();
                      },
                      title: "My Home",
                      drawerCallback: () {},
                    ),
                    SizedBox(height: 3.h),
                    profileField(
                      "Property Address",
                      fullAddressController,
                      Icons.location_on,
                      false,
                    ),
                    profileField(
                      "Key Waivers",
                      KeyWaiversController,
                      Icons.vpn_key,
                      true,
                    ),
                    SizedBox(height: 0.5.h),
                    profileModel?.data?.unit?.documentsFiles?.length == null ||
                            profileModel?.data?.unit?.documentsFiles?.length ==
                                0
                        ? SizedBox()
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Apartment Documents",
                                style: TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
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
                                      ?.unit
                                      ?.documentsFiles
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final documentUrl =
                                    profileModel!
                                        .data!
                                        .unit!
                                        .documentsFiles![index];
                                final labels =
                                    profileModel!
                                        .data!
                                        .unit!
                                        .documentsFilesLabel;

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
                                    if (documentUrl.isNotEmpty) {
                                      Get.to(PdfView(link: documentUrl));
                                    }
                                  },
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

                    profileModel
                                    ?.data
                                    ?.buildingDocument
                                    ?.documentsFiles
                                    ?.length ==
                                null ||
                            profileModel
                                    ?.data
                                    ?.buildingDocument
                                    ?.documentsFiles
                                    ?.length ==
                                0
                        ? SizedBox()
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Building Documents",
                                style: TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
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
                    batan(
                      title: "Save Home",
                      route: () {
                        EditProfile();
                      },
                      color: AppColors.maincolor,
                      fontcolor: Colors.white,
                      height: 5.5.h,
                      fontsize: 17.sp,
                      radius: 12.0,
                    ),
                  ],
                ),
              ).paddingOnly(right: 3.w, left: 3.w),
          if (isEditing)
            //
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
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

  void EditProfile() {
    final Map<String, String> data = {
      'update_id': profileModel?.data?.id.toString() ?? '',
      "keywaivers": KeyWaiversController.text.trim(),
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

      setState(() {
        isEditing = true;
      });

      try {
        final response = await ProfileProvider().updateProfile(data);

        if (response.statusCode == 200) {
          var profileModel = ProfileModel.fromJson(response.data);

          if (profileModel.status == 200) {
            Get.snackbar(
              "Success",
              "Home Updated Successfully",
              backgroundColor: AppColors.maincolor,
              colorText: Colors.white,
            );

            Future.delayed(Duration(seconds: 1), () {
              Get.offAll(HomePage(userName: ""));
            });
          } else {
            Get.snackbar(
              "Error",
              "Failed to update profile: ${profileModel.message}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else if (response.statusCode == 422) {
          Get.snackbar(
            "Error",
            "Validation Error: ${response.data['message']}",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            "Server error, please try again",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e, straceTrace) {
        Get.snackbar(
          "Error",
          "An error occurred: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          isEditing = false;
        });
      }
    });
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
                var unit = profileModel.data?.unit;

                if (user != null) {
                  var address = user.address;

                  /// Function to check valid string (not null, not empty, not "N/A")
                  bool isValid(String? value) {
                    return value != null &&
                        value.trim().isNotEmpty &&
                        value != "N/A";
                  }

                  /// Build Address Parts
                  List<String> addressParts = [];

                  if (isValid(unit?.blockNumber)) {
                    addressParts.add(unit!.blockNumber!);
                  }
                  if (isValid(unit?.flatNumber)) {
                    addressParts.add(unit!.flatNumber!);
                  }
                  if (isValid(address?.address)) {
                    addressParts.add(address!.address!);
                  }
                  if (isValid(address?.city)) {
                    addressParts.add(address!.city!);
                  }
                  if (isValid(address?.country)) {
                    addressParts.add(address!.country!);
                  }
                  if (isValid(address?.zipCode)) {
                    addressParts.add(address!.zipCode!);
                  }

                  fullAddressController.text = addressParts.join(', ');

                  KeyWaiversController.text =
                      isValid(unit?.keyWaiver) ? unit!.keyWaiver! : "";

                  propertydetailsController.text = [
                    if (isValid(unit?.blockNumber)) unit!.blockNumber!,
                    if (isValid(unit?.flatNumber)) unit!.flatNumber!,
                  ].join(" - ");

                  if (user.profile != null && user.profile!.isNotEmpty) {
                    profileImage = user.profile!;
                  }
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
