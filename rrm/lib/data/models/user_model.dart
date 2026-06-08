class UserModel {
  final String localUuid;
  final String? serverId;
  final String? mobileNumber;
  final String? firstName;
  final String? lastName;
  final String? companyId;
  final String? lastLoginAt;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.localUuid,
    this.serverId,
    this.mobileNumber,
    this.firstName,
    this.lastName,
    this.companyId,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      localUuid: map['local_uuid'] as String,
      serverId: map['server_id'] as String?,
      mobileNumber: map['mobile_number'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      companyId: map['company_id'] as String?,
      lastLoginAt: map['last_login_at'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_uuid': localUuid,
      'server_id': serverId,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'company_id': companyId,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
