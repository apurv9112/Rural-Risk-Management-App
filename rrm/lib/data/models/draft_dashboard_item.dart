class DraftDashboardItem {
  final String entityUuid;
  final String workflowType;
  final String ownerName;
  final String mobileNumber;
  final String village;
  final int totalCattleCount;
  final String syncStatus;
  final String lastUpdatedAt;
  final int currentStep;
  final String lastScreenRoute;
  final double completionPercentage;
  final String? lastError;

  DraftDashboardItem({
    required this.entityUuid,
    required this.workflowType,
    required this.ownerName,
    required this.mobileNumber,
    required this.village,
    required this.totalCattleCount,
    required this.syncStatus,
    required this.lastUpdatedAt,
    required this.currentStep,
    required this.lastScreenRoute,
    required this.completionPercentage,
    this.lastError,
  });

  factory DraftDashboardItem.fromMap(Map<String, dynamic> map) {
    return DraftDashboardItem(
      entityUuid: map['entity_uuid'] as String? ?? map['local_uuid'] as String? ?? '',
      workflowType: map['workflow_type'] as String? ?? 'Tagging',
      ownerName: map['owner_name'] as String? ?? 'Unknown',
      mobileNumber: map['mobile_number'] as String? ?? '',
      village: map['village'] as String? ?? '',
      totalCattleCount: map['total_cattle_count'] as int? ?? 0,
      syncStatus: map['sync_status'] as String? ?? 'DRAFT',
      lastUpdatedAt: map['updated_at'] as String? ?? map['last_updated_at'] as String? ?? '',
      currentStep: map['current_step'] as int? ?? 0,
      lastScreenRoute: map['last_screen_route'] as String? ?? '',
      completionPercentage: (map['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      lastError: map['last_error'] as String?,
    );
  }
}
