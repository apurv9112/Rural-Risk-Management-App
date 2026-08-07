import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfService {
  Future<File> createFile(List<int> bytes, String fileName) async {
    final directory = await getTemporaryDirectory();

    final file = File("${directory.path}/$fileName");

    await file.writeAsBytes(bytes);

    return file;
  }
}
