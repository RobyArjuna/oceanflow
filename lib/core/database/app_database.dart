import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/db_constants.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// SQLite database lifecycle manager.
/// Handles creation, migrations, and provides the underlying [Database] instance.
class AppDatabase {
  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);

    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    // WAL mode for better concurrent read performance
    await db.rawQuery('PRAGMA journal_mode = WAL');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createV1Tables(batch);
    if (version >= 2) _createV2Tables(batch);
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();
    if (oldVersion < 2) _createV2Tables(batch);
    await batch.commit(noResult: true);
  }

  void _createV1Tables(Batch batch) {
    // Shipments
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableShipments} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colTrackingNumber} TEXT NOT NULL,
        ${DbConstants.colStatus} TEXT NOT NULL,
        ${DbConstants.colOrigin} TEXT NOT NULL,
        ${DbConstants.colDestination} TEXT NOT NULL,
        ${DbConstants.colEta} TEXT,
        ${DbConstants.colVesselName} TEXT,
        ${DbConstants.colContainerIds} TEXT DEFAULT '[]',
        ${DbConstants.colCargoDescription} TEXT,
        ${DbConstants.colWeightKg} REAL,
        ${DbConstants.colOwnerId} TEXT NOT NULL,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL,
        ${DbConstants.colIsDirty} INTEGER DEFAULT 0,
        ${DbConstants.colCachedAt} TEXT NOT NULL
      )
    ''');

    // Tracking Checkpoints
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableCheckpoints} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colShipmentId} TEXT NOT NULL,
        ${DbConstants.colStatus} TEXT NOT NULL,
        ${DbConstants.colLocation} TEXT,
        ${DbConstants.colNotes} TEXT,
        ${DbConstants.colProofImagePath} TEXT,
        ${DbConstants.colScannedCode} TEXT,
        ${DbConstants.colOperatorId} TEXT NOT NULL,
        ${DbConstants.colIsSynced} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colShipmentId}) 
          REFERENCES ${DbConstants.tableShipments}(${DbConstants.colId})
          ON DELETE CASCADE
      )
    ''');

    // Sync Queue
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableSyncQueue} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colActionType} TEXT NOT NULL,
        ${DbConstants.colEntityType} TEXT NOT NULL,
        ${DbConstants.colEntityId} TEXT NOT NULL,
        ${DbConstants.colPayload} TEXT NOT NULL,
        ${DbConstants.colSyncStatus} TEXT NOT NULL DEFAULT 'pending',
        ${DbConstants.colRetryCount} INTEGER DEFAULT 0,
        ${DbConstants.colMaxRetries} INTEGER DEFAULT 5,
        ${DbConstants.colLastError} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colNextRetryAt} TEXT,
        ${DbConstants.colPriority} INTEGER DEFAULT 5
      )
    ''');

    // Notifications
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableNotifications} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colTitle} TEXT NOT NULL,
        ${DbConstants.colBody} TEXT NOT NULL,
        ${DbConstants.colType} TEXT NOT NULL,
        ${DbConstants.colReferenceId} TEXT,
        ${DbConstants.colIsRead} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');

    // Indexes for performance
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_shipments_status 
      ON ${DbConstants.tableShipments}(${DbConstants.colStatus})
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_status_priority 
      ON ${DbConstants.tableSyncQueue}(${DbConstants.colSyncStatus}, ${DbConstants.colPriority} DESC)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkpoints_shipment 
      ON ${DbConstants.tableCheckpoints}(${DbConstants.colShipmentId})
    ''');
  }

  void _createV2Tables(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableAiConversations} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colRole} TEXT NOT NULL,
        ${DbConstants.colContent} TEXT NOT NULL,
        ${DbConstants.colShipmentContextId} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
