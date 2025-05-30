import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
// import 'package:pay/pay.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wavee/Screen/Buy%20Product/place_order_model.dart';
import 'package:wavee/Screen/Thankyou%20Page/view/thankyou_page.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/loader.dart';
// import 'package:wavee/comman/payment_config.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/in_web_view.dart';
import '../../Add to Cart/model/add_to_cart_model.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../../Community Screen/Community Screen/Model/BusnessViewModal.dart';
import '../../Community Screen/Community Screen/Provider/community_provider.dart';
import '../provider/check_out_provider.dart';

class BuyProductView extends StatefulWidget {
  String? type;

  BuyProductView({super.key, this.type});

  @override
  State<BuyProductView> createState() => _BuyProductViewState();
}

class _BuyProductViewState extends State<BuyProductView> {
  final GlobalKey<ScaffoldState> buyKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isCheckout = false;
  String selectedPayment = "";
  String selectedPickupTime = "";
  // UpiIndia _upiIndia = UpiIndia();
  // List<UpiApp> apps = [];
  // String transactionStatus = "No transaction yet.";

  List<Map<String, dynamic>> timeSlots = [];

  Future<void> initPickupSlots() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Step 1: Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Step 2: Get country name from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String country = placemarks.first.country ?? "";

    // Step 3: Detect region based on country
    String region;
    if (country.toLowerCase().contains("india")) {
      region = "India";
    } else if (country.toLowerCase().contains("united kingdom")) {
      region = "UK";
    } else {
      region = "India"; // default fallback
    }

    // Step 4: Generate slots with correct region
    generateTimeSlots(region: region);
  }

  void generateTimeSlots({required String region}) {
    tz.Location location;

    if (region == 'India') {
      location = tz.getLocation('Asia/Kolkata');
    } else if (region == 'UK') {
      location = tz.getLocation('Europe/London');
    } else {
      throw Exception('Unsupported region');
    }

    final now = tz.TZDateTime.now(location);
    final currentHour = now.hour;

    timeSlots = [];

    if (currentHour < 12) {
      timeSlots.add({'value': '10am-12pm', 'label': '10 AM - 12 PM'});
    }

    if (currentHour < 16) {
      timeSlots.add({'value': '1pm-4pm', 'label': '1 PM - 4 PM'});
    }
    if (currentHour < 19) {
      timeSlots.add({'value': '5pm-7pm', 'label': '5 PM - 7 PM'});
    }

    if (timeSlots.isNotEmpty) {
      selectedPickupTime = timeSlots.first['value'];
    }

    // Update UI
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    GetCartDetailApi();
    // _fetchUpiApps();
    // generateTimeSlots();
    initPickupSlots();
  }

  // void _fetchUpiApps() async {
  //   List<UpiApp> availableApps = await _upiIndia.getAllUpiApps(
  //     mandatoryTransactionId: false,
  //   );
  //   setState(() {
  //     apps = availableApps;
  //   });
  // }

  // Future<void> _initiateTransaction(UpiApp app) async {
  //   UpiResponse response = await _upiIndia.startTransaction(
  //     app: app,
  //     receiverUpiId: "hirenpchandaliya@okicici",
  //     receiverName: "Hiren Chandaliya",
  //     transactionRefId: "TXNID123456",
  //     transactionNote: "Test Payment",
  //     amount: 1.0,
  //   );

  //   setState(() {
  //     if (response.status == UpiPaymentStatus.SUCCESS) {
  //       transactionStatus =
  //           "✅ Payment Successful\nTxn ID: ${response.transactionId}";
  //     } else if (response.status == UpiPaymentStatus.FAILURE) {
  //       transactionStatus = "❌ Payment Failed";
  //     } else {
  //       transactionStatus = "⚠️ Payment Cancelled by User";
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: buyKey,
      drawer: SideMenu(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 4.h),
              TitleBar(
                title: "Checkout",
                drawerCallback: () {
                  buyKey.currentState?.openDrawer();
                },
              ),
              isLoading
                  ? Loader().paddingOnly(top: 30.h)
                  : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Text(
                            "Customer Details",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: boxDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoRow(
                                  icon: Icons.person_outline,
                                  label:
                                      "${loginModel?.data?.user?.name?.firstName ?? ''} ${loginModel?.data?.user?.name?.lastName ?? ''}",
                                ),
                                SizedBox(height: 1.h),
                                // infoRow(
                                //   icon: Icons.phone,
                                //   label:
                                //       "${loginModel?.data?.user?.mobileNo ?? ''}",
                                // ),

                                // infoRow(
                                //   icon: Icons.email_outlined,
                                //   label:
                                //       "${loginModel?.data?.user?.email ?? 'No email'}",
                                // ),
                                // SizedBox(height: 1.h),
                                // infoRow(
                                //   icon: Icons.location_on_outlined,
                                //   label:
                                //       "${loginModel?.data?.user?.address?.address ?? ''}, ${loginModel?.data?.user?.address?.city ?? ''}, ${loginModel?.data?.user?.address?.country ?? ''}, ${loginModel?.data?.user?.address?.zipCode ?? ''}",
                                // ),
                              ],
                            ),
                          ),
                          busnessviewmodal?.data?.business?.user?.mobileNo ==
                                  null
                              ? SizedBox()
                              : Text(
                                widget.type == "service"
                                    ? "Business Location"
                                    : "Pickup Location",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          SizedBox(height: 1.h),
                          busnessviewmodal?.data?.business?.user?.mobileNo ==
                                  null
                              ? SizedBox()
                              : Container(
                                padding: EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: boxDecoration(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoRow(
                                      icon: Icons.storefront,
                                      label:
                                          busnessviewmodal
                                              ?.data
                                              ?.business
                                              ?.businessName ??
                                          "N/A",
                                    ),
                                    SizedBox(height: 1.h),
                                    infoRow(
                                      icon: Icons.phone,
                                      label:
                                          busnessviewmodal
                                              ?.data
                                              ?.business
                                              ?.user
                                              ?.mobileNo
                                              .toString() ??
                                          "N/A",
                                    ),
                                    SizedBox(height: 1.h),
                                    infoRow(
                                      icon: Icons.email_outlined,
                                      label:
                                          busnessviewmodal
                                              ?.data
                                              ?.business
                                              ?.user
                                              ?.email
                                              .toString() ??
                                          "N/A",
                                    ),
                                    SizedBox(height: 1.h),
                                    infoRow(
                                      icon: Icons.location_on_outlined,
                                      label:
                                          (busnessviewmodal
                                                          ?.data
                                                          ?.business
                                                          ?.user
                                                          ?.address
                                                          ?.address ==
                                                      null ||
                                                  busnessviewmodal
                                                          ?.data
                                                          ?.business
                                                          ?.user
                                                          ?.address
                                                          ?.address ==
                                                      "")
                                              ? "N/A"
                                              : "${busnessviewmodal?.data?.business?.user?.address?.address}, "
                                                  "${busnessviewmodal?.data?.business?.user?.address?.city}, "
                                                  "${busnessviewmodal?.data?.business?.user?.address?.country}, "
                                                  "${busnessviewmodal?.data?.business?.user?.address?.zipCode},",
                                    ),
                                  ],
                                ),
                              ),
                          widget.type == 'service'
                              ? SizedBox()
                              : SizedBox(height: 2.h),
                          widget.type == 'service'
                              ? SizedBox()
                              : Text(
                                "Pickup Time",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          widget.type == 'service'
                              ? SizedBox()
                              : SizedBox(height: 1.h),
                          widget.type == 'service'
                              ? SizedBox()
                              : Container(
                                padding: EdgeInsets.all(12),
                                decoration: boxDecoration(),
                                child: Column(
                                  children:
                                      timeSlots.map((slot) {
                                        return RadioListTile(
                                          value: slot['value'],
                                          groupValue: selectedPickupTime,
                                          activeColor: AppColors.maincolor,
                                          title: Text(
                                            slot['label'],
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPickupTime = value!;
                                            });
                                          },
                                        );
                                      }).toList(),
                                ),
                              ),
                          SizedBox(height: 2.h),
                          Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: boxDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Payment Method",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                paymentOptionContainer(
                                  image: "assets/images/stripe_pay_image2.png",
                                  value: "Stripe",
                                ),
                                // paymentOptionContainer(
                                //   image: "assets/images/google_pay.png",
                                //   value: "Google Pay",
                                // ),
                                // paymentOptionContainer(
                                //   image: "assets/images/apple_pay.png",
                                //   value: "Apple Pay",
                                // ),
                                // GooglePayButton(
                                //   paymentConfiguration:
                                //       PaymentConfiguration.fromJsonString(
                                //           defaultGooglePay),
                                //   paymentItems: const [
                                //     PaymentItem(
                                //       label: 'Total',
                                //       amount: '100.0',
                                //       status: PaymentItemStatus.final_price,
                                //     ),
                                //   ],
                                //   type: GooglePayButtonType.pay,
                                //   width: double.infinity,
                                //   height: 5.h,
                                //   margin: const EdgeInsets.only(top: 15.0),
                                //   onPaymentResult: (result) => debugPrint(
                                //       'Payment Result ave che $result'),
                                //   loadingIndicator: const Center(
                                //     child: CircularProgressIndicator(
                                //       color: AppColors.white,
                                //     ),
                                //   ),
                                // ),
                                // Platform.isIOS
                                //     ? applePayButton
                                //     : SizedBox(
                                //         height: 2.h,
                                //       ),
                                // if (apps.isEmpty)
                                //   const CircularProgressIndicator()
                                // else
                                //   Wrap(
                                //     spacing: 20,
                                //     runSpacing: 20,
                                //     children: apps
                                //         .map((app) => BuildUpiIcon(app: app))
                                //         .toList(),
                                //   ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: boxDecoration(),
                            child: Column(
                              children: [
                                summaryTile("Subtotal", getSubtotal()),
                                // summaryTile("Packing Fees", 0.00),
                                // summaryTile("Taxes", 0.0),
                                // summaryTile("Other Fees", 0.0),
                                Divider(height: 2.h),
                                summaryTile(
                                  "Total",
                                  getSubtotal(),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          GestureDetector(
                            onTap: () {
                              if (widget.type != 'service' &&
                                  (selectedPickupTime == null ||
                                      selectedPickupTime!.isEmpty)) {
                                Get.snackbar(
                                  "Pickup Time Required",
                                  "Please select a pickup time before placing your order.",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(10),
                                  snackPosition: SnackPosition.TOP,
                                );
                              } else if (selectedPayment == null ||
                                  selectedPayment!.isEmpty) {
                                Get.snackbar(
                                  "Payment Method Required",
                                  "Please select a payment method before placing your order.",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(10),
                                  snackPosition: SnackPosition.TOP,
                                );
                              } else if (selectedPayment!.toLowerCase() ==
                                  "stripe") {
                                CheckOutAPI(
                                  selectedPickupTime,
                                  selectedPayment!.toLowerCase(),
                                );
                              } else {
                                Get.to(ThankYouPage());
                              }
                            },
                            child: Container(
                              height: 5.5.h,
                              alignment: Alignment.center,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.maincolor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Click & Collect",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: AppColors.white,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Container(
                                    height: 5.h,
                                    width: 4.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_checkout_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                        ],
                      ),
                    ),
                  ),
            ],
          ).paddingOnly(left: 2.w, right: 2.w),
          if (isCheckout)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  double getSubtotal() {
    double total = 0.0;
    checkoutTotal?.data?.forEach((item) {
      double price =
          double.tryParse(
            item.itemDetails?.offerPrice ?? item.itemDetails?.price ?? '0',
          ) ??
          0;
      total += price * (item.quantity ?? 1);
    });
    return total;
  }

  // Widget BuildUpiIcon({required UpiApp app}) {
  //   return GestureDetector(
  //     onTap: () {
  //       _initiateTransaction(app);
  //     },
  //     child: Container(
  //       margin: EdgeInsets.only(bottom: 1.5.h),
  //       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.grey.shade300, width: 1.2),
  //       ),
  //       child: Row(
  //         children: [
  //           Image.memory(app.icon, height: 5.h, width: 15.w),
  //           SizedBox(width: 4.w),
  //           Text(
  //             app.name,
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               fontWeight: FontWeight.w600,
  //               fontFamily: AppConstants.manrope,
  //             ),
  //           ),
  //           Spacer(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget paymentOptionContainer({
    required String image,
    required String value,
  }) {
    bool isSelected = selectedPayment == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.maincolor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.maincolor : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Image.asset(image, height: 5.h, width: 15.w, fit: BoxFit.contain),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.manrope,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.maincolor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  String getPaymentMethodForApi(String selectedPayment) {
    switch (selectedPayment.toLowerCase()) {
      case 'google pay':
        return 'googlepay';
      case 'stripe':
        return 'stripe';
      case 'apple pay':
        return 'applepay';
      default:
        return '';
    }
  }

  Widget infoRow({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.maincolor),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: AppConstants.manrope,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget summaryTile(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 17.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: AppConstants.manrope,
            ),
          ),
          Text(
            "£${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 17.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  BussinessViewProfile(String id) {
    // EasyLoading.show();

    setState(() {
      isLoading = true; // Show Loader
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .projectlistapi(
              (loginModel?.data?.user?.id).toString(),
              id,
              'AppLat',
              'AppLon',
            )
            .then((response) async {
              busnessviewmodal = BusnessViewModal.fromJson(
                json.decode(response.body),
              );
              if (response.statusCode == 200) {
                print("done LIst");
                //log("data ave che che ${response.body}");
                //  EasyLoading.dismiss();
                setState(() {
                  isLoading = false; // Hide Loader
                });

                // await _showBottomSheet(busnessviewmodal);
              } else if (response.statusCode == 422) {
                // EasyLoading.dismiss();
                setState(() {
                  isLoading = false; // Hide Loader
                });
              } else {
                //EasyLoading.dismiss();
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

  GetCartDetailApi() {
    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .GetCartDetailsApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              checkoutTotal = CartDetailsModel.fromJson(
                jsonDecode(response.body),
              );
              if (response.statusCode == 200) {
                print("adfdsfsdf${response.body}");
                print(
                  "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
                );

                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
                log("Error");
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

  CheckOutAPI(String picktime, paymentOption) {
    setState(() {
      isCheckout = true;
    });
    String apiValue = getPaymentMethodForApi(paymentOption);
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "pickup_time": picktime.toString(),
      "payment_gateway": apiValue,
    };

    log("Sending quantity update: $data");

    checkInternet().then((internet) async {
      if (internet) {
        CheckoutProvider().ProductCheckoutApi(data).then((response) async {
          placeOrderModel = PlaceOrderModel.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200) {
            log("Quantity updated successfully: ${response.body}");
            setState(() {
              isCheckout = false;
            });
            log(
              "Payment Link Ave che che ###${placeOrderModel?.data?.paymentUrl.toString()}",
            );
            _openPaymentPage(
              placeOrderModel?.data?.paymentUrl.toString() ?? "",
            );
          } else {
            setState(() {
              isCheckout = false;
            });
            log("Error updating quantity");
          }
        });
      } else {
        setState(() {
          isCheckout = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  _openPaymentPage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StripeWebView(title: 'Pay Online', link: url),
      ),
    );
  }

  // var applePayButton = ApplePayButton(
  //   paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
  //   paymentItems: const [
  //     PaymentItem(
  //       label: 'Item A',
  //       amount: '0.01',
  //       status: PaymentItemStatus.final_price,
  //     ),
  //     PaymentItem(
  //       label: 'Item B',
  //       amount: '0.01',
  //       status: PaymentItemStatus.final_price,
  //     ),
  //     PaymentItem(
  //       label: 'Total',
  //       amount: '0.02',
  //       status: PaymentItemStatus.final_price,
  //     ),
  //   ],
  //   style: ApplePayButtonStyle.black,
  //   width: double.infinity,
  //   height: 50,
  //   type: ApplePayButtonType.buy,
  //   margin: const EdgeInsets.only(top: 15.0),
  //   onPaymentResult: (result) => debugPrint('Payment Result $result'),
  //   loadingIndicator: const Center(child: CircularProgressIndicator()),
  // );

  // var googlePayButton = GooglePayButton(
  //   paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
  //   paymentItems: const [
  //     PaymentItem(
  //       label: 'Total',
  //       amount: '100.0',
  //       status: PaymentItemStatus.final_price,
  //     ),
  //   ],
  //   onPressed: () {},
  //   type: GooglePayButtonType.pay,
  //   width: double.infinity,
  //   margin: const EdgeInsets.only(top: 15.0),
  //   onPaymentResult: (result) => debugPrint('Payment Result ave che $result'),
  //   loadingIndicator: const Center(
  //     child: CircularProgressIndicator(color: AppColors.white),
  //   ),
  // );
}
