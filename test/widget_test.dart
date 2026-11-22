import 'package:flutter_test/flutter_test.dart';
import 'package:biit_paper_setting/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('BIIT Paper Setting'), findsOneWidget);
  });
}
