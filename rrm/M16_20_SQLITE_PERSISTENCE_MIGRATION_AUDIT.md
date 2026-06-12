# M16.20 – SQLITE PERSISTENCE MIGRATION AUDIT

## Objective
To replace the volatile, in-memory `MockDatabase` with a robust `sqflite` persistence layer. This document provides the migration blueprint strictly based on the current implementation state.

---

## 1. MockDatabase Usage Audit

The `MockDatabase` is currently deeply embedded throughout the background offline architecture. It is instantiated globally in `dependency_injection.dart` and `background_sync_manager.dart`, and injected into:
- `SyncCoordinator`
- `QueueProcessor`
- `MediaSyncWorker`
- `PayloadAssemblyService`
- `QueueInsertionService`
- `QueueStatisticsService`
- `SyncQueuePage` (UI)

---

## 2. Queue Models Audit

1. **`SyncQueue`**: Holds the parent JSON payload, ID, and overarching synchronization state.
2. **`MediaQueue`**: Holds file references, SHA-256 checksums, AWS chunking byte bounds, and nested array indices.
3. **Queue Statistics**: Computed iteratively by traversing all in-memory rows. 
4. **Dashboard Metrics**: `SyncDashboardWidget` leverages stream broadcasts from `MockDatabase`.
5. **Payload Assembly**: Queries all `MediaQueue` children by parent `syncQueueId` to inject remote asset IDs into the parent payload.

---

## 3. Target SQLite Schema Design

### Table: `sync_queue`
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  state TEXT NOT NULL,
  payload TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL
);
CREATE INDEX idx_sync_queue_state ON sync_queue(state);
```

### Table: `media_queue`
```sql
CREATE TABLE media_queue (
  id TEXT PRIMARY KEY,
  syncQueueId TEXT NOT NULL,
  filePath TEXT NOT NULL,
  totalSizeBytes INTEGER NOT NULL,
  uploadedBytes INTEGER NOT NULL DEFAULT 0,
  state TEXT NOT NULL,
  fieldName TEXT NOT NULL,
  arrayIndex INTEGER,
  remoteAssetId TEXT,
  remoteUploadId TEXT,
  checksum TEXT,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  FOREIGN KEY (syncQueueId) REFERENCES sync_queue(id) ON DELETE CASCADE
);
CREATE INDEX idx_media_queue_sync_id ON media_queue(syncQueueId);
CREATE INDEX idx_media_queue_state ON media_queue(state);
```

---

## 4. Repository Migration Strategy

- **Current API**: Completely synchronous. Evaluates via memory `Map.values.where(...)`.
- **Required API**: Entirely asynchronous (`Future` based). 
- **Breaking Changes**: 
  - Every service relying on `database.syncQueues` must convert to `await database.getSyncQueues()`.
  - `QueueStatisticsService` must abandon loop iteration and convert to native SQLite `SELECT COUNT(*) ... GROUP BY state` queries.
  - The UI Stream (`_changeController`) must be replaced with `sqflite` change listener mechanisms or specific application-layer Rx hooks.
- **Backward Compatibility**: Because `MockDatabase` is inherently volatile, existing users have no legacy SQLite records to migrate. The database creation will fire as a fresh install for 100% of the user base.

---

## 5. Startup Migration Flow

1. **Fresh Install / Current Users**: `openDatabase()` will execute `onCreate`. Tables `sync_queue` and `media_queue` will be generated.
2. **App Upgrade (Future)**: The schema uses an initial `version: 1`. Future schema modifications will leverage the standard `onUpgrade` execution pipeline.

---

## 6. Transaction Requirements

1. **Queue Insertion (`QueueInsertionService`)**: Must utilize an `Exclusive Transaction`. The `sync_queue` row and all associated `media_queue` rows must be committed as a single atomic batch to prevent orphaned media if the app crashes during enqueue.
2. **Media Updates (`MediaSyncWorker`)**: Should execute standard unbatched `UPDATE media_queue` commands, utilizing the `checksum` as an idempotency safeguard.
3. **Cascade Delete**: Purging a successful `sync_queue` row must automatically trigger `ON DELETE CASCADE` to wipe associated `media_queue` rows, ensuring SQLite space doesn't artificially bloat.

---

## 7. Performance Expectations

- **10k Rows**: 
  - Iteration logic from `QueueStatisticsService` will crash or severely stutter the UI. Moving computation natively into SQL (`GROUP BY`) will reduce read time to < 10ms.
  - The `idx_media_queue_sync_id` index is strictly mandatory for `PayloadAssemblyService` to construct payloads instantly.
- **100k Rows**:
  - `SyncQueuePage` cannot load the entire `sync_queue` table into a List. Native SQL `LIMIT/OFFSET` pagination must be introduced to the repository interface.

---

## Final Verdict: READY FOR IMPLEMENTATION

The architecture perfectly supports dropping in a real SQLite layer. The interfaces simply need to shift from synchronous memory maps to asynchronous database queries. No core logic in the queue processors or transport workers requires redesign.
