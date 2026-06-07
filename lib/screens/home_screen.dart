// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../utils/app_colors.dart';

import 'schemes_screen.dart';
import 'practices_screen.dart';
import 'market_screen.dart';
import 'profile_screen.dart';
import 'expert_help_screen.dart';
import 'weather_widget.dart';

import 'package:agri_helper/screens/menubar.dart';
import '../widgets/recent_updates_widget.dart';
import '../widgets/main_scaffold.dart'; // wrapper that adds the drawer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Change tab safely
  void _onTabTapped(int index) {
    if (!mounted) return;
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// UNIVERSAL Drawer Navigation Handler
  void _onNavigate(MenuDestination dest) {
    if (!mounted) return;

    switch (dest) {
      case MenuDestination.home:
        _onTabTapped(0);
        break;
      case MenuDestination.schemes:
        _onTabTapped(1);
        break;
      case MenuDestination.practices:
        _onTabTapped(2);
        break;
      case MenuDestination.market:
        _onTabTapped(3);
        break;
      case MenuDestination.expertHelp:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ExpertHelpScreen()),
        );
        break;
      case MenuDestination.profile:
        _onTabTapped(4);
        break;
      case MenuDestination.logout:
      // Clear entire stack and go to Login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          _onTabTapped(0);
          return false;
        }
        return true;
      },

      child: Scaffold(
        // ⭐ RIGHT-SIDE Drawer ONLY
        endDrawer: AppMenuDrawer(onNavigate: _onNavigate),

        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) {
            if (!mounted) return;
            setState(() => _currentIndex = i);
          },

          children: [
            MainScaffold(
              onNavigate: _onNavigate,
              child: _buildHomeContent(),
            ),
            MainScaffold(
              onNavigate: _onNavigate,
              child: const SchemesScreen(),
            ),
            MainScaffold(
              onNavigate: _onNavigate,
              child: PracticesScreen(),
            ),
            MainScaffold(
              onNavigate: _onNavigate,
              child: MarketScreen(),
            ),
            MainScaffold(
              onNavigate: _onNavigate,
              child: const ProfileScreen(),
            ),
          ],
        ),

        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  // ================================
  // HOME TAB CONTENT
  // ================================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.agriculture, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'AgriHelper',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),

                  // ⭐ Hamburger icon that opens RIGHT-SIDE drawer
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.green),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ),

            // WELCOME + WEATHER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Farmer!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your smart farming companion',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const WeatherWidget(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // QUICK ACCESS TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // QUICK ACCESS GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickAccessCard(
                    'Government Schemes',
                    Icons.account_balance,
                    AppColors.primaryGreen,
                        () => _onTabTapped(1),
                  ),
                  _buildQuickAccessCard(
                    'Farming Practices',
                    Icons.agriculture,
                    AppColors.accentBlue,
                        () => _onTabTapped(2),
                  ),
                  _buildQuickAccessCard(
                    'Market Prices',
                    Icons.trending_up,
                    AppColors.accentOrange,
                        () => _onTabTapped(3),
                  ),
                  _buildQuickAccessCard(
                    'Expert Help',
                    Icons.support_agent,
                    AppColors.accentRed,
                    // reuse centralized handler so behavior is consistent
                        () => _onNavigate(MenuDestination.expertHelp),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // RECENT UPDATES
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 320,
                child: RecentUpdatesWidget(maxItems: 6),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===============================
  // QUICK ACCESS CARD GENERATOR
  // ===============================
  Widget _buildQuickAccessCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.85), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
