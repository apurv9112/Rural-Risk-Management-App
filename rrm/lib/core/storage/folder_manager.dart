import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FolderManager {
  static const _uuid = Uuid();
  static Directory? _baseDir;

  static Future<void> init() async {
    if (_baseDir != null) return;
    final docDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory('${docDir.path}/RRM');
    
    // Create base structure
    final folders = [
      'media/tagging',
      'media/retagging',
      'media/claim',
      'media/kyc',
      'media/cancel_lead',
      'temp'
    ];

    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');

    for (var folder in folders) {
      if (folder.startsWith('media/')) {
        await Directory('${_baseDir!.path}/$folder/$year/$month').create(recursive: true);
      } else {
        await Directory('${_baseDir!.path}/$folder').create(recursive: true);
      }
    }
  }

  static Future<String> getDirectoryForWorkflow(String workflow) async {
    await init();
    if (workflow == 'temp') {
      return '${_baseDir!.path}/temp';
    }
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    
    final dir = Directory('${_baseDir!.path}/media/$workflow/$year/$month');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static String generateFileName(String workflow, String extension, [String? uuid]) {
    final finalUuid = uuid ?? _uuid.v4();
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    
    // Format: {WORKFLOW}_{YYYYMMDD}_{HHMMSS}_{UUID}.{EXT}
    // Note: Replaced * from prompt with _ as * is an invalid file character in Windows
    return '${workflow}_${date}_${time}_$finalUuid.$extension';
  }

  static Future<File> moveFromCache(File sourceFile, {String workflow = 'temp', String? uuid}) async {
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourceFile.path);
    }

    final ext = sourceFile.path.split('.').last;
    final finalUuid = uuid ?? _uuid.v4();
    final fileName = generateFileName(workflow, ext, finalUuid);
    
    final targetDir = await getDirectoryForWorkflow(workflow);
    final targetPath = '$targetDir/$fileName';
    final targetFile = File(targetPath);

    // Copy file
    await sourceFile.copy(targetPath);
    
    // Verify write success
    if (!await targetFile.exists()) {
      throw FileSystemException('Failed to write to persistent storage', targetPath);
    }

    // Delete original cache file
    try {
      await sourceFile.delete();
    } catch (e) {
      // Best effort deletion if OS locked it
    }

    return targetFile;
  }

  static Future<String?> migrateDraftPathIfNeeded(String oldPath) async {
    if (oldPath.isEmpty) return null;
    
    final file = File(oldPath);
    if (!await file.exists()) {
      return null;
    }

    // If already in RRM structure, return as is
    if (oldPath.contains('/RRM/media/') || oldPath.contains('\\RRM\\media\\') || 
        oldPath.contains('/RRM/temp/') || oldPath.contains('\\RRM\\temp\\')) {
      return oldPath;
    }

    // Migrate from legacy cache
    final newFile = await moveFromCache(file, workflow: 'temp');
    return newFile.path;
  }
}
