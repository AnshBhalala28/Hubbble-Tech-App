import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await _isAndroid13orAbove()) {
      var imageResult = await Permission.photos.request();
      var videoResult = await Permission.videos.request();
      var audioResult = await Permission.audio.request();

      return imageResult.isGranted &&
          videoResult.isGranted &&
          audioResult.isGranted;
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  } else if (Platform.isIOS) {
    return true;
  }
  return false;
}

Future<bool> _isAndroid13orAbove() async {
  return (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33;
}

Future<Directory?> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  }
  return null;
}

Future<void> downloadFile(
  String url,
  BuildContext context,
  String filename,
  String extension,
) async {
  try {
    bool permissionGranted = await requestStoragePermission();

    if (permissionGranted || Platform.isIOS) {
      Dio dio = Dio();
      Directory? downloadDir = await getDownloadDirectory();

      if (downloadDir == null) {
        throw Exception("Downloads directory not found");
      }

      Directory appDir = Directory('${downloadDir.path}/Project Manager');
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      String formattedTime = DateFormat(
        'yyyy-MM-dd-hh-mm-ss-a',
      ).format(DateTime.now());
      String filePath = '${appDir.path}/$filename-$formattedTime.$extension';

      ValueNotifier<double> downloadProgress = ValueNotifier(0.0);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ValueListenableBuilder<double>(
            valueListenable: downloadProgress,
            builder: (context, value, child) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color(0xff232323),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff232323),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Downloading File",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'task',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              color: Colors.grey.shade200,
                              strokeWidth: 6.0,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: value,
                              color: Colors.green,
                              strokeWidth: 6.0,
                            ),
                          ),
                          Text(
                            "${(value * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: "File downloaded successfully: $filePath",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Storage permission denied",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    Navigator.of(context).pop();

    Fluttertoast.showToast(
      msg: "Error: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
