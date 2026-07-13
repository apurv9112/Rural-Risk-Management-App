import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

class GalleryService {
  static Future<bool> saveImage(File file) async {
    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      await Gal.putImage(file.path);

      debugPrint("Gallery Image Saved");

      return true;
    } catch (e) {
      debugPrint("Gallery Save Error : $e");
      return false;
    }
  }

  static Future<bool> saveVideo(File file) async {
    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      await Gal.putVideo(file.path);

      debugPrint("Gallery Video Saved");

      return true;
    } catch (e) {
      debugPrint("Gallery Video Error : $e");
      return false;
    }
  }
}
