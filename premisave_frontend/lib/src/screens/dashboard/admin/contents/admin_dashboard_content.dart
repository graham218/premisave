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
                  _WelcomeCard(user: authState.currentUser),
                  const SizedBox(height: 24),
                  _DashboardGrid(),
                  const SizedBox(height: 24),
                  _QuickActionsGrid(),
                  const SizedBox(height: 24),
                  _SystemHealthSection(),
                  const SizedBox(height: 24),
                  _RecentActivitySection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final UserModel? user;
  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2B4C).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8EBF0),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(28),
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
                      'Welcome back,',
                      style: TextStyle(
                        color: const Color(0xFF2C3E50).withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.firstName ?? 'Admin',
                      style: const TextStyle(
                        color: Color(0xFF1A2B4C),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatusChip(
                'System Active',
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
              ),
              _buildStatusChip(
                'Users Online',
                Icons.people_alt_rounded,
                const Color(0xFF6366F1),
              ),
              _buildStatusChip(
                'Services Running',
                Icons.verified_rounded,
                const Color(0xFF1A2B4C),
              ),
              _buildStatusChip(
                'Last Backup',
                Icons.backup_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2B4C).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('System Overview'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
            final childAspectRatio = isSmallScreen ? 1.3 : (isMediumScreen ? 1.5 : 1.2);
            final mainAxisSpacing = isSmallScreen ? 12.0 : 16.0;

            final stats = [
              _StatInfo('Total Users', '1,254', Icons.people, const Color(0xFF6366F1)),
              _StatInfo('Properties', '842', Icons.home, const Color(0xFF10B981)),
              _StatInfo('Revenue Today', 'KES 45,820', Icons.attach_money, const Color(0xFFF59E0B)),
              _StatInfo('Pending Transactions', '24', Icons.receipt, const Color(0xFFFF5A5F)),
              if (crossAxisCount > 3) _StatInfo('Support Tickets', '12', Icons.support_agent, const Color(0xFF8B5CF6)),
              if (crossAxisCount > 3) _StatInfo('Growth Rate', '+15%', Icons.trending_up, const Color(0xFF00A699)),
            ];

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
              children: stats.map((stat) => _StatCard(info: stat)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StatInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatInfo(this.title, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatInfo info;

  const _StatCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          shadowColor: info.color.withValues(alpha: 0.3),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 80 : 100,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  info.color.withValues(alpha: 0.05),
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
                              info.color.withValues(alpha: 0.2),
                              info.color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: info.color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(info.icon, color: info.color, size: iconSize),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),
                      Expanded(
                        child: Text(
                          info.title,
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
                      info.value,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.bold,
                        color: info.color,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: info.color.withValues(alpha: 0.2),
                            offset: const Offset(1, 1),
                          ),
                        ],
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
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
            final childAspectRatio = isSmallScreen ? 1.1 : (isMediumScreen ? 1.3 : 1.1);
            final padding = isSmallScreen ? 16.0 : 20.0;

            final actions = [
              _ActionInfo('Manage Users', Icons.people, const Color(0xFF6366F1)),
              _ActionInfo('View Reports', Icons.assessment, const Color(0xFF10B981)),
              _ActionInfo('System Settings', Icons.settings, const Color(0xFF8B5CF6)),
              _ActionInfo('View Analytics', Icons.analytics, const Color(0xFFF59E0B)),
            ];

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
                children: actions.map((action) => _ActionCard(action: action)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionInfo {
  final String title;
  final IconData icon;
  final Color color;

  _ActionInfo(this.title, this.icon, this.color);
}

class _ActionCard extends StatelessWidget {
  final _ActionInfo action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          shadowColor: action.color.withValues(alpha: 0.4),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            hoverColor: action.color.withValues(alpha: 0.1),
            splashColor: action.color.withValues(alpha: 0.2),
            child: Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 80 : 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    action.color.withValues(alpha: 0.08),
                    action.color.withValues(alpha: 0.02),
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
                          action.color.withValues(alpha: 0.2),
                          action.color.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: action.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(action.icon, color: action.color, size: iconSize),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 12),
                  Flexible(
                    child: Text(
                      action.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: action.color,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: action.color.withValues(alpha: 0.2),
                            offset: const Offset(1, 1),
                          ),
                        ],
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
}

class _SystemHealthSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = [
      _HealthInfo('Database', 95, const Color(0xFF10B981)),
      _HealthInfo('API Services', 88, const Color(0xFF6366F1)),
      _HealthInfo('Payment Gateway', 92, const Color(0xFF00A699)),
      _HealthInfo('Email Service', 75, const Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('System Health'),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.blue.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: services.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
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
                    child: _HealthIndicator(info: service),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthInfo {
  final String name;
  final int percentage;
  final Color color;

  _HealthInfo(this.name, this.percentage, this.color);
}

class _HealthIndicator extends StatelessWidget {
  final _HealthInfo info;

  const _HealthIndicator({required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                info.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${info.percentage}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: info.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: info.percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: info.color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _ActivityInfo('New User Registered', 'John Doe registered a new account', '2h ago', Icons.person_add, const Color(0xFF6366F1)),
      _ActivityInfo('Payment Processed', 'KES 15,000 payment for property #123', '3h ago', Icons.payment, const Color(0xFF10B981)),
      _ActivityInfo('System Backup Completed', 'Daily backup executed successfully', '5h ago', Icons.backup, const Color(0xFF8B5CF6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Recent Activity'),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.blue.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.withValues(alpha: 0.02),
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
                    child: _ActivityItem(info: activity),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityInfo {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  _ActivityInfo(this.title, this.description, this.time, this.icon, this.color);
}

class _ActivityItem extends StatelessWidget {
  final _ActivityInfo info;

  const _ActivityItem({required this.info});

  @override
  Widget build(BuildContext context) {
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
                info.color.withValues(alpha: 0.2),
                info.color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: info.color.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(info.icon, color: info.color, size: 20),
        ),
        title: Text(
          info.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          info.description,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Text(
          info.time,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}