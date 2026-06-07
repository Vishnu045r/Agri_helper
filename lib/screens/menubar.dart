// lib/screens/menubar.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart'; // relative import to your login screen

/// MENU OPTIONS (ensure this enum contains every value referenced by screens)
enum MenuDestination {
  home,
  profile,
  practices,
  schemes,
  market,      // <-- IMPORTANT: included
  expertHelp,
  logout,
}

typedef MenuNavigateCallback = void Function(MenuDestination dest);

class AppMenuDrawer extends StatefulWidget {
  final MenuNavigateCallback? onNavigate;
  const AppMenuDrawer({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends State<AppMenuDrawer> {
  String _name = "Welcome";
  String _email = "user@example.com";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? '';
    final savedEmail = prefs.getString('email') ?? '';

    setState(() {
      _name = savedName.trim().isNotEmpty ? savedName : "Welcome";
      _email = savedEmail.trim().isNotEmpty ? savedEmail : "user@example.com";
    });
  }

  Widget _buildTile(
      BuildContext context, IconData icon, String title, MenuDestination dest,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.green),
      title: Text(title,
          style: TextStyle(
              color: isLogout ? Colors.red : null,
              fontWeight: isLogout ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        Navigator.of(context).pop(); // close drawer first

        if (dest == MenuDestination.logout) {
          _performLogout(context);
          return;
        }

        // Delegate navigation to callback if provided
        widget.onNavigate?.call(dest);
      },
    );
  }

  // Use same logic as ProfileScreen logout so it works from nested scaffolds
  void _performLogout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 32)),
                  const SizedBox(height: 12),
                  Text(_name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // Menu items
            _buildTile(context, Icons.home, 'Home', MenuDestination.home),
            _buildTile(context, Icons.account_balance, 'Schemes', MenuDestination.schemes),
            _buildTile(context, Icons.agriculture, 'Practices', MenuDestination.practices),
            _buildTile(context, Icons.trending_up, 'Market Prices', MenuDestination.market),
            _buildTile(context, Icons.support_agent, 'Expert Help', MenuDestination.expertHelp),
            _buildTile(context, Icons.person, 'Profile', MenuDestination.profile),

            const Spacer(),
            const Divider(),

            _buildTile(context, Icons.logout, 'Logout', MenuDestination.logout, isLogout: true),
          ],
        ),
      ),
    );
  }
}
