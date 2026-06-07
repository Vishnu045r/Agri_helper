// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/practices_screen.dart';
import 'screens/market_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/expert_help_screen.dart';

void main() {
  runApp(const AgriHelperApp());
}

class AgriHelperApp extends StatelessWidget {
  const AgriHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriHelper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        brightness: Brightness.light,
      ),

      // Start at login
      initialRoute: '/login',

      // Named routes (avoid using `const` unless the screen constructor is actually const)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/schemes': (context) => SchemesScreen(),
        '/practices': (context) => PracticesScreen(),
        '/market': (context) => MarketScreen(),
        '/profile': (context) => ProfileScreen(),
        '/expert_help': (context) => ExpertHelpScreen(),
      },

      // Optional fallback if a route isn't found:
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
