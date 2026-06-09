import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'core/storage/folder_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("========================================");
  print("STARTING M16.8 STORAGE VALIDATION");
  print("========================================");

  final uuid = const Uuid().v4();
  final tempDir = await getTemporaryDirectory();
  final tempFile = File(p.join(tempDir.path, 'cache_image_123.jpg'));
  await tempFile.writeAsString("fake_image_bytes");

  print("--- STEP 1: Image Cache Migration ---");
  print("Initial cache path: ${tempFile.path}");
  final persistentFile = await FolderManager.moveFromCache(tempFile, 'tagging', uuid, 'jpg');
  print("Persistent path: ${persistentFile.path}");

  if (await persistentFile.exists()) {
    print("PASS: File successfully written to persistent partition.");
  } else {
    print("FAIL: File missing from persistent partition.");
  }

  if (!(await tempFile.exists())) {
    print("PASS: Cache file successfully deleted.");
  } else {
    print("FAIL: Cache file was not cleaned up.");
  }

  print("--- STEP 2: Naming Convention ---");
  final fileName = p.basename(persistentFile.path);
  print("Filename generated: $fileName");
  if (fileName.startsWith('tagging_') && fileName.endsWith('.jpg') && fileName.contains(uuid)) {
    print("PASS: Naming convention strictly enforced.");
  } else {
    print("FAIL: Naming convention violated.");
  }

  print("--- STEP 3: Draft Recovery (Existing File) ---");
  final simulatedCacheFile = File(p.join(tempDir.path, 'cache_draft.jpg'));
  await simulatedCacheFile.writeAsString("fake_draft_bytes");
  
  final draftUuid = const Uuid().v4();
  final migratedPath = await FolderManager.migrateDraftPathIfNeeded(simulatedCacheFile.path, 'retagging', draftUuid);
  
  if (migratedPath != null && !migratedPath.contains('/cache/') && migratedPath.contains('retagging_')) {
    print("PASS: Draft recovery successfully migrated path: $migratedPath");
  } else {
    print("FAIL: Draft recovery failed.");
  }

  print("--- STEP 4: Draft Recovery (Missing File) ---");
  final missingPath = p.join(tempDir.path, 'cache_missing.jpg');
  final missingMigrated = await FolderManager.migrateDraftPathIfNeeded(missingPath, 'claim', const Uuid().v4());
  
  if (missingMigrated == null) {
    print("PASS: Missing file correctly flagged as null.");
  } else {
    print("FAIL: Missing file not caught.");
  }

  print("--- STEP 5: Folder Partition Validation ---");
  final mediaRoot = p.dirname(persistentFile.path);
  print("Final Media Root: $mediaRoot");
  if (mediaRoot.contains('media') && mediaRoot.contains('tagging')) {
    print("PASS: Hierarchical partitioning verified.");
  } else {
    print("FAIL: Folder hierarchy incorrect.");
  }

  // Cleanup initial tests
  await FolderManager.deleteMediaFile(persistentFile.path);
  if (migratedPath != null) await FolderManager.deleteMediaFile(migratedPath);

  print("--- STEP 8: App Restart Persistence Test ---");
  final docDir = await getApplicationDocumentsDirectory();
  final restartStateFile = File(p.join(docDir.path, 'restart_state.txt'));

  if (!(await restartStateFile.exists())) {
    print("PHASE 1: Creating test image for restart persistence...");
    final restartTemp = File(p.join(tempDir.path, 'cache_restart.jpg'));
    await restartTemp.writeAsString("restart_test_data_123");
    
    final restartPersistent = await FolderManager.moveFromCache(restartTemp, 'claim', const Uuid().v4(), 'jpg');
    
    await restartStateFile.writeAsString(restartPersistent.path);
    print("Test image created at: ${restartPersistent.path}");
    print("Please close the application completely and relaunch to run Phase 2.");
  } else {
    print("PHASE 2: Verifying persistence after restart...");
    final savedPath = await restartStateFile.readAsString();
    final savedFile = File(savedPath);
    
    if (await savedFile.exists() && await savedFile.length() == "restart_test_data_123".length) {
      final dir = savedFile.parent;
      if (await dir.exists()) {
        print("PASS: Persistent media survived application restart.");
      } else {
        print("FAIL: Directory missing after restart.");
      }
    } else {
      print("FAIL: Persistent media missing after restart.");
    }
    
    // Cleanup
    await savedFile.delete();
    await restartStateFile.delete();
  }

  print("========================================");
  print("M16.8 VALIDATION COMPLETE");
  print("========================================");
}
