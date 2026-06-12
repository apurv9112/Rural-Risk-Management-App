class UploadInitResult {
  final bool success;
  final String? uploadId;
  final String? error;
  final bool isFileMissing;

  UploadInitResult({
    required this.success,
    this.uploadId,
    this.error,
    this.isFileMissing = false,
  });
}

class ChunkUploadResult {
  final bool success;
  final String? error;
  final bool shouldRetry;
  final int? acknowledgedBytes;

  ChunkUploadResult({
    required this.success,
    this.error,
    this.shouldRetry = false,
    this.acknowledgedBytes,
  });
}

class UploadCompleteResult {
  final bool success;
  final String? assetId;
  final String? error;

  UploadCompleteResult({
    required this.success,
    this.assetId,
    this.error,
  });
}

abstract class MediaTransportService {
  Future<UploadInitResult> initUpload({
    required String checksum,
    required int fileSize,
    required String mimeType,
  });

  Future<ChunkUploadResult> uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required List<int> bytes,
  });

  Future<UploadCompleteResult> completeUpload({
    required String uploadId,
    required String checksum,
  });
}
