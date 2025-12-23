import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/expension_tile.dart';
import '../../../Utils/loader.dart';
import '../../../Utils/stripeWebView.dart';
import '../../CartScreen/model/cartDetailsModal.dart';
import '../../CommunityScreen/Provider/communityProvider.dart';
import '../../CommunityScreen/modal/BusnessViewModal.dart';
import '../../cartScreen/provider/addToCartProvider.dart';
import '../../thankYouPage/view/thankYouPage.dart';
import '../modal/placeOrderModel.dart';
import '../provider/checkOutProvider.dart';

class BuyProductView extends StatefulWidget {
  String? type;
  String? bunessid;

  BuyProductView({super.key, this.type, this.bunessid});

  @override
  State<BuyProductView> createState() => _BuyProductViewState();
}

class _BuyProductViewState extends State<BuyProductView> {
  final GlobalKey<ScaffoldState> buyKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isCheckout = false;
  String selectedPayment = "";
  String selectedPickupTime = "";
  String transactionStatus = "No transaction yet.";
  String AppLat = '';
  String AppLon = '';
  final bool _mapVisible = false;

  List<Map<String, dynamic>> timeSlots = [];

  Future<void> initPickupSlots() async {
    tz.initializeTimeZones();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String country = placemarks.first.country ?? "";

    String region;
    if (country.toLowerCase().contains("india")) {
      region = "India";
    } else if (country.toLowerCase().contains("united kingdom")) {
      region = "UK";
    } else {
      region = "India";
    }

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

    if (mounted) setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();

        BussinessViewProfile(widget.bunessid ?? "");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    GetCartDetailApi();

    initPickupSlots();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = getSubtotal();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TitleBar(title: "Checkout", drawerCallback: () {}),
                isLoading
                    ? Expanded(child: Center(child: Loader()))
                    : Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 1.h),
                            Column(
                              children: [
                                _buildInfoTile(
                                  ontap: () {},
                                  icon: Icons.storefront,
                                  subtitle:
                                      busnessviewmodal
                                          ?.data
                                          ?.business
                                          ?.businessName ??
                                      "N/A",
                                ),
                                _buildInfoTile(
                                  ontap: () {
                                    final phone =
                                        busnessviewmodal
                                            ?.data
                                            ?.business
                                            ?.user
                                            ?.mobileNo;
                                    if (phone != null &&
                                        phone.toString().isNotEmpty) {
                                      final telUrl = Uri.parse(
                                        "tel:${phone.toString()}",
                                      );
                                      launchUrl(
                                        telUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  icon: Icons.phone,
                                  subtitle:
                                      busnessviewmodal
                                          ?.data
                                          ?.business
                                          ?.user
                                          ?.mobileNo
                                          ?.toString() ??
                                      "N/A",
                                ),
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  margin: EdgeInsets.only(top: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                            ),
                                            child: Icon(
                                              Icons.map,
                                              color: Colors.grey[600],
                                              size: 20.sp,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Business Location",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 0.2.h),
                                                Text(
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
                                                      ? "Location on map"
                                                      : "${busnessviewmodal?.data?.business?.user?.address?.address}",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 1.h),
                                      Container(
                                        height: 110,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child:
                                            (busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.latitude !=
                                                        null &&
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.longitude !=
                                                        null)
                                                ? GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                        target: LatLng(
                                                          double.parse(
                                                            busnessviewmodal!
                                                                .data!
                                                                .business!
                                                                .latitude
                                                                .toString(),
                                                          ),
                                                          double.parse(
                                                            busnessviewmodal!
                                                                .data!
                                                                .business!
                                                                .longitude
                                                                .toString(),
                                                          ),
                                                        ),
                                                        zoom: 15.0,
                                                      ),
                                                  markers: {
                                                    Marker(
                                                      markerId: const MarkerId(
                                                        'business',
                                                      ),
                                                      position: LatLng(
                                                        double.parse(
                                                          busnessviewmodal!
                                                              .data!
                                                              .business!
                                                              .latitude
                                                              .toString(),
                                                        ),
                                                        double.parse(
                                                          busnessviewmodal!
                                                              .data!
                                                              .business!
                                                              .longitude
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  },
                                                  zoomControlsEnabled: false,
                                                  scrollGesturesEnabled: true,
                                                  zoomGesturesEnabled: true,
                                                )
                                                : Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: Text(
                                                      "Location not available",
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildSectionCard(
                                  title: "Opening Hours",
                                  icon: Icons.access_time,
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: CustomExpansionTile(
                                      fontSize: 16.sp,
                                      title: _getCurrentDayStatus(),
                                      leadingIcon: Icons.timer,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Column(
                                            children: [
                                              _buildHoursRow(
                                                "Monday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.monday,
                                              ),
                                              _buildHoursRow(
                                                "Tuesday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.tuesday,
                                              ),
                                              _buildHoursRow(
                                                "Wednesday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.wednesday,
                                              ),
                                              _buildHoursRow(
                                                "Thursday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.thursday,
                                              ),
                                              _buildHoursRow(
                                                "Friday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.friday,
                                              ),
                                              _buildHoursRow(
                                                "Saturday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.saturday,
                                              ),
                                              _buildHoursRow(
                                                "Sunday",
                                                busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.openingHours
                                                    ?.sunday,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildSectionCard(
                              title: "Payment Method",
                              icon: Icons.payment,
                              child: Column(
                                children: [
                                  _buildPaymentOption(
                                    image:
                                        "assets/images/stripe_pay_image2.png",
                                    title: "Stripe",
                                    subtitle: "Pay securely with Stripe",
                                    value: "Stripe",
                                  ),
                                  // Platform.isAndroid
                                  //     ? GooglePayButton(
                                  //         paymentConfiguration:
                                  //             PaymentConfiguration
                                  //                 .fromJsonString(
                                  //                     defaultGooglePay),
                                  //         paymentItems: [
                                  //           PaymentItem(
                                  //             label: 'Total',
                                  //             amount:
                                  //                 subtotal.toStringAsFixed(2),
                                  //             status: PaymentItemStatus
                                  //                 .final_price,
                                  //           )
                                  //         ],
                                  //         onPressed: () {},
                                  //         type: GooglePayButtonType.pay,
                                  //         width: double.infinity,
                                  //         margin: const EdgeInsets.only(
                                  //             top: 15.0),
                                  //         onPaymentResult: (result) {
                                  //           debug
                                  //           debugPrint(
                                  //               '💳 Card Description: ${result['paymentMethodData']['description']}');
                                  //           debugPrint(
                                  //               '📞 Phone: ${result['paymentMethodData']['info']['billingAddress']['phoneNumber']}');
                                  //           debugPrint(
                                  //               '🏠 Address: ${result['paymentMethodData']['info']['billingAddress']['address1']}');
                                  //           debugPrint(
                                  //               '🌍 Country: ${result['paymentMethodData']['info']['billingAddress']['countryCode']}');
                                  //           debugPrint(
                                  //               '🧾 Card Last 4 Digits: ${result['paymentMethodData']['info']['cardDetails']}');
                                  //           debugPrint(
                                  //               '📦 Token: ${result['paymentMethodData']['tokenizationData']['token']}');
                                  //         },
                                  //         loadingIndicator: const Center(
                                  //           child: CircularProgressIndicator(
                                  //             color: AppColors.white,
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : ApplePayButton(
                                  //         paymentConfiguration:
                                  //             PaymentConfiguration
                                  //                 .fromJsonString(
                                  //                     defaultApplePay),
                                  //         paymentItems: [
                                  //           PaymentItem(
                                  //             label: 'Item A',
                                  //             amount:
                                  //                 subtotal.toStringAsFixed(2),
                                  //             status: PaymentItemStatus
                                  //                 .final_price,
                                  //           ),
                                  //         ],
                                  //         style: ApplePayButtonStyle.black,
                                  //         width: double.infinity,
                                  //         height: 50,
                                  //         type: ApplePayButtonType.buy,
                                  //         margin: const EdgeInsets.only(
                                  //             top: 15.0),
                                  //         onPaymentResult: (result) {
                                  //           debugPrint(
                                  //               'Payment Result $result');
                                  //         },
                                  //         loadingIndicator: const Center(
                                  //           child:
                                  //               CircularProgressIndicator(),
                                  //         ),
                                  //       ),
                                ],
                              ),
                            ),
                            _buildSectionCard(
                              title: "Order Summary",
                              icon: Icons.receipt,
                              child: Column(
                                children: [
                                  widget.type != 'service'
                                      ? _buildSummaryRow(
                                        "Subtotal",
                                        getSubtotal(),
                                      )
                                      : _buildSummaryRow(
                                        "Subtotal",
                                        getSubtotal1(),
                                      ),
                                  cartDetailsModel?.data?[0].type ==
                                              "product" &&
                                          cartDetailsModel
                                                  ?.data?[0]
                                                  .loyaltyDetails
                                                  ?.willGetLoyaltyDiscountOnCurrentOrder ==
                                              true
                                      ? _buildSummaryRow(
                                        "Loyalty Discount (-${getLoyaltyDiscountPercentage().toStringAsFixed(0)}%)",
                                        getLoyaltyDiscountAmount(),
                                        isDiscount: true,
                                      )
                                      : const SizedBox(),
                                  Divider(height: 2.5.h, thickness: 1),
                                  widget.type != 'service'
                                      ? _buildSummaryRow(
                                        "Total",
                                        getFinalTotal(),
                                        isTotal: true,
                                      )
                                      : _buildSummaryRow(
                                        "Total",
                                        getSubtotal1(),
                                        isTotal: true,
                                      ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            GestureDetector(
                              onTap: () {
                                if (selectedPayment.isEmpty) {
                                  Get.snackbar(
                                    "Payment Method Required",
                                    "Please select a payment method before placing your order.",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(10),
                                    snackPosition: SnackPosition.TOP,
                                  );
                                } else if (selectedPayment.toLowerCase() ==
                                    "stripe") {
                                  CheckOutAPI(
                                    selectedPickupTime,
                                    selectedPayment.toLowerCase(),
                                  );
                                } else {
                                  Get.to(const ThankYouPage());
                                }
                              },
                              child: Container(
                                height: 6.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.maincolor,
                                      AppColors.maincolor.withValues(
                                        alpha: 0.8,
                                      ),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.maincolor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag,
                                      color: Colors.white,
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      "Click & Collect",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontFamily: AppConstants.manrope,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
          if (isCheckout)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
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

  double getSubtotal1() {
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
              isSelected
                  ? AppColors.maincolor.withValues(alpha: 0.08)
                  : Colors.white,
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
            const Spacer(),
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
        color: Colors.grey.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
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
    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().businessProfileViewApi(id, AppLat, AppLon).then((
          response,
        ) async {
          busnessviewmodal = BusnessViewModal.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
          } else if (response.statusCode == 422) {
            setState(() {
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

  GetCartDetailApi() {
    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .cartDetailApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              checkoutTotal = CartDetailsModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
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

    checkInternet().then((internet) async {
      if (internet) {
        CheckoutProvider().productCheckoutApi(data).then((response) async {
          placeOrderModel = PlaceOrderModel.fromJson(response.data);

          if (response.statusCode == 200) {
            setState(() {
              isCheckout = false;
            });

            _openPaymentPage(
              placeOrderModel?.data?.paymentUrl.toString() ?? "",
            );
          } else {
            setState(() {
              isCheckout = false;
            });
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.maincolor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.maincolor, size: 20.sp),
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppConstants.manropeBold,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(4.w), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String subtitle,
    required VoidCallback ontap,
  }) {
    return InkWell(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18.sp, color: Colors.grey[600]),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppConstants.manropeBold,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 17.sp : 17.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              color:
                  isDiscount
                      ? Colors.green[700]
                      : (isTotal ? Colors.black : Colors.black),
            ),
          ),
          Text(
            isDiscount
                ? "-£${amount.toStringAsFixed(2)}"
                : "£${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 17.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              color:
                  isDiscount
                      ? Colors.green[700]
                      : (isTotal ? AppColors.maincolor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String image,
    required String title,
    required String subtitle,
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
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.maincolor.withValues(alpha: 0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.maincolor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Image.asset(
                image,
                height: 4.h,
                width: 8.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.maincolor : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.maincolor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  double getLoyaltyDiscountPercentage() {
    final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
    if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
      return 0.0;
    }
    String discountStr =
        checkoutTotal?.data?.first.loyaltyDetails?.loyaltyDiscountPercentage ??
        "0";
    return double.tryParse(discountStr) ?? 0.0;
  }

  double getLoyaltyDiscountAmount() {
    final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
    if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
      return 0.0;
    }

    double subtotal = getSubtotal();
    double discountPercent = getLoyaltyDiscountPercentage();

    return subtotal * (discountPercent / 100);
  }

  double getFinalTotal() {
    double subtotal = getSubtotal();
    double loyaltyDiscount = getLoyaltyDiscountAmount();
    return subtotal - loyaltyDiscount;
  }

  String _getCurrentDayStatus() {
    final now = DateTime.now();
    final today = _getDayName(now.weekday);
    final todayHours = _getHoursForDay(today);

    if (todayHours == null) {
      return "Not Set Yet";
    }

    if (todayHours.closed == true) {
      return "Closed Today";
    }

    if (todayHours.open != null && todayHours.close != null) {
      return "${todayHours.open} - ${todayHours.close}";
    }

    return "Hours not available";
  }

  Widget _buildHoursRow(String day, dynamic dayHours) {
    final isToday = day == _getDayName(DateTime.now().weekday);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration:
          isToday
              ? BoxDecoration(
                color: AppColors.maincolor,
                borderRadius: BorderRadius.circular(6),
              )
              : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isToday ? 8 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.white : Colors.black87,
                fontFamily: AppConstants.manrope,
              ),
            ),
            Text(
              _getHoursText(dayHours),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.white : Colors.grey[600],
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Monday";
    }
  }

  dynamic _getHoursForDay(String day) {
    final openingHours = busnessviewmodal?.data?.business?.openingHours;
    if (openingHours == null) return null;

    switch (day.toLowerCase()) {
      case "monday":
        return openingHours.monday;
      case "tuesday":
        return openingHours.tuesday;
      case "wednesday":
        return openingHours.wednesday;
      case "thursday":
        return openingHours.thursday;
      case "friday":
        return openingHours.friday;
      case "saturday":
        return openingHours.saturday;
      case "sunday":
        return openingHours.sunday;
      default:
        return null;
    }
  }

  String _getHoursText(dynamic dayHours) {
    if (dayHours == null) return "N/A";
    if (dayHours.closed == true) return "Closed";
    if (dayHours.open != null && dayHours.close != null) {
      return "${dayHours.open} - ${dayHours.close}";
    }
    return "N/A";
  }
}
