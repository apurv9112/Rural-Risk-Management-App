# Media Queue Schema

## 1. Database Schema
The client-side SQLite database requires two primary tables to support offline syncing and parent-child dependencies.

### 1.1 `sync_queue` Table (Parent)
Stores JSON payloads that are awaiting network transport.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | Unique UUID for the sync job. |
| `payload` | TEXT | NOT NULL | The V2 JSON payload (contains local file identifiers). |
| `endpoint` | TEXT | NOT NULL | The REST endpoint path (e.g., `/api/v2/cattle`). |
| `status` | TEXT | NOT NULL | Current state of the sync job. |
| `created_at` | INT | NOT NULL | Unix timestamp of creation. |

**Status Enum for `sync_queue`:**
- `PENDING`
- `UPLOADING_MEDIA`
- `ELIGIBLE_FOR_SYNC`
- `COMPLETED`
- `FAILED`

### 1.2 `media_queue` Table (Child)
Stores binary file descriptors required by a parent sync job.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | Unique UUID for the media job. |
| `sync_queue_id` | TEXT | FOREIGN KEY | Links to `sync_queue.id`. |
| `file_path` | TEXT | NOT NULL | Local device path to the media file. |
| `total_size_bytes` | INT | NOT NULL | Total file size in bytes. |
| `uploaded_bytes` | INT | NOT NULL | Number of bytes securely acknowledged by the server. |
| `remote_upload_id` | TEXT | NULLABLE | The chunk session ID provided by `/init`. |
| `remote_asset_id` | TEXT | NULLABLE | The final asset ID provided by `/complete`. |
| `state` | TEXT | NOT NULL | Current state of the media upload. |

**State Enum for `media_queue`:**
- `PENDING`
- `UPLOADING`
- `INIT`
- `CHUNK_LOOP`
- `COMPLETE`
- `COMPLETED`
- `RETRY_PENDING`
- `FAILED`

## 2. Parent-Child Dependency Rules
1. **Creation:** When a form is saved offline, 1 `sync_queue` row is created, and N `media_queue` rows are generated for every file attached.
2. **Execution Gate:** A `sync_queue` row must remain `PENDING` or `UPLOADING_MEDIA` until `COUNT(*) FROM media_queue WHERE sync_queue_id = ? AND state != 'COMPLETED'` equals exactly 0.
3. **Payload Mutability:** Once the execution gate passes, the SyncWorker must swap local file paths in the `sync_queue.payload` JSON string with the generated `media_queue.remote_asset_id`s before executing the final POST.
