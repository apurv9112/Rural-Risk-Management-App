
import 'package:flutter_test/flutter_test.dart';
import 'package:rrm/core/storage/media_naming_utils.dart';

void main() {
  group('Media Naming Utils Tests', () {
    test('Image generation creates a, b, c suffix', () {
      expect(MediaNamingUtils.generateImageName('123', 0), '123a.jpg');
      expect(MediaNamingUtils.generateImageName('123', 1), '123b.jpg');
      expect(MediaNamingUtils.generateImageName('123', 2), '123c.jpg');
    });

    test('Video generation creates _1, _2 suffix', () {
      expect(MediaNamingUtils.generateVideoName('123', 1), '123_1.mp4');
      expect(MediaNamingUtils.generateVideoName('123', 2), '123_2.mp4');
    });

    test('Certificate generation creates specific suffix', () {
      expect(MediaNamingUtils.generateCertificateName('123', 'HC'), '123HC.pdf');
      expect(MediaNamingUtils.generateCertificateName('123', 'DC'), '123DC.pdf');
    });
  });
  
  // Note: FolderManager and MediaManager rely on getApplicationDocumentsDirectory()
  // which is a native path_provider channel call and cannot be easily tested in pure 
  // unit tests without extensive mocking. They will be validated manually.
}
