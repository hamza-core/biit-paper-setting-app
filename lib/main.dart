import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/auth/domain/user_model.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/shell/presentation/main_shell.dart';

void main() {
  runApp(const MyApp());
}

// Session state (the logged in user and their role) lives here and is
// passed down to the screens through constructors.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserModel? user;

  void onLoggedIn(UserModel loggedInUser) {
    setState(() {
      user = loggedInUser;
    });
  }

  void onLoggedOut() {
    setState(() {
      user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (user == null) {
      home = LoginScreen(onLoggedIn: onLoggedIn);
    } else {
      home = MainShell(user: user!, onLogout: onLoggedOut);
    }

    return MaterialApp(
      title: 'BIIT Paper Setting',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    );
  }
}
