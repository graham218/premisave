import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/auth/auth_provider.dart';

class AdminUserManagementContent extends ConsumerStatefulWidget {
  const AdminUserManagementContent({super.key});

  @override
  ConsumerState<AdminUserManagementContent> createState() => _AdminUserManagementContentState();
}

class _AdminUserManagementContentState extends ConsumerState<AdminUserManagementContent> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by name, email, or phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) {
                      authNotifier.searchUsers(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => authNotifier.searchUsers(searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Search', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: authState.searchedUsers.length,
              itemBuilder: (context, index) {
                final user = authState.searchedUsers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.firstName.isNotEmpty && user.lastName.isNotEmpty
                                ? '${user.firstName[0]}${user.lastName[0]}'
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${user.email} • ${user.username}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role.name),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.role.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.active ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.active ? 'ACTIVE' : 'INACTIVE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.verified ? Colors.blue : Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.verified ? 'VERIFIED' : 'UNVERIFIED',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                          const PopupMenuItem(value: 'activate', child: Text('Activate User')),
                          const PopupMenuItem(value: 'deactivate', child: Text('Deactivate User')),
                          const PopupMenuItem(value: 'verify', child: Text('Verify Account')),
                          const PopupMenuItem(value: 'unverify', child: Text('Unverify Account')),
                          const PopupMenuItem(value: 'archive', child: Text('Archive User')),
                          const PopupMenuItem(value: 'unarchive', child: Text('Unarchive User')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.red))),
                        ],
                      ),
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'client':
        return Colors.green;
      case 'home_owner':
        return Colors.blue;
      case 'operations':
        return Colors.orange;
      case 'finance':
        return Colors.purple;
      case 'support':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}