import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SignatureStorageService {
  Future<Directory> getProfileDirectory() async {
    final root = await getExternalStorageDirectory();

    final folder = Directory("${root!.path}/RRM/Profile");

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folder;
  }

  Future<File> getWorkerSignatureFile(String mobile) async {
    final folder = await getProfileDirectory();

    return File("${folder.path}/${mobile}_worker_signature.png");
  }
}
