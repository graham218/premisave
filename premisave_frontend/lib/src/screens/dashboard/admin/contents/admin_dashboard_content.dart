import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../providers/auth/auth_provider.dart';

class AdminDashboardContent extends ConsumerWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(user: authState.currentUser),
          const SizedBox(height: 24),
          _DashboardGrid(screenWidth: screenWidth),
          const SizedBox(height: 24),
          _QuickActionsGrid(screenWidth: screenWidth),
          const SizedBox(height: 24),
          _SystemHealthSection(),
          const SizedBox(height: 24),
          _RecentActivitySection(),
        ],
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
      decoration: _cardDecoration(),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to Premisave Admin Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5A5F), Color(0xFFFF8A8E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatusChip('System Active', Icons.check_circle, Color(0xFF00A699)),
              _StatusChip('Users Online', Icons.people, Color(0xFF6366F1)),
              _StatusChip('All Services Up', Icons.verified, Color(0xFF10B981)),
              _StatusChip('Last Backup: Today', Icons.backup, Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _StatusChip(this.text, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final double screenWidth;
  const _DashboardGrid({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isSmall = screenWidth < 600;
    final crossAxisCount = isSmall ? 2 : (screenWidth < 900 ? 3 : 4);

    final stats = [
      _StatInfo('Total Users', '1,254', Icons.people, Color(0xFF6366F1)),
      _StatInfo('Properties', '842', Icons.home, Color(0xFF10B981)),
      _StatInfo('Revenue Today', 'KES 45,820', Icons.attach_money, Color(0xFFF59E0B)),
      _StatInfo('Pending Transactions', '24', Icons.receipt, Color(0xFFFF5A5F)),
      if (crossAxisCount > 3) _StatInfo('Support Tickets', '12', Icons.support_agent, Color(0xFF8B5CF6)),
      if (crossAxisCount > 3) _StatInfo('Growth Rate', '+15%', Icons.trending_up, Color(0xFF00A699)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('System Overview'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: stats.map((stat) => _StatCard(stat, screenWidth)).toList(),
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
  final double screenWidth;

  const _StatCard(this.info, this.screenWidth);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: _cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(info.icon, color: info.color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                info.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: info.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final double screenWidth;
  const _QuickActionsGrid({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isSmall = screenWidth < 600;
    final crossAxisCount = isSmall ? 2 : (screenWidth < 900 ? 3 : 4);

    final actions = [
      _ActionInfo('Manage Users', Icons.people, Color(0xFF6366F1)),
      _ActionInfo('View Reports', Icons.assessment, Color(0xFF10B981)),
      _ActionInfo('System Settings', Icons.settings, Color(0xFF8B5CF6)),
      _ActionInfo('View Analytics', Icons.analytics, Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: actions.map((action) => _ActionCard(action)).toList(),
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

  const _ActionCard(this.action);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [action.color.withOpacity(0.2), action.color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, color: action.color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  action.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: action.color,
                  ),
                ),
              ],
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
      _HealthInfo('Database', 95, Color(0xFF10B981)),
      _HealthInfo('API Services', 88, Color(0xFF6366F1)),
      _HealthInfo('Payment Gateway', 92, Color(0xFF00A699)),
      _HealthInfo('Email Service', 75, Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('System Health'),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: services.map((service) => _HealthIndicator(service)).toList(),
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

  const _HealthIndicator(this.info);

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
      _ActivityInfo('New User Registered', 'John Doe registered a new account', '2h ago', Icons.person_add, Color(0xFF6366F1)),
      _ActivityInfo('Payment Processed', 'KES 15,000 payment for property #123', '3h ago', Icons.payment, Color(0xFF10B981)),
      _ActivityInfo('System Backup Completed', 'Daily backup executed successfully', '5h ago', Icons.backup, Color(0xFF8B5CF6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Recent Activity'),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: activities.map((activity) => _ActivityItem(activity)).toList(),
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

  const _ActivityItem(this.info);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: info.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            info.time,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}