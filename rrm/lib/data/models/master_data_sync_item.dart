class MasterDataSyncItem {
  final String serverId;
  final String category;
  final String key;
  final String value;
  final String? parentKey;
  final int sortOrder;
  final int version;
  final int isActive;
  final String? deletedAt;
  final String serverUpdatedAt;

  MasterDataSyncItem({
    required this.serverId,
    required this.category,
    required this.key,
    required this.value,
    this.parentKey,
    required this.sortOrder,
    required this.version,
    required this.isActive,
    this.deletedAt,
    required this.serverUpdatedAt,
  });

  factory MasterDataSyncItem.fromJson(Map<String, dynamic> json) {
    return MasterDataSyncItem(
      serverId: json['server_id'] as String,
      category: json['category'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      parentKey: json['parent_key'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      version: json['version'] as int? ?? 1,
      isActive: json['is_active'] as int? ?? 1,
      deletedAt: json['deleted_at'] as String?,
      serverUpdatedAt: json['server_updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_id': serverId,
      'category': category,
      'key': key,
      'value': value,
      'parent_key': parentKey,
      'sort_order': sortOrder,
      'version': version,
      'is_active': isActive,
      'deleted_at': deletedAt,
      'server_updated_at': serverUpdatedAt,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'server_id': serverId,
      'category': category,
      'key': key,
      'value': value,
      'parent_key': parentKey,
      'sort_order': sortOrder,
      'version': version,
      'is_active': isActive,
      'deleted_at': deletedAt,
      'server_updated_at': serverUpdatedAt,
    };
  }
}
