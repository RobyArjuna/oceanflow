import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/repositories/shipment_repository.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final AppDatabase _dbHelper;
  final NetworkInfo _networkInfo;
  final Random _random = Random();

  ShipmentRepositoryImpl(this._dbHelper, this._networkInfo);

  Future<Database> get _db => _dbHelper.database;

  // Mock server latency simulation
  Future<void> _simulateLatency() async {
    final delay = 300 + _random.nextInt(500);
    await Future<void>.delayed(Duration(milliseconds: delay));
  }

  @override
  Future<List<ShipmentEntity>> getShipments({bool forceRefresh = false}) async {
    final db = await _db;
    final isOnline = await _networkInfo.isConnected;

    // 1. Check local DB cache
    final localMaps = await db.query(DbConstants.tableShipments);

    // If no cache, or force refresh is requested while online, fetch from remote
    if (localMaps.isEmpty || (forceRefresh && isOnline)) {
      if (!isOnline) {
        if (localMaps.isNotEmpty) {
          return _mapShipmentList(localMaps);
        }
        throw const NetworkError(
            message: 'Offline: Cannot fetch initial shipment log.');
      }

      await _simulateLatency();
      // Generate initial mock remote shipments
      final remoteShipments = _generateMockShipments();

      // Clear old cached shipments that aren't dirty
      await db.delete(
        DbConstants.tableShipments,
        where: '${DbConstants.colIsDirty} = 0',
      );

      // Cache the new records
      final batch = db.batch();
      for (final shipment in remoteShipments) {
        batch.insert(
          DbConstants.tableShipments,
          _toMap(shipment),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      final updatedLocal = await db.query(DbConstants.tableShipments);
      return _mapShipmentList(updatedLocal);
    }

    return _mapShipmentList(localMaps);
  }

  @override
  Future<ShipmentEntity> getShipmentById(String id,
      {bool forceRefresh = false}) async {
    final db = await _db;
    final isOnline = await _networkInfo.isConnected;

    if (forceRefresh && isOnline) {
      await _simulateLatency();
      final shipments = await getShipments(forceRefresh: true);
      return shipments.firstWhere((s) => s.id == id);
    }

    final maps = await db.query(
      DbConstants.tableShipments,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw DatabaseError(message: 'Shipment with ID $id not found locally.');
    }

    return _mapShipment(maps.first);
  }

  @override
  Future<void> updateShipmentStatusLocal(
      String id, ShipmentStatus status) async {
    final db = await _db;
    final shipment = await getShipmentById(id);

    final updated = shipment.copyWith(
      status: status,
      isDirty: true,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await db.update(
      DbConstants.tableShipments,
      _toMap(updated),
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> syncShipmentLocalToServer(String id) async {
    final db = await _db;
    // Check if the shipment exists locally (it might have been deleted locally)
    final maps = await db.query(
      DbConstants.tableShipments,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      // Already deleted locally, nothing to clean up
      return;
    }

    final shipment = _mapShipment(maps.first);

    // Simulate remote server push
    await _simulateLatency();

    final cleanShipment = shipment.copyWith(
      isDirty: false,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await db.update(
      DbConstants.tableShipments,
      _toMap(cleanShipment),
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> createShipmentLocal(ShipmentEntity shipment) async {
    final db = await _db;
    final updated = shipment.copyWith(
      isDirty: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.insert(
      DbConstants.tableShipments,
      _toMap(updated),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateShipmentLocal(ShipmentEntity shipment) async {
    final db = await _db;
    final updated = shipment.copyWith(
      isDirty: true,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.update(
      DbConstants.tableShipments,
      _toMap(updated),
      where: '${DbConstants.colId} = ?',
      whereArgs: [shipment.id],
    );
  }

  @override
  Future<void> deleteShipmentLocal(String id) async {
    final db = await _db;
    await db.delete(
      DbConstants.tableShipments,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  List<ShipmentEntity> _mapShipmentList(List<Map<String, dynamic>> maps) {
    return maps.map(_mapShipment).toList();
  }

  ShipmentEntity _mapShipment(Map<String, dynamic> map) {
    return ShipmentEntity(
      id: map[DbConstants.colId] as String,
      trackingNumber: map[DbConstants.colTrackingNumber] as String,
      status: ShipmentStatus.values.firstWhere(
        (s) => s.name == map[DbConstants.colStatus],
        orElse: () => ShipmentStatus.pending,
      ),
      origin: map[DbConstants.colOrigin] as String,
      destination: map[DbConstants.colDestination] as String,
      eta: map[DbConstants.colEta] as String?,
      vesselName: map[DbConstants.colVesselName] as String?,
      containerIds: List<String>.from(
        jsonDecode(map[DbConstants.colContainerIds] as String? ?? '[]')
            as Iterable,
      ),
      cargoDescription: map[DbConstants.colCargoDescription] as String?,
      weightKg: map[DbConstants.colWeightKg] as double?,
      ownerId: map[DbConstants.colOwnerId] as String,
      createdAt: map[DbConstants.colCreatedAt] as String,
      updatedAt: map[DbConstants.colUpdatedAt] as String,
      isDirty: (map[DbConstants.colIsDirty] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> _toMap(ShipmentEntity shipment) {
    return {
      DbConstants.colId: shipment.id,
      DbConstants.colTrackingNumber: shipment.trackingNumber,
      DbConstants.colStatus: shipment.status.name,
      DbConstants.colOrigin: shipment.origin,
      DbConstants.colDestination: shipment.destination,
      DbConstants.colEta: shipment.eta,
      DbConstants.colVesselName: shipment.vesselName,
      DbConstants.colContainerIds: jsonEncode(shipment.containerIds),
      DbConstants.colCargoDescription: shipment.cargoDescription,
      DbConstants.colWeightKg: shipment.weightKg,
      DbConstants.colOwnerId: shipment.ownerId,
      DbConstants.colCreatedAt: shipment.createdAt,
      DbConstants.colUpdatedAt: shipment.updatedAt,
      DbConstants.colIsDirty: shipment.isDirty ? 1 : 0,
      DbConstants.colCachedAt: DateTime.now().toIso8601String(),
    };
  }

  List<ShipmentEntity> _generateMockShipments() {
    return [
      ShipmentEntity(
        id: 'shp_001',
        trackingNumber: 'TRK-IDN-2026-A102',
        status: ShipmentStatus.sailing,
        origin: 'Port of Tanjung Priok, Jakarta',
        destination: 'Port of Belawan, Medan',
        eta: '2026-06-05T18:00:00Z',
        vesselName: 'KM Nusantara Jaya',
        containerIds: ['CONT-ID1001', 'CONT-ID2045'],
        cargoDescription: 'Electronic Components & Retail Distribution Goods',
        weightKg: 12450.0,
        ownerId: 'usr_admin_001',
        createdAt: '2026-05-10T08:00:00Z',
        updatedAt: '2026-05-20T14:22:00Z',
      ),
      ShipmentEntity(
        id: 'shp_002',
        trackingNumber: 'TRK-IDN-2026-B223',
        status: ShipmentStatus.atPort,
        origin: 'Port of Tanjung Perak, Surabaya',
        destination: 'Port of Makassar, Sulawesi Selatan',
        eta: '2026-05-28T06:30:00Z',
        vesselName: 'KM Samudera Timur',
        containerIds: ['CONT-ID3302'],
        cargoDescription: 'Medical Equipment & Pharmaceutical Supplies',
        weightKg: 8900.0,
        ownerId: 'usr_super_002',
        createdAt: '2026-05-12T12:00:00Z',
        updatedAt: '2026-05-21T09:15:00Z',
      ),
      ShipmentEntity(
        id: 'shp_003',
        trackingNumber: 'TRK-IDN-2026-C774',
        status: ShipmentStatus.loaded,
        origin: 'Port of Batam, Kepulauan Riau',
        destination: 'Port of Sorong, Papua Barat',
        eta: '2026-06-12T21:00:00Z',
        vesselName: 'KM Laut Indonesia',
        containerIds: [
          'CONT-ID6632',
          'CONT-ID8891',
          'CONT-ID2245',
        ],
        cargoDescription: 'Heavy Machinery & Mining Equipment',
        weightKg: 28400.0,
        ownerId: 'usr_op_003',
        createdAt: '2026-05-15T09:30:00Z',
        updatedAt: '2026-05-21T11:00:00Z',
      ),
      ShipmentEntity(
        id: 'shp_004',
        trackingNumber: 'TRK-IDN-2026-D449',
        status: ShipmentStatus.delivered,
        origin: 'Port of Balikpapan, Kalimantan Timur',
        destination: 'Port of Benoa, Bali',
        eta: '2026-05-20T15:00:00Z',
        vesselName: 'KM Garuda Bahari',
        containerIds: ['CONT-ID7002'],
        cargoDescription: 'Solar Panel Modules & Energy Infrastructure',
        weightKg: 14200.0,
        ownerId: 'usr_drv_004',
        createdAt: '2026-05-08T07:15:00Z',
        updatedAt: '2026-05-20T15:45:00Z',
      ),
      ShipmentEntity(
        id: 'shp_005',
        trackingNumber: 'TRK-IDN-2026-E118',
        status: ShipmentStatus.pending,
        origin: 'Port of Bitung, Sulawesi Utara',
        destination: 'Port of Ambon, Maluku',
        eta: '2026-06-18T10:00:00Z',
        vesselName: 'KM Cakrawala Timur',
        containerIds: ['CONT-ID3301', 'CONT-ID5521'],
        cargoDescription: 'Frozen Seafood & Refrigerated Food Products',
        weightKg: 5200.0,
        ownerId: 'usr_admin_001',
        createdAt: '2026-05-20T16:00:00Z',
        updatedAt: '2026-05-20T16:00:00Z',
      ),
    ];
  }
}
