import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
// If you have a separate sign-up screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeStep Analyzer',
      theme: ThemeData(
        fontFamily: 'Roboto', // Optional: use a clean font
        primarySwatch: Colors.deepPurple, // Matches your UI theme
      ),
      
      // 👇 Start app from Login Page
      initialRoute: '/login',

      // 👇 Routes according to frontend UI
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        // For Signup navigation
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
