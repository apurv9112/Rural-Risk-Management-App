import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rrm/core/storage/folder_manager.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> captureImage(
    String workflowType,
    String mediaUuid,
  ) async {
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        final persistentFile = await FolderManager.moveFromCache(
          File(file.path),
          workflow: workflowType,
          uuid: mediaUuid,
          extension: file.path.split('.').last,
        );
        return persistentFile;
      }
    } catch (e) {
      debugPrint("Camera capture error: $e");
    }

    return null;
  }
}
