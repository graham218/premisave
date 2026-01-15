import 'package:flutter/material.dart';

class AboutContent extends StatefulWidget {
  const AboutContent({super.key});

  @override
  State<AboutContent> createState() => _AdminAboutContentState();
}

class _AdminAboutContentState extends State<AboutContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF0D47A1),
              tabs: const [
                Tab(text: 'About Premisave'),
                Tab(text: 'Management Team'),
                Tab(text: 'Mission & Vision'),
                Tab(text: 'Core Values'),
                Tab(text: 'Privacy Policy'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AboutPremisaveTab(),
                ManagementTeamTab(),
                MissionVisionTab(),
                CoreValuesTab(),
                PrivacyPolicyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPremisaveTab extends StatelessWidget {
  const AboutPremisaveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.business, color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About Premisave',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004799),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Premisave is a revolutionary real estate platform that connects property owners, buyers, and service providers in Kenya\'s growing real estate market. Founded in 2020, we have rapidly grown to become one of the most trusted names in the industry.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Our platform leverages cutting-edge technology to streamline property transactions, provide secure payment solutions, and offer comprehensive property management services. We are committed to transparency, security, and excellence in every interaction.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('1,250+', 'Active Users'),
                      _buildStatItem('840+', 'Properties Listed'),
                      _buildStatItem('KES 2.5B+', 'Transactions'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004799),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class ManagementTeamTab extends StatelessWidget {
  const ManagementTeamTab({super.key});

  @override
  Widget build(BuildContext context) {
    final managementTeam = [
      {'name': 'Dr. James Maina', 'position': 'Chief Executive Officer'},
      {'name': 'Grace Nyong\'o', 'position': 'Chief Financial Officer'},
      {'name': 'Peter Kariuki', 'position': 'Chief Technology Officer'},
      {'name': 'Lucy Wambui', 'position': 'Head of Operations'},
      {'name': 'Robert Omondi', 'position': 'Sales Director'},
      {'name': 'Susan Chebet', 'position': 'Marketing Director'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: managementTeam.length,
      itemBuilder: (context, index) {
        final member = managementTeam[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D47A1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member['name']!.split(' ').map((n) => n[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  member['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF004799),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  member['position']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MissionVisionTab extends StatelessWidget {
  const MissionVisionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.flag, color: Colors.white, size: 40),
                        SizedBox(height: 16),
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'To revolutionize real estate transactions in Kenya by providing a secure, transparent, and efficient platform that empowers property owners, buyers, and service providers.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.visibility, color: Colors.green, size: 40),
                        SizedBox(height: 16),
                        Text(
                          'Our Vision',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'To become East Africa\'s leading real estate platform, transforming how people buy, sell, and manage properties while driving sustainable growth in the real estate sector.',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoreValuesTab extends StatelessWidget {
  const CoreValuesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final coreValues = [
      {
        'title': 'Integrity',
        'description': 'We conduct our business with honesty and transparency',
        'icon': Icons.verified,
        'color': Colors.blue,
      },
      {
        'title': 'Innovation',
        'description': 'We embrace technology to create better solutions',
        'icon': Icons.lightbulb,
        'color': Colors.green,
      },
      {
        'title': 'Customer Focus',
        'description': 'Our customers are at the heart of everything we do',
        'icon': Icons.people,
        'color': Colors.orange,
      },
      {
        'title': 'Excellence',
        'description': 'We strive for the highest standards in service delivery',
        'icon': Icons.star,
        'color': Colors.purple,
      },
      {
        'title': 'Teamwork',
        'description': 'We collaborate to achieve common goals',
        'icon': Icons.group,
        'color': Colors.teal,
      },
      {
        'title': 'Sustainability',
        'description': 'We build for the long-term benefit of all stakeholders',
        'icon': Icons.eco,
        'color': Colors.green,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coreValues.length,
      itemBuilder: (context, index) {
        final value = coreValues[index];

        // Add null safety checks
        final color = value['color'] as Color?;
        final icon = value['icon'] as IconData?;
        final title = value['title'] as String?;
        final description = value['description'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (color ?? Colors.blue).withOpacity(0.2),
                        (color ?? Colors.blue).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? Icons.help_outline, // Fallback icon
                    color: color ?? Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'No Title', // Fallback text
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color ?? Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description ?? 'No description available', // Fallback text
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PrivacyPolicyTab extends StatelessWidget {
  const PrivacyPolicyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004799),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    'Information We Collect',
                    'We collect personal information necessary for service provision including contact details, property information, transaction history, and usage data. This information is used to provide you with personalized services and improve your experience.',
                  ),
                  _buildPolicySection(
                    'How We Use Your Information',
                    'Your information is used for service delivery, transaction processing, customer support, regulatory compliance, security, and service improvement. We do not sell your personal information to third parties.',
                  ),
                  _buildPolicySection(
                    'Data Security',
                    'We implement robust security measures including SSL encryption, secure servers, access controls, and regular security audits to protect your personal information from unauthorized access or disclosure.',
                  ),
                  _buildPolicySection(
                    'Your Rights',
                    'You have the right to access, correct, or delete your personal information. You can also opt-out of marketing communications and request data portability. Contact our support team for assistance.',
                  ),
                  _buildPolicySection(
                    'Updates to This Policy',
                    'We may update this privacy policy from time to time. We will notify you of significant changes through our platform or via email. Continued use of our services constitutes acceptance of the updated policy.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF004799),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              height: 1.6,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}