
import 'media_transport_service.dart';
import 'transport_exceptions.dart';

class MockMediaTransportService implements MediaTransportService {
  bool injectNetworkFailureAfterChunk3 = false;
  bool injectAuthFailureDuringComplete = false;
  int? injectAppKillAfterChunk;
  int? injectNetworkFailureAfterChunk;
  
  bool inject401MidUpload = false;
  int? inject401AtChunk;
  bool inject403AtChunk = false;
  bool inject429AtChunk = false;
  bool injectTimeoutAtChunk = false;
  


  @override
  Future<UploadInitResult> initUpload({
    required String checksum,
    required int fileSize,
    required String mimeType,
  }) async {
    return UploadInitResult(
      success: true,
      uploadId: 'mock_upload_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<ChunkUploadResult> uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required List<int> bytes,
  }) async {
    
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 10));

    // For new tests:
    if (inject401AtChunk == chunkIndex && inject401MidUpload) {
      inject401MidUpload = false; 
      throw AuthenticationException("Mock 401 mid upload");
    }
    
    if (inject403AtChunk && chunkIndex == 2) {
      throw ForbiddenException("Mock 403 mid upload");
    }

    if (inject429AtChunk && chunkIndex == 2) {
      throw RateLimitException("Mock 429 mid upload");
    }

    if (injectTimeoutAtChunk && chunkIndex == 2) {
      throw TimeoutException("Mock Timeout");
    }

    if (injectNetworkFailureAfterChunk3 && chunkIndex == 4) {
      return ChunkUploadResult(
        success: false,
        error: "Network Failure",
        shouldRetry: true,
      );
    }
    
    if (injectAppKillAfterChunk != null && chunkIndex == injectAppKillAfterChunk) {
      throw StateError("APP_KILLED");
    }

    if (injectNetworkFailureAfterChunk != null && chunkIndex == injectNetworkFailureAfterChunk) {
      return ChunkUploadResult(
        success: false,
        error: "Network Failure",
        shouldRetry: true,
      );
    }

    return ChunkUploadResult(success: true, acknowledgedBytes: bytes.length);
  }

  @override
  Future<UploadCompleteResult> completeUpload({
    required String uploadId,
    required String checksum,
  }) async {
    if (injectAuthFailureDuringComplete) {
      return UploadCompleteResult(
        success: false,
        error: "Auth Failure",
      );
    }

    return UploadCompleteResult(
      success: true,
      assetId: 'mock_asset_123',
    );
  }
}
