import '../entities/shipment_entity.dart';

abstract interface class ShipmentRepository {
  Future<List<ShipmentEntity>> getShipments({bool forceRefresh = false});
  Future<ShipmentEntity> getShipmentById(String id, {bool forceRefresh = false});
  Future<void> updateShipmentStatusLocal(String id, ShipmentStatus status);
  Future<void> syncShipmentLocalToServer(String id);
  Future<void> createShipmentLocal(ShipmentEntity shipment);
  Future<void> updateShipmentLocal(ShipmentEntity shipment);
  Future<void> deleteShipmentLocal(String id);
}
