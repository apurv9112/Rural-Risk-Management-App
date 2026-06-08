class LeadModel {
  final String localUuid;
  final String? serverId;
  final String? workflowType;
  final String? ownerName;
  final String? mobileNumber;
  final String? village;
  final int? totalCattleCount;
  final String? syncStatus;
  final int? revisionNumber;
  final int? localRevisionNumber;
  final int? serverRevisionNumber;
  final String? lastServerUpdatedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  LeadModel({
    required this.localUuid,
    this.serverId,
    this.workflowType,
    this.ownerName,
    this.mobileNumber,
    this.village,
    this.totalCattleCount,
    this.syncStatus,
    this.revisionNumber,
    this.localRevisionNumber,
    this.serverRevisionNumber,
    this.lastServerUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      localUuid: map['local_uuid'] as String,
      serverId: map['server_id'] as String?,
      workflowType: map['workflow_type'] as String?,
      ownerName: map['owner_name'] as String?,
      mobileNumber: map['mobile_number'] as String?,
      village: map['village'] as String?,
      totalCattleCount: map['total_cattle_count'] as int?,
      syncStatus: map['sync_status'] as String?,
      revisionNumber: map['revision_number'] as int?,
      localRevisionNumber: map['local_revision_number'] as int?,
      serverRevisionNumber: map['server_revision_number'] as int?,
      lastServerUpdatedAt: map['last_server_updated_at'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      deletedAt: map['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_uuid': localUuid,
      'server_id': serverId,
      'workflow_type': workflowType,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'village': village,
      'total_cattle_count': totalCattleCount,
      'sync_status': syncStatus,
      'revision_number': revisionNumber,
      'local_revision_number': localRevisionNumber,
      'server_revision_number': serverRevisionNumber,
      'last_server_updated_at': lastServerUpdatedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  LeadModel copyWith({
    String? localUuid,
    String? serverId,
    String? workflowType,
    String? ownerName,
    String? mobileNumber,
    String? village,
    int? totalCattleCount,
    String? syncStatus,
    int? revisionNumber,
    int? localRevisionNumber,
    int? serverRevisionNumber,
    String? lastServerUpdatedAt,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return LeadModel(
      localUuid: localUuid ?? this.localUuid,
      serverId: serverId ?? this.serverId,
      workflowType: workflowType ?? this.workflowType,
      ownerName: ownerName ?? this.ownerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      village: village ?? this.village,
      totalCattleCount: totalCattleCount ?? this.totalCattleCount,
      syncStatus: syncStatus ?? this.syncStatus,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      localRevisionNumber: localRevisionNumber ?? this.localRevisionNumber,
      serverRevisionNumber: serverRevisionNumber ?? this.serverRevisionNumber,
      lastServerUpdatedAt: lastServerUpdatedAt ?? this.lastServerUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
