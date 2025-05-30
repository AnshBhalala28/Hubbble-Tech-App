import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wavee/comman/colors.dart';

import 'downloadFunctions.dart';

class PdfView extends StatefulWidget {
  final String? link;

  PdfView({Key? key, this.link}) : super(key: key);

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String? downloadedFilePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('Link Is : ${widget.link}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maincolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  Text(
                    'View Pdf',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: "task",
                      letterSpacing: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => downloadFile(
                          widget.link ?? '',
                          context,
                          ((widget.link ?? '')
                                  .split('/')
                                  .last
                                  .split('.')
                                  .first ??
                              ''),
                          ((widget.link ?? '')
                                  .split('/')
                                  .last
                                  .split('.')
                                  .last ??
                              ''),
                        ),
                    icon: Icon(
                      Icons.file_download,
                      size: 19.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(height: 85.h, child: _buildPdfViewer()),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (widget.link != null && widget.link!.isNotEmpty) {
      final link = widget.link!.trim(); // Remove any leading or trailing spaces

      try {
        final uri = Uri.parse(link);

        // Check if it's a valid URL
        if (uri.scheme == 'file' && downloadedFilePath != null) {
          return SfPdfViewer.file(File(downloadedFilePath!));
        } else if (uri.scheme == 'http' || uri.scheme == 'https') {
          return SfPdfViewer.network(
            link,
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              Fluttertoast.showToast(
                msg: 'Failed to load PDF',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 13.sp,
              );
            },
          );
        }
      } catch (e) {
        print('Error: Invalid URL format');
        Fluttertoast.showToast(
          msg: 'Invalid PDF URL',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.sp,
        );
      }
    }

    return Center(
      child: Text(
        'No PDF available to display',
        style: TextStyle(
          color: Colors.white,
          fontFamily: "task",
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Future<void> _downloadFile(String? url) async {
    if (url == null || !Uri.parse(url).isAbsolute) {
      // Corrected URL validation
      Fluttertoast.showToast(
        msg: 'Invalid PDF URL',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 13.sp,
      );
      return;
    }

    try {
      EasyLoading.show(status: 'Downloading...');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final fileName =
            'Downloaded_File_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final filePath = '${documentsDirectory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Update the state with the new downloaded file path
        setState(() {
          downloadedFilePath = filePath;
        });

        EasyLoading.dismiss();
        EasyLoading.showSuccess('File downloaded successfully');
        Fluttertoast.showToast(
          msg: 'File downloaded to: $filePath',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff232323),
          textColor: Colors.white,
          fontSize: 13.sp,
        );
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to download file');
      Fluttertoast.showToast(
        msg: 'Failed to download file',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 13.sp,
      );
    }
  }
}
