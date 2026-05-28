import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment_entity.dart';
import '../providers/tracking_provider.dart';

class TrackingUpdateScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const TrackingUpdateScreen({super.key, required this.shipmentId});

  @override
  ConsumerState<TrackingUpdateScreen> createState() => _TrackingUpdateScreenState();
}

class _TrackingUpdateScreenState extends ConsumerState<TrackingUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  ShipmentStatus? _selectedStatus;
  String? _scannedCode;
  String? _simulatedPhotoPath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _simulatePhotoCapture() {
    setState(() {
      _simulatedPhotoPath = '/storage/emulated/0/DCIM/Camera/IMG_2026_CONT_PROOF.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated Camera: Photo proof captured successfully.'),
        backgroundColor: OceanColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simulateCodeScanner() {
    setState(() {
      _scannedCode = 'CONT-SEAL-89721-A';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated Scanner: Container barcode CONT-SEAL-89721-A scanned.'),
        backgroundColor: OceanColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitCheckpoint() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an operational status update.'),
          backgroundColor: OceanColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authStateProvider).user;
      final operatorId = user?.id ?? 'usr_anonymous';

      await ref.read(trackingProvider).submitCheckpoint(
            shipmentId: widget.shipmentId,
            status: _selectedStatus!,
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            proofImagePath: _simulatedPhotoPath,
            scannedCode: _scannedCode,
            operatorId: operatorId,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkpoint logged locally. Sync queue initialized.'),
          backgroundColor: OceanColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Force detail reload so layout displays changes instantly
      ref.read(shipmentDetailProvider(widget.shipmentId).notifier).loadDetail();

      context.go('${RouteNames.shipments}/detail/${widget.shipmentId}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to queue update: $e'),
          backgroundColor: OceanColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(shipmentDetailProvider(widget.shipmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOG OPERATIONAL CHECKPOINT'),
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (shipment) {
          // Initialize selected status on first load
          _selectedStatus ??= shipment.status;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment.trackingNumber,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Route: ${shipment.origin} → ${shipment.destination}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Selector Dropdown
                  DropdownButtonFormField<ShipmentStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Cargo Status update',
                      prefixIcon: Icon(Icons.swap_horizontal_circle_outlined),
                    ),
                    items: ShipmentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedStatus = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location text input
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Current GPS / Port location coordinate',
                      prefixIcon: Icon(Icons.place_outlined),
                      hintText: 'e.g., Shanghai Terminal 4, Berth B3',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note text field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Operational checklist comments',
                      prefixIcon: Icon(Icons.notes_rounded),
                      hintText: 'Describe container damage checks, vessel delays, sea weather...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Proof Actions Row
                  Row(
                    children: [
                      // Camera simulation button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _simulatePhotoCapture,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('PROOF PHOTO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OceanColors.surfaceElevated,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Barcode scanner simulation button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _simulateCodeScanner,
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('SCAN SEAL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OceanColors.surfaceElevated,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Captured status view
                  if (_simulatedPhotoPath != null || _scannedCode != null)
                    Card(
                      color: OceanColors.surfaceElevated,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            if (_simulatedPhotoPath != null)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: OceanColors.success, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Container Proof Image Saved',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            if (_simulatedPhotoPath != null && _scannedCode != null)
                              const SizedBox(height: 8),
                            if (_scannedCode != null)
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: OceanColors.success, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Seal Scanned: $_scannedCode',
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Log Checkpoint Action Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCheckpoint,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                        : const Text('CONFIRM & ENQUEUE CHECKPOINT'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
