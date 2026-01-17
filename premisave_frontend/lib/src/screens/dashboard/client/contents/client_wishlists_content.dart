import 'package:flutter/material.dart';

class ClientWishlistsContent extends StatelessWidget {
  const ClientWishlistsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSection(),
          const SizedBox(height: 24),
          const _WishlistStats(),
          const SizedBox(height: 24),
          const _WishlistSection(
            title: 'Beachfront Properties',
            properties: _beachfrontWishlist,
          ),
          const SizedBox(height: 24),
          const _WishlistSection(
            title: 'Mountain Getaways',
            properties: _mountainWishlist,
          ),
          const SizedBox(height: 24),
          const _WishlistSection(
            title: 'City Apartments',
            properties: _cityWishlist,
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Wishlists',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save and organize your favorite properties',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistStats extends StatelessWidget {
  const _WishlistStats();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;

    final stats = [
      {'title': 'Total Saved', 'value': '12', 'color': Colors.pink, 'icon': Icons.favorite},
      {'title': 'Lists Created', 'value': '3', 'color': Colors.green, 'icon': Icons.list},
      {'title': 'Recently Viewed', 'value': '5', 'color': Colors.blue, 'icon': Icons.visibility},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wishlist Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(stat: stats[index]),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [stat['color'].withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: stat['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(stat['icon'], color: stat['color'], size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              stat['value'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: stat['color'],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat['title'],
              style: TextStyle(
                fontSize: 13,
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

class _WishlistSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> properties;

  const _WishlistSection({
    required this.title,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text('View All'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${properties.length} properties',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: properties.length,
          itemBuilder: (context, index) => _WishlistPropertyCard(property: properties[index]),
        ),
      ],
    );
  }
}

class _WishlistPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;

  const _WishlistPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(property['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite,
                      size: 18,
                      color: Colors.pink,
                    ),
                  ),
                ),
                if (property['badge'] != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        property['badge'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          property['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  property['location'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property['type'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      property['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Book Now', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sample wishlist data
const List<Map<String, dynamic>> _beachfrontWishlist = [
  {
    'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=400&auto=format&fit=crop',
    'title': 'Ocean View Villa',
    'location': 'Diani Beach',
    'price': 'KSh 25,000/night',
    'rating': 4.88,
    'type': 'Villa',
    'badge': 'Beachfront',
  },
  {
    'image': 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=400&auto=format&fit=crop',
    'title': 'Beach House',
    'location': 'Mombasa',
    'price': 'KSh 18,000/night',
    'rating': 4.75,
    'type': 'House',
    'badge': 'Luxury',
  },
];

const List<Map<String, dynamic>> _mountainWishlist = [
  {
    'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&auto=format&fit=crop',
    'title': 'Mountain Cabin',
    'location': 'Mount Kenya',
    'price': 'KSh 12,000/night',
    'rating': 4.95,
    'type': 'Cabin',
    'badge': 'Popular',
  },
  {
    'image': 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=400&auto=format&fit=crop',
    'title': 'Forest Retreat',
    'location': 'Aberdare',
    'price': 'KSh 9,500/night',
    'rating': 4.82,
    'type': 'Retreat',
    'badge': 'Eco',
  },
  {
    'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&auto=format&fit=crop',
    'title': 'Hiking Lodge',
    'location': 'Samburu',
    'price': 'KSh 14,000/night',
    'rating': 4.90,
    'type': 'Lodge',
    'badge': 'Adventure',
  },
];

const List<Map<String, dynamic>> _cityWishlist = [
  {
    'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400&auto=format&fit=crop',
    'title': 'Modern Apartment',
    'location': 'Nairobi CBD',
    'price': 'KSh 8,500/night',
    'rating': 4.92,
    'type': 'Apartment',
    'badge': 'Guest Favorite',
  },
  {
    'image': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400&auto=format&fit=crop',
    'title': 'City Studio',
    'location': 'Westlands',
    'price': 'KSh 6,500/night',
    'rating': 4.75,
    'type': 'Studio',
    'badge': 'Modern',
  },
  {
    'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&auto=format&fit=crop',
    'title': 'Penthouse Loft',
    'location': 'Kilimani',
    'price': 'KSh 15,000/night',
    'rating': 4.89,
    'type': 'Loft',
    'badge': 'Luxury',
  },
];