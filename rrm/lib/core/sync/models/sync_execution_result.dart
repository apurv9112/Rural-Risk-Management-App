class SyncExecutionResult {
  final bool success;
  final String? serverId;
  final int? responseCode;
  final String? errorMessage;
  final String? responsePayload;

  SyncExecutionResult({
    required this.success,
    this.serverId,
    this.responseCode,
    this.errorMessage,
    this.responsePayload,
  });

  bool get isRetryable {
    if (responseCode == null) return true; // Network errors are retryable
    // 408 Request Timeout, 429 Too Many Requests, 5xx Server Errors
    return responseCode == 408 || responseCode == 429 || (responseCode! >= 500 && responseCode! < 600);
  }

  bool get isFatal {
    if (responseCode == null) return false;
    // 4xx client errors (excluding 408, 429) are fatal
    return responseCode! >= 400 && responseCode! < 500 && responseCode != 408 && responseCode != 429;
  }
}
