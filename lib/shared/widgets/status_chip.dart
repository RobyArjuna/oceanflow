import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../features/shipment/domain/entities/shipment_entity.dart';

class StatusChip extends StatelessWidget {
  final ShipmentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case ShipmentStatus.pending:
        color = OceanColors.pending;
        label = 'Pending';
      case ShipmentStatus.loaded:
        color = OceanColors.loaded;
        label = 'Loaded';
      case ShipmentStatus.atPort:
        color = OceanColors.atPort;
        label = 'At Port';
      case ShipmentStatus.sailing:
        color = OceanColors.sailing;
        label = 'Sailing';
      case ShipmentStatus.arrived:
        color = OceanColors.arrived;
        label = 'Arrived';
      case ShipmentStatus.delivered:
        color = OceanColors.delivered;
        label = 'Delivered';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
