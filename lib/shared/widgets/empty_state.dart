import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: OceanColors.grey400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel ?? 'Reload Log'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
