class MediaMetadataModel {
  final String localUuid;
  final String? cattleUuid;
  final String? leadUuid;
  final String? serverId;
  final String? captureType;
  final String? mediaType;
  final String? absoluteLocalPath;
  final int? fileSizeBytes;
  final String? md5Checksum;
  final String? syncStatus;
  final String? syncedAt;
  final String? createdAt;
  final String? deletedAt;

  MediaMetadataModel({
    required this.localUuid,
    this.cattleUuid,
    this.leadUuid,
    this.serverId,
    this.captureType,
    this.mediaType,
    this.absoluteLocalPath,
    this.fileSizeBytes,
    this.md5Checksum,
    this.syncStatus,
    this.syncedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory MediaMetadataModel.fromMap(Map<String, dynamic> map) {
    return MediaMetadataModel(
      localUuid: map['local_uuid'] as String,
      cattleUuid: map['cattle_uuid'] as String?,
      leadUuid: map['lead_uuid'] as String?,
      serverId: map['server_id'] as String?,
      captureType: map['capture_type'] as String?,
      mediaType: map['media_type'] as String?,
      absoluteLocalPath: map['absolute_local_path'] as String?,
      fileSizeBytes: map['file_size_bytes'] as int?,
      md5Checksum: map['md5_checksum'] as String?,
      syncStatus: map['sync_status'] as String?,
      syncedAt: map['synced_at'] as String?,
      createdAt: map['created_at'] as String?,
      deletedAt: map['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_uuid': localUuid,
      'cattle_uuid': cattleUuid,
      'lead_uuid': leadUuid,
      'server_id': serverId,
      'capture_type': captureType,
      'media_type': mediaType,
      'absolute_local_path': absoluteLocalPath,
      'file_size_bytes': fileSizeBytes,
      'md5_checksum': md5Checksum,
      'sync_status': syncStatus,
      'synced_at': syncedAt,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }
}
