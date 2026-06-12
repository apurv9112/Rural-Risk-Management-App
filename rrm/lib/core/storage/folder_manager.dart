import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class FolderManager {
  static const String rootFolder = 'RRM';
  static const _uuid = Uuid();
  static Directory? _baseDir;

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
    'media/kyc',
    'media/cancel_lead',
    'temp',
    'logs'
  ];

  static Future<void> initializeStructure() async {
    await init();
  }

  static Future<void> init() async {
    if (_baseDir != null) return;
    final docDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory(p.join(docDir.path, rootFolder));
    
    for (final folder in requiredFolders) {
      final folderPath = p.join(_baseDir!.path, folder);
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

  static Future<String> getPartitionedMediaFolder(String workflowType, DateTime timestamp) async {
    final year = timestamp.year.toString();
    final month = timestamp.month.toString().padLeft(2, '0');
    final subPath = p.join('media', workflowType, year, month);
    final folderPath = await getFolderPath(subPath);
    
    final directory = Directory(folderPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    
    return folderPath;
  }

  static Future<String> getDirectoryForWorkflow(String workflow) async {
    await init();
    if (workflow == 'temp') {
      return p.join(_baseDir!.path, 'temp');
    }
    return await getPartitionedMediaFolder(workflow, DateTime.now());
  }

  static String generateFileName(String workflow, String extension, [String? uuid]) {
    final finalUuid = uuid ?? _uuid.v4();
    final timestamp = DateTime.now();
    final yyyymmdd = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final hhmmss = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '${workflow}_${yyyymmdd}_${hhmmss}_$finalUuid$ext';
  }

  static Future<File> saveMediaFile(File sourceFile, String workflowType, String mediaUuid, String extension) async {
    final timestamp = DateTime.now();
    final folderPath = await getPartitionedMediaFolder(workflowType, timestamp);
    final ext = extension.startsWith('.') ? extension.substring(1) : extension;
    final fileName = generateFileName(workflowType, ext, mediaUuid);
    final destPath = p.join(folderPath, fileName);
    return await sourceFile.copy(destPath);
  }

  static Future<File> moveFromCache(File sourceFile, {String workflow = 'temp', String? uuid, String? mediaUuid, String? extension}) async {
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourceFile.path);
    }

    final ext = extension ?? sourceFile.path.split('.').last;
    final finalUuid = uuid ?? mediaUuid ?? _uuid.v4();
    
    final destFile = await saveMediaFile(sourceFile, workflow, finalUuid, ext);
    try {
      await sourceFile.delete();
    } catch (e) {
      // Best effort deletion
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
    // Basic cleanup placeholder
  }

  static Future<String?> migrateDraftPathIfNeeded(String oldPath, [String? workflowType, String? mediaUuid]) async {
    if (oldPath.isEmpty) return null;
    
    final file = File(oldPath);
    if (!await file.exists()) {
      return null;
    }

    if (oldPath.contains('/RRM/media/') || oldPath.contains('\\RRM\\media\\') || 
        oldPath.contains('/RRM/temp/') || oldPath.contains('\\RRM\\temp\\') ||
        (!oldPath.contains('/cache/') && !oldPath.contains('/tmp/'))) {
      return oldPath;
    }

    final newFile = await moveFromCache(file, workflow: workflowType ?? 'temp', uuid: mediaUuid);
    return newFile.path;
  }
}
