class ConflictLogModel {
  final String conflictUuid;
  final String? entityType;
  final String? entityUuid;
  final String? localPayloadJson;
  final String? serverPayloadJson;
  final String? resolvedAt;
  final String? createdAt;

  ConflictLogModel({
    required this.conflictUuid,
    this.entityType,
    this.entityUuid,
    this.localPayloadJson,
    this.serverPayloadJson,
    this.resolvedAt,
    this.createdAt,
  });

  factory ConflictLogModel.fromMap(Map<String, dynamic> map) {
    return ConflictLogModel(
      conflictUuid: map['conflict_uuid'] as String,
      entityType: map['entity_type'] as String?,
      entityUuid: map['entity_uuid'] as String?,
      localPayloadJson: map['local_payload_json'] as String?,
      serverPayloadJson: map['server_payload_json'] as String?,
      resolvedAt: map['resolved_at'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conflict_uuid': conflictUuid,
      'entity_type': entityType,
      'entity_uuid': entityUuid,
      'local_payload_json': localPayloadJson,
      'server_payload_json': serverPayloadJson,
      'resolved_at': resolvedAt,
      'created_at': createdAt,
    };
  }
}
