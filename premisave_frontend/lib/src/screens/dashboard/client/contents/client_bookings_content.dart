import 'package:flutter/material.dart';

class ClientBookingsContent extends StatelessWidget {
  const ClientBookingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(),
          SizedBox(height: 24),
          _BookingStats(),
          SizedBox(height: 24),
          _ActiveBookings(),
          SizedBox(height: 24),
          _PastBookings(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage all your property bookings in one place',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.green,
              size: isSmallScreen ? 24 : 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStats extends StatelessWidget {
  const _BookingStats();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // FIXED: Better responsive breakpoints for smoother transitions
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    // Mobile: 0-599
    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
      spacing = 12.0;
    }
    // Tablet: 600-1023
    else if (screenWidth < 1024) {
      crossAxisCount = screenWidth < 800 ? 2 : 4; // Tablet transition at 800px
      childAspectRatio = crossAxisCount == 2 ? 1.5 : 1.2;
      spacing = 16.0;
    }
    // Desktop: 1024+
    else {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
      spacing = 20.0;
    }

    final stats = [
      {'title': 'Active', 'value': '3', 'color': Colors.green, 'icon': Icons.check_circle},
      {'title': 'Upcoming', 'value': '2', 'color': Colors.blue, 'icon': Icons.upcoming},
      {'title': 'Completed', 'value': '8', 'color': Colors.purple, 'icon': Icons.done_all},
      {'title': 'Cancelled', 'value': '1', 'color': Colors.orange, 'icon': Icons.cancel},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Use MediaQuery.of(context).size.width instead of constraints for consistency
            final width = constraints.maxWidth;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _StatCard(stat: stats[index], screenWidth: screenWidth),
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  final double screenWidth;

  const _StatCard({required this.stat, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1024 && screenWidth >= 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          gradient: LinearGradient(
            colors: [stat['color'].withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 14 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : isTablet ? 7 : 8),
              decoration: BoxDecoration(
                color: stat['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                stat['icon'],
                color: stat['color'],
                size: isMobile ? 18 : isTablet ? 19 : 20,
              ),
            ),
            SizedBox(height: isMobile ? 8 : isTablet ? 10 : 12),
            Text(
              stat['value'],
              style: TextStyle(
                fontSize: isMobile ? 20 : isTablet ? 22 : 24,
                fontWeight: FontWeight.w800,
                color: stat['color'],
              ),
            ),
            SizedBox(height: isMobile ? 2 : isTablet ? 3 : 4),
            Text(
              stat['title'],
              style: TextStyle(
                fontSize: isMobile ? 12 : isTablet ? 12.5 : 13,
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

class _ActiveBookings extends StatelessWidget {
  const _ActiveBookings();

  final List<Map<String, dynamic>> activeBookings = const [
    {
      'property': 'Modern Apartment',
      'location': 'Nairobi CBD',
      'checkIn': '15 Dec 2024',
      'checkOut': '20 Dec 2024',
      'amount': 'KSh 42,500',
      'status': 'Confirmed',
      'color': Colors.green,
    },
    {
      'property': 'Luxury Villa',
      'location': 'Mombasa',
      'checkIn': '22 Jan 2025',
      'checkOut': '29 Jan 2025',
      'amount': 'KSh 175,000',
      'status': 'Confirmed',
      'color': Colors.green,
    },
    {
      'property': 'Mountain Cabin',
      'location': 'Mount Kenya',
      'checkIn': '10 Feb 2025',
      'checkOut': '15 Feb 2025',
      'amount': 'KSh 60,000',
      'status': 'Pending',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Bookings',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your current and upcoming stays',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...activeBookings.map((booking) => _BookingCard(booking: booking)).toList(),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1024 && screenWidth >= 600;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : isTablet ? 14 : 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : isTablet ? 14 : 16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 18 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 12 : isTablet ? 14 : 16),
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 50 : isTablet ? 55 : 60,
                  height: isMobile ? 50 : isTablet ? 55 : 60,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(isMobile ? 8 : isTablet ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.home,
                    color: Colors.green,
                    size: isMobile ? 24 : isTablet ? 27 : 30,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : isTablet ? 14 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['property'],
                        style: TextStyle(
                          fontSize: isMobile ? 16 : isTablet ? 17 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : isTablet ? 3 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isMobile ? 12 : isTablet ? 13 : 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: isMobile ? 2 : isTablet ? 3 : 4),
                          Text(
                            booking['location'],
                            style: TextStyle(
                              fontSize: isMobile ? 13 : isTablet ? 13.5 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : isTablet ? 10 : 12,
                    vertical: isMobile ? 4 : isTablet ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: isMobile ? 11 : isTablet ? 11.5 : 12,
                      fontWeight: FontWeight.w600,
                      color: booking['color'],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : isTablet ? 18 : 20),
            const Divider(),
            SizedBox(height: isMobile ? 12 : isTablet ? 14 : 16),
            // Responsive layout for booking details
            if (screenWidth < 480)
            // Stack vertically on very small screens
              Column(
                children: [
                  _BookingDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-in',
                    value: booking['checkIn'],
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: 12),
                  _BookingDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-out',
                    value: booking['checkOut'],
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: 12),
                  _BookingDetail(
                    icon: Icons.payments,
                    title: 'Total',
                    value: booking['amount'],
                    isAmount: true,
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                ],
              )
            else
            // Horizontal layout on larger screens
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BookingDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-in',
                    value: booking['checkIn'],
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                  _BookingDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-out',
                    value: booking['checkOut'],
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                  _BookingDetail(
                    icon: Icons.payments,
                    title: 'Total',
                    value: booking['amount'],
                    isAmount: true,
                    isSmall: isMobile,
                    isTablet: isTablet,
                  ),
                ],
              ),
            SizedBox(height: isMobile ? 16 : isTablet ? 18 : 20),
            // Responsive button layout
            if (screenWidth < 480)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.visibility, size: isMobile ? 16 : isTablet ? 17 : 18),
                      label: Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.chat, size: isMobile ? 16 : isTablet ? 17 : 18),
                      label: Text('Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.visibility, size: isMobile ? 16 : isTablet ? 17 : 18),
                      label: Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : isTablet ? 10 : 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.chat, size: isMobile ? 16 : isTablet ? 17 : 18),
                      label: Text('Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isAmount;
  final bool isSmall;
  final bool isTablet;

  const _BookingDetail({
    required this.icon,
    required this.title,
    required this.value,
    this.isAmount = false,
    required this.isSmall,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: isSmall ? 18 : isTablet ? 19 : 20, color: Colors.grey[600]),
        SizedBox(height: isSmall ? 4 : isTablet ? 6 : 8),
        Text(
          title,
          style: TextStyle(fontSize: isSmall ? 11 : isTablet ? 11.5 : 12, color: Colors.grey[600]),
        ),
        SizedBox(height: isSmall ? 2 : isTablet ? 3 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 13 : isTablet ? 13.5 : 14,
            fontWeight: FontWeight.w700,
            color: isAmount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _PastBookings extends StatelessWidget {
  const _PastBookings();

  final List<Map<String, dynamic>> pastBookings = const [
    {'date': '10 Nov 2024', 'property': 'Beach House', 'amount': 'KSh 35,000'},
    {'date': '25 Oct 2024', 'property': 'City Apartment', 'amount': 'KSh 28,500'},
    {'date': '15 Sep 2024', 'property': 'Mountain Lodge', 'amount': 'KSh 48,000'},
    {'date': '5 Aug 2024', 'property': 'Studio Flat', 'amount': 'KSh 19,500'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1024 && screenWidth >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past Bookings',
          style: TextStyle(
            fontSize: isMobile ? 18 : isTablet ? 19 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your previous stays',
          style: TextStyle(
            fontSize: isMobile ? 13 : isTablet ? 13.5 : 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : isTablet ? 14 : 16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 12 : isTablet ? 14 : 16),
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 18 : 20),
            child: Column(
              children: pastBookings.map((booking) => _PastBookingItem(
                booking: booking,
                isMobile: isMobile,
                isTablet: isTablet,
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PastBookingItem extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isMobile;
  final bool isTablet;

  const _PastBookingItem({required this.booking, required this.isMobile, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : isTablet ? 11 : 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : isTablet ? 7 : 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(isMobile ? 6 : isTablet ? 7 : 8),
            ),
            child: Icon(
              Icons.history,
              size: isMobile ? 18 : isTablet ? 19 : 20,
              color: Colors.green,
            ),
          ),
          SizedBox(width: isMobile ? 12 : isTablet ? 14 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['property'],
                  style: TextStyle(
                    fontSize: isMobile ? 14 : isTablet ? 14.5 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : isTablet ? 3 : 4),
                Text(
                  booking['date'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : isTablet ? 12.5 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            booking['amount'],
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 15 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}