import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rrm/services/camera_service.dart';
import 'package:rrm/services/image_processing_service.dart';
import 'package:rrm/services/image_watermark_service.dart';
import 'package:rrm/core/storage/folder_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync('docs_').path;
  }
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.createTempSync('temp_').path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  test('M16.22.1: Physical Workflow Trace', () async {
    await FolderManager.init();
    
    // Simulate Cattle workflow
    final tempDir = Directory.systemTemp.createTempSync('os_cache_');
    final dummyImage = File('${tempDir.path}/dummy_camera.jpg');
    await dummyImage.writeAsBytes([0, 0, 0, 0]);

    // 1. Camera Service (Simulated output)
    final persistentFile = await FolderManager.moveFromCache(dummyImage, workflow: 'temp');
    print('Camera Output Path: ${persistentFile.path}');

    // 2. Image Processing Service
    final processedFile = await ImageProcessingService.processImage(persistentFile);
    print('Processed Output Path: ${processedFile.path}');

    // 3. Image Watermark Service
    final position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
    final watermarkedFile = await ImageWatermarkService.addWatermark(processedFile, position);
    print('Watermarked Output Path: ${watermarkedFile.path}');

    if (!watermarkedFile.path.contains('RRM/media') && !watermarkedFile.path.contains('RRM/temp')) {
      print('FAIL: Final cattle image leaked outside FolderManager to OS cache: ${watermarkedFile.path}');
    }

  });
}
