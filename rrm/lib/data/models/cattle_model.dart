class CattleModel {
  final String localUuid;
  final String? leadUuid;
  final String? serverId;
  final String? tagNumber;
  final String? oldTagNumber;
  final String? species;
  final String? breed;
  final String? age;
  final String? syncStatus;
  final int? revisionNumber;
  final int? localRevisionNumber;
  final int? serverRevisionNumber;
  final String? lastServerUpdatedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  CattleModel({
    required this.localUuid,
    this.leadUuid,
    this.serverId,
    this.tagNumber,
    this.oldTagNumber,
    this.species,
    this.breed,
    this.age,
    this.syncStatus,
    this.revisionNumber,
    this.localRevisionNumber,
    this.serverRevisionNumber,
    this.lastServerUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CattleModel.fromMap(Map<String, dynamic> map) {
    return CattleModel(
      localUuid: map['local_uuid'] as String,
      leadUuid: map['lead_uuid'] as String?,
      serverId: map['server_id'] as String?,
      tagNumber: map['tag_number'] as String?,
      oldTagNumber: map['old_tag_number'] as String?,
      species: map['species'] as String?,
      breed: map['breed'] as String?,
      age: map['age'] as String?,
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
      'lead_uuid': leadUuid,
      'server_id': serverId,
      'tag_number': tagNumber,
      'old_tag_number': oldTagNumber,
      'species': species,
      'breed': breed,
      'age': age,
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
}
