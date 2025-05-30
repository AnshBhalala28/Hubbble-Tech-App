import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/custom_button.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/input_decoration.dart';
import '../../../comman/loader.dart';
import '../../../comman/viewPdfFunction.dart';
import '../../HomeNewPage/View/homenewpage.dart';
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
      drawer: SideMenu(),
      key: Myhome,
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      TitleBar(
                        back: () {
                          Get.back();
                        },
                        title: "My Home",
                        drawerCallback: () => Myhome.currentState?.openDrawer(),
                      ),
                      SizedBox(height: 3.h),

                      profileField(
                        "Property Address",
                        fullAddressController,
                        Icons.location_on,
                        false,
                      ),

                      // profileField(
                      //     "Property Details",
                      //     propertydetailsController,
                      //     Icons.business,
                      //     true
                      // ),
                      profileField(
                        "Key Waivers",
                        KeyWaiversController,
                        Icons.vpn_key,
                        true,
                      ),
                      SizedBox(height: 0.5.h),
                      profileModel?.data?.unit?.documentsFiles?.length ==
                                  null ||
                              profileModel
                                      ?.data
                                      ?.unit
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
                                  "Documents",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
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

                                  // જો label available હોય તો લો, નહિ તો "Document {index+1}" લવો
                                  String label =
                                      (labels != null && index < labels.length)
                                          ? labels[index]
                                          : 'Document ${index + 1}';

                                  // First letter capital
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
                              SizedBox(height: 5.h),
                            ],
                          ),

                      //   SizedBox(height: 5.h),
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
                ),
              ),
          if (isEditing)
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
    };

    log("DaRequest ta: $data");

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

      // 🟢 Start loader
      setState(() {
        isEditing = true;
      });

      try {
        final response = await ProfileProvider().ProfileEdit(
          data,
          selectedImage,
        );

        log("Response Status Code: ${response.statusCode}");
        log("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          var profileModel = ProfileModel.fromJson(jsonDecode(response.body));

          if (profileModel.status == 200) {
            log("Profile Updated Successfully");

            Get.snackbar(
              "Success",
              "Home Updated Successfully",
              backgroundColor: AppColors.maincolor,
              colorText: Colors.white,
            );

            Future.delayed(Duration(seconds: 1), () {
              Get.offAll(HomeNewPage(userName: ""));
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
            "Validation Error: ${response.body}",
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
        log("Exception error : $e, $straceTrace");
        Get.snackbar(
          "Error",
          "An error occurred: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        // 🔴 Stop loader
        setState(() {
          isEditing = false;
        });
      }
    });
  }

  void GetProfile() {
    final Map<String, String> data = {'id': widget.id.toString()};
    log('DATA JAY VCJEEE #${data}');
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              var profileModel = ProfileModel.fromJson(
                jsonDecode(response.body),
              );
              if (profileModel.status == 200) {
                log("sadfsafds${response.body}");
                var user = profileModel.data?.user;
                var unit = profileModel.data?.unit;
                if (user != null) {
                  var address = user.address;
                  if (address != null) {
                    fullAddressController.text =
                        address.address == null ||
                                address.address == '' ||
                                address.city == null ||
                                address.city == '' ||
                                unit?.flatNumber == null ||
                                unit?.flatNumber == ''
                            ? "N/A"
                            : "${unit?.blockNumber ?? ""} - ${unit?.flatNumber ?? ""}, ${address.address ?? ""}, ${address.city ?? ""}, ${address.country ?? ""},${address.zipCode ?? ""}";
                  }
                  KeyWaiversController.text = unit?.keyWaiver ?? "";
                  propertydetailsController.text =
                      "${unit?.blockNumber ?? ""} - ${unit?.flatNumber ?? ""}";
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
