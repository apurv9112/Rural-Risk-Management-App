# M16.16 – REAL TRANSPORT INTEGRATION PREPARATION AUDIT

## Phase 1 – Transport Dependency Audit

### Dependency Graph
- `dependency_injection.dart` explicitly constructs `MockMediaTransportService()` and injects it into `MediaSyncWorker`.
- `background_sync_manager.dart` explicitly constructs `MockMediaTransportService()` inside the isolate re-initialization routine.

### Findings
1. **Instantiation:** `MockMediaTransportService` is explicitly hardcoded in both DI registration locations instead of being injected via an interface factory.
2. **Swap Safety:** Swapping is partially safe as `MediaSyncWorker` accepts the abstract `MediaTransportService`. However, the isolate logic in `background_sync_manager.dart` must be updated to use the production transport cleanly.
3. **Mock Dependencies:** There are no components in the system logic that directly reference mock-only variables (like `injectNetworkFailureAfterChunk3`), ensuring the orchestration layer treats the transport generically.
4. **State Transitions:** State transitions rely strictly on the `UploadInitResult`, `ChunkUploadResult`, and `UploadCompleteResult` interfaces, meaning they are completely abstracted from the mock implementation.

---

## Phase 2 – Backend Contract Compatibility

### PASS / FAIL Matrix against APIs
| Required Field | Status | Queue Schema Equivalent | Gap / Missing |
| :--- | :--- | :--- | :--- |
| `checksum` | **FAIL** | N/A | Needs to be added to `MediaQueue` and calculated locally. |
| `remote_upload_id` | **PASS** | `remoteUploadId` | Available. |
| `uploaded_bytes` | **PASS** | `uploadedBytes` | Available. |
| `file_size` | **PASS** | `totalSizeBytes` | Available. |
| `media_uuid` | **PASS** | `id` | Available. |

### Findings
The schema is largely sufficient but critically lacks the `checksum` field required by `/api/v1/media/upload/init`.

---

## Phase 3 – Authentication Audit

### Findings
1. **Refresh Flow Missing:** The transport interfaces and worker loops currently contain zero logic for intercepting 401s, refreshing tokens, and re-attempting a chunk. 
2. **Resume after Refresh:** If the app natively intercepts a 401 and refreshes a token in a global API client, chunk upload could resume naturally on the next attempt.
3. **Failure Path (Token expires at chunk 12/20):**
   - Chunk 12 fails with HTTP 401.
   - `ChunkUploadResult` returns `success: false, shouldRetry: false` (since it's not configured to classify 401 as retryable).
   - `MediaSyncWorker` updates state to `FAILED`.
   - The queue halts permanently until the user manually triggers a "Retry Failed" from the dashboard, at which point it resumes correctly from chunk 12.

---

## Phase 4 – Retry Audit

### Findings
Current retry behavior relies solely on a boolean `shouldRetry`.

| HTTP Response | Required Behavior | Current Orchestration Behavior | Gap |
| :--- | :--- | :--- | :--- |
| Network Failure | Retry / Wait | Depends on transport setting `shouldRetry: true` | Transport relies on naive mock booleans. |
| HTTP 401 | Refresh Token & Retry | Transitions to `FAILED` | Critical. Needs token refresh interceptor. |
| HTTP 403 | Fail permanently | Transitions to `FAILED` | OK. |
| HTTP 429 | Exponential Backoff | Transitions to `FAILED` | Missing exponential backoff logic. |
| HTTP 500 | Retry with Backoff | Transitions to `FAILED` | Fails immediately unless `shouldRetry: true`. |
| Timeout | Retry | Unknown | Relies on transport wrapper. |

---

## Phase 5 – Queue Assembly Audit

### Findings
1. **Asset IDs Assembled:** **FAIL**. `QueueProcessor` currently fakes the parent payload sync with a `Future.delayed(50ms)` and assumes completion. It does not extract `remoteAssetId` fields from `MediaQueue` records or assemble a payload.
2. **Parent Payload Injection:** **FAIL**. Missing completely.
3. **KYC Array Handling:** **FAIL**. Unimplemented.
4. **Cancel Lead Array Handling:** **FAIL**. Unimplemented.

**Production Risk:** High. The orchestration infrastructure properly routes states, but actual data assembly is entirely stubbed out.

---

## Phase 6 – Cleanup Audit

### Findings
**Physical media deletion:** 
- `QueueProcessor` iterates over `mediaItems` only *after* the `SyncQueue` is transitioned to `SyncState.COMPLETED`.
- It verifies if the file exists, deletes the physical file, and handles file system exceptions gracefully.

**Safety Assessment:** 
- Extremely Safe. Physical deletion strictly requires the parent `SyncQueue` to complete fully.
- Minor Risk: SQLite records for completed media remain forever. The database will bloat over time. A periodic cleanup task is needed to cull old `COMPLETED` records.

---

## Phase 7 – Production Readiness Gap Analysis

| Category | Readiness Status |
| :--- | :--- |
| **Real Transport Integration** | **PARTIAL** (Needs `checksum` logic and token interceptors). |
| **Auth Integration** | **BLOCKED** (Missing refresh orchestration during loop). |
| **Backend Integration** | **BLOCKED** (Queue assembly and parent injection stubbed). |
| **Queue Lifecycle** | **READY** (State machine works perfectly). |
| **Recovery Lifecycle** | **READY** (Reboot, orphan recovery, and network resumption are bulletproof). |

---

## Blockers & Recommendations

### Blocker List
1. No `checksum` support for file validation on backend.
2. No token refresh handler integrated into the worker pipeline.
3. Queue Processor lacks JSON assembly logic for attaching `remoteAssetId` values to the parent payload.

### Recommended Implementation Sequence (M16.17+)
1. Modify `MediaQueue` schema to include local file `checksum`.
2. Implement robust interceptor in `api_service.dart` that automatically refreshes tokens and safely throws specific retryable exceptions.
3. Upgrade `MediaTransportService` interface to handle and map HTTP status codes to specific retry policies (e.g., Backoff).
4. Implement data assembly in `QueueProcessor` (Phase 5 tasks).
5. Finally, swap the transport layer implementations inside DI.

### Final Verdict
**APPROVE** for proceeding to M16.16 resolution. The architecture is sound but requires strict data-binding patches before flipping to production APIs.
