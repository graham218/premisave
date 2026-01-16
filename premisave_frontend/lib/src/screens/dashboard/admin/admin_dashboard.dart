import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/auth/user_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../public/about_content.dart';
import '../../public/contact_content.dart';
import 'contents/admin_dashboard_content.dart';
import 'contents/admin_user_management_content.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/dashboard/admin';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/dashboard/admin'},
    {'icon': Icons.people, 'label': 'Manage Users', 'route': '/admin/users'},
    {'icon': Icons.bar_chart, 'label': 'Analytics', 'route': '/admin/analytics'},
    {'icon': Icons.settings, 'label': 'Settings', 'route': '/admin/settings'},
    {'icon': Icons.report, 'label': 'Reports', 'route': '/admin/reports'},
    {'icon': Icons.notifications, 'label': 'Notifications', 'route': '/admin/notifications'},
    {'icon': Icons.history, 'label': 'Audit Log', 'route': '/admin/audit'},
    {'icon': Icons.contact_support, 'label': 'Contact Us', 'route': '/admin/contact'},
    {'icon': Icons.info, 'label': 'About Us', 'route': '/admin/about'},
  ];

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
      // Find the index in the visible tabs (first 4 items)
      final visibleTabs = _menuItems.take(4).toList();
      _selectedIndex = visibleTabs.indexWhere((item) => item['route'] == route);
      if (_selectedIndex == -1) {
        _selectedIndex = 0; // Default to first tab if not found in visible tabs
      }
      _isSidebarOpen = false;
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/admin/users':
        return const AdminUserManagementContent();
      case '/admin/contact':
        return const ContactContent();
      case '/admin/about':
        return const AboutContent();
      case '/dashboard/admin':
      default:
        return const AdminDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          _menuItems.firstWhere(
                (item) => item['route'] == _currentRoute,
            orElse: () => _menuItems.first,
          )['label'],
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: !isMobile
            ? IconButton(
          icon: Icon(
            _isSidebarOpen ? Icons.close : Icons.menu,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        )
            : null,
        actions: [
          // Profile Picture with dropdown menu
          _buildProfileDropdown(context, authState.currentUser),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87, size: 22),
            onPressed: () => authNotifier.confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 260 : 0),
            child: _getCurrentContent(),
          ),

          // Sidebar overlay for mobile
          if (isMobile && _isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Sidebar
          if (!isMobile)
            _buildDesktopSidebar(),
          if (isMobile)
            _buildMobileSidebar(),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: safeSelectedIndex,
          onTap: (index) {
            if (index == 4 && moreTabs.isNotEmpty) {
              _showMoreOptions(context, moreTabs);
            } else if (index < visibleTabs.length) {
              final route = visibleTabs[index]['route'];
              _navigateToRoute(route);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF5A5F), // Airbnb pink/red
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs
                .map(
                  (item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              ),
            )
                .toList(),
            if (moreTabs.isNotEmpty)
              const BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildProfileDropdown(BuildContext context, UserModel? currentUser) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          context.go('/profile');
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: ClipOval(
              child: _buildProfilePicture(currentUser),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(UserModel? currentUser) {
    if (currentUser?.profilePictureUrl != null && currentUser!.profilePictureUrl!.isNotEmpty) {
      // If user has a profile picture, display it
      return Image.network(
        currentUser.profilePictureUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(currentUser);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      // If no profile picture, show default avatar with initials
      return _buildDefaultAvatar(currentUser);
    }
  }

  Widget _buildDefaultAvatar(UserModel? currentUser) {
    String initials = 'U';
    Color bgColor = const Color(0xFFFF5A5F);

    if (currentUser?.firstName != null && currentUser?.lastName != null) {
      final firstChar = currentUser!.firstName!.isNotEmpty ? currentUser.firstName![0] : '';
      final lastChar = currentUser.lastName!.isNotEmpty ? currentUser.lastName![0] : '';
      initials = '$firstChar$lastChar'.toUpperCase();
    } else if (currentUser?.email != null) {
      initials = currentUser!.email![0].toUpperCase();
    }

    // Generate a consistent color based on user ID or initials
    if (currentUser?.id != null) {
      final colorIndex = currentUser!.id!.hashCode % 360;
      bgColor = HSLColor.fromAHSL(1.0, colorIndex.toDouble(), 0.7, 0.65).toColor();
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Material(
      elevation: 4,
      child: Container(
        width: 260,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: Color(0xFFEBEBEB), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(1, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87, size: 22),
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = false;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Menu items - takes all available space
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: _menuItems.map((item) {
                  final isSelected = _currentRoute == item['route'];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Color(0xFFFF5A5F).withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    child: ListTile(
                      leading: Icon(item['icon'],
                          color: isSelected ? Color(0xFFFF5A5F) : Colors.grey.shade700,
                          size: 22
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.circle, color: Color(0xFFFF5A5F), size: 8)
                          : Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 18),
                      onTap: () => _navigateToRoute(item['route']),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer with info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premisave Admin Panel',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0;
    final headerHeight = 120.0;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: items.map(
                        (item) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF5A5F).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: Color(0xFFFF5A5F)),
                      ),
                      title: Text(
                        item['label'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToRoute(item['route']);
                      },
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}