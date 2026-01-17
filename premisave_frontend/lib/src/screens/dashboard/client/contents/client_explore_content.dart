import 'package:flutter/material.dart';

class ClientExploreContent extends StatefulWidget {
  const ClientExploreContent({super.key});

  @override
  State<ClientExploreContent> createState() => _ClientExploreContentState();
}

class _ClientExploreContentState extends State<ClientExploreContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Apartments', 'Houses', 'Villas', 'Studios', 'Cabins'];
  final List<String> _counties = [
    'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Naivasha',
    'Thika', 'Kitale', 'Malindi', 'Nyeri', 'Meru', 'Kisii'
  ];

  int _selectedCategoryIndex = 0;
  int _selectedCountyIndex = 0;
  String _searchQuery = '';
  String _rentalType = 'daily'; // 'daily' or 'monthly'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: const Color(0xFF00A699),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find your perfect stay',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Circular',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Book apartments, homes, and services across Kenya',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Circular',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Search Bar
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search destinations, properties, or services',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      icon: const Icon(Icons.search, color: Color(0xFF00A699)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00A699),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(Icons.tune, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Rental Type Toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          children: [
                            _buildRentalTypeButton('Daily Rentals', 'daily'),
                            const SizedBox(width: 12),
                            _buildRentalTypeButton('Monthly Rentals', 'monthly'),
                          ],
                        ),
                      ),

                      // County Filter
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _counties.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedCountyIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(_counties[index]),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCountyIndex = index;
                                  });
                                },
                                selectedColor: const Color(0xFF00A699),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF00A699) : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Category Tabs
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: const Color(0xFF00A699),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF00A699),
                        tabs: const [
                          Tab(text: 'Properties'),
                          Tab(text: 'Services'),
                          Tab(text: 'Experiences'),
                          Tab(text: 'Chefs'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Properties Tab
            _buildPropertiesTab(),

            // Services Tab
            _buildServicesTab(),

            // Experiences Tab
            _buildExperiencesTab(),

            // Chefs Tab
            _buildChefsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalTypeButton(String label, String value) {
    final isSelected = _rentalType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _rentalType = value;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00A699) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? const Color(0xFF00A699) : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    final properties = [
      {
        'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        'title': 'Modern Apartment in Nairobi CBD',
        'location': 'Nairobi, Kenya',
        'price': _rentalType == 'daily' ? 'KSh 8,500 / night' : 'KSh 150,000 / month',
        'rating': 4.92,
        'reviews': 128,
        'type': 'Apartment',
        'badge': 'Guest favorite',
      },
      {
        'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233',
        'title': 'Luxury Villa with Ocean View',
        'location': 'Mombasa, Kenya',
        'price': _rentalType == 'daily' ? 'KSh 25,000 / night' : 'KSh 450,000 / month',
        'rating': 4.88,
        'reviews': 89,
        'type': 'Villa',
        'badge': 'Trending',
      },
      {
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        'title': 'Cozy Cabin in the Mountains',
        'location': 'Mount Kenya',
        'price': _rentalType == 'daily' ? 'KSh 12,000 / night' : 'KSh 220,000 / month',
        'rating': 4.95,
        'reviews': 56,
        'type': 'Cabin',
        'badge': null,
      },
      {
        'image': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461',
        'title': 'City Center Studio Apartment',
        'location': 'Nairobi West',
        'price': _rentalType == 'daily' ? 'KSh 6,500 / night' : 'KSh 120,000 / month',
        'rating': 4.75,
        'reviews': 203,
        'type': 'Studio',
        'badge': 'Popular',
      },
      {
        'image': 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5',
        'title': 'Beachfront House in Diani',
        'location': 'Diani Beach',
        'price': _rentalType == 'daily' ? 'KSh 30,000 / night' : 'KSh 550,000 / month',
        'rating': 4.98,
        'reviews': 67,
        'type': 'House',
        'badge': 'Luxury',
      },
      {
        'image': 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9',
        'title': 'Luxury Penthouse with Pool',
        'location': 'Westlands, Nairobi',
        'price': _rentalType == 'daily' ? 'KSh 45,000 / night' : 'KSh 800,000 / month',
        'rating': 4.96,
        'reviews': 42,
        'type': 'Penthouse',
        'badge': 'Premium',
      },
    ];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final property = properties[index];
                return _PropertyCard(
                  imageUrl: property['image'] as String,
                  title: property['title'] as String,
                  location: property['location'] as String,
                  price: property['price'] as String,
                  rating: property['rating'] as double,
                  reviews: property['reviews'] as int,
                  type: property['type'] as String,
                  badge: property['badge'] as String?,
                );
              },
              childCount: properties.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return const Center(
      child: Text(
        'Services Content - Coming Soon',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildExperiencesTab() {
    return const Center(
      child: Text(
        'Experiences Content - Coming Soon',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildChefsTab() {
    return const Center(
      child: Text(
        'Chefs Content - Coming Soon',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final double rating;
  final int reviews;
  final String type;
  final String? badge;

  const _PropertyCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.type,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to property details
        // context.push('/property/${propertyId}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (badge != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Circular',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Circular',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.black87),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00A699),
                          fontFamily: 'Circular',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}