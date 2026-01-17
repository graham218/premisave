import 'package:flutter/material.dart';

class PropertyDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> property;
  final String rentalType;

  const PropertyDetailsDialog({
    super.key,
    required this.property,
    required this.rentalType,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final dialogWidth = screenWidth * 0.9;
    final maxDialogWidth = 500.0;

    final price = rentalType == 'daily'
        ? '${property['dailyPrice']} / night'
        : '${property['monthlyPrice']} / month';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth > maxDialogWidth ? maxDialogWidth : dialogWidth,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: isSmallScreen ? 180 : 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(property['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  if (property['badge'] != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green!),
                        ),
                        child: Text(
                          property['badge'],
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Content Section
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property['title'],
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    property['location'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.amber[600]),
                              const SizedBox(width: 4),
                              Text(
                                property['rating'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber[800],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Property Type and Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            property['type'],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 17 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Property Features
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(
                          icon: Icons.king_bed,
                          label: '3 Beds',
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildFeatureItem(
                          icon: Icons.bathtub,
                          label: '2 Baths',
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildFeatureItem(
                          icon: Icons.aspect_ratio,
                          label: '120 m²',
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildFeatureItem(
                          icon: Icons.wifi,
                          label: 'WiFi',
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),

                    // Description
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beautiful ${property['type'].toString().toLowerCase()} with stunning views, fully furnished with premium amenities. Perfect for both short stays and long-term rentals. Located in a prime area with easy access to all major facilities.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),

                    // Action Buttons
                    const SizedBox(height: 20),
                    isSmallScreen
                        ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green!),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Add to Wishlist'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue!),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.reviews),
                            label: const Text('View Reviews'),
                          ),
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green!),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Wishlist'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue!),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.reviews),
                            label: const Text('Reviews'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
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
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: isSmallScreen ? 22 : 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}