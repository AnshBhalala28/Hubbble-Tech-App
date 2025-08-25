import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Buy%20Product/place_order_model.dart';
import 'package:wavee/Screen/thankYouPage/view/thankyou_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../Screen/Buy Product/provider/check_out_provider.dart';
import 'check_inernet_connecty.dart';
import 'const.dart';
import 'error_dialog.dart';

class StripeWebView extends StatefulWidget {
  final String? title;
  final String? link;

  const StripeWebView({super.key, required this.title, required this.link});

  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  late final WebViewController _webViewController;
  bool _load = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _webViewController = _createWebViewController();
  }

  WebViewController _createWebViewController() {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..loadRequest(Uri.parse(widget.link.toString()))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _load = true;
                });
              },
              onPageFinished: (String url) async {
                setState(() {
                  _load = false;
                });

                if (url.contains("payment-successful")) {
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    CheckOutAPI();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThankYouPage(),
                      ),
                    );
                  }
                }
              },
            ),
          );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          await _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 5.5.h),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 35.w),
                Text(
                  widget.title.toString(),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontFamily: AppConstants.manrope,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_load) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void CheckOutAPI() {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "session_id": placeOrderModel?.data?.sessionId.toString() ?? "",
      "is_finalizing": "true",
    };

    checkInternet().then((internet) async {
      if (internet) {
        CheckoutProvider().productCheckoutApi(data).then((response) async {
          placeOrderModel = PlaceOrderModel.fromJson(response.data);

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
}
