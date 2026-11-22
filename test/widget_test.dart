import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biit_paper_setting/main.dart';

void main() {
  // Tests use a square font by default. Load the real Inter font so the
  // text sizes are the same as on a phone.
  setUpAll(() async {
    FontLoader loader = FontLoader('Inter');
    ByteData bytes = ByteData.sublistView(
      File('assets/fonts/Inter.ttf').readAsBytesSync(),
    );
    loader.addFont(Future.value(bytes));
    await loader.load();
  });

  // Waits for the fake loading delays of the repositories.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  // Use the phone size from the Figma design (420 x 912).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 912);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Login works for a datacell user', (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    expect(find.text('WELCOME BACK'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'datacell@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    expect(find.text('Papers'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
  });

  testWidgets('Wrong password shows an error', (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'datacell@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('Profile tab shows profile, edit and logout', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'faculty@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    await settle(tester);
    expect(find.text('Mr. Amir Rasheed'), findsOneWidget);
    expect(find.text('Notifications & Reminders'), findsOneWidget);

    // Edit profile and save a new name
    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Amir R');
    await tester.tap(find.text('Save Changes'));
    await settle(tester);
    expect(find.text('Amir R'), findsOneWidget);

    // Notifications
    await tester.tap(find.text('Notifications & Reminders'));
    await settle(tester);
    expect(find.text('Assigned Paper'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await settle(tester);

    // Sign out
    await tester.tap(find.text('Sign Out from Portal'));
    await settle(tester);
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });

  testWidgets('Datacell: dashboard, papers and import flow', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'datacell@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);
    await settle(tester);

    // Dashboard numbers
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    // Papers tab: filter and submit
    await tester.tap(find.text('Papers'));
    await settle(tester);
    expect(find.text('Compiler Construction'), findsOneWidget);
    await tester.tap(find.text('Not Submitted').first);
    await settle(tester);
    expect(find.text('Compiler Construction'), findsNothing);
    await tester.tap(find.text('Submit'));
    await settle(tester);
    expect(find.text('No papers found'), findsOneWidget);

    // Import flow (wait until the snack bar is gone)
    await tester.pump(const Duration(seconds: 6));
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('7'), findsNothing);
    expect(find.text('19'), findsOneWidget); // 18 + 1 submitted
    await tester.tap(find.text('Import Excel'));
    await settle(tester);
    expect(find.text('Import Academic Data'), findsOneWidget);
    await tester.tap(find.text('Upload Bulk Data\nor\nDate Sheet\n (.xlsx)'));
    await settle(tester);
    expect(find.text('data-file.xlsx'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('Preview Imported Data'), findsOneWidget);
    expect(find.text('Teachers 3'), findsOneWidget);
    await tester.tap(find.text('Confirm Import'));
    await settle(tester);
    expect(find.text('Import Successful!'), findsOneWidget);
    await tester.tap(find.text('Back to Dashboard'));
    await settle(tester);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
