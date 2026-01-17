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
    {
      'icon': Icons.calendar_month,
      'label': 'Bookings',
      'route': '/client/bookings'
    },
    {
      'icon': Icons.favorite_border,
      'label': 'Wishlists',
      'route': '/client/wishlists'
    },
    {'icon': Icons.payments, 'label': 'Payments', 'route': '/client/payments'},
    {
      'icon': Icons.receipt_long,
      'label': 'Transactions',
      'route': '/client/transactions'
    },
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
      appBar:
      _buildAppBar(isMobile, context, authState.currentUser, authNotifier),
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
      leadingWidth: isMobile ? 140 : 180,
      leading: _buildLogo(),
      centerTitle: !isMobile,
      title: !isMobile ? _buildDesktopNavigation() : null,
      actions: [
        // Add spacing to prevent overlap
        if (!isMobile) const SizedBox(width: 8),
        _buildProfileMenu(context, currentUser, authNotifier, isMobile),
        if (!isMobile) const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: () => _navigateToRoute('/dashboard/client'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00A699),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A699).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Circular',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Premisave',
              style: TextStyle(
                color: Color(0xFF00A699),
                fontSize: 18,
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
    // Reduce to 4 visible items on larger screens
    final maxVisibleItems = 3;
    final visibleItems = _menuItems.take(maxVisibleItems).toList();
    final hiddenItems = _menuItems.sublist(maxVisibleItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _NavButton(
                icon: visibleItems[i]['icon'],
                label: visibleItems[i]['label'],
                isActive: _selectedIndex == i,
                onPressed: () => _navigateToRoute(visibleItems[i]['route']),
              ),
            ),
          // Always show "More" button since we have hidden items
          if (hiddenItems.isNotEmpty)
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              constraints: BoxConstraints(
                maxWidth: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              itemBuilder: (context) {
                return hiddenItems.map<PopupMenuEntry<String>>((item) {
                  final index = _menuItems.indexOf(item);
                  return PopupMenuItem<String>(
                    value: item['route'],
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 12),
                        Text(
                          item['label'],
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: _selectedIndex == index
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToRoute(item['route']),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: _selectedIndex >= maxVisibleItems
                      ? Colors.white
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: _selectedIndex >= maxVisibleItems
                          ? const Color(0xFF00A699)
                          : Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'More',
                      style: TextStyle(
                        fontWeight: _selectedIndex >= maxVisibleItems
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                        color: _selectedIndex >= maxVisibleItems
                            ? const Color(0xFF00A699)
                            : Colors.grey[700],
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

  Widget _buildProfileMenu(
      BuildContext context,
      UserModel? currentUser,
      AuthNotifier authNotifier,
      bool isMobile,
      ) {
    return Container(
      margin: isMobile
          ? const EdgeInsets.only(right: 12)
          : const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        position: PopupMenuPosition.under,
        constraints: BoxConstraints(
          maxWidth: isMobile
              ? MediaQuery.of(context).size.width * 0.9
              : 350,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        onSelected: (value) {
          if (value == 'profile') {
            context.push('/profile');
          } else if (value == 'about') {
            _navigateToRoute('/client/about');
          } else if (value == 'contact') {
            _navigateToRoute('/client/contact');
          } else if (value == 'language') {
            _showLanguageCurrencyDialog(context);
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
                              currentUser.firstName
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                                  'U',
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
                      currentUser?.firstName?.substring(0, 1).toUpperCase() ??
                          'U',
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
          PopupMenuItem<String>(
            value: 'language',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language, size: 20, color: Colors.black87),
              ),
              title: const Text('Language & Currency'),
              subtitle: const Text('EN | KES'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'about',
            child: ListTile(
                leading: Icon(Icons.info), title: Text('About Premisave')),
          ),
          const PopupMenuItem<String>(
            value: 'contact',
            child: ListTile(
                leading: Icon(Icons.contact_support), title: Text('Contact Us')),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu, color: Colors.grey, size: 20),
              const SizedBox(width: 6),
              if (currentUser?.profilePictureUrl?.isNotEmpty ?? false)
                Container(
                  width: 28,
                  height: 28,
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
                      width: 28,
                      height: 28,
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
                          radius: 14,
                          backgroundColor: const Color(0xFF00A699),
                          child: Text(
                            currentUser.firstName
                                ?.substring(0, 1)
                                .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF00A699),
                  child: Text(
                    currentUser?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Language & Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildLanguageOption('English', 'EN', true),
                _buildLanguageOption('Swahili', 'SW', false),
                const SizedBox(height: 16),
                const Text(
                  'Currency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildCurrencyOption('KES - Kenyan Shilling', true),
                _buildCurrencyOption('USD - US Dollar', false),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A699),
              ),
              child: const Text('Apply Changes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String code, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00A699).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF00A699) : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        leading: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF00A699))
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        title: Text(language),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        onTap: () {
          // Handle language selection
        },
      ),
    );
  }

  Widget _buildCurrencyOption(String currency, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00A699).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF00A699) : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        leading: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF00A699))
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        title: Text(currency),
        onTap: () {
          // Handle currency selection
        },
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
                  tileColor: _selectedIndex == index
                      ? const Color(0xFF00A699).withOpacity(0.1)
                      : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}