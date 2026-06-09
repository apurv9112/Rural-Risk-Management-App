import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FolderManager {
  static const String rootFolder = 'RRM';
  
  static const List<String> requiredFolders = [
    'auth',
    'signatures',
    'database',
    'leads/tagging',
    'leads/retagging',
    'leads/claim',
    'media/tagging',
    'media/retagging',
    'media/claim',
    'logs'
  ];

  static Future<void> initializeStructure() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final rootPath = p.join(appDocDir.path, rootFolder);

    for (final folder in requiredFolders) {
      final folderPath = p.join(rootPath, folder);
      final directory = Directory(folderPath);
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
    }
  }

  static Future<String> getFolderPath(String subPath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return p.join(appDocDir.path, rootFolder, subPath);
  }

  /// Returns partitioned folder path: RRM/media/YYYY/MM
  static Future<String> getPartitionedMediaFolder(String workflowType, DateTime timestamp) async {
    final year = timestamp.year.toString();
    final month = timestamp.month.toString().padLeft(2, '0');
    final subPath = p.join('media', workflowType, year, month);
    final appDocDir = await getApplicationDocumentsDirectory();
    final folderPath = p.join(appDocDir.path, rootFolder, subPath);
    
    final directory = Directory(folderPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    
    return folderPath;
  }

  static String _generateFileName(String workflowType, DateTime timestamp, String uuid, String extension) {
    final yyyymmdd = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final hhmmss = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '${workflowType}_${yyyymmdd}_${hhmmss}_$uuid$ext';
  }

  static Future<File> saveMediaFile(File sourceFile, String workflowType, String mediaUuid, String extension) async {
    final timestamp = DateTime.now();
    final folderPath = await getPartitionedMediaFolder(workflowType, timestamp);
    final fileName = _generateFileName(workflowType, timestamp, mediaUuid, extension);
    final destPath = p.join(folderPath, fileName);
    return await sourceFile.copy(destPath);
  }

  static Future<File> moveFromCache(File sourceFile, String workflowType, String mediaUuid, String extension) async {
    final destFile = await saveMediaFile(sourceFile, workflowType, mediaUuid, extension);
    if (await sourceFile.exists()) {
      await sourceFile.delete();
    }
    return destFile;
  }

  static Future<void> deleteMediaFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> cleanupCompletedMedia(String workflowType, DateTime before) async {
    // Basic cleanup placeholder: iterates and deletes media older than 'before'
    // This can be expanded based on specific retention rules
  }

  static Future<String?> migrateDraftPathIfNeeded(String oldPath, String workflowType, String mediaUuid) async {
    // If it's already in the persistent partition, do nothing
    if (!oldPath.contains('/cache/') && !oldPath.contains('/tmp/')) {
      return oldPath;
    }

    final file = File(oldPath);
    if (!(await file.exists())) {
      return null; // media is missing
    }

    final ext = p.extension(oldPath);
    final newFile = await moveFromCache(file, workflowType, mediaUuid, ext);
    return newFile.path;
  }
}
