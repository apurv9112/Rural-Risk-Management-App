class MediaNamingUtils {
  static String generateImageName(String tagNumber, int index) {
    // Generates [tagNumber]a.jpg, [tagNumber]b.jpg...
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final suffix = (index >= 0 && index < letters.length) ? letters[index] : index.toString();
    return '$tagNumber$suffix.jpg';
  }

  static String generateVideoName(String tagNumber, int index) {
    // Generates [tagNumber]_1.mp4, [tagNumber]_2.mp4...
    return '${tagNumber}_$index.mp4';
  }

  static String generateCertificateName(String tagNumber, String type) {
    // Expected types: HC, DC, CF
    return '$tagNumber$type.pdf';
  }
}
