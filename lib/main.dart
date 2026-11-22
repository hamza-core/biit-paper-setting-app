import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/design_tokens.dart';
import 'features/auth/domain/user_model.dart';
import 'features/auth/presentation/login_screen.dart';

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
  String? name;

  void onLoggedIn(UserModel user) {
    setState(() {
      token = user.token;
      role = user.role;
      name = user.name;
    });
  }

  void onLoggedOut() {
    setState(() {
      token = null;
      role = null;
      name = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (token == null) {
      home = LoginScreen(onLoggedIn: onLoggedIn);
    } else {
      // Temporary screen. Each role gets its own home in its own feature.
      home = Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome $name',
                style: const TextStyle(fontSize: AppFontSize.subtitle),
              ),
              Text('Role: $role'),
              TextButton(onPressed: onLoggedOut, child: const Text('Log out')),
            ],
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'BIIT Paper Setting',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    );
  }
}
