import 'package:flutter/material.dart';

class ClientBookingsContent extends StatelessWidget {
  const ClientBookingsContent({super.key});

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
          const _BookingStats(),
          const SizedBox(height: 24),
          const _ActiveBookings(),
          const SizedBox(height: 24),
          const _PastBookings(),
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
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage all your property bookings in one place',
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
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.green,
              size: 30,
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
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : 4;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Bookings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your current and upcoming stays',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home, color: Colors.green, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['property'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            booking['location'],
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: booking['color'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BookingDetail(
                  icon: Icons.calendar_today,
                  title: 'Check-in',
                  value: booking['checkIn'],
                ),
                _BookingDetail(
                  icon: Icons.calendar_today,
                  title: 'Check-out',
                  value: booking['checkOut'],
                ),
                _BookingDetail(
                  icon: Icons.payments,
                  title: 'Total',
                  value: booking['amount'],
                  isAmount: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Support'),
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

  const _BookingDetail({
    required this.icon,
    required this.title,
    required this.value,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Past Bookings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your previous stays',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: pastBookings.map((booking) => _PastBookingItem(booking: booking)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PastBookingItem extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _PastBookingItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['property'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking['date'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            booking['amount'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}