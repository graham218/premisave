import 'package:flutter/material.dart';
import 'widgets/client_explore/property_details_dialog.dart';

class ClientExploreContent extends StatefulWidget {
  const ClientExploreContent({super.key});

  @override
  State<ClientExploreContent> createState() => _ClientExploreContentState();
}

class _ClientExploreContentState extends State<ClientExploreContent> {
  final List<String> _categories = ['All', 'Apartments', 'Homes', 'Studios', 'Villas', 'Cabins', 'Beachfront', 'City view', 'Luxury'];
  final List<String> _counties = ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Naivasha', 'Thika', 'Kitale', 'Malindi', 'Nyeri', 'Meru', 'Kisii', 'Machakos'];

  int _selectedCategoryIndex = 0;
  int _selectedCountyIndex = 0;
  String _rentalType = 'daily';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProperties {
    return _sampleProperties.where((property) {
      final matchesSearch = _searchQuery.isEmpty ||
          property['title'].toLowerCase().contains(_searchQuery) ||
          property['location'].toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategoryIndex == 0 ||
          property['type'].toLowerCase().contains(_categories[_selectedCategoryIndex].toLowerCase());
      final matchesCounty = _selectedCountyIndex == 0 ||
          property['location'].contains(_counties[_selectedCountyIndex]);

      return matchesSearch && matchesCategory && matchesCounty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 768;
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 1200 ? 3 : 4);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: true,
          expandedHeight: isSmall ? 140 : 180,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Find Your Perfect Stay',
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover amazing properties across Kenya',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search destinations, properties...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: const Icon(Icons.search, color: Colors.green),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.green),
                            onPressed: () {},
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(isSmall ? 130 : 120),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRentalTypeButton('Daily Rentals', 'daily'),
                        const SizedBox(width: 12),
                        _buildRentalTypeButton('Monthly Rentals', 'monthly'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
                      itemCount: _counties.length,
                      itemBuilder: (context, index) => _buildCountyChip(index),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) => _buildCategoryChip(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          sliver: filteredProperties.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No properties found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
              : SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isSmall ? 12 : 16,
              mainAxisSpacing: isSmall ? 16 : 24,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => PropertyCard(
                property: filteredProperties[index],
                rentalType: _rentalType,
                onTap: () => _showPropertyDetails(context, filteredProperties[index]),
              ),
              childCount: filteredProperties.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showPropertyDetails(BuildContext context, Map<String, dynamic> property) {
    showDialog(
      context: context,
      builder: (context) => PropertyDetailsDialog(property: property, rentalType: _rentalType),
    );
  }

  Widget _buildRentalTypeButton(String label, String value) {
    final isSelected = _rentalType == value;
    return GestureDetector(
      onTap: () => setState(() => _rentalType = value),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
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
    );
  }

  Widget _buildCountyChip(int index) {
    final isSelected = _selectedCountyIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(_counties[index]),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCountyIndex = index),
        backgroundColor: Colors.white,
        selectedColor: Colors.green[50],
        labelStyle: TextStyle(
          color: isSelected ? Colors.green[800] : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        checkmarkColor: Colors.green,
      ),
    );
  }

  Widget _buildCategoryChip(int index) {
    final isSelected = _selectedCategoryIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(_categories[index]),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategoryIndex = index),
        backgroundColor: Colors.grey[50],
        selectedColor: Colors.green,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green! : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final String rentalType;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.rentalType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = rentalType == 'daily'
        ? '${property['dailyPrice']}/night'
        : '${property['monthlyPrice']}/month';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.grey[700],
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
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 8),
                  Text(
                    property['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
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
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
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

final List<Map<String, dynamic>> _sampleProperties = [
  {
    'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&auto=format&fit=crop',
    'title': 'Modern Apartment in Nairobi CBD',
    'location': 'Nairobi, Kenya',
    'dailyPrice': 'KSh 8,500',
    'monthlyPrice': 'KSh 150,000',
    'rating': 4.92,
    'type': 'Apartment',
    'badge': 'Guest favorite',
  },
  {
    'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=800&auto=format&fit=crop',
    'title': 'Luxury Villa with Ocean View',
    'location': 'Mombasa, Kenya',
    'dailyPrice': 'KSh 25,000',
    'monthlyPrice': 'KSh 450,000',
    'rating': 4.88,
    'type': 'Villa',
    'badge': 'Trending',
  },
  {
    'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w-800&auto=format&fit=crop',
    'title': 'Cozy Cabin in the Mountains',
    'location': 'Mount Kenya',
    'dailyPrice': 'KSh 12,000',
    'monthlyPrice': 'KSh 220,000',
    'rating': 4.95,
    'type': 'Cabin',
    'badge': 'Popular',
  },
  {
    'image': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&auto=format&fit=crop',
    'title': 'City Center Studio Apartment',
    'location': 'Nairobi West',
    'dailyPrice': 'KSh 6,500',
    'monthlyPrice': 'KSh 120,000',
    'rating': 4.75,
    'type': 'Studio',
    'badge': null,
  },
];