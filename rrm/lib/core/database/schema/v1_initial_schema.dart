class V1InitialSchema {
  static const List<String> createTables = [
    '''
    CREATE TABLE users (
      local_uuid TEXT PRIMARY KEY,
      server_id TEXT UNIQUE,
      mobile_number TEXT UNIQUE,
      first_name TEXT,
      last_name TEXT,
      company_id TEXT,
      last_login_at TEXT,
      created_at TEXT,
      updated_at TEXT
    )
    ''',
    '''
    CREATE TABLE master_data (
      local_uuid TEXT PRIMARY KEY,
      server_id TEXT,
      category TEXT NOT NULL,
      key TEXT,
      value TEXT NOT NULL,
      parent_key TEXT,
      sort_order INTEGER DEFAULT 0,
      version INTEGER DEFAULT 1,
      is_active INTEGER DEFAULT 1,
      sync_source TEXT DEFAULT 'SEED',
      server_updated_at TEXT,
      updated_at TEXT,
      deleted_at TEXT
    )
    ''',
    '''
    CREATE TABLE master_data_sync_state (
        category TEXT PRIMARY KEY,
        sync_session_id TEXT,
        last_server_updated_at TEXT,
        current_page INTEGER DEFAULT 1,
        total_pages INTEGER DEFAULT 1,
        sync_status TEXT,
        last_successful_sync_at TEXT,
        last_error TEXT,
        started_at TEXT,
        completed_at TEXT,
        updated_at TEXT
    )
    ''',
    '''
    CREATE TABLE leads (
      local_uuid TEXT PRIMARY KEY,
      server_id TEXT UNIQUE,
      workflow_type TEXT,
      owner_name TEXT,
      mobile_number TEXT,
      village TEXT,
      total_cattle_count INTEGER,
      sync_status TEXT,
      revision_number INTEGER DEFAULT 1,
      local_revision_number INTEGER DEFAULT 1,
      server_revision_number INTEGER DEFAULT 1,
      last_server_updated_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT
    )
    ''',
    '''
    CREATE TABLE cattle (
      local_uuid TEXT PRIMARY KEY,
      lead_uuid TEXT,
      server_id TEXT UNIQUE,
      tag_number TEXT,
      old_tag_number TEXT,
      species TEXT,
      breed TEXT,
      age TEXT,
      sync_status TEXT,
      revision_number INTEGER DEFAULT 1,
      local_revision_number INTEGER DEFAULT 1,
      server_revision_number INTEGER DEFAULT 1,
      last_server_updated_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT,
      FOREIGN KEY (lead_uuid) REFERENCES leads(local_uuid) ON DELETE CASCADE
    )
    ''',
    '''
    CREATE TABLE media_metadata (
      local_uuid TEXT PRIMARY KEY,
      cattle_uuid TEXT,
      lead_uuid TEXT,
      server_id TEXT,
      capture_type TEXT,
      media_type TEXT,
      absolute_local_path TEXT,
      file_size_bytes INTEGER,
      md5_checksum TEXT,
      sync_status TEXT,
      synced_at TEXT,
      created_at TEXT,
      deleted_at TEXT,
      FOREIGN KEY (cattle_uuid) REFERENCES cattle(local_uuid) ON DELETE CASCADE
    )
    ''',
    '''
    CREATE TABLE sync_queue (
      queue_uuid TEXT PRIMARY KEY,
      dependency_queue_uuid TEXT,
      entity_type TEXT,
      entity_uuid TEXT,
      operation_type TEXT,
      payload_json TEXT,
      status TEXT,
      attempt_count INTEGER DEFAULT 0,
      next_retry_at TEXT,
      last_error TEXT,
      coalesce_key TEXT,
      idempotency_key TEXT NOT NULL,
      processing_started_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      media_status TEXT DEFAULT 'COMPLETED'
    )
    ''',
    '''
    CREATE TABLE media_queue (
      media_uuid TEXT PRIMARY KEY,
      queue_uuid TEXT NOT NULL,
      workflow_type TEXT,
      priority INTEGER DEFAULT 0,
      local_file_path TEXT NOT NULL,
      file_name TEXT NOT NULL,
      mime_type TEXT,
      file_size INTEGER NOT NULL,
      checksum TEXT,
      media_key_name TEXT NOT NULL,
      remote_asset_id TEXT,
      remote_upload_id TEXT,
      uploaded_bytes INTEGER DEFAULT 0,
      upload_status TEXT DEFAULT 'PENDING',
      upload_attempts INTEGER DEFAULT 0,
      last_error TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY(queue_uuid) REFERENCES sync_queue(queue_uuid) ON DELETE CASCADE
    )
    ''',
    '''
    CREATE TABLE sync_logs (
      log_uuid TEXT PRIMARY KEY,
      queue_uuid TEXT,
      entity_type TEXT,
      resolved_status TEXT,
      execution_time_ms INTEGER,
      created_at TEXT
    )
    ''',
    '''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT,
      updated_at TEXT
    )
    ''',
    '''
    CREATE TABLE conflict_log (
      conflict_uuid TEXT PRIMARY KEY,
      entity_type TEXT,
      entity_uuid TEXT,
      local_payload_json TEXT,
      server_payload_json TEXT,
      resolved_at TEXT,
      created_at TEXT
    )
    ''',
    '''
    CREATE TABLE draft_progress (
      entity_uuid TEXT PRIMARY KEY,
      workflow_type TEXT,
      current_step INTEGER,
      last_screen_route TEXT,
      completion_percentage REAL,
      updated_at TEXT
    )
    '''
  ];

  static const List<String> createIndexes = [
    'CREATE INDEX idx_users_mobile_number ON users(mobile_number);',
    'CREATE INDEX idx_leads_mobile ON leads(mobile_number);',
    'CREATE INDEX idx_cattle_tag ON cattle(tag_number);',
    'CREATE INDEX idx_leads_status ON leads(sync_status, deleted_at);',
    'CREATE INDEX idx_media_archive ON media_metadata(sync_status, created_at);',
    'CREATE INDEX idx_queue_poll ON sync_queue(status, next_retry_at, dependency_queue_uuid);',
    'CREATE INDEX idx_queue_sort ON sync_queue(status, created_at);',
    'CREATE INDEX idx_master_data_lookup ON master_data(category, parent_key, is_active, deleted_at);',
    'CREATE INDEX idx_master_data_server ON master_data(server_id);',
    'CREATE INDEX idx_master_data_updated ON master_data(server_updated_at);',
    'CREATE INDEX idx_media_queue_uuid ON media_queue(queue_uuid);',
    'CREATE INDEX idx_media_upload_status ON media_queue(upload_status);'
  ];
}
