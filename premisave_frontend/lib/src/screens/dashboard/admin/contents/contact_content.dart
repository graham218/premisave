import 'package:flutter/material.dart';

class ContactContent extends StatelessWidget {
  const ContactContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 20),

            // Contact Information Cards
            _buildContactCard(
              Icons.location_on,
              'Premisave Headquarters',
              'Premisave Plaza\n123 Business District\nNairobi, Kenya\nP.O. Box 12345-00100',
            ),

            _buildContactCard(
              Icons.phone,
              'Phone Support',
              'Customer Service: +254-700-123456\nTechnical Support: +254-700-654321\nEmergency: +254-720-987654',
            ),

            _buildContactCard(
              Icons.email,
              'Email Addresses',
              'info@premisave.co.ke\nsupport@premisave.co.ke\ntechnical@premisave.co.ke\nadmin@premisave.co.ke',
            ),

            _buildContactCard(
              Icons.access_time,
              'Business Hours',
              'Monday - Friday: 8:00 AM - 6:00 PM\nSaturday: 9:00 AM - 2:00 PM\nSunday & Holidays: Closed',
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Team Contact'),
            const SizedBox(height: 16),

            // Team Contacts Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildTeamMemberCard(
                  'John Mwangi',
                  'Head of Operations',
                  '+254-723-456789',
                  'john@premisave.co.ke',
                  Colors.blue,
                ),
                _buildTeamMemberCard(
                  'Sarah Kimani',
                  'Technical Manager',
                  '+254-724-567890',
                  'sarah@premisave.co.ke',
                  Colors.green,
                ),
                _buildTeamMemberCard(
                  'David Ochieng',
                  'Customer Support Lead',
                  '+254-725-678901',
                  'david@premisave.co.ke',
                  Colors.orange,
                ),
                _buildTeamMemberCard(
                  'Grace Wambui',
                  'Finance Director',
                  '+254-726-789012',
                  'grace@premisave.co.ke',
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Regional Offices'),
            const SizedBox(height: 16),

            _buildBranchCard('Nairobi Office', 'Upper Hill, Nairobi CBD'),
            _buildBranchCard('Mombasa Office', 'Nyali, Mombasa'),
            _buildBranchCard('Kisumu Office', 'Milimani, Kisumu'),
            _buildBranchCard('Nakuru Office', 'CBD, Nakuru'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF004799),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004799),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(String name, String position, String phone, String email, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.split(' ').map((n) => n[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
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

  Widget _buildBranchCard(String title, String address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business, color: Color(0xFF0D47A1)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(address),
        trailing: IconButton(
          icon: const Icon(Icons.location_on, color: Color(0xFF0D47A1)),
          onPressed: () {},
        ),
      ),
    );
  }
}