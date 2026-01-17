import 'package:flutter/material.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSection(),
          const SizedBox(height: 32),
          isLargeScreen ? const _MissionVisionRow() : const _MissionVisionColumn(),
          const SizedBox(height: 32),
          _TeamSection(isLargeScreen: isLargeScreen, isMediumScreen: isMediumScreen),
          const SizedBox(height: 32),
          _CoreValuesSection(isLargeScreen: isLargeScreen, isMediumScreen: isMediumScreen),
          const SizedBox(height: 32),
          const _ContactSection(),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400&auto=format&fit=crop',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Premisave',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revolutionizing Real Estate in Kenya',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Premisave connects property owners, buyers, and service providers through innovative technology.',
            style: TextStyle(fontSize: 16, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MissionVisionRow extends StatelessWidget {
  const _MissionVisionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _MissionVisionCard(
          icon: Icons.flag,
          title: 'Our Mission',
          content: 'To revolutionize real estate in Kenya with secure, transparent, and efficient digital solutions.',
          color: Colors.green,
        )),
        SizedBox(width: 20),
        Expanded(child: _MissionVisionCard(
          icon: Icons.visibility,
          title: 'Our Vision',
          content: 'To become East Africa\'s leading real estate platform, transforming property management.',
          color: Colors.blue,
        )),
      ],
    );
  }
}

class _MissionVisionColumn extends StatelessWidget {
  const _MissionVisionColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _MissionVisionCard(
          icon: Icons.flag,
          title: 'Our Mission',
          content: 'To revolutionize real estate in Kenya with secure, transparent, and efficient digital solutions.',
          color: Colors.green,
        ),
        SizedBox(height: 20),
        _MissionVisionCard(
          icon: Icons.visibility,
          title: 'Our Vision',
          content: 'To become East Africa\'s leading real estate platform, transforming property management.',
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _MissionVisionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _MissionVisionCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final bool isLargeScreen;
  final bool isMediumScreen;

  const _TeamSection({
    required this.isLargeScreen,
    required this.isMediumScreen,
  });

  final List<Map<String, dynamic>> teamMembers = const [
    {
      'name': 'James Maina',
      'role': 'CEO',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w-200',
    },
    {
      'name': 'Grace Nyong\'o',
      'role': 'CFO',
      'image': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w-200',
    },
    {
      'name': 'Peter Kariuki',
      'role': 'CTO',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w-200',
    },
    {
      'name': 'Lucy Wambui',
      'role': 'Operations',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w-200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meet Our Team',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Experts driving innovation in real estate',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 3 : 2),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isLargeScreen ? 0.85 : 0.9,
          ),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) => _TeamMemberCard(
            member: teamMembers[index],
            isLargeScreen: isLargeScreen,
          ),
        ),
      ],
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isLargeScreen;

  const _TeamMemberCard({
    required this.member,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 20),
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
              radius: isLargeScreen ? 35 : 50,
              backgroundImage: NetworkImage(member['image']),
            ),
            SizedBox(height: isLargeScreen ? 12 : 16),
            Text(
              member['name'],
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 18,
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
                fontSize: isLargeScreen ? 13 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoreValuesSection extends StatelessWidget {
  final bool isLargeScreen;
  final bool isMediumScreen;

  const _CoreValuesSection({
    required this.isLargeScreen,
    required this.isMediumScreen,
  });

  final List<Map<String, dynamic>> values = const [
    {
      'icon': Icons.verified,
      'title': 'Integrity',
      'description': 'Honesty and transparency in all dealings',
      'color': Colors.green,
    },
    {
      'icon': Icons.lightbulb,
      'title': 'Innovation',
      'description': 'Creating better solutions with technology',
      'color': Colors.blue,
    },
    {
      'icon': Icons.people,
      'title': 'Customer Focus',
      'description': 'Our customers are at the heart of everything',
      'color': Colors.orange,
    },
    {
      'icon': Icons.star,
      'title': 'Excellence',
      'description': 'Highest standards in service delivery',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Core Values',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'The principles that guide our work',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 2 : 1),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isLargeScreen ? 0.9 : 1.2,
          ),
          itemCount: values.length,
          itemBuilder: (context, index) => _ValueCard(
            value: values[index],
            isLargeScreen: isLargeScreen,
          ),
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  final Map<String, dynamic> value;
  final bool isLargeScreen;

  const _ValueCard({
    required this.value,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [value['color'].withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isLargeScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: value['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value['icon'],
                size: isLargeScreen ? 24 : 28,
                color: value['color'],
              ),
            ),
            SizedBox(height: isLargeScreen ? 12 : 16),
            Text(
              value['title'],
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: value['color'],
              ),
            ),
            SizedBox(height: isLargeScreen ? 6 : 8),
            Text(
              value['description'],
              style: TextStyle(
                fontSize: isLargeScreen ? 13 : 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'d love to hear from you',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const _ContactInfo(
            icon: Icons.email,
            title: 'Email',
            value: 'contact@premisave.co.ke',
          ),
          const SizedBox(height: 16),
          const _ContactInfo(
            icon: Icons.phone,
            title: 'Phone',
            value: '+254 700 123 456',
          ),
          const SizedBox(height: 16),
          const _ContactInfo(
            icon: Icons.location_on,
            title: 'Address',
            value: 'Nairobi, Kenya',
          ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}