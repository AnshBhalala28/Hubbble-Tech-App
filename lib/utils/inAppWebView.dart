import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  bool isLoading = true;
  double progressValue = 0;

  String getDisplayUrl() {
    try {
      Uri uri = Uri.parse(widget.url);
      return uri.host.replaceAll("www.", "");
    } catch (_) {
      return widget.url;
    }
  }

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                setState(() {
                  progressValue = progress / 100;
                });
              },
              onPageStarted: (_) {
                setState(() => isLoading = true);
              },
              onPageFinished: (_) {
                setState(() => isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),

        title: Text(
          getDisplayUrl(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          // Progress Bar
          if (progressValue < 1.0)
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 3,
              backgroundColor: Colors.grey.shade300,
            ),

          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: controller),

                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
