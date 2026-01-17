import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/auth/user_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../public/about_content.dart';
import '../../public/contact_content.dart';
import 'contents/client_dashboard_content.dart';
import 'contents/client_explore_content.dart';
import 'contents/client_bookings_content.dart';
import 'contents/client_wishlists_content.dart';
import 'contents/client_payments_content.dart';
import 'contents/client_messages_content.dart';
import 'contents/client_transactions_content.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _selectedIndex = 0;
  String _currentRoute = '/client/explore';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.search, 'label': 'Explore', 'route': '/client/explore'},
    {'icon': Icons.home, 'label': 'Home', 'route': '/dashboard/client'},
    {'icon': Icons.calendar_month, 'label': 'Bookings', 'route': '/client/bookings'},
    {'icon': Icons.favorite_border, 'label': 'Wishlists', 'route': '/client/wishlists'},
    {'icon': Icons.payments, 'label': 'Payments', 'route': '/client/payments'},
    {'icon': Icons.receipt_long, 'label': 'Transactions', 'route': '/client/transactions'},
    {'icon': Icons.message, 'label': 'Messages', 'route': '/client/messages'},
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
      case '/client/transactions':
        return const ClientTransactionsContent();
      case '/client/messages':
        return const ClientMessagesContent();
      case '/client/about':
        return const AboutContent();
      case '/client/contact':
        return const ContactContent();
      case '/dashboard/client':
        return const ClientDashboardContent();
      case '/client/explore':
      default:
        return const ClientExploreContent();
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
      leadingWidth: isMobile ? 180 : null,
      leading: isMobile ? _buildLogo() : null,
      centerTitle: !isMobile,
      title: !isMobile ? _buildDesktopNavigation() : null,
      actions: [
        if (!isMobile) _buildLogo(),
        if (!isMobile)
          _buildLanguageCurrencySelector(),
        _buildProfileMenu(context, currentUser, authNotifier),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: GestureDetector(
        onTap: () => _navigateToRoute('/dashboard/client'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }

  Widget _buildDesktopNavigation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxVisibleItems = screenWidth < 1200 ? 5 : _menuItems.length;
    final visibleItems = _menuItems.take(maxVisibleItems).toList();
    final hasMoreItems = _menuItems.length > maxVisibleItems;

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
          for (int i = 0; i < visibleItems.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NavButton(
                icon: visibleItems[i]['icon'],
                label: visibleItems[i]['label'],
                isActive: _selectedIndex == i,
                onPressed: () => _navigateToRoute(visibleItems[i]['route']),
              ),
            ),
          if (hasMoreItems)
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              itemBuilder: (context) {
                final hiddenItems = _menuItems.sublist(maxVisibleItems);
                return hiddenItems.map<PopupMenuEntry<String>>((item) {
                  final index = _menuItems.indexOf(item);
                  return PopupMenuItem<String>(
                    value: item['route'],
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 20),
                        const SizedBox(width: 12),
                        Text(item['label']),
                      ],
                    ),
                    onTap: () => _navigateToRoute(item['route']),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.more_horiz, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'More',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
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
        const PopupMenuItem<String>(value: 'en', child: Text('English')),
        const PopupMenuItem<String>(value: 'sw', child: Text('Swahili')),
        const PopupMenuItem<String>(value: 'kes', child: Text('KES - Kenyan Shilling')),
        const PopupMenuItem<String>(value: 'usd', child: Text('USD - US Dollar')),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, UserModel? currentUser, AuthNotifier authNotifier) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      onSelected: (value) {
        if (value == 'profile') {
          context.push('/profile');
        } else if (value == 'account') {
          context.push('/client/account');
        } else if (value == 'help') {
          context.push('/client/help');
        } else if (value == 'about') {
          _navigateToRoute('/client/about');
        } else if (value == 'contact') {
          _navigateToRoute('/client/contact');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              if (currentUser?.profilePictureUrl?.isNotEmpty ?? false)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00A699).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      currentUser!.profilePictureUrl!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: const Color(0xFF00A699),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF00A699),
                          child: Text(
                            currentUser.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF00A699),
                  child: Text(
                    currentUser?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
        const PopupMenuItem<String>(
          value: 'account',
          child: ListTile(leading: Icon(Icons.settings), title: Text('Account settings')),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: ListTile(leading: Icon(Icons.help), title: Text('Help Center')),
        ),
        const PopupMenuItem<String>(
          value: 'about',
          child: ListTile(leading: Icon(Icons.info), title: Text('About Premisave')),
        ),
        const PopupMenuItem<String>(
          value: 'contact',
          child: ListTile(leading: Icon(Icons.contact_support), title: Text('Contact Us')),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
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
            const Icon(Icons.menu, color: Colors.grey),
            const SizedBox(width: 8),
            if (currentUser?.profilePictureUrl?.isNotEmpty ?? false)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00A699).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    currentUser!.profilePictureUrl!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: const Color(0xFF00A699),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF00A699),
                        child: Text(
                          currentUser.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF00A699),
                child: Text(
                  currentUser?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxVisibleItems = screenWidth < 400 ? 4 : 5;
    final visibleItems = _menuItems.take(maxVisibleItems).toList();
    final hasMoreItems = _menuItems.length > maxVisibleItems;

    return BottomNavigationBar(
      currentIndex: _selectedIndex.clamp(0, maxVisibleItems - 1),
      onTap: (index) {
        if (index < visibleItems.length) {
          _navigateToRoute(visibleItems[index]['route']);
        } else if (hasMoreItems && index == visibleItems.length) {
          _showMoreMenu(context);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF00A699),
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        for (int i = 0; i < visibleItems.length; i++)
          BottomNavigationBarItem(
            icon: Icon(visibleItems[i]['icon']),
            label: visibleItems[i]['label'],
          ),
        if (hasMoreItems)
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxVisibleItems = screenWidth < 400 ? 4 : 5;
    final hiddenItems = _menuItems.sublist(maxVisibleItems);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              ...hiddenItems.map((item) {
                final index = _menuItems.indexOf(item);
                return ListTile(
                  leading: Icon(item['icon'], color: Colors.grey[700]),
                  title: Text(item['label']),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToRoute(item['route']);
                  },
                  tileColor: _selectedIndex == index ? const Color(0xFF00A699).withOpacity(0.1) : null,
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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