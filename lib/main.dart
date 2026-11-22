import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/design_tokens.dart';

void main() {
  runApp(const MyApp());
}

// Session state (token and role) lives here and is passed down
// to the screens through constructors.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  String? role;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIIT Paper Setting',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        body: Center(
          child: Text(
            'BIIT Paper Setting',
            style: TextStyle(
              fontSize: AppFontSize.title,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
