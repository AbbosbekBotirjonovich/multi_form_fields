import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Login form smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our status starts as 'Idle'.
    expect(find.textContaining('Status: Idle'), findsOneWidget);

    // Enter text into the email field.
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.pump();

    // Verify that status changed to typing.
    expect(find.textContaining('Status: Typing in email...'), findsOneWidget);

    // Verify that the login button is present.
    expect(find.text('Login'), findsOneWidget);
  });
}
