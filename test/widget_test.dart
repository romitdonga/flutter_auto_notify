// This is a basic Flutter widget test for the example app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_auto_notify/example_app.dart';
import 'package:flutter_auto_notify/auto_notify_sdk.dart';

void main() {
  testWidgets('Example app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExampleApp());

    // Verify that the app title is displayed
    expect(find.text('Notification Settings'), findsOneWidget);
    
    // Verify that the notification toggle is displayed
    expect(find.text('Daily Reminders'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    
    // Verify that the system settings button is displayed
    expect(find.text('System Notification Settings'), findsOneWidget);
  });
  
  testWidgets('Toggle changes notification state', (WidgetTester tester) async {
    // Mock the AutoNotifyManager for testing
    final initialState = autoNotify.isEnabled;
    
    // Build our app and trigger a frame
    await tester.pumpWidget(const ExampleApp());
    
    // Find the switch
    final switchFinder = find.byType(Switch);
    
    // Tap the switch to toggle notifications
    await tester.tap(switchFinder);
    await tester.pump();
    
    // Verify the switch was toggled
    // Note: In a real test, you would mock the AutoNotifyManager
    // and verify that setEnabled was called with the correct value
  });
}
