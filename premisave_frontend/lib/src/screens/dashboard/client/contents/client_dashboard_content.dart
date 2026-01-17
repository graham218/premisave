import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../providers/auth/auth_provider.dart';

class ClientDashboardContent extends ConsumerStatefulWidget {
  const ClientDashboardContent({super.key});

  @override
  ConsumerState<ClientDashboardContent> createState() => _ClientDashboardContentState();
}

class _ClientDashboardContentState extends ConsumerState<ClientDashboardContent>
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
                  _RecentTransactionsSection(),
                  const SizedBox(height: 24),
                  _MyPropertiesSection(),
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
                      user?.firstName ?? 'Client',
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
                  color: const Color(0xFF00A699),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A699).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
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
              color: const Color(0xFF00A699),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatusChip(
                'Account Active',
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
              ),
              _buildStatusChip(
                'Properties Owned',
                Icons.home_work_rounded,
                const Color(0xFF00A699),
              ),
              _buildStatusChip(
                'Transactions',
                Icons.receipt_long_rounded,
                const Color(0xFF6366F1),
              ),
              _buildStatusChip(
                'Last Payment',
                Icons.payment_rounded,
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
        const _SectionTitle('My Overview'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
            final childAspectRatio = isSmallScreen ? 1.3 : (isMediumScreen ? 1.5 : 1.2);
            final mainAxisSpacing = isSmallScreen ? 12.0 : 16.0;

            final stats = [
              _StatInfo('My Properties', '5', Icons.home, const Color(0xFF00A699)),
              _StatInfo('Total Payments', 'KES 250,000', Icons.payments, const Color(0xFF10B981)),
              _StatInfo('Pending Bills', 'KES 45,820', Icons.receipt, const Color(0xFFF59E0B)),
              _StatInfo('Support Tickets', '2', Icons.support_agent, const Color(0xFF6366F1)),
              if (crossAxisCount > 3) _StatInfo('Lease Duration', '12 Months', Icons.calendar_today, const Color(0xFF8B5CF6)),
              if (crossAxisCount > 3) _StatInfo('Saved Amount', 'KES 150,000', Icons.savings, const Color(0xFF00A699)),
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
          shadowColor: info.color.withOpacity(0.3),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 80 : 100,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  info.color.withOpacity(0.05),
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
                              info.color.withOpacity(0.2),
                              info.color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: info.color.withOpacity(0.2),
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
                            color: info.color.withOpacity(0.2),
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
              _ActionInfo('Make Payment', Icons.payment, const Color(0xFF00A699)),
              _ActionInfo('View Properties', Icons.home_work, const Color(0xFF10B981)),
              _ActionInfo('Support Ticket', Icons.support_agent, const Color(0xFF6366F1)),
              _ActionInfo('Account Settings', Icons.settings, const Color(0xFF8B5CF6)),
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
          shadowColor: action.color.withOpacity(0.4),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            hoverColor: action.color.withOpacity(0.1),
            splashColor: action.color.withOpacity(0.2),
            child: Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 80 : 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    action.color.withOpacity(0.08),
                    action.color.withOpacity(0.02),
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
                          action.color.withOpacity(0.2),
                          action.color.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: action.color.withOpacity(0.3),
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
                            color: action.color.withOpacity(0.2),
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

class _RecentTransactionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactions = [
      _TransactionInfo('Property Payment', 'KES 25,000', '2h ago', Icons.payment, const Color(0xFF10B981)),
      _TransactionInfo('Maintenance Fee', 'KES 5,000', '1 day ago', Icons.home_repair_service, const Color(0xFF00A699)),
      _TransactionInfo('Security Deposit', 'KES 15,000', '3 days ago', Icons.security, const Color(0xFF6366F1)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Recent Transactions'),
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
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
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
                    child: _TransactionItem(info: transaction),
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

class _TransactionInfo {
  final String title;
  final String amount;
  final String time;
  final IconData icon;
  final Color color;

  _TransactionInfo(this.title, this.amount, this.time, this.icon, this.color);
}

class _TransactionItem extends StatelessWidget {
  final _TransactionInfo info;

  const _TransactionItem({required this.info});

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
                info.color.withOpacity(0.2),
                info.color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: info.color.withOpacity(0.2),
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              info.amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: info.color,
              ),
            ),
            Text(
              info.time,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPropertiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final properties = [
      _PropertyInfo('Sky Gardens Apartments', 'Nairobi CBD', 'KES 85,000/month', Icons.apartment, const Color(0xFF00A699)),
      _PropertyInfo('Mountain View Villa', 'Karen', 'KES 250,000/month', Icons.villa, const Color(0xFF8B5CF6)),
      _PropertyInfo('City Center Office', 'Westlands', 'KES 120,000/month', Icons.business, const Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('My Properties'),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.green.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.green.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: properties.asMap().entries.map((entry) {
                  final index = entry.key;
                  final property = entry.value;
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
                    child: _PropertyItem(info: property),
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

class _PropertyInfo {
  final String name;
  final String location;
  final String price;
  final IconData icon;
  final Color color;

  _PropertyInfo(this.name, this.location, this.price, this.icon, this.color);
}

class _PropertyItem extends StatelessWidget {
  final _PropertyInfo info;

  const _PropertyItem({required this.info});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                info.color.withOpacity(0.2),
                info.color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: info.color.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(info.icon, color: info.color, size: 24),
        ),
        title: Text(
          info.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          info.location,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              info.price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: info.color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: info.color,
                ),
              ),
            ),
          ],
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