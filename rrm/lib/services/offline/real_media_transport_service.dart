import 'media_transport_service.dart';
import 'media_http_client.dart';
import 'endpoint_provider.dart';
import 'transport_exceptions.dart';

class RealMediaTransportService implements MediaTransportService {
  final EndpointProvider endpointProvider;
  final MediaHttpClient httpClient;

  RealMediaTransportService({
    required this.endpointProvider,
    required this.httpClient,
  });

  @override
  Future<UploadInitResult> initUpload({
    required String checksum,
    required int fileSize,
    required String mimeType,
  }) async {
    try {
      final response = await httpClient.postJson(
        endpointProvider.mediaInitUrl(),
        {
          'checksum': checksum,
          'fileSize': fileSize,
          'mimeType': mimeType,
        },
      );

      return UploadInitResult(
        success: true,
        uploadId: response['uploadId'],
      );
    } catch (e) {
      if (e is TransportException && e.statusCode == 404) {
        return UploadInitResult(success: false, error: e.message, isFileMissing: true);
      }
      rethrow;
    }
  }

  @override
  Future<ChunkUploadResult> uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required List<int> bytes,
  }) async {
    final response = await httpClient.postMultipartChunk(
      endpointProvider.mediaChunkUrl(),
      uploadId,
      chunkIndex,
      bytes,
    );

    return ChunkUploadResult(
      success: true,
      acknowledgedBytes: response['acknowledgedBytes'] ?? bytes.length,
    );
  }

  @override
  Future<UploadCompleteResult> completeUpload({
    required String uploadId,
    required String checksum,
  }) async {
    final response = await httpClient.postJson(
      endpointProvider.mediaCompleteUrl(),
      {
        'uploadId': uploadId,
        'checksum': checksum,
      },
    );

    return UploadCompleteResult(
      success: true,
      assetId: response['assetId'],
    );
  }
}
