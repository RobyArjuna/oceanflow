import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oceanflow/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('displays title, description, and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No Cargo Found',
              description: 'Try searching for another shipment.',
              icon: Icons.search_off_rounded,
            ),
          ),
        ),
      );

      // Verify strings and icon display correctly
      expect(find.text('No Cargo Found'), findsOneWidget);
      expect(find.text('Try searching for another shipment.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('triggers onRetry callback when tapped', (WidgetTester tester) async {
      bool isCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Offline',
              description: 'Cannot fetch cargo list.',
              icon: Icons.wifi_off_rounded,
              retryLabel: 'Try Again',
              onRetry: () {
                isCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify retry button is visible
      final buttonText = find.text('Try Again');
      expect(buttonText, findsOneWidget);

      // Tap the button and verify callback triggers
      await tester.tap(buttonText);
      await tester.pump();

      expect(isCalled, isTrue);
    });
  });
}
