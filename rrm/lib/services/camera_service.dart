import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/storage/folder_manager.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> captureImage(String workflowType, String mediaUuid) async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final ext = pickedFile.path.split('.').last;
        final persistentFile = await FolderManager.moveFromCache(File(pickedFile.path), workflowType, mediaUuid, ext);
        return persistentFile;
      }
    } catch (e) {
      debugPrint("Camera capture error: $e");
    }
    
    return null;
  }
}
