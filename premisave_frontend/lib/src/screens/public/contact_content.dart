import 'package:flutter/material.dart';

class ContactContent extends StatelessWidget {
  const ContactContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      child: Column(
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to help you',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Responsive contact cards layout
          isLargeScreen
              ? _buildContactCardsRow()
              : Column(
            children: _buildContactCards(),
            mainAxisSize: MainAxisSize.min,
          ),

          const SizedBox(height: 32),
          const Text(
            'Our Team',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Responsive team grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 3 : 2),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isLargeScreen ? 0.8 : 1.1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _TeamCard(
              index: index,
              isLargeScreen: isLargeScreen,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Regional Offices',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Responsive office layout
          isLargeScreen
              ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _OfficeCard(
              name: ['Nairobi Office', 'Mombasa Office', 'Kisumu Office', 'Nakuru Office'][index],
            ),
          )
              : Column(
            children: ['Nairobi Office', 'Mombasa Office', 'Kisumu Office', 'Nakuru Office']
                .map((office) => _OfficeCard(name: office))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCardsRow() {
    const cards = [
      _ContactCard(
        icon: Icons.location_on,
        title: 'Visit Us',
        items: ['Premisave Plaza', 'Nairobi, Kenya'],
        color: Colors.green,
      ),
      _ContactCard(
        icon: Icons.phone,
        title: 'Call Us',
        items: ['+254-700-123456', '24/7 Support'],
        color: Colors.blue,
      ),
      _ContactCard(
        icon: Icons.email,
        title: 'Email Us',
        items: ['info@premisave.co.ke', 'Quick Response'],
        color: Colors.orange,
      ),
      _ContactCard(
        icon: Icons.access_time,
        title: 'Hours',
        items: ['Mon-Fri: 8AM-6PM', 'Sat: 9AM-2PM'],
        color: Colors.purple,
      ),
    ];

    return Row(
      children: cards.map((card) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: card,
      ))).toList(),
    );
  }

  List<Widget> _buildContactCards() {
    return [
      _ContactCard(
        icon: Icons.location_on,
        title: 'Visit Us',
        items: [
          'Premisave Plaza, 123 Business District',
          'Nairobi, Kenya',
          'P.O. Box 12345-00100',
        ],
        color: Colors.green,
      ),
      const SizedBox(height: 16),
      _ContactCard(
        icon: Icons.phone,
        title: 'Call Us',
        items: [
          'Customer Service: +254-700-123456',
          'Technical Support: +254-700-654321',
        ],
        color: Colors.blue,
      ),
      const SizedBox(height: 16),
      _ContactCard(
        icon: Icons.email,
        title: 'Email Us',
        items: [
          'info@premisave.co.ke',
          'support@premisave.co.ke',
        ],
        color: Colors.orange,
      ),
      const SizedBox(height: 16),
      _ContactCard(
        icon: Icons.access_time,
        title: 'Hours',
        items: [
          'Mon-Fri: 8:00 AM - 6:00 PM',
          'Saturday: 9:00 AM - 2:00 PM',
        ],
        color: Colors.purple,
      ),
    ];
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(item, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final int index;
  final bool isLargeScreen;

  const _TeamCard({
    required this.index,
    required this.isLargeScreen,
  });

  final List<Map<String, dynamic>> team = const [
    {
      'name': 'John Mwangi',
      'role': 'Operations',
      'email': 'john@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    },
    {
      'name': 'Sarah Kimani',
      'role': 'Technical',
      'email': 'sarah@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
    },
    {
      'name': 'David Ochieng',
      'role': 'Support',
      'email': 'david@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    },
    {
      'name': 'Grace Wambui',
      'role': 'Finance',
      'email': 'grace@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final member = team[index];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isLargeScreen ? 24 : 30,
              backgroundImage: NetworkImage(member['image']),
            ),
            SizedBox(height: isLargeScreen ? 8 : 12),
            Text(
              member['name'],
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              member['role'],
              style: TextStyle(
                fontSize: isLargeScreen ? 12 : 13,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isLargeScreen ? 6 : 8),
            Text(
              member['email'],
              style: TextStyle(
                fontSize: isLargeScreen ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final String name;

  const _OfficeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business, color: Colors.green),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${name.split(' ')[0]} CBD'),
        trailing: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.green),
          onPressed: () {},
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}