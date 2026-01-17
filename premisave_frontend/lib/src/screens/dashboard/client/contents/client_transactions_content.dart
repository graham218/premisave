import 'package:flutter/material.dart';

class ClientTransactionsContent extends StatelessWidget {
  const ClientTransactionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(),
          SizedBox(height: 24),
          _TransactionStats(),
          SizedBox(height: 24),
          _RecentTransactions(),
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
                  'Transactions',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'View all your payment history',
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
            child: const Icon(Icons.receipt_long, color: Colors.green, size: 30),
          ),
        ],
      ),
    );
  }
}

class _TransactionStats extends StatelessWidget {
  const _TransactionStats();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmall ? 2 : 3;

    final stats = [
      {'title': 'Total Spent', 'value': 'KES 450,000', 'color': Colors.green, 'icon': Icons.payments},
      {'title': 'This Month', 'value': 'KES 85,000', 'color': Colors.blue, 'icon': Icons.calendar_month},
      {'title': 'Pending', 'value': 'KES 25,000', 'color': Colors.orange, 'icon': Icons.pending},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stat['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Last 5 transactions',
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
              children: _transactions.map((txn) => _TransactionItem(transaction: txn)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download Statement'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  final List<Map<String, dynamic>> _transactions = const [
    {'id': '#TRX-001', 'property': 'Modern Apartment', 'date': '15 Dec 2024', 'amount': 'KES 42,500', 'status': 'Completed'},
    {'id': '#TRX-002', 'property': 'Luxury Villa', 'date': '10 Dec 2024', 'amount': 'KES 175,000', 'status': 'Completed'},
    {'id': '#TRX-003', 'property': 'Mountain Cabin', 'date': '5 Dec 2024', 'amount': 'KES 60,000', 'status': 'Pending'},
    {'id': '#TRX-004', 'property': 'City Studio', 'date': '28 Nov 2024', 'amount': 'KES 32,500', 'status': 'Completed'},
    {'id': '#TRX-005', 'property': 'Beach House', 'date': '15 Nov 2024', 'amount': 'KES 105,000', 'status': 'Refunded'},
  ];
}

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusInfo(transaction['status'] as String);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction['property'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(transaction['id'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(transaction['amount'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  transaction['status'] as String,
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
      case 'Completed':
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