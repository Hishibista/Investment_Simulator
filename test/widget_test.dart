import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/main.dart';

void main() {
  testWidgets('App loads home screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We pass firebaseInitialized: true to simulate a successful initialization
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(firebaseInitialized: true),
      ),
    );

    // Verify that the Home Screen content is displayed.
    expect(find.text('Investment Strategy'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('View Samples'), findsOneWidget);
  });

  testWidgets('App shows error when Firebase fails', (WidgetTester tester) async {
    // Build our app with firebaseInitialized: false
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(firebaseInitialized: false),
      ),
    );

    // Verify that the error message is displayed.
    expect(find.textContaining('Firebase could not be initialized'), findsOneWidget);
  });
}
