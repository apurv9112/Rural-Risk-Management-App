import 'package:get/get.dart';

enum SyncStateStatus {
  idle,
  syncingMedia,
  syncingRecords,
  completed,
  failed,
}

class SyncStatusService extends GetxService {
  final Rx<SyncStateStatus> status = SyncStateStatus.idle.obs;

  void setStatus(SyncStateStatus newStatus) {
    status.value = newStatus;
  }
}
