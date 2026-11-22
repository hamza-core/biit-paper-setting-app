import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biit_paper_setting/main.dart';

void main() {
  testWidgets('Login works for a datacell user', (WidgetTester tester) async {
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

    expect(find.text('Role: datacell'), findsOneWidget);
  });

  testWidgets('Wrong password shows an error', (WidgetTester tester) async {
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
}
