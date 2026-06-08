class SyncQueueModel {
  final String queueUuid;
  final String? dependencyQueueUuid;
  final String? entityType;
  final String? entityUuid;
  final String? operationType;
  final String? payloadJson;
  final String? status;
  final int? attemptCount;
  final String? nextRetryAt;
  final String? lastError;
  final String? coalesceKey;
  final String idempotencyKey;
  final String? processingStartedAt;
  final String? createdAt;
  final String? updatedAt;

  SyncQueueModel({
    required this.queueUuid,
    this.dependencyQueueUuid,
    this.entityType,
    this.entityUuid,
    this.operationType,
    this.payloadJson,
    this.status,
    this.attemptCount,
    this.nextRetryAt,
    this.lastError,
    this.coalesceKey,
    required this.idempotencyKey,
    this.processingStartedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      queueUuid: map['queue_uuid'] as String,
      dependencyQueueUuid: map['dependency_queue_uuid'] as String?,
      entityType: map['entity_type'] as String?,
      entityUuid: map['entity_uuid'] as String?,
      operationType: map['operation_type'] as String?,
      payloadJson: map['payload_json'] as String?,
      status: map['status'] as String?,
      attemptCount: map['attempt_count'] as int?,
      nextRetryAt: map['next_retry_at'] as String?,
      lastError: map['last_error'] as String?,
      coalesceKey: map['coalesce_key'] as String?,
      idempotencyKey: map['idempotency_key'] as String,
      processingStartedAt: map['processing_started_at'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queue_uuid': queueUuid,
      'dependency_queue_uuid': dependencyQueueUuid,
      'entity_type': entityType,
      'entity_uuid': entityUuid,
      'operation_type': operationType,
      'payload_json': payloadJson,
      'status': status,
      'attempt_count': attemptCount,
      'next_retry_at': nextRetryAt,
      'last_error': lastError,
      'coalesce_key': coalesceKey,
      'idempotency_key': idempotencyKey,
      'processing_started_at': processingStartedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
