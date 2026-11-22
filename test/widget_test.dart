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

  testWidgets('HOD: review CLO grid and decide', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'hod@biit.edu.pk');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    // A paper is waiting for the CLO review
    expect(find.text('Review Paper'), findsOneWidget);
    await tester.tap(find.text('Review Paper').first);
    await settle(tester);
    expect(find.text('Review CLO Grid'), findsOneWidget);
    expect(find.text('CLO Summary'), findsOneWidget);
    expect(find.text('Final Exam • 30 Marks'), findsOneWidget);

    // Common topics and Detail tabs still work
    await tester.tap(find.text('Common Topics'));
    await settle(tester);
    expect(find.text('Syntax Analysis'), findsOneWidget);
    await tester.tap(find.text('CLO Grid'));
    await settle(tester);

    // Reject without a comment is not allowed
    await tester.tap(find.text('Reject'));
    await settle(tester);
    await tester.ensureVisible(find.text('Confirm Decision'));
    await tester.tap(find.text('Confirm Decision'));
    await settle(tester);
    expect(
      find.text('Please add a comment to reject the paper'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 6));

    // Approve
    await tester.tap(find.text('Approve'));
    await settle(tester);
    await tester.ensureVisible(find.text('Confirm Decision'));
    await tester.tap(find.text('Confirm Decision'));
    await settle(tester);
    expect(find.text('Review CLO Grid'), findsNothing);
    expect(find.text('Review Paper'), findsNothing);
  });

  testWidgets('Director: dashboard, papers and courses', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'director@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    // Dashboard
    expect(find.text('Welcome, Director'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('50/60'), findsOneWidget);
    expect(find.text('Compiler Construction'), findsOneWidget);
    await tester.tap(find.text('Not Submitted').last);
    await settle(tester);
    expect(find.text('Artificial Intelligence'), findsOneWidget);
    await tester.tap(find.text('Send reminder'));
    await settle(tester);
    expect(find.text('Reminder sent to Dr. Sadaf Gul'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));

    // Papers: current, then archive
    await tester.tap(find.text('Papers'));
    await settle(tester);
    expect(find.text('Current Papers'), findsOneWidget);
    await tester.tap(find.text('Archive'));
    await settle(tester);
    expect(find.text('Archived Papers'), findsOneWidget);
    expect(find.text('Programming Fundamentals'), findsOneWidget);
    await tester.tap(find.text('Rejected').first);
    await settle(tester);
    expect(find.text('Expository Writing'), findsOneWidget);
    expect(find.text('Programming Fundamentals'), findsNothing);

    // Courses: open a card
    await tester.tap(find.text('Courses'));
    await settle(tester);
    expect(find.text('4 courses shown'), findsOneWidget);
    await tester.tap(find.text('Show ').first);
    await settle(tester);
    expect(find.text('Mr. Amir Rasheed'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
    await tester.tap(find.text('SE Department'));
    await settle(tester);
    expect(find.text('1 courses shown'), findsOneWidget);
  });

  testWidgets('Director reviews a paper and approves it', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'director@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    // Open the paper from the To Review tab
    await tester.tap(find.text('Review Paper'));
    await settle(tester);
    expect(find.text('Paper Workspace'), findsOneWidget);
    expect(find.text('3 questions · 30/60 marks'), findsOneWidget);
    expect(find.text('Q1 • 10 Marks'), findsOneWidget);

    // Next question with the arrow
    await tester.tap(find.text('›'));
    await settle(tester);
    expect(find.text('Q2 • 12 Marks'), findsOneWidget);

    // Covered topics sheet and CLO grid
    await tester.tap(find.text('Check Covered Topics  & CLO Grid'));
    await settle(tester);
    expect(find.text('Regular Expressions'), findsOneWidget);
    await tester.tap(find.text('CLO Grid'));
    await settle(tester);
    expect(find.text('CLO Summary'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await settle(tester);

    // Edit Q1 and add a comment
    await tester.tap(find.text('‹'));
    await settle(tester);
    await tester.tap(find.text('Edit / Comment'));
    await settle(tester);
    expect(find.text('Edit Question'), findsOneWidget);
    await tester.tap(find.text('Comments'));
    await settle(tester);
    expect(
      find.text(
        'Noted. Please also add labels to all transitions for clarity.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).last, 'Please check marks');
    await tester.tap(find.text('Send'));
    await settle(tester);
    expect(find.text('Please check marks'), findsOneWidget);
    await tester.tap(find.text('Question'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.tap(find.text('Save Changes'));
    await settle(tester);
    expect(find.text('Q1 • 12 Marks'), findsOneWidget);
    expect(find.text('2 comments'), findsOneWidget);

    // Decision: reject needs a comment, approve works
    await tester.tap(find.text('Proceed to Decision'));
    await settle(tester);
    expect(find.text('Paper Decision'), findsOneWidget);
    await tester.tap(find.text('Reject'));
    await settle(tester);
    await tester.tap(find.text('Confirm Decision'));
    await settle(tester);
    expect(
      find.text('Please add a comment to reject the paper'),
      findsOneWidget,
    );
    await tester.tap(find.text('Approve'));
    await settle(tester);
    await tester.tap(find.text('Confirm Decision'));
    await settle(tester);

    // Back on the dashboard: the paper moved to Approved
    expect(find.text('Welcome, Director'), findsOneWidget);
    expect(find.text('Review Paper'), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    await tester.tap(find.text('Approved').last);
    await settle(tester);
    expect(find.text('Compiler Construction'), findsOneWidget);
  });

  testWidgets('Director: role handover start and end', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'director@biit.edu.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('Dr. Jameel Sawar'), findsOneWidget);
    await tester.tap(find.text('Role Handover'));
    await settle(tester);
    expect(find.text('No Active Handover'), findsOneWidget);
    expect(find.text('Dr. Naseer Ahmed'), findsOneWidget);

    // Open the sheet: confirming with an empty form shows an error
    await tester.tap(find.text('Role Handover').last);
    await settle(tester);
    await tester.tap(find.text('Confirm Handover'));
    await settle(tester);
    expect(find.text('Please select a faculty member'), findsOneWidget);

    // Fill the form
    await tester.tap(find.text('Select Faculty Member'));
    await settle(tester);
    await tester.tap(find.text('Dr. Munir').last);
    await settle(tester);
    await tester.tap(find.text('Select Start'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('Select End'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('Confirm Handover'));
    await settle(tester);

    expect(find.text('ACTIVE HANDOVER'), findsOneWidget);
    expect(find.text('Acting Director'), findsOneWidget);

    // End it: goes to the history
    await tester.tap(find.text('End Active Handover'));
    await settle(tester);
    await tester.tap(find.text('End'));
    await settle(tester);
    expect(find.text('No Active Handover'), findsOneWidget);
    expect(find.text('Dr. Munir'), findsOneWidget);
  });

  testWidgets('HOD: dashboard, assign paper and CLO rules', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'hod@biit.edu.pk');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await settle(tester);

    // Dashboard
    expect(find.text('HOD Dashboard'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('55'), findsOneWidget);
    expect(find.text('My Activities'), findsOneWidget);

    // Assign Paper: assigning without a date shows an error
    await tester.tap(find.text('Assign Paper'));
    await settle(tester);
    expect(find.text('7 Courses'), findsOneWidget);
    await tester.tap(find.text('Assign').first);
    await settle(tester);
    expect(find.text('Please select a date'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));

    // Pick a date and a teacher, then assign
    await tester.tap(find.text('-- Select Date --').first);
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('-- Select Teacher --').first);
    await settle(tester);
    await tester.tap(find.text('Nauman Iqbal').last);
    await settle(tester);
    await tester.tap(find.text('Assign').first);
    await settle(tester);
    expect(
      find.text('Data Structures assigned to Nauman Iqbal'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 6));

    // Semester filter
    await tester.tap(find.text('Semester 1'));
    await settle(tester);
    expect(find.text('2 Courses'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await settle(tester);

    // Papers tab is the shared papers list
    await tester.tap(find.text('Papers'));
    await settle(tester);
    expect(find.text('Current Papers'), findsOneWidget);

    // CLO Rule tab: choose CLOs for all courses
    await tester.tap(find.text('CLO Rule'));
    await settle(tester);
    expect(find.text('CLO Rules'), findsOneWidget);
    await tester.tap(find.text('-- Select CLO for all Subjects --'));
    await settle(tester);
    await tester.tap(find.text('CLO-1, CLO-2, CLO-3').last);
    await settle(tester);
    expect(find.text('CLO-1, CLO-2, CLO-3'), findsWidgets);
    expect(find.text('-- Select CLOs --'), findsNothing);
  });

  testWidgets('Faculty: dashboard, papers and course details', (tester) async {
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

    // Dashboard
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Papers to Set'), findsOneWidget);
    expect(find.text('Changes Required'), findsOneWidget);
    expect(find.text('Paper to set'), findsOneWidget);
    expect(find.text('Questions to add'), findsOneWidget);

    // Course details
    await tester.tap(find.text('Data Structures'));
    await settle(tester);
    expect(find.text('Course Details'), findsOneWidget);
    expect(find.text('2 of 3 teachers marked their topics.'), findsOneWidget);
    expect(find.text('Waiting for 1 teacher.'), findsOneWidget);
    await tester.tap(find.text('Common Topics'));
    await settle(tester);
    expect(find.text('Syntax Analysis'), findsOneWidget);
    await tester.tap(find.text('Details'));
    await settle(tester);
    expect(find.text('Lexical Analysis'), findsOneWidget);
    await tester.tap(find.text('Check Similarity'));
    await settle(tester);
    expect(find.text('Paper Similarity Report'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await settle(tester);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await settle(tester);

    // Papers tab: current, then archive
    await tester.tap(find.text('Papers'));
    await settle(tester);
    expect(find.text('Current Papers'), findsOneWidget);
    await tester.tap(find.text('Archive'));
    await settle(tester);
    expect(find.text('Past Papers'), findsOneWidget);
    expect(find.text('Programming Fundamentals'), findsOneWidget);
    await tester.tap(find.text('Rejected').first);
    await settle(tester);
    expect(find.text('Technical Writing'), findsOneWidget);
    expect(find.text('Programming Fundamentals'), findsNothing);
  });

  testWidgets('Faculty: mark covered topics and submit', (tester) async {
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

    // CS-303 has Dr. Saeed Iqbal pending, CS-301 has Mr. Afrasiab pending
    await tester.tap(find.text('Operating Systems'));
    await settle(tester);
    expect(find.text('1 of 2 teachers marked their topics.'), findsOneWidget);
    await tester.tap(find.text('Topics'));
    await settle(tester);

    expect(find.text('Covered Topics'), findsOneWidget);
    expect(find.text('Selected: 3 of 12 topics'), findsOneWidget);
    expect(find.text('While Loop'), findsOneWidget);

    // Select a topic
    await tester.tap(find.text('Sorting Algorithms'));
    await settle(tester);
    expect(find.text('Selected: 4 of 12 topics'), findsOneWidget);

    // Select all topics, then clear them
    await tester.tap(find.text('Select All Topics for Section A'));
    await settle(tester);
    expect(find.text('Selected: 12 of 12 topics'), findsOneWidget);
    await tester.tap(find.text('Select All Topics for Section A'));
    await settle(tester);
    expect(find.text('Selected: 0 of 12 topics'), findsOneWidget);

    // Nothing marked: submit is refused
    await tester.tap(find.text('Submit your marked topics'));
    await settle(tester);
    expect(find.text('Please mark at least one topic'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));

    // Search, then mark a topic and submit
    await tester.enterText(find.byType(TextField).first, 'Heaps');
    await settle(tester);
    expect(find.text('Sorting Algorithms'), findsNothing);
    await tester.tap(find.text('Heaps and Priority Queues'));
    await settle(tester);
    expect(find.text('Selected: 1 of 12 topics'), findsOneWidget);
    await tester.tap(find.text('Submit your marked topics'));
    await settle(tester);

    // Back on course details: both teachers have marked now? (Amir did)
    expect(find.text('Course Details'), findsOneWidget);
  });
}
