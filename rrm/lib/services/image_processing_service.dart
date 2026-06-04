import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  static Future<File> processImage(File sourceImage) async {
    final bytes = await sourceImage.readAsBytes();
    
    // Process image in a separate isolate to avoid UI jank
    final processedBytes = await compute(_processImageSync, bytes);
    
    // Save to temp directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final resultFile = File(tempPath);
    await resultFile.writeAsBytes(processedBytes);
    return resultFile;
  }

  static List<int> _processImageSync(List<int> bytes) {
    // Decode image
    img.Image? original = img.decodeImage(Uint8List.fromList(bytes));
    if (original == null) return bytes;

    // New target: Landscape (1440 x 1080, Aspect Ratio 4:3)
    // By enforcing this target ratio, portrait images will naturally 
    // be center-cropped (top and bottom removed) without rotation.
    int targetWidth = 1440;
    int targetHeight = 1080;
    
    double srcRatio = original.width / original.height;
    double targetRatio = 4 / 3;
    
    int cropWidth, cropHeight, cropX, cropY;
    
    if (srcRatio > targetRatio) {
      // Original is wider than 4:3. Crop width.
      cropHeight = original.height;
      cropWidth = (cropHeight * targetRatio).round();
      cropX = ((original.width - cropWidth) / 2).round();
      cropY = 0;
    } else {
      // Original is taller than 4:3. Crop height.
      cropWidth = original.width;
      cropHeight = (cropWidth / targetRatio).round();
      cropX = 0;
      cropY = ((original.height - cropHeight) / 2).round();
    }
    
    // Crop
    final cropped = img.copyCrop(original, x: cropX, y: cropY, width: cropWidth, height: cropHeight);
    
    // Resize
    final resized = img.copyResize(cropped, width: targetWidth, height: targetHeight);
    
    // Compress & Encode (85% quality)
    return img.encodeJpg(resized, quality: 85);
  }
}
