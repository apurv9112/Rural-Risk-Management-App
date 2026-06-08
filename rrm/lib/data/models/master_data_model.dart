class MasterDataModel {
  final String localUuid;
  final String? category;
  final String? key;
  final String? value;
  final String? parentKey;
  final int? isActive;
  final String? serverUpdatedAt;

  MasterDataModel({
    required this.localUuid,
    this.category,
    this.key,
    this.value,
    this.parentKey,
    this.isActive,
    this.serverUpdatedAt,
  });

  factory MasterDataModel.fromMap(Map<String, dynamic> map) {
    return MasterDataModel(
      localUuid: map['local_uuid'] as String,
      category: map['category'] as String?,
      key: map['key'] as String?,
      value: map['value'] as String?,
      parentKey: map['parent_key'] as String?,
      isActive: map['is_active'] as int?,
      serverUpdatedAt: map['server_updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_uuid': localUuid,
      'category': category,
      'key': key,
      'value': value,
      'parent_key': parentKey,
      'is_active': isActive,
      'server_updated_at': serverUpdatedAt,
    };
  }
}
