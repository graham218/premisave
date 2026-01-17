import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../providers/auth/auth_provider.dart';
import 'widgets/client_explore/property_details_dialog.dart';

class ClientDashboardContent extends ConsumerStatefulWidget {
  const ClientDashboardContent({super.key});

  @override
  ConsumerState<ClientDashboardContent> createState() => _ClientDashboardContentState();
}

class _ClientDashboardContentState extends ConsumerState<ClientDashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(user: authState.currentUser),
              const SizedBox(height: 24),
              _DashboardGrid(),
              const SizedBox(height: 24),
              _QuickActionsGrid(),
              const SizedBox(height: 24),
              _TrendingPropertiesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final UserModel? user;
  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasProfilePic = user?.profilePictureUrl?.isNotEmpty == true;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.firstName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusChip('Active', Icons.verified, Colors.green),
                    _buildStatusChip('Premium', Icons.diamond, Colors.blue),
                    _buildStatusChip('Member', Icons.star, Colors.amber),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: hasProfilePic
                  ? Image.network(
                user!.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildProfileFallback(),
              )
                  : _buildProfileFallback(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFallback() {
    return Container(
      color: Colors.green[100],
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.green,
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final List<_StatInfo> stats = [
    _StatInfo('Properties', '5', Icons.home, Colors.green),
    _StatInfo('Payments', 'KES 250K', Icons.payments, Colors.blue),
    _StatInfo('Pending', 'KES 45K', Icons.pending, Colors.orange),
    _StatInfo('Support', '2', Icons.support, Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmallScreen ? 2 : 4;
    final spacing = isSmallScreen ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('My Overview'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(info: stats[index]),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [info.color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              info.value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: info.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              info.title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_ActionInfo> actions = [
    _ActionInfo('Pay Bills', Icons.payment, Colors.green),
    _ActionInfo('Properties', Icons.home_work, Colors.blue),
    _ActionInfo('Support', Icons.support, Colors.purple),
    _ActionInfo('Settings', Icons.settings, Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmallScreen ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => _ActionCard(action: actions[index]),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: action.color,
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

class _TrendingPropertiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> trendingProperties = [
    {
      'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
      'title': 'Modern Apartment',
      'location': 'Nairobi CBD',
      'dailyPrice': 'KSh 8,500',
      'monthlyPrice': 'KSh 150,000',
      'rating': 4.92,
      'type': 'Apartment',
      'badge': 'Trending',
    },
    {
      'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233',
      'title': 'Luxury Villa',
      'location': 'Mombasa',
      'dailyPrice': 'KSh 25,000',
      'monthlyPrice': 'KSh 450,000',
      'rating': 4.88,
      'type': 'Villa',
      'badge': 'Popular',
    },
    {
      'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
      'title': 'Mountain Cabin',
      'location': 'Mount Kenya',
      'dailyPrice': 'KSh 12,000',
      'monthlyPrice': 'KSh 220,000',
      'rating': 4.95,
      'type': 'Cabin',
      'badge': 'New',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final itemCount = isSmallScreen ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle('Trending Right Now'),
            TextButton(
              onPressed: () => _showAllProperties(context),
              child: const Row(
                children: [
                  Text('Show More'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: index < itemCount - 1 ? 16 : 0),
              child: _TrendingPropertyCard(
                property: trendingProperties[index],
                onTap: () => _showPropertyDetails(context, trendingProperties[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAllProperties(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Trending Properties'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: trendingProperties.length,
            itemBuilder: (context, index) => ListTile(
              leading: Image.network(
                trendingProperties[index]['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(trendingProperties[index]['title']),
              subtitle: Text(trendingProperties[index]['location']),
              trailing: Text(trendingProperties[index]['dailyPrice']),
              onTap: () {
                Navigator.pop(context);
                _showPropertyDetails(context, trendingProperties[index]);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(BuildContext context, Map<String, dynamic> property) {
    showDialog(
      context: context,
      builder: (context) => PropertyDetailsDialog(property: property, rentalType: 'daily'),
    );
  }
}

class _TrendingPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;

  const _TrendingPropertyCard({
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(property['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (property['badge'] != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              property['badge'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property['dailyPrice'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[800],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 2),
                            Text(
                              property['rating'].toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}