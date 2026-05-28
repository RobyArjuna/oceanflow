import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/models/sync_action.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../data/repositories/shipment_repository_impl.dart';

final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(networkInfoProvider),
  );
});

final shipmentListProvider =
    StateNotifierProvider<ShipmentListNotifier, AsyncValue<List<ShipmentEntity>>>((ref) {
  return ShipmentListNotifier(ref.watch(shipmentRepositoryProvider), ref);
});

class ShipmentListNotifier extends StateNotifier<AsyncValue<List<ShipmentEntity>>> {
  final ShipmentRepository _repository;
  final Ref _ref;

  ShipmentListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadShipments();
  }

  Future<void> loadShipments({bool forceRefresh = false}) async {
    if (forceRefresh) {
      state = const AsyncValue.loading();
    }
    try {
      final shipments = await _repository.getShipments(forceRefresh: forceRefresh);
      state = AsyncValue.data(shipments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateShipmentStatusLocal(String id, ShipmentStatus status) async {
    try {
      // Optimistic state update in UI
      state.whenData((list) {
        state = AsyncValue.data(
          list.map((s) => s.id == id ? s.copyWith(status: status, isDirty: true) : s).toList(),
        );
      });

      // Save locally to SQLite cache
      await _repository.updateShipmentStatusLocal(id, status);
      
      // Reload from local to confirm database sync
      await loadShipments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createShipment(ShipmentEntity shipment) async {
    try {
      // Optimistic state update in UI
      state.whenData((list) {
        state = AsyncValue.data([shipment.copyWith(isDirty: true), ...list]);
      });

      // Save locally to SQLite cache
      await _repository.createShipmentLocal(shipment);

      // Enqueue sync action
      final syncEngine = _ref.read(syncEngineProvider);
      await syncEngine.enqueue(
        actionType: SyncActionType.createShipment,
        entityType: 'shipment',
        entityId: shipment.id,
        payload: {
          'id': shipment.id,
          'trackingNumber': shipment.trackingNumber,
          'status': shipment.status.name,
          'origin': shipment.origin,
          'destination': shipment.destination,
          'vesselName': shipment.vesselName,
          'containerIds': shipment.containerIds,
          'cargoDescription': shipment.cargoDescription,
          'weightKg': shipment.weightKg,
          'ownerId': shipment.ownerId,
        },
      );

      // Reload from local to confirm database sync
      await loadShipments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateShipment(ShipmentEntity shipment) async {
    try {
      // Optimistic state update in UI
      state.whenData((list) {
        state = AsyncValue.data(
          list.map((s) => s.id == shipment.id ? shipment.copyWith(isDirty: true) : s).toList(),
        );
      });

      // Save locally to SQLite cache
      await _repository.updateShipmentLocal(shipment);

      // Enqueue sync action
      final syncEngine = _ref.read(syncEngineProvider);
      await syncEngine.enqueue(
        actionType: SyncActionType.updateShipment,
        entityType: 'shipment',
        entityId: shipment.id,
        payload: {
          'id': shipment.id,
          'trackingNumber': shipment.trackingNumber,
          'status': shipment.status.name,
          'origin': shipment.origin,
          'destination': shipment.destination,
          'vesselName': shipment.vesselName,
          'containerIds': shipment.containerIds,
          'cargoDescription': shipment.cargoDescription,
          'weightKg': shipment.weightKg,
          'ownerId': shipment.ownerId,
        },
      );

      // Reload from local to confirm database sync
      await loadShipments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteShipment(String id) async {
    try {
      // Optimistic state update in UI
      state.whenData((list) {
        state = AsyncValue.data(list.where((s) => s.id != id).toList());
      });

      // Save locally to SQLite cache
      await _repository.deleteShipmentLocal(id);

      // Enqueue sync action
      final syncEngine = _ref.read(syncEngineProvider);
      await syncEngine.enqueue(
        actionType: SyncActionType.deleteShipment,
        entityType: 'shipment',
        entityId: id,
        payload: {'id': id},
      );

      // Reload from local to confirm database sync
      await loadShipments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final shipmentDetailProvider = StateNotifierProvider.family<
    ShipmentDetailNotifier,
    AsyncValue<ShipmentEntity>,
    String>((ref, id) {
  return ShipmentDetailNotifier(ref.watch(shipmentRepositoryProvider), id);
});

class ShipmentDetailNotifier extends StateNotifier<AsyncValue<ShipmentEntity>> {
  final ShipmentRepository _repository;
  final String _id;

  ShipmentDetailNotifier(this._repository, this._id) : super(const AsyncValue.loading()) {
    loadDetail();
  }

  Future<void> loadDetail({bool forceRefresh = false}) async {
    try {
      final shipment = await _repository.getShipmentById(_id, forceRefresh: forceRefresh);
      state = AsyncValue.data(shipment);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
