import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_lock/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Setup refreshes status without any lock request', (
    tester,
  ) async {
    final calls = <String>[];
    var ready = false;
    const channel = MethodChannel('one_tap_lock/setup');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return call.method == 'isReady' ? ready : null;
    });
    await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Enable Accessibility to get started'), findsOneWidget);
    ready = true;
    await tester.ensureVisible(find.text('Refresh status'));
    await tester.tap(find.text('Refresh status'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to lock'), findsOneWidget);
    expect(calls, ['isReady', 'isReady']);
  });
}
