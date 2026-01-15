import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../providers/auth/auth_provider.dart';

class AdminDashboardContent extends ConsumerStatefulWidget {
  const AdminDashboardContent({super.key});

  @override
  ConsumerState<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends ConsumerState<AdminDashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(authState.currentUser),
                  const SizedBox(height: 24),
                  _buildQuickStatsSection(),
                  const SizedBox(height: 24),
                  _buildActionSection(),
                  const SizedBox(height: 24),
                  _buildSystemHealthSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066CC), Color(0xFF004799), Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004799).withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.firstName ?? 'Admin'} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome to Premisave Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black26,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatusChip('System Active', Icons.check_circle, Colors.green),
              _buildStatusChip('Users Online', Icons.people, Colors.lightBlue),
              _buildStatusChip('All Services Up', Icons.verified, Colors.green),
              _buildStatusChip('Last Backup: Today', Icons.backup, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004799),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
            final childAspectRatio = isSmallScreen ? 1.3 : (isMediumScreen ? 1.5 : 1.2);
            final mainAxisSpacing = isSmallScreen ? 12.0 : 16.0;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
              children: [
                _buildResponsiveInfoCard(
                  Icons.people,
                  'Total Users',
                  '1,254',
                  Colors.blue,
                  constraints.maxWidth,
                ),
                _buildResponsiveInfoCard(
                  Icons.home,
                  'Properties',
                  '842',
                  Colors.teal,
                  constraints.maxWidth,
                ),
                _buildResponsiveInfoCard(
                  Icons.attach_money,
                  'Revenue Today',
                  'KES 45,820',
                  Colors.green,
                  constraints.maxWidth,
                ),
                _buildResponsiveInfoCard(
                  Icons.receipt,
                  'Pending Transactions',
                  '24',
                  Colors.orange,
                  constraints.maxWidth,
                ),
                if (crossAxisCount > 3) ...[
                  _buildResponsiveInfoCard(
                    Icons.support_agent,
                    'Support Tickets',
                    '12',
                    Colors.purple,
                    constraints.maxWidth,
                  ),
                  _buildResponsiveInfoCard(
                    Icons.trending_up,
                    'Growth Rate',
                    '+15% this month',
                    Colors.green,
                    constraints.maxWidth,
                  ),
                ] else if (crossAxisCount == 3) ...[
                  _buildResponsiveInfoCard(
                    Icons.support_agent,
                    'Support Tickets',
                    '12',
                    Colors.purple,
                    constraints.maxWidth,
                  ),
                  _buildResponsiveInfoCard(
                    Icons.trending_up,
                    'Growth Rate',
                    '+15% this month',
                    Colors.green,
                    constraints.maxWidth,
                  ),
                ] else ...[
                  _buildResponsiveInfoCard(
                    Icons.support_agent,
                    'Support Tickets',
                    '12',
                    Colors.purple,
                    constraints.maxWidth,
                  ),
                ]
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveInfoCard(IconData icon, String title, String value, Color color, double screenWidth) {
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 16.0 : 18.0;
    final titleSize = isSmallScreen ? 11.0 : 13.0;
    final valueSize = isSmallScreen ? 12.0 : 14.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double val, child) {
          return Transform.scale(
            scale: 1 + (val * 0.05),
            child: child,
          );
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: color.withOpacity(0.3),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 80 : 100,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: color, size: iconSize),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 10),
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004799),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
            final childAspectRatio = isSmallScreen ? 1.1 : (isMediumScreen ? 1.3 : 1.1);

            return Container(
              constraints: BoxConstraints(
                maxHeight: isSmallScreen ? 200 : (isMediumScreen ? 180 : 160),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildResponsiveActionCard(
                    'Manage Users',
                    Icons.people,
                    Colors.blue,
                        () {}, // Empty for now
                    constraints.maxWidth,
                  ),
                  _buildResponsiveActionCard(
                    'View Reports',
                    Icons.assessment,
                    Colors.green,
                        () {}, // Empty for now
                    constraints.maxWidth,
                  ),
                  _buildResponsiveActionCard(
                    'System Settings',
                    Icons.settings,
                    Colors.purple,
                        () {}, // Empty for now
                    constraints.maxWidth,
                  ),
                  _buildResponsiveActionCard(
                    'View Analytics',
                    Icons.analytics,
                    Colors.orange,
                        () {}, // Empty for now
                    constraints.maxWidth,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveActionCard(String text, IconData icon, Color color, VoidCallback onTap, double screenWidth) {
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final textSize = isSmallScreen ? 11.0 : 13.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double val, child) {
          return Transform.translate(
            offset: Offset(0, (1 - val) * 20),
            child: Opacity(
              opacity: val,
              child: child,
            ),
          );
        },
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: color.withOpacity(0.4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: color.withOpacity(0.1),
            splashColor: color.withOpacity(0.2),
            child: Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 80 : 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: iconSize),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 12),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Health',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004799),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHealthIndicator('Database', 95, Colors.green),
                  const SizedBox(height: 12),
                  _buildHealthIndicator('API Services', 88, Colors.blue),
                  const SizedBox(height: 12),
                  _buildHealthIndicator('Payment Gateway', 92, Colors.green),
                  const SizedBox(height: 12),
                  _buildHealthIndicator('Email Service', 75, Colors.orange),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthIndicator(String service, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              service,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    final activities = [
      {
        'type': 'user',
        'title': 'New User Registered',
        'description': 'John Doe registered a new account',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
      {
        'type': 'payment',
        'title': 'Payment Processed',
        'description': 'KES 15,000 payment for property #123',
        'time': '3 hours ago',
        'icon': Icons.payment,
        'color': Colors.green,
      },
      {
        'type': 'system',
        'title': 'System Backup Completed',
        'description': 'Daily backup executed successfully',
        'time': '5 hours ago',
        'icon': Icons.backup,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004799),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 600 + (index * 200)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double val, child) {
                      return Opacity(
                        opacity: val,
                        child: Transform.translate(
                          offset: Offset((1 - val) * 20, 0),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAnimatedActivityItem(activity),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedActivityItem(Map<String, dynamic> activity) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                activity['color'].withOpacity(0.2),
                activity['color'].withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: activity['color'].withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(activity['icon'], color: activity['color'], size: 20),
        ),
        title: Text(
          activity['title'],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          activity['description'],
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Text(
          activity['time'],
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}