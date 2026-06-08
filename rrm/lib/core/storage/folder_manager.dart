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
}
