# Backend Media API Specification (v2)

## 1. Overview
This specification details the Backend Media API (v2) contract required to support the chunked offline upload transport architecture. The backend must strictly implement these endpoints to fulfill the `MediaTransportService` client-side contract.

---

## 2. Endpoint Definitions

### 2.1 Init Upload
**Endpoint:** `POST /api/v2/media/upload/init`
**Description:** Initializes a new chunked upload session.

**Request Schema:**
```json
{
  "file_name": "string",
  "total_size": "number",
  "mime_type": "string"
}
```

**Response Schema (200 OK):**
```json
{
  "upload_id": "string (uuid)",
  "expires_at": "string (iso8601)",
  "chunk_size": 5242880
}
```

### 2.2 Upload Chunk
**Endpoint:** `POST /api/v2/media/upload/chunk`
**Description:** Uploads a specific binary chunk for an active upload session.

**Query Parameters:**
- `upload_id`: string (uuid)
- `chunk_index`: number (0-based)

**Headers:**
- `Content-Type`: `application/octet-stream`

**Request Body:**
Binary payload (up to `chunk_size` bytes)

**Response Schema (200 OK):**
```json
{
  "success": true,
  "received_bytes": "number",
  "chunk_index": "number"
}
```

### 2.3 Complete Upload
**Endpoint:** `POST /api/v2/media/upload/complete`
**Description:** Signals the completion of an upload session, prompting the backend to assemble chunks and verify integrity.

**Request Schema:**
```json
{
  "upload_id": "string (uuid)",
  "total_chunks": "number",
  "checksum": "string (sha256)"
}
```

**Response Schema (200 OK):**
```json
{
  "asset_id": "string (uuid)",
  "checksum": "string (sha256)",
  "file_size": "number",
  "status": "AVAILABLE"
}
```

### 2.4 Get Asset
**Endpoint:** `GET /api/v2/media/{asset_id}`
**Description:** Retrieves metadata or binary data for a completed asset.

---

## 3. Idempotency Requirements
- **Init Phase**: If the same request parameters are sent, generating a new `upload_id` is acceptable, provided the client uses the latest one. Abandoned tokens must be garbage-collected.
- **Chunk Phase**: Submitting the same `chunk_index` multiple times must gracefully overwrite the existing chunk or return HTTP 200 without duplication.
- **Complete Phase**: Submitting `complete` for an already completed `upload_id` MUST return the exact same `asset_id` without duplicating backend storage or throwing an error.

---

## 4. Asset & Storage Lifecycle
1. **Garbage Collection (Orphans):** If an `upload_id` passes its `expires_at` (e.g., 24 hours) without a `complete` signal, the backend must delete all associated partial chunks to free storage.
2. **Persistence:** Once `complete` is successful, chunks must be stitched into a unified file block (e.g., S3 object) linked by the final `asset_id`.
3. **Reference Counting:** Assets should be maintained as long as a parent entity (JSON payload) references them. 
