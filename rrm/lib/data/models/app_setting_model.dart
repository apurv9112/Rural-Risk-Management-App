class AppSettingModel {
  final String key;
  final String? value;
  final String? updatedAt;

  AppSettingModel({
    required this.key,
    this.value,
    this.updatedAt,
  });

  factory AppSettingModel.fromMap(Map<String, dynamic> map) {
    return AppSettingModel(
      key: map['key'] as String,
      value: map['value'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'updated_at': updatedAt,
    };
  }
}
