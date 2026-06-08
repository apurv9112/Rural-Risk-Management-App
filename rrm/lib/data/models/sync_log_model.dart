class SyncLogModel {
  final String logUuid;
  final String? queueUuid;
  final String? entityType;
  final String? resolvedStatus;
  final int? executionTimeMs;
  final String? createdAt;

  SyncLogModel({
    required this.logUuid,
    this.queueUuid,
    this.entityType,
    this.resolvedStatus,
    this.executionTimeMs,
    this.createdAt,
  });

  factory SyncLogModel.fromMap(Map<String, dynamic> map) {
    return SyncLogModel(
      logUuid: map['log_uuid'] as String,
      queueUuid: map['queue_uuid'] as String?,
      entityType: map['entity_type'] as String?,
      resolvedStatus: map['resolved_status'] as String?,
      executionTimeMs: map['execution_time_ms'] as int?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'log_uuid': logUuid,
      'queue_uuid': queueUuid,
      'entity_type': entityType,
      'resolved_status': resolvedStatus,
      'execution_time_ms': executionTimeMs,
      'created_at': createdAt,
    };
  }
}
