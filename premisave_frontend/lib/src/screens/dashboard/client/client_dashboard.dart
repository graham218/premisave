import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/auth/user_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../public/about_content.dart';
import '../../public/contact_content.dart';
import 'contents/client_dashboard_content.dart';
import 'contents/client_bookings_content.dart';
import 'contents/client_wishlists_content.dart';
import 'contents/client_payments_content.dart';
import 'contents/client_messages_content.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _selectedIndex = 0;
  String _currentRoute = '/dashboard/client';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.search, 'label': 'Explore', 'route': '/dashboard/client'},
    {'icon': Icons.calendar_month, 'label': 'Bookings', 'route': '/client/bookings'},
    {'icon': Icons.favorite_border, 'label': 'Wishlists', 'route': '/client/wishlists'},
    {'icon': Icons.payments, 'label': 'Payments', 'route': '/client/payments'},
    {'icon': Icons.message, 'label': 'Messages', 'route': '/client/messages'},
    {'icon': Icons.account_circle, 'label': 'Profile', 'route': '/profile'},
    {'icon': Icons.help_outline, 'label': 'Help', 'route': '/client/help'},
    {'icon': Icons.info_outline, 'label': 'About Us', 'route': '/client/about'},
    {'icon': Icons.contact_support, 'label': 'Contact', 'route': '/client/contact'},
  ];

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
      final index = _menuItems.indexWhere((item) => item['route'] == route);
      _selectedIndex = index >= 0 ? index : 0;
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/client/bookings':
        return const ClientBookingsContent();
      case '/client/wishlists':
        return const ClientWishlistsContent();
      case '/client/payments':
        return const ClientPaymentsContent();
      case '/client/messages':
        return const ClientMessagesContent();
      case '/client/contact':
        return const ContactContent();
      case '/client/about':
        return const AboutContent();
      case '/dashboard/client':
      default:
        return const ClientDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isMobile, context, authState.currentUser, authNotifier),
      body: _getCurrentContent(),
      bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
      bool isMobile,
      BuildContext context,
      UserModel? currentUser,
      AuthNotifier authNotifier,
      ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.white,
      leadingWidth: 180,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: GestureDetector(
          onTap: () => context.go('/dashboard/client'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premisave Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A699),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A699).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Circular',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Premisave',
                style: TextStyle(
                  color: Color(0xFF00A699),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Circular',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      title: !isMobile ? _buildDesktopNavigation() : null,
      actions: [
        if (!isMobile)
          _buildLanguageCurrencySelector(),
        _buildProfileMenu(context, currentUser, authNotifier),
      ],
    );
  }

  Widget _buildDesktopNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NavButton(
                icon: _menuItems[i]['icon'],
                label: _menuItems[i]['label'],
                isActive: _selectedIndex == i,
                onPressed: () => _navigateToRoute(_menuItems[i]['route']),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageCurrencySelector() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.language, size: 20, color: Colors.black87),
            SizedBox(width: 4),
            Text('EN | KES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'sw', child: Text('Swahili')),
        const PopupMenuItem(value: 'kes', child: Text('KES - Kenyan Shilling')),
        const PopupMenuItem(value: 'usd', child: Text('USD - US Dollar')),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, UserModel? currentUser, AuthNotifier authNotifier) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF00A699),
                child: Text(
                  currentUser?.firstName?.substring(0, 1) ?? 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentUser?.firstName ?? 'User'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'account', child: ListTile(leading: Icon(Icons.settings), title: Text('Account settings'))),
        const PopupMenuItem(value: 'help', child: ListTile(leading: Icon(Icons.help), title: Text('Help Center'))),
        const PopupMenuItem(value: 'about', child: ListTile(leading: Icon(Icons.info), title: Text('About Premisave'))),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () => authNotifier.confirmLogout(context),
          ),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(Icons.menu, color: Colors.grey[700]),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00A699),
              child: Text(
                currentUser?.firstName?.substring(0, 1) ?? 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex.clamp(0, 3),
      onTap: (index) {
        if (index < 4) {
          _navigateToRoute(_menuItems[index]['route']);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF00A699),
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? const Color(0xFF00A699) : Colors.black87,
        backgroundColor: isActive ? Colors.white : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}