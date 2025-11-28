// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:safestep/main.dart';

void main() {
  testWidgets('App navigation works and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // The login screen title should be visible
    expect(find.text('SafeStep Analyzer'), findsOneWidget);

    // Tap Login button and navigate to dashboard
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify dashboard shows up
    expect(find.text('Live Sound Detection'), findsOneWidget);
  });
}
