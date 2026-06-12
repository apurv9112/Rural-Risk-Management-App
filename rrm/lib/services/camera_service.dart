import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rrm/core/storage/folder_manager.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> captureImage() async {
    XFile? pickedFile;
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        final persistentFile = await FolderManager.moveFromCache(File(file.path), workflow: 'temp');
        pickedFile = XFile(persistentFile.path);
      }
    } catch (e) {
      debugPrint("Camera capture error: $e");
    }
    
    return pickedFile;
  }
}
