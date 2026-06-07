// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'package:agri_helper/screens/menubar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _villageController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _landController;
  late TextEditingController _schemesController;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _villageController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _landController = TextEditingController();
    _schemesController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _villageController.text = prefs.getString('village') ?? '';
      _cityController.text = prefs.getString('city') ?? '';
      _stateController.text = prefs.getString('state') ?? '';
      _landController.text = prefs.getString('land') ?? '';
      _schemesController.text = prefs.getString('schemes') ?? '';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('phone', _phoneController.text.trim());
    await prefs.setString('village', _villageController.text.trim());
    await prefs.setString('city', _cityController.text.trim());
    await prefs.setString('state', _stateController.text.trim());
    await prefs.setString('land', _landController.text.trim());
    await prefs.setString('schemes', _schemesController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _confirmLogout() async {
    final doLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (doLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _landController.dispose();
    _schemesController.dispose();
    super.dispose();
  }

  void _handleMenuNavigate(MenuDestination dest) {
    Navigator.pop(context); // ensure drawer is closed
    switch (dest) {
      case MenuDestination.home:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case MenuDestination.schemes:
        Navigator.pushNamed(context, '/schemes');
        break;
      case MenuDestination.practices:
        Navigator.pushNamed(context, '/practices');
        break;
      case MenuDestination.market:
        Navigator.pushNamed(context, '/market');
        break;
      case MenuDestination.expertHelp:
        Navigator.pushNamed(context, '/expert_help');
        break;
      case MenuDestination.profile:
      // already here
        break;
      case MenuDestination.logout:
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryGreen;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ⭐ RIGHT-SIDE MENU DRAWER
      endDrawer: AppMenuDrawer(onNavigate: _handleMenuNavigate),

      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primary,
        foregroundColor: Colors.white,

        // ⭐ BACK ARROW (pops when this screen was pushed)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),

        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.secondaryGreen,
                child: const Icon(Icons.person, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone', Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_villageController, 'Village', Icons.home),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_stateController, 'State', Icons.map)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_landController, 'Land (in acres)', Icons.terrain, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_schemesController, 'Schemes Applied', Icons.list),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.accentBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter $label' : null,
    );
  }
}
