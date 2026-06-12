# JSON V2 Contract

## 1. Motivation
The V1 APIs (multipart/form-data) coupled metadata with binary files, causing massive request payloads that failed on slow rural 2G/3G networks. 
V2 completely decouples binary uploads from metadata. Binaries are uploaded via the chunked transport, returning `asset_id`s. Metadata is sent as a pure, lightweight JSON payload containing these `asset_id` references.

## 2. Migration Strategy (V1 to V2)
- **Deprecate V1:** The backend will deprecate multipart routes. Mobile clients must transition 100% to V2 routes.
- **Isolate Transports:** The client will exclusively use the chunking worker for files, resolving all local file paths to remote `asset_id` strings.
- **Reference Replacement:** Once the sync worker determines all media queues for a parent form are `COMPLETED`, it will map local file identifiers to the generated `remote_asset_id`s and inject them into the V2 JSON payload.

## 3. V2 Payload Example (Cattle Registration)
```json
{
  "farmer_id": "frm_123456",
  "registration_date": "2026-06-11T12:00:00Z",
  "cattle": {
    "tag_number": "TAG9999",
    "breed": "Jersey",
    "media_assets": {
      "front_pose": "mock_asset_front_123",
      "side_pose": "mock_asset_side_456",
      "ear_tag_closeup": "mock_asset_tag_789"
    }
  }
}
```

## 4. Backend Validation
The backend JSON receiver MUST:
1. Validate that `mock_asset_front_123`, etc., exist in the system and are strictly owned by the caller.
2. Bind the assets to the `TAG9999` database entity.
3. Mark the assets as permanently retained (exempt from orphaned chunk garbage collection).
