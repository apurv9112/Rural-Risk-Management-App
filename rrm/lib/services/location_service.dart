import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    // Loop until GPS is turned on, or user cancels
    while (!serviceEnabled) {
      bool? openedSettings = await Get.defaultDialog<bool>(
        title: "Location Required",
        middleText: "Please turn on device location (GPS) to capture cattle inspection photos.",
        barrierDismissible: false,
        confirm: TextButton(
          onPressed: () async {
            await Geolocator.openLocationSettings();
            Get.back(result: true);
          },
          child: const Text("Enable Location", style: TextStyle(color: Colors.green)),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
      );

      if (openedSettings != true) {
        return null; // User cancelled
      }

      // Automatically re-check
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    // 2. Check Permissions
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      bool? openedSettings = await Get.defaultDialog<bool>(
        title: "Location Permission Required",
        middleText: "Location permission is mandatory for cattle photo verification.",
        barrierDismissible: false,
        confirm: TextButton(
          onPressed: () async {
            await openAppSettings();
            Get.back(result: true);
          },
          child: const Text("Open Settings", style: TextStyle(color: Colors.green)),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
      );

      if (openedSettings != true) {
        return null;
      }

      status = await Permission.location.status;
      if (!status.isGranted) {
        return null;
      }
    }

    // 3. Get Location
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        return position;
      } catch (e) {
        return await Geolocator.getLastKnownPosition();
      }
    }
    
    return null;
  }
}
