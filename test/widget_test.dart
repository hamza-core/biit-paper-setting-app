import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biit_paper_setting/main.dart';

void main() {
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
    await tester.pump(const Duration(seconds: 1));

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
    await tester.pump(const Duration(seconds: 1));

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
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Mr. Amir Rasheed'), findsOneWidget);
    expect(find.text('Notifications & Reminders'), findsOneWidget);

    // Edit profile and save a new name
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Amir R');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Amir R'), findsOneWidget);

    // Notifications
    await tester.tap(find.text('Notifications & Reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Assigned Paper'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    // Sign out
    await tester.tap(find.text('Sign Out from Portal'));
    await tester.pumpAndSettle();
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
