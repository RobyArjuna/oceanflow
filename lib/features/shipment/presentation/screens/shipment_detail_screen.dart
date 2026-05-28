import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/auth/auth_state.dart';
import '../providers/shipment_provider.dart';
import '../../domain/entities/shipment_entity.dart';

class ShipmentDetailScreen extends ConsumerWidget {
  final String shipmentId;

  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(shipmentDetailProvider(shipmentId));
    final currentUser = ref.watch(authStateProvider).user;
    final canUpdate = currentUser?.role == UserRole.operator ||
        currentUser?.role == UserRole.driver ||
        currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHIPMENT SPECIFICATIONS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(shipmentDetailProvider(shipmentId).notifier).loadDetail(forceRefresh: true);
            },
          ),
        ],
      ),
      body: detailState.when(
        loading: () => const _DetailSkeleton(),
        error: (err, _) => ErrorState(
          title: 'Retrieval Issue',
          errorMessage: err.toString(),
          onRetry: () {
            ref.read(shipmentDetailProvider(shipmentId).notifier).loadDetail();
          },
        ),
        data: (shipment) {
          final etaDate = shipment.eta != null ? DateTime.tryParse(shipment.eta!) : null;
          final formattedEta = etaDate != null
              ? DateFormat('MMM dd, yyyy - HH:mm').format(etaDate)
              : 'Unscheduled';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Specifications Header Card
                _SpecificationsHeader(
                  shipment: shipment,
                  formattedEta: formattedEta,
                ),
                const SizedBox(height: 20),

                // Operational Checklist Action
                if (canUpdate) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('${RouteNames.shipments}/detail/${shipment.id}/${RouteNames.trackingUpdate}');
                    },
                    icon: const Icon(Icons.edit_road_outlined),
                    label: const Text('LOG OPERATIONAL CHECKPOINT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OceanColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Cargo Manifest Card
                _ManifestDetails(shipment: shipment),
                const SizedBox(height: 20),

                // Shipment status flow timeline
                _ShipmentProgressTimeline(currentStatus: shipment.status),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpecificationsHeader extends StatelessWidget {
  final ShipmentEntity shipment;
  final String formattedEta;

  const _SpecificationsHeader({
    required this.shipment,
    required this.formattedEta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.trackingNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_boat_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              shipment.vesselName ?? 'No Vessel Assigned',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(status: shipment.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _SpecificationField(
              icon: Icons.access_time_rounded,
              label: 'Estimated Cargo Arrival (ETA)',
              value: formattedEta,
            ),
            const SizedBox(height: 12),
            _SpecificationField(
              icon: Icons.place_outlined,
              label: 'Origin Port location',
              value: shipment.origin,
            ),
            const SizedBox(height: 12),
            _SpecificationField(
              icon: Icons.location_on_outlined,
              label: 'Destination warehouse delivery',
              value: shipment.destination,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManifestDetails extends StatelessWidget {
  final ShipmentEntity shipment;

  const _ManifestDetails({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cargo Manifest',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _SpecificationField(
              icon: Icons.description_outlined,
              label: 'Operational Cargo Description',
              value: shipment.cargoDescription ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _SpecificationField(
              icon: Icons.scale_outlined,
              label: 'Total Net Weight',
              value: shipment.weightKg != null ? '${shipment.weightKg} kg' : 'Unknown',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Assigned Containers',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: shipment.containerIds.map((cid) {
                return Chip(
                  avatar: const Icon(Icons.inventory_2_outlined, size: 14),
                  label: Text(cid),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecificationField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecificationField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: OceanColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: OceanColors.grey400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShipmentProgressTimeline extends StatelessWidget {
  final ShipmentStatus currentStatus;

  const _ShipmentProgressTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statusList = ShipmentStatus.values;
    final currentIndex = statusList.indexOf(currentStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipment Status Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusList.length,
              itemBuilder: (context, index) {
                final status = statusList[index];
                final isCompleted = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and line track builder
                    Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? OceanColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? OceanColors.primary
                                  : OceanColors.grey400,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        if (index < statusList.length - 1)
                          Container(
                            width: 2,
                            height: 36,
                            color: index < currentIndex
                                ? OceanColors.primary
                                : OceanColors.grey400.withOpacity(0.3),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // Detail of step
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? OceanColors.primary
                                    : (isCompleted ? null : OceanColors.grey400),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusMessage(status),
                              style: TextStyle(
                                fontSize: 11,
                                color: isCompleted ? null : OceanColors.grey400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Order booked, preparing container loads.';
      case ShipmentStatus.loaded:
        return 'Containers sealed and loaded onto transfer chassis.';
      case ShipmentStatus.atPort:
        return 'Arrived at departure shipyard terminal gate.';
      case ShipmentStatus.sailing:
        return 'Vessel departed; currently in deep sea transit.';
      case ShipmentStatus.arrived:
        return 'Arrived at destination discharge port terminal.';
      case ShipmentStatus.delivered:
        return 'Discharged and cargo successfully received at local warehouse.';
    }
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerLoader.rectangular(width: double.infinity, height: 180),
          SizedBox(height: 20),
          ShimmerLoader.rectangular(width: double.infinity, height: 160),
          SizedBox(height: 20),
          ShimmerLoader.rectangular(width: double.infinity, height: 280),
        ],
      ),
    );
  }
}
