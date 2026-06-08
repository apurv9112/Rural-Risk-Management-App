import 'dart:io';
import 'package:path/path.dart' as p;
import 'folder_manager.dart';

class MediaManager {
  /// Moves a file from a temporary location to the permanent AppDocuments storage.
  /// Validates that the file exists and has size > 0.
  /// Returns the absolute path of the newly copied file.
  static Future<String?> moveMediaToPermanentStorage({
    required File tempFile,
    required String workflowType, // e.g. "tagging"
    required String targetFileName, // e.g. "230045678a.jpg"
  }) async {
    if (!(await tempFile.exists())) {
      throw Exception('Temporary file does not exist: ${tempFile.path}');
    }

    final fileSize = await tempFile.length();
    if (fileSize == 0) {
      throw Exception('Temporary file is empty (size 0): ${tempFile.path}');
    }

    final extension = p.extension(tempFile.path).toLowerCase();
    if (extension.isEmpty) {
      throw Exception('Temporary file missing extension: ${tempFile.path}');
    }

    final targetFolder = await FolderManager.getFolderPath('media/$workflowType');
    
    // Ensure the folder exists just in case it was deleted during runtime
    final directory = Directory(targetFolder);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final destinationPath = p.join(targetFolder, targetFileName);
    final destinationFile = File(destinationPath);

    // Copy rather than rename across volume boundaries
    await tempFile.copy(destinationPath);

    return destinationFile.absolute.path;
  }
}
