import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/shipment_provider.dart';
import '../../domain/entities/shipment_entity.dart';

class ShipmentListScreen extends ConsumerStatefulWidget {
  const ShipmentListScreen({super.key});

  @override
  ConsumerState<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _LoginPromptBanner extends StatelessWidget {
  final String label;
  const _LoginPromptBanner({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OceanColors.primary.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: OceanColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OceanColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentListScreenState extends ConsumerState<ShipmentListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _generateRandomTracking() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _showShipmentForm(BuildContext context, {ShipmentEntity? shipment}) {
    final isEdit = shipment != null;
    final formKey = GlobalKey<FormState>();

    final trackingController = TextEditingController(
      text: isEdit ? shipment.trackingNumber : 'TRK-2026-${_generateRandomTracking()}',
    );
    final originController = TextEditingController(
      text: isEdit ? shipment.origin : '',
    );
    final destinationController = TextEditingController(
      text: isEdit ? shipment.destination : '',
    );
    final vesselController = TextEditingController(
      text: isEdit ? shipment.vesselName ?? '' : '',
    );
    final cargoController = TextEditingController(
      text: isEdit ? shipment.cargoDescription ?? '' : '',
    );
    final weightController = TextEditingController(
      text: isEdit ? shipment.weightKg?.toString() ?? '' : '',
    );

    ShipmentStatus selectedStatus = isEdit ? shipment.status : ShipmentStatus.pending;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: OceanColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2D3748), width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_road_rounded : Icons.add_road_rounded,
                    color: OceanColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'EDIT SHIPMENT' : 'NEW SHIPMENT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: trackingController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Tracking Number',
                          prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Tracking number required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: originController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Origin Port',
                          prefixIcon: Icon(Icons.circle_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Origin port required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: destinationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Destination Port',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Destination port required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: vesselController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Vessel Name',
                          prefixIcon: Icon(Icons.directions_boat_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: cargoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Cargo Description',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: weightController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Must be a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<ShipmentStatus>(
                        value: selectedStatus,
                        dropdownColor: OceanColors.surfaceElevated,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.rocket_launch_outlined),
                        ),
                        items: ShipmentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.name.toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedStatus = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: OceanColors.grey400)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final user = ref.read(authStateProvider).user;
                      final ownerId = user?.id ?? 'usr_admin_001';

                      final updatedShipment = ShipmentEntity(
                        id: isEdit ? shipment.id : 'shp_${DateTime.now().millisecondsSinceEpoch}',
                        trackingNumber: trackingController.text.trim(),
                        status: selectedStatus,
                        origin: originController.text.trim(),
                        destination: destinationController.text.trim(),
                        vesselName: vesselController.text.trim().isNotEmpty ? vesselController.text.trim() : null,
                        cargoDescription: cargoController.text.trim().isNotEmpty ? cargoController.text.trim() : null,
                        weightKg: double.tryParse(weightController.text.trim()),
                        containerIds: isEdit ? shipment.containerIds : ['CONT-${1000 + Random().nextInt(8999)}'],
                        ownerId: ownerId,
                        createdAt: isEdit ? shipment.createdAt : DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        isDirty: true,
                      );

                      if (isEdit) {
                        ref.read(shipmentListProvider.notifier).updateShipment(updatedShipment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Shipment ${updatedShipment.trackingNumber} updated locally & queued for sync.'),
                            backgroundColor: OceanColors.teal,
                          ),
                        );
                      } else {
                        ref.read(shipmentListProvider.notifier).createShipment(updatedShipment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Shipment ${updatedShipment.trackingNumber} added locally & queued for sync.'),
                            backgroundColor: OceanColors.primary,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEdit ? 'SAVE' : 'CREATE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(shipmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHIPMENT OPERATIONS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(shipmentListProvider.notifier).loadShipments(forceRefresh: true);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShipmentForm(context),
        tooltip: 'Add Shipment',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          const _LoginPromptBanner(
            label: 'Offline-First: All changes save to local DB instantly and sync when online.',
          ),
          
          // Search & Filter Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search cargo number, vessel, origin...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Reactive List Area
          Expanded(
            child: shipmentState.when(
              loading: () => const ShipmentListSkeleton(),
              error: (err, _) => ErrorState(
                title: 'Operation Failure',
                errorMessage: err.toString(),
                onRetry: () {
                  ref.read(shipmentListProvider.notifier).loadShipments();
                },
              ),
              data: (shipments) {
                final filtered = shipments.where((s) {
                  return s.trackingNumber.toLowerCase().contains(_searchQuery) ||
                      s.origin.toLowerCase().contains(_searchQuery) ||
                      s.destination.toLowerCase().contains(_searchQuery) ||
                      (s.vesselName?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    title: 'No Cargo Found',
                    description: 'No shipments match the specified active tracking code filter.',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(shipmentListProvider.notifier).loadShipments(forceRefresh: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final shipment = filtered[index];
                      return Dismissible(
                        key: Key(shipment.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: OceanColors.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'DELETE FROM DB',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: OceanColors.surfaceElevated,
                              title: const Text('Confirm Deletion'),
                              content: Text('Delete shipment ${shipment.trackingNumber} from local database?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('CANCEL', style: TextStyle(color: OceanColors.grey400)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: OceanColors.error),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          ref.read(shipmentListProvider.notifier).deleteShipment(shipment.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Shipment ${shipment.trackingNumber} deleted locally & queue updated.'),
                              backgroundColor: OceanColors.error,
                            ),
                          );
                        },
                        child: _ShipmentListItemCard(
                          shipment: shipment,
                          onEdit: () => _showShipmentForm(context, shipment: shipment),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms, delay: (index * 50).ms)
                            .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentListItemCard extends StatelessWidget {
  final ShipmentEntity shipment;
  final VoidCallback onEdit;

  const _ShipmentListItemCard({
    required this.shipment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.go('${RouteNames.shipments}/detail/${shipment.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            shipment.trackingNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (shipment.isDirty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: OceanColors.warning.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 14,
                              color: OceanColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: OceanColors.grey400),
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: shipment.status),
                ],
              ),
              const SizedBox(height: 16),
              
              // Direct route connection track
              Row(
                children: [
                  const Icon(Icons.circle_outlined, size: 14, color: OceanColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.origin,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: SizedBox(
                  height: 12,
                  child: VerticalDivider(
                    thickness: 1.5,
                    width: 1.5,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: OceanColors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.destination,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Bottom row summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.directions_boat_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            shipment.vesselName ?? 'Not Assigned',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${shipment.containerIds.length} CONTAINERS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

