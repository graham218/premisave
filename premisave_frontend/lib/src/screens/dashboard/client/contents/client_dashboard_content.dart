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
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 12 : 24,
        vertical: screenWidth < 600 ? 8 : 16,
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(user: authState.currentUser),
              const SizedBox(height: 20),
              _DashboardGrid(),
              const SizedBox(height: 20),
              _QuickActionsGrid(),
              const SizedBox(height: 20),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.firstName ?? 'Guest',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Wrap(
                  spacing: isSmallScreen ? 6 : 8,
                  runSpacing: isSmallScreen ? 6 : 8,
                  children: [
                    _buildStatusChip('Active', Icons.verified, Colors.green),
                    _buildStatusChip('Premium', Icons.diamond, Colors.blue),
                    _buildStatusChip('Member', Icons.star, Colors.amber),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Container(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 30 : 40),
              child: hasProfilePic
                  ? Image.network(
                user!.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildProfileFallback(isSmallScreen),
              )
                  : _buildProfileFallback(isSmallScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFallback(bool isSmallScreen) {
    return Container(
      color: Colors.green[100],
      child: Icon(
        Icons.person,
        size: isSmallScreen ? 30 : 40,
        color: Colors.green,
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid logic
    int crossAxisCount;
    if (screenWidth < 400) {
      crossAxisCount = 2;
    } else if (screenWidth < 768) {
      crossAxisCount = 2;
    } else if (screenWidth < 1024) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('My Overview'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate child aspect ratio based on screen size
            final childAspectRatio = screenWidth < 400 ? 1.3 :
            screenWidth < 600 ? 1.5 :
            screenWidth < 1024 ? 1.2 : 1.1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _StatCard(info: stats[index]),
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
    final isSmallScreen = screenWidth < 400;

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
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.color, size: isSmallScreen ? 16 : 20),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              info.value,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: info.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              info.title,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid logic
    int crossAxisCount;
    if (screenWidth < 400) {
      crossAxisCount = 2;
    } else if (screenWidth < 768) {
      crossAxisCount = 2;
    } else if (screenWidth < 1024) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate child aspect ratio based on screen size
            final childAspectRatio = screenWidth < 400 ? 1.8 :
            screenWidth < 600 ? 1.6 :
            screenWidth < 1024 ? 1.4 : 1.5;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) => _ActionCard(action: actions[index]),
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
    final isSmallScreen = screenWidth < 400;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: isSmallScreen ? 20 : 24),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                action.title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
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
    final screenWidth = MediaQuery.of(context).size.width;

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
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive card width calculation
            final availableWidth = constraints.maxWidth;
            double cardWidth;
            int itemCount;

            if (screenWidth < 400) {
              cardWidth = availableWidth * 0.75;
              itemCount = 1;
            } else if (screenWidth < 600) {
              cardWidth = availableWidth * 0.6;
              itemCount = 2;
            } else if (screenWidth < 900) {
              cardWidth = availableWidth * 0.45;
              itemCount = 2;
            } else {
              cardWidth = availableWidth * 0.3;
              itemCount = 3;
            }

            // Ensure card has minimum and maximum width
            cardWidth = cardWidth.clamp(180, 280);

            return SizedBox(
              height: screenWidth < 400 ? 200 : 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    right: index < itemCount - 1 ? 12 : 0,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: _TrendingPropertyCard(
                    property: trendingProperties[index],
                    width: cardWidth,
                    onTap: () => _showPropertyDetails(context, trendingProperties[index]),
                  ),
                ),
              ),
            );
          },
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
  final double width;

  const _TrendingPropertyCard({
    required this.property,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 9 : 10,
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
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property['location'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            property['dailyPrice'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: isSmallScreen ? 12 : 14, color: Colors.amber[600]),
                            const SizedBox(width: 2),
                            Text(
                              property['rating'].toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth < 400 ? 18 : 20,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}