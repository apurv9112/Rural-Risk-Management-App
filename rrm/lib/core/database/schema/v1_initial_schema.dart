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
      category TEXT,
      key TEXT,
      value TEXT,
      parent_key TEXT,
      is_active INTEGER,
      server_updated_at TEXT
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
      updated_at TEXT
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
    'CREATE INDEX idx_queue_poll ON sync_queue(status, next_retry_at, dependency_queue_uuid);'
  ];
}
