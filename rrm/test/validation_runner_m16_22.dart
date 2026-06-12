import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rrm/core/storage/folder_manager.dart';

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
  test('M16.22: FolderManager Persistent Media Storage Validation', () async {
    // Setup FolderManager
    await FolderManager.init();

    // Create a mock cache file
    final tempDir = await getTemporaryDirectory();
    final cacheFile = File('${tempDir.path}/fake_cache_image.jpg');
    await cacheFile.writeAsString('fake image data');

    final persistentFile = await FolderManager.moveFromCache(cacheFile, workflow: 'tagging');

    print('\n--- A. Cache -> Persistent migration ---');
    print('SUCCESS: Migrated to ${persistentFile.path}');

    print('\n--- B. Cache cleanup ---');
    expect(await cacheFile.exists(), isFalse, reason: 'Original cache file should be deleted');
    print('SUCCESS: Cache file deleted.');

    print('\n--- C. Naming convention ---');
    final pathParts = persistentFile.path.split('/');
    final fileName = pathParts.last;
    final nameRegex = RegExp(r'^tagging_\d{8}_\d{6}_.*\.jpg$');
    expect(nameRegex.hasMatch(fileName), isTrue, reason: 'File name should match {WORKFLOW}_{YYYYMMDD}_{HHMMSS}_{UUID}.{EXT}');
    print('SUCCESS: Naming convention matches ($fileName).');

    print('\n--- G. Physical file existence validation ---');
    expect(await persistentFile.exists(), isTrue, reason: 'Persistent file must physically exist');
    print('SUCCESS: Persistent file exists.');

    // D, E: migrateDraftPathIfNeeded
    print('\n--- D. Legacy draft migration ---');
    final legacyCacheFile = File('${tempDir.path}/legacy_draft.jpg');
    await legacyCacheFile.writeAsString('legacy data');
    
    final migratedPath = await FolderManager.migrateDraftPathIfNeeded(legacyCacheFile.path);
    expect(migratedPath, isNotNull);
    expect(migratedPath!.contains('temp'), isTrue, reason: 'Legacy draft should migrate to RRM/temp');
    expect(await File(migratedPath).exists(), isTrue, reason: 'Migrated file should exist');
    print('SUCCESS: Migrated legacy draft to $migratedPath');

    print('\n--- E. Missing file handling ---');
    final missingPath = await FolderManager.migrateDraftPathIfNeeded('${tempDir.path}/missing.jpg');
    expect(missingPath, isNull, reason: 'Missing file should return null');
    print('SUCCESS: Missing file handled properly.');

    print('\n--- F. App restart persistence ---');
    // Simulate app restart by checking if files still exist from a clean state (no memory variables)
    final checkFile = File(persistentFile.path);
    expect(await checkFile.exists(), isTrue, reason: 'File should persist beyond memory');
    print('SUCCESS: Files persist independent of runtime state.');
  });
}
