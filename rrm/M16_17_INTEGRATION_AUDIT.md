# M16.17 – FULL OFFLINE ARCHITECTURE INTEGRATION AUDIT

## Objective
A strict, read-only audit of the Offline Architecture from M16.1 through M16.16.3 to evaluate end-to-end connectivity before production deployment.

---

## 1. Component Dependency Graph
```text
UI/ViewModels -> [DISCONNECTED] -> media_queue / sync_queue
                                          |
                                          v
                                   SyncCoordinator
                                   /             \
                   MediaSyncWorker                QueueProcessor
                          |                              |
               RealMediaTransportService         PayloadAssemblyService
                          |
                   MediaHttpClient
```

---

## 2. End-to-End Trace Findings

### Phase 1: Tagging Flow
- **Trace Result**: `TaggingService` and `CattleService` completely bypass the offline queues. They natively assemble `http.MultipartRequest` instances and directly invoke backend APIs.
- **`FolderManager`**: DOES NOT EXIST.
- **Verdict**: **DISCONNECTED**.

### Phase 2: Retagging Flow
- **Trace Result**: Direct execution via `CattleService`. No interaction with `media_queue` or `PayloadAssemblyService`.
- **Verdict**: **DISCONNECTED**.

### Phase 3: Claim Flow
- **Trace Result**: Direct execution via `ClaimService`. Binaries bypass offline staging entirely.
- **Verdict**: **DISCONNECTED**.

### Phase 4: KYC Flow
- **Trace Result**: Direct execution via `KycService`. `files[]` are appended natively to multipart HTTP requests. `PayloadAssemblyService` array sorting logic is completely unused.
- **Verdict**: **DISCONNECTED**.

### Phase 5: Cancel Lead Flow
- **Trace Result**: Direct execution via `CancelLeadService`. `cancellationImages` completely bypass the `MediaSyncWorker`.
- **Verdict**: **DISCONNECTED**.

---

## 3. Architecture Audit Findings

### Phase 6: Queue Gating Audit
- **Status**: **PASS (Isolated)**. 
- **Proof**: `MediaSyncWorker._checkParentEligibility` perfectly blocks parent progression until `MediaState.COMPLETED` and `remoteAssetId` are validated. `QueueProcessor` securely halts upon `PayloadAssemblyException`.

### Phase 7: Cleanup Audit
- **Status**: **PASS (Isolated)**. 
- **Proof**: File deletion cleanly executes inside `queue_processor.dart` (Line 36-46) immediately following `SyncState.COMPLETED` progression. No premature deletion exists.

### Phase 8: Crash Recovery Audit
- **Status**: **FAIL**.
- **Proof**: While byte-preservation (`uploadedBytes`), idempotent `checksum`, and token resilience are perfectly modeled, the schema relies entirely on an in-memory `MockDatabase`. If an "App Kill" occurs, all queue state evaporates. A native SQLite integration is mandatory to actually survive crashes.

### Phase 9: Background Worker Audit
- **Status**: **PARTIAL**.
- **Proof**: Concurrency collision is successfully defended natively within `SyncCoordinator._isSyncing`. Orphan lock recovery (`recoverStaleLocks`) successfully executes upon boot. However, the system lacks native OS scheduling (e.g., `WorkManager` or `BGTaskScheduler`); `background_sync_manager.dart` lacks the platform-channel hook bindings.

---

## 4. Production Risk Matrix

| Component | Risk Level | Description |
| :--- | :--- | :--- |
| **Frontend Integration** | **CRITICAL** | Zero UI components push data to the offline queues. All flows are currently hard-wired to direct API calls. |
| **Storage Persistence** | **CRITICAL** | `MockDatabase` holds state strictly in memory. Offline architecture provides zero crash resilience without SQLite/Hive backing. |
| **Local File Handling** | **HIGH** | `FolderManager` is completely absent. The frontend does not systematically stage files into protected offline directories before queuing. |
| **OS Background Execution** | **MEDIUM** | Isolate dispatchers are defined, but Android `WorkManager` and iOS background tasks are not natively triggering the dispatcher yet. |

---

## Final Verdict: REVISE

### Justification:
The Offline Architecture Services (`PayloadAssemblyService`, `RealMediaTransportService`, `QueueProcessor`, `MediaSyncWorker`) are flawlessly modeled, strictly bounded, and defensively programmed against network latency and authentication drops.

However, the application is physically bifurcated. The frontend UI remains hardcoded to direct-network transports (`http.MultipartRequest`). Furthermore, the persistence layer is actively mocked in memory. Deploying to production in the current state means the offline architecture will sit completely dormant while users continue to face legacy network failures.

**Required Action**: 
Immediately initiate an integration epic to construct the physical SQLite/Hive storage layer and refactor the `CattleService`, `KycService`, and `ClaimService` interfaces to push DTOs and files strictly into the `sync_queue` rather than the internet.
