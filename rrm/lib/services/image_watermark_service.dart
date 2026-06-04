import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageWatermarkService {
  static Future<File> addWatermark(File sourceImage, Position? position) async {
    final bytes = await sourceImage.readAsBytes();
    
    // Get current date and time
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);
    
    String latStr = position != null ? position.latitude.toStringAsFixed(6) : "Unknown";
    String lngStr = position != null ? position.longitude.toStringAsFixed(6) : "Unknown";
    
    final watermarkData = {
      'bytes': bytes,
      'lat': latStr,
      'lng': lngStr,
      'date': dateStr,
      'time': timeStr,
    };
    
    final processedBytes = await compute(_addWatermarkSync, watermarkData);
    
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final resultFile = File(tempPath);
    await resultFile.writeAsBytes(processedBytes);
    return resultFile;
  }

  static List<int> _addWatermarkSync(Map<String, dynamic> data) {
    final bytes = data['bytes'] as List<int>;
    final lat = data['lat'] as String;
    final lng = data['lng'] as String;
    final date = data['date'] as String;
    final time = data['time'] as String;
    
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return bytes;
    
    final String watermarkText = "Lat: $lat   Lng: $lng\nDate: $date   Time: $time";
    
    // Using arial_48
    final font = img.arial48;
    
    // text area dimensions
    int lines = 2;
    int lineHeight = font.lineHeight; // Usually 48
    int textHeight = lines * lineHeight;
    int textWidth = 850; // Approximated width for "Lat: XX.XXXXXX   Lng: XX.XXXXXX" with size 48
    
    int padding = 20;
    int rectX1 = 0;
    int rectY1 = image.height - textHeight - (padding * 2);
    int rectX2 = textWidth + (padding * 2);
    int rectY2 = image.height;
    
    // Draw semi-transparent background (black with alpha 90 for lighter side)
    img.fillRect(image, x1: rectX1, y1: rectY1, x2: rectX2, y2: rectY2, color: img.ColorRgba8(0, 0, 0, 90));
    
    // Draw text (white)
    int currentY = rectY1 + padding;
    for (var line in watermarkText.split('\n')) {
      img.drawString(image, line, font: font, x: padding, y: currentY, color: img.ColorRgb8(255, 255, 255));
      currentY += lineHeight;
    }
    
    return img.encodeJpg(image, quality: 90);
  }
}
