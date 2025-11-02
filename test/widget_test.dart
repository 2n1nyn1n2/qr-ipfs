// Imports the Flutter testing utilities.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Imports the file you want to test (your app's main file).
// NOTE: Adjust the path if your main file is not at 'package:qr_ipfs/main.dart'
import 'package:qr_ipfs/main.dart';

void main() {
  // The group function allows you to organize multiple related tests.
  group('QrIpfsApp Tests', () {
    // The testWidgets function is used for testing widget rendering and interaction.
    testWidgets('App displays the correct title', (WidgetTester tester) async {
      // 1. Arrange: Build the widget under test.
      // We use the corrected version of the app (const removed from AppBar).
      await tester.pumpWidget(const QrIpfsApp());

      // 2. Act: Find the widget(s) we want to verify.
      // We look for a Text widget that contains the exact string 'QR-IPFS SPA'.
      final titleFinder = find.text('QR-IPFS SPA');

      // 3. Assert: Verify the results.
      // Expect that exactly one widget with that text is found.
      expect(titleFinder, findsOneWidget);

      // The app also contains a CircularProgressIndicator while loading.
      // We can check for its presence initially.
      final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(loadingIndicatorFinder, findsOneWidget);
    });
  });
}
