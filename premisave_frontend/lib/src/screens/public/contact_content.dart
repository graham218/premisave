import 'package:flutter/material.dart';

class ContactContent extends StatelessWidget {
  const ContactContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
              'Emergency: +254-720-987654',
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
              'admin@premisave.co.ke',
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
              'Sunday & Holidays: Closed',
            ],
            color: Colors.purple,
          ),
          const SizedBox(height: 32),
          const Text(
            'Our Team',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _TeamCard(index: index),
          ),
          const SizedBox(height: 32),
          const Text(
            'Regional Offices',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...['Nairobi Office', 'Mombasa Office', 'Kisumu Office', 'Nakuru Office']
              .map((office) => _OfficeCard(name: office))
              .toList(),
        ],
      ),
    );
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final int index;

  const _TeamCard({required this.index});

  final List<Map<String, dynamic>> team = const [
    {
      'name': 'John Mwangi',
      'role': 'Operations Head',
      'email': 'john@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
    },
    {
      'name': 'Sarah Kimani',
      'role': 'Technical Manager',
      'email': 'sarah@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=300',
    },
    {
      'name': 'David Ochieng',
      'role': 'Support Lead',
      'email': 'david@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
    },
    {
      'name': 'Grace Wambui',
      'role': 'Finance Director',
      'email': 'grace@premisave.co.ke',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final member = team[index];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(member['image']),
            ),
            const SizedBox(height: 12),
            Text(
              member['name'],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              member['role'],
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              member['email'],
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
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