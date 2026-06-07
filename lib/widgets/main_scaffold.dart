// lib/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:agri_helper/screens/menubar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final MenuNavigateCallback? onNavigate;

  const MainScaffold({
    super.key,
    required this.child,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use endDrawer so the menu opens from the RIGHT side.
      endDrawer: AppMenuDrawer(onNavigate: onNavigate),

      // Keep the passed child as the body. The child's menu button should call
      // Scaffold.of(context).openEndDrawer() to open this right-side drawer.
      body: child,
    );
  }
}
