import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> captureImage() async {
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint("Camera capture error: $e");
    }
    
    return pickedFile;
  }
}
