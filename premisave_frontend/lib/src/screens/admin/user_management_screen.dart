import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name, email, or phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => authNotifier.searchUsers(searchController.text),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: authState.searchedUsers.length,
              itemBuilder: (context, index) {
                final user = authState.searchedUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text('${user.firstName} ${user.lastName} (${user.username})'),
                    subtitle: Text('${user.email}\nRole: ${user.role.name.toUpperCase()} | ${user.active ? 'Active' : 'Inactive'} | ${user.verified ? 'Verified' : 'Unverified'}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        switch (action) {
                          case 'delete':
                            await authNotifier.adminAction('delete', user.id);
                            break;
                          case 'archive':
                            await authNotifier.adminAction('archive', user.id);
                            break;
                          case 'unarchive':
                            await authNotifier.adminAction('unarchive', user.id);
                            break;
                          case 'activate':
                            await authNotifier.adminAction('activate', user.id);
                            break;
                          case 'deactivate':
                            await authNotifier.adminAction('deactivate', user.id);
                            break;
                          case 'verify':
                            await authNotifier.adminAction('verify', user.id);
                            break;
                          case 'unverify':
                            await authNotifier.adminAction('unverify', user.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        const PopupMenuItem(value: 'archive', child: Text('Archive')),
                        const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
                        const PopupMenuItem(value: 'activate', child: Text('Activate')),
                        const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                        const PopupMenuItem(value: 'verify', child: Text('Verify')),
                        const PopupMenuItem(value: 'unverify', child: Text('Unverify')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}