import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'queue_insertion_service.dart';

class MediaExtractionResult {
  final Map<String, dynamic> metadata;
  final List<MediaQueueItem> mediaItems;

  MediaExtractionResult(this.metadata, this.mediaItems);
}

class MediaExtractionHelper {
  static Future<MediaExtractionResult> extractMediaFields(
    Map<String, dynamic> payload,
    String workflowType,
  ) async {
    final Map<String, dynamic> metadata = {};
    final List<MediaQueueItem> mediaItems = [];
    final uuid = const Uuid();

    for (final entry in payload.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        final item = await _createMediaItem(key, value, uuid.v4(), workflowType);
        mediaItems.add(item);
        // Inject the placeholder AssetId back into metadata
        metadata[key] = '\${${item.mediaKeyName}}';
      } else if (value is List<File>) {
        final List<String> placeholders = [];
        for (int i = 0; i < value.length; i++) {
          final file = value[i];
          final item = await _createMediaItem("${key}AssetIds_$i", file, uuid.v4(), workflowType);
          mediaItems.add(item);
          placeholders.add('\${${item.mediaKeyName}}');
        }
        metadata[key] = placeholders;
      } else if (value != null) {
        metadata[key] = value.toString();
      }
    }

    return MediaExtractionResult(metadata, mediaItems);
  }

  static Future<MediaQueueItem> _createMediaItem(
      String baseKey, File file, String mediaUuid, String workflowType) async {
    final fileName = p.basename(file.path);
    final ext = p.extension(file.path).toLowerCase();
    
    String mimeType = 'application/octet-stream';
    if (ext == '.jpg' || ext == '.jpeg') mimeType = 'image/jpeg';
    else if (ext == '.png') mimeType = 'image/png';
    else if (ext == '.mp4') mimeType = 'video/mp4';
    else if (ext == '.pdf') mimeType = 'application/pdf';

    final bytes = await file.readAsBytes();
    final fileSizeBytes = bytes.length;
    final checksum = md5.convert(bytes).toString();

    // Mapping logic for AssetIds
    final mediaKeyName = baseKey.endsWith('AssetId') || baseKey.endsWith('AssetIds')
        ? baseKey 
        : '${baseKey}AssetId';

    return MediaQueueItem(
      mediaUuid: mediaUuid,
      localFilePath: file.path,
      fileName: fileName,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      checksum: checksum,
      mediaKeyName: mediaKeyName,
    );
  }
}
