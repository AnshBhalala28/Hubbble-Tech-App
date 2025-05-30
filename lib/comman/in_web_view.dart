import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Buy%20Product/place_order_model.dart';
import 'package:wavee/Screen/Thankyou%20Page/view/thankyou_page.dart';
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

                log("Current URL app redirect: $url");

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

    // Platform specific configuration
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title.toString(),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontFamily: "task",
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

    log("Checkout API data: $data");

    checkInternet().then((internet) async {
      if (internet) {
        CheckoutProvider().ProductCheckoutApi(data).then((response) async {
          placeOrderModel = PlaceOrderModel.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200) {
            log("Checkout successful: ${response.body}");
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            log("Payment URL: ${placeOrderModel?.data?.paymentUrl.toString()}");
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            log("Error during checkout");
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
