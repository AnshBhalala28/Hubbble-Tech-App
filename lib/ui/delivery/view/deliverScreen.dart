import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/delivery/view/deliveryDetailsScreen.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';

class DeliverScreen extends StatefulWidget {
  const DeliverScreen({super.key});

  @override
  State<DeliverScreen> createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  int selectedIndex = 0;

  Color getStatusColor(String type, bool isDark) {
    switch (type) {
      case "Delivery":
        return Colors.green;

      case "Pending":
        return Colors.red; // 🔥 best for pending

      default:
        return Colors.grey;
    }
  }

  final List<String> categories = ["All", "Deliver/Collection", "Pending"];

  final List<DeliveryModel> deliveries = [
    DeliveryModel(
      scheduleDate: "05/10/2026",
      time: "10:00 AM",
      eventName: "Annual Gala Event",
      company: "Wavee Community",
      contactDetails: "9876543210",
      item: "Sound System & Lighting",
      type: "Delivery",
      // Can be 'Delivery' or 'Collection'
      comments: "Handle with care, premium equipment.",
    ),
    DeliveryModel(
      scheduleDate: "06/10/2026",
      time: "02:30 PM",
      eventName: "Tech Conference",
      company: "Community Tech",
      contactDetails: "9988776655",
      item: "LED Screens & Projectors",
      type: "Delivery",
      comments: "",
    ),
    DeliveryModel(
      scheduleDate: "05/10/2026",
      time: "10:00 AM",
      eventName: "Annual Gala Event",
      company: "Wavee Community",
      contactDetails: "9876543210",
      item: "Sound System & Lighting",
      type: "Pending",
      // Can be 'Delivery' or 'Collection'
      comments: "Handle with care, premium equipment.",
    ),
    DeliveryModel(
      scheduleDate: "06/10/2026",
      time: "02:30 PM",
      eventName: "Tech Conference",
      company: "Community Tech",
      contactDetails: "9988776655",
      item: "LED Screens & Projectors",
      type: "Pending",
      comments: "",
    ),
  ];

  List<DeliveryModel> getFilteredList() {
    if (selectedIndex == 0) {
      return deliveries;
    } else if (selectedIndex == 1) {
      return deliveries.where((e) => e.type == "Delivery").toList();
    } else if (selectedIndex == 2) {
      return deliveries.where((e) => e.type == "Pending").toList();
    }
    return deliveries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    Color secondaryTextColor = isDark ? Colors.white : Colors.black;
    final filteredList = getFilteredList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),

              TitleBar(
                back: () => Get.back(),
                title: "Deliver/Collection",
                drawerCallback: () {},
              ),

              SizedBox(height: 2.h),

              SizedBox(
                height: 6.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        margin: EdgeInsets.only(right: 3.w),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (isDark
                                      ? const Color(0xffCBB88C)
                                      : AppColors.lightText)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontFamily: AppConstants.manropeBold,
                            fontSize: 14.sp,
                            color:
                                isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child:
                    filteredList.isEmpty
                        ? Center(child: Text("No Data Found",
                      style: TextStyle(
                        fontFamily: AppConstants.manropeBold,
                        fontSize: 16.sp,
                        color: secondaryTextColor,
                      ),
                    ))
                        : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            var item = filteredList[index];

                            return GestureDetector(
                              onTap: (){
                                Get.to(()=> DeliveryDetailsScreen());
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xf0252525) : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status & Date Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.type.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: AppConstants.manropeBold,
                                            color: getStatusColor(item.type, isDark),
                                          ),
                                        ),
                                        Text(
                                          "${item.scheduleDate} | ${item.time}",
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13.sp,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 20,
                                      thickness: 2,
                                      color:
                                          isDark
                                              ? Color(0xFFCFB583)
                                              : AppColors.lightText,
                                    ),

                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Color(
                                                      0xFFCFB583,
                                                    ).withOpacity(0.2)
                                                    : AppColors.lightText.withOpacity(
                                                      0.1,
                                                    ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            CupertinoIcons
                                                .cube_box,
                                            size: 22.sp,
                                            color:
                                                isDark
                                                    ? Color(0xFFCFB583)
                                                    : AppColors.lightText,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.eventName,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      AppConstants.manropeBold,
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                "Company: ${item.company}",
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14.sp,
                                                  fontFamily: AppConstants.manrope,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              // Items & Contact
                                              Row(
                                                children: [
                                                  Text(
                                                    "Item: ${item.item}",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          isDark
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Contact: ${item.contactDetails}",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          isDark
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ).paddingSymmetric(horizontal: 3.w),
        ],
      ),
    );
  }
}

class DeliveryModel {
  final String scheduleDate;
  final String time;
  final String eventName;
  final String company;
  final String contactDetails;
  final String item;
  final String type;
  final String comments;

  DeliveryModel({
    required this.scheduleDate,
    required this.time,
    required this.eventName,
    required this.company,
    required this.contactDetails,
    required this.item,
    required this.type,
    required this.comments,
  });
}
