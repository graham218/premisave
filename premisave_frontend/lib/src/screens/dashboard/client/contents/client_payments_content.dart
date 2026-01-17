import 'package:flutter/material.dart';

class ClientPaymentsContent extends StatelessWidget {
  const ClientPaymentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSection(),
          const SizedBox(height: 24),
          const _PaymentMethods(),
          const SizedBox(height: 24),
          const _RecentPayments(),
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
                  'Payments',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your payment methods and history',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
            child: const Icon(Icons.credit_card, color: Colors.green, size: 30),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods();

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'name': 'M-Pesa', 'icon': Icons.phone_android, 'color': Colors.green, 'last4': '0721'},
      {'name': 'Visa', 'icon': Icons.credit_card, 'color': Colors.blue, 'last4': '4321'},
      {'name': 'MasterCard', 'icon': Icons.credit_card, 'color': Colors.orange, 'last4': '8765'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...methods.map((method) {
          final color = method['color'] as Color;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(method['icon'] as IconData, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '•••• ${method['last4']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Payment Method'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _RecentPayments extends StatelessWidget {
  const _RecentPayments();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Payments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
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
              children: _payments.map((payment) => _PaymentItem(payment: payment)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  final List<Map<String, dynamic>> _payments = const [
    {'date': '15 Dec 2024', 'amount': 'KES 42,500', 'method': 'M-Pesa', 'status': 'Paid'},
    {'date': '10 Dec 2024', 'amount': 'KES 175,000', 'method': 'Visa', 'status': 'Paid'},
    {'date': '5 Dec 2024', 'amount': 'KES 25,000', 'method': 'M-Pesa', 'status': 'Pending'},
    {'date': '28 Nov 2024', 'amount': 'KES 32,500', 'method': 'M-Pesa', 'status': 'Paid'},
    {'date': '15 Nov 2024', 'amount': 'KES 105,000', 'method': 'MasterCard', 'status': 'Refunded'},
  ];
}

class _PaymentItem extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusInfo(payment['status'] as String);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['date'] as String,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  payment['method'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment['amount'] as String,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  payment['status'] as String,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color color, IconData icon) _getStatusInfo(String status) {
    switch (status) {
      case 'Paid':
        return (Colors.green, Icons.check_circle);
      case 'Pending':
        return (Colors.orange, Icons.pending);
      case 'Refunded':
        return (Colors.red, Icons.reply);
      default:
        return (Colors.grey, Icons.help);
    }
  }
}