import 'package:meta/meta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/db_constants.dart';

@immutable
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? referenceId,
    bool? isRead,
    String? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationListNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationListNotifier(ref.watch(appDatabaseProvider));
});

class NotificationListNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final AppDatabase _dbHelper;
  final _uuid = const Uuid();

  NotificationListNotifier(this._dbHelper) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbConstants.tableNotifications,
        orderBy: '${DbConstants.colCreatedAt} DESC',
      );

      // Populate mock notifications if empty on first-run
      if (maps.isEmpty) {
        await _insertInitialMockNotifications();
        await loadNotifications();
        return;
      }

      final list = maps.map((map) {
        return AppNotification(
          id: map[DbConstants.colId] as String,
          title: map[DbConstants.colTitle] as String,
          body: map[DbConstants.colBody] as String,
          type: map[DbConstants.colType] as String,
          referenceId: map[DbConstants.colReferenceId] as String?,
          isRead: (map[DbConstants.colIsRead] as int? ?? 0) == 1,
          createdAt: map[DbConstants.colCreatedAt] as String,
        );
      }).toList();

      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        DbConstants.tableNotifications,
        {DbConstants.colIsRead: 1},
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      await loadNotifications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(DbConstants.tableNotifications);
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _insertInitialMockNotifications() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final mocks = [
      {
        DbConstants.colId: 'notif_001',
        DbConstants.colTitle: 'Vessel Arrival Alert',
        DbConstants.colBody: 'Vessel Atlantic Pioneer has entered Newark Harbor berths limits.',
        DbConstants.colType: 'shipment_update',
        DbConstants.colReferenceId: 'shp_001',
        DbConstants.colIsRead: 0,
        DbConstants.colCreatedAt: now,
      },
      {
        DbConstants.colId: 'notif_002',
        DbConstants.colTitle: 'Queue Sync Completed',
        DbConstants.colBody: 'Operational checkpoints for TRK-2026-K0081 synced successfully.',
        DbConstants.colType: 'sync_result',
        DbConstants.colReferenceId: 'shp_002',
        DbConstants.colIsRead: 1,
        DbConstants.colCreatedAt: now,
      },
    ];

    final batch = db.batch();
    for (final m in mocks) {
      batch.insert(
        DbConstants.tableNotifications,
        m,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
