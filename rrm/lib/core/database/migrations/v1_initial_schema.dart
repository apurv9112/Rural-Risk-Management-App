class V1InitialSchema {
  static const int version = 1;

  static const String createSyncQueueTable = '''
    CREATE TABLE sync_queue (
      id TEXT PRIMARY KEY,
      state TEXT NOT NULL,
      payload TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      updatedAt INTEGER NOT NULL
    )
  ''';

  static const String createMediaQueueTable = '''
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
    )
  ''';

  static const String idxSyncState = 
    'CREATE INDEX idx_sync_status ON sync_queue(state)';
    
  static const String idxMediaSyncId = 
    'CREATE INDEX idx_media_queue_uuid ON media_queue(syncQueueId)';
    
  static const String idxMediaState = 
    'CREATE INDEX idx_media_upload_status ON media_queue(state)';
}
