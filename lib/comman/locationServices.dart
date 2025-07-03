import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
//
// class LocationService {
//   Future<void> requestLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print("Location services are disabled.");
//       exit(0);
//
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print("Location permission denied.");
//         exit(0);
//
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       print("Location permissions are permanently denied.");
//       exit(0);
//
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
//   }
// }
class LocationService {
  Future<void> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showAlertDialog(context, "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showAlertDialog(context, "Location permission denied. Please allow permission.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showAlertDialog(context, "Location permission permanently denied. Please enable it from app settings.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
