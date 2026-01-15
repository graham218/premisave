import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../providers/admin/user_management_provider.dart';
import 'widgets/user-management/change_password_dialog.dart';
import 'widgets/user-management/change_role_dialog.dart';
import 'widgets/user-management/create_user_dialog.dart';
import 'widgets/user-management/delete_confirmation_dialog.dart';
import 'widgets/user-management/edit_user_dialog.dart';
import 'widgets/user-management/user_details_dialog.dart';

class AdminUserManagementContent extends ConsumerStatefulWidget {
  const AdminUserManagementContent({super.key});

  @override
  ConsumerState<AdminUserManagementContent> createState() => _AdminUserManagementContentState();
}

class _AdminUserManagementContentState extends ConsumerState<AdminUserManagementContent> {
  final TextEditingController searchController = TextEditingController();
  Role? selectedRoleFilter;
  bool? selectedActiveFilter;
  bool? selectedVerifiedFilter;

  // Timer for debouncing search
  Timer? _searchDebounceTimer;
  final Duration _searchDebounceDelay = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // Load users when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userManagementProvider.notifier).refreshUsers();
    });
  }

  @override
  void dispose() {
    // Cancel any pending timer
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged(String value) {
    // Cancel previous timer if it exists
    if (_searchDebounceTimer != null && _searchDebounceTimer!.isActive) {
      _searchDebounceTimer!.cancel();
    }

    // Start a new timer
    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      if (value.isEmpty) {
        // If search is empty, refresh to show all users
        ref.read(userManagementProvider.notifier).refreshUsers();
      } else {
        // Perform search with the current text
        ref.read(userManagementProvider.notifier).searchUsers(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userManagementState = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          // Filters Bar
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
            child: Column(
              children: [
                // Search Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search users...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              ref.read(userManagementProvider.notifier).refreshUsers();
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: _onSearchTextChanged,
                        onSubmitted: (value) {
                          // Cancel any pending debounce timer
                          _searchDebounceTimer?.cancel();
                          if (value.isEmpty) {
                            ref.read(userManagementProvider.notifier).refreshUsers();
                          } else {
                            ref.read(userManagementProvider.notifier).searchUsers(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Search',
                      child: ElevatedButton(
                        onPressed: () {
                          _searchDebounceTimer?.cancel();
                          ref.read(userManagementProvider.notifier).searchUsers(searchController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Search', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Refresh',
                      child: IconButton(
                        onPressed: () {
                          // Clear search and refresh
                          searchController.clear();
                          ref.read(userManagementProvider.notifier).refreshUsers();
                          // Clear filters
                          setState(() {
                            selectedRoleFilter = null;
                            selectedActiveFilter = null;
                            selectedVerifiedFilter = null;
                          });
                          userManagementNotifier.filterByStatus(null, null);
                          userManagementNotifier.filterByRole(null);
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),

                // Filter Chips Row
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Role Filters
                      FilterChip(
                        label: const Text('All Roles'),
                        selected: selectedRoleFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            selectedRoleFilter = null;
                          });
                          userManagementNotifier.filterByRole(null);
                        },
                      ),
                      ...Role.values.map((role) {
                        final roleName = role.name.replaceAll('_', ' ').toUpperCase();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(roleName),
                            selected: selectedRoleFilter == role,
                            onSelected: (selected) {
                              setState(() {
                                selectedRoleFilter = selected ? role : null;
                              });
                              userManagementNotifier.filterByRole(selectedRoleFilter);
                            },
                          ),
                        );
                      }).toList(),

                      const SizedBox(width: 16),

                      // Status Filters
                      FilterChip(
                        label: const Text('Active'),
                        selected: selectedActiveFilter == true,
                        onSelected: (selected) {
                          setState(() {
                            selectedActiveFilter = selected ? true : null;
                          });
                          userManagementNotifier.filterByStatus(selectedActiveFilter, selectedVerifiedFilter);
                        },
                      ),
                      FilterChip(
                        label: const Text('Inactive'),
                        selected: selectedActiveFilter == false,
                        onSelected: (selected) {
                          setState(() {
                            selectedActiveFilter = selected ? false : null;
                          });
                          userManagementNotifier.filterByStatus(selectedActiveFilter, selectedVerifiedFilter);
                        },
                      ),

                      const SizedBox(width: 8),

                      FilterChip(
                        label: const Text('Verified'),
                        selected: selectedVerifiedFilter == true,
                        onSelected: (selected) {
                          setState(() {
                            selectedVerifiedFilter = selected ? true : null;
                          });
                          userManagementNotifier.filterByStatus(selectedActiveFilter, selectedVerifiedFilter);
                        },
                      ),
                      FilterChip(
                        label: const Text('Unverified'),
                        selected: selectedVerifiedFilter == false,
                        onSelected: (selected) {
                          setState(() {
                            selectedVerifiedFilter = selected ? false : null;
                          });
                          userManagementNotifier.filterByStatus(selectedActiveFilter, selectedVerifiedFilter);
                        },
                      ),

                      // Clear Filters Button
                      if (selectedRoleFilter != null || selectedActiveFilter != null || selectedVerifiedFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedRoleFilter = null;
                                selectedActiveFilter = null;
                                selectedVerifiedFilter = null;
                              });
                              userManagementNotifier.filterByStatus(null, null);
                              userManagementNotifier.filterByRole(null);
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (userManagementState.isLoading)
            const LinearProgressIndicator(),

          // Error Message
          if (userManagementState.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userManagementState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(userManagementProvider.notifier).state =
                          userManagementState.copyWith(error: null);
                    },
                  ),
                ],
              ),
            ),

          // Search Status Indicator
          if (searchController.text.isNotEmpty && !userManagementState.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Searching for "${searchController.text}" • ${userManagementState.filteredUsers.length} results',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),

          // User List or Empty State
          Expanded(
            child: userManagementState.filteredUsers.isEmpty
                ? _buildEmptyState(userManagementState, searchController.text)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userManagementState.filteredUsers.length,
              itemBuilder: (context, index) {
                final user = userManagementState.filteredUsers[index];
                final isExpanded = userManagementState.expandedUsers[user.id] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // User Summary
                        ListTile(
                          onTap: () => userManagementNotifier.toggleUserExpansion(user.id),
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
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
                                      user.role.name.replaceAll('_', ' ').toUpperCase(),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                              ),
                              const SizedBox(width: 8),
                              _buildUserActionsMenu(userManagementNotifier, user),
                            ],
                          ),
                        ),

                        // Expanded Details
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  'User Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 8,
                                  children: [
                                    _buildDetailItem('Phone', user.phoneNumber),
                                    _buildDetailItem('Country', user.country),
                                    _buildDetailItem('Language', user.language),
                                    _buildDetailItem('Address 1', user.address1),
                                    _buildDetailItem('Address 2', user.address2),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => UserDetailsDialog(user: user),
                                        );
                                      },
                                      child: const Text('View Details'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditUserDialog(
                                            user: user,
                                            onSave: (updatedData) async {
                                              await userManagementNotifier.updateUser(user.id, updatedData);
                                            },
                                          ),
                                        );
                                      },
                                      child: const Text('Edit User'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => ChangePasswordDialog(
                                            userId: user.id,
                                            onSave: (newPassword) async {
                                              await userManagementNotifier.updatePassword(user.id, newPassword);
                                            },
                                          ),
                                        );
                                      },
                                      child: const Text('Change Password'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add User Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateUserDialog(
                    onCreate: (userData) async {
                      await userManagementNotifier.createUser(userData);
                    },
                  ),
                );
              },
              backgroundColor: const Color(0xFF0D47A1),
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(UserManagementState state, String searchQuery) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (searchQuery.isNotEmpty)
            Column(
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No users found for "$searchQuery"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try a different search term',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else
            Column(
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No users found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CreateUserDialog(
                        onCreate: (userData) async {
                          await ref.read(userManagementProvider.notifier).createUser(userData);
                        },
                      ),
                    );
                  },
                  child: const Text('Add First User'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'Not set',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildUserActionsMenu(UserManagementNotifier notifier, UserModel user) {
    return PopupMenuButton<String>(
      onSelected: (action) async {
        switch (action) {
          case 'activate':
            await notifier.toggleUserStatus(user.id, true);
            break;
          case 'deactivate':
            await notifier.toggleUserStatus(user.id, false);
            break;
          case 'verify':
            await notifier.toggleVerification(user.id, true);
            break;
          case 'unverify':
            await notifier.toggleVerification(user.id, false);
            break;
          case 'archive':
            await notifier.toggleArchive(user.id, true);
            break;
          case 'unarchive':
            await notifier.toggleArchive(user.id, false);
            break;
          case 'change_role':
            showDialog(
              context: context,
              builder: (context) => ChangeRoleDialog(
                user: user,
                onChange: (role) async {
                  await notifier.changeUserRole(user.id, role);
                },
              ),
            );
            break;
          case 'delete':
            showDialog(
              context: context,
              builder: (context) => DeleteConfirmationDialog(
                user: user,
                onConfirm: () async {
                  await notifier.deleteUser(user.id);
                },
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: user.active ? 'deactivate' : 'activate',
          child: Text(user.active ? 'Deactivate User' : 'Activate User'),
        ),
        PopupMenuItem(
          value: user.verified ? 'unverify' : 'verify',
          child: Text(user.verified ? 'Unverify Account' : 'Verify Account'),
        ),
        const PopupMenuItem(
          value: 'change_role',
          child: Text('Change Role'),
        ),
        const PopupMenuItem(
          value: 'archive',
          child: Text('Archive User'),
        ),
        const PopupMenuItem(
          value: 'unarchive',
          child: Text('Unarchive User'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete User', style: TextStyle(color: Colors.red)),
        ),
      ],
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