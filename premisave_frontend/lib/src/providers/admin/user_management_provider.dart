import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/auth/user_model.dart';
import '../../services/secure_storage.dart';
import '../../utils/toast_utils.dart';

final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>(
      (ref) => UserManagementNotifier(),
);

class UserManagementState {
  final List<UserModel> users;
  final List<UserModel> filteredUsers;
  final UserModel? selectedUser;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final Map<String, bool> expandedUsers;

  UserManagementState({
    this.users = const [],
    this.filteredUsers = const [],
    this.selectedUser,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.expandedUsers = const {},
  });

  UserManagementState copyWith({
    List<UserModel>? users,
    List<UserModel>? filteredUsers,
    UserModel? selectedUser,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Map<String, bool>? expandedUsers,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedUsers: expandedUsers ?? this.expandedUsers,
    );
  }
}

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  UserManagementNotifier() : super(UserManagementState()) {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(
        '/admin/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<UserModel> users = (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      state = state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to load users';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
        if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied. Admin privileges required.';
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> refreshUsers() async {
    await _loadUsers();
  }

  Future<void> searchUsers(String query) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, searchQuery: query);
    try {
      final response = await _dio.post(
        '/admin/users/search',
        data: {'query': query},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<UserModel> users = (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      state = state.copyWith(
        filteredUsers: users,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Search failed';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        '/admin/users/create',
        data: userData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final UserModel newUser = UserModel.fromJson(response.data);

      // Add to users list
      final updatedUsers = List<UserModel>.from(state.users)..add(newUser);
      final updatedFiltered = List<UserModel>.from(state.filteredUsers)..add(newUser);

      ToastUtils.showSuccessToast('User created successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to create user';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
        if (e.response?.statusCode == 409) {
          errorMessage = 'User with this email already exists';
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put(
        '/admin/users/update/$userId',
        data: userData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final UserModel updatedUser = UserModel.fromJson(response.data);

      // Update in users list
      final updatedUsers = state.users.map((user) =>
      user.id == userId ? updatedUser : user
      ).toList();

      final updatedFiltered = state.filteredUsers.map((user) =>
      user.id == userId ? updatedUser : user
      ).toList();

      ToastUtils.showSuccessToast('User updated successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        selectedUser: state.selectedUser?.id == userId ? updatedUser : state.selectedUser,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to update user';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.put(
        '/admin/users/update-password/$userId',
        data: {'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      ToastUtils.showSuccessToast('Password updated successfully!');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to update password';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.delete(
        '/admin/users/delete/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Remove from lists
      final updatedUsers = state.users.where((user) => user.id != userId).toList();
      final updatedFiltered = state.filteredUsers.where((user) => user.id != userId).toList();

      ToastUtils.showSuccessToast('User deleted successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        selectedUser: state.selectedUser?.id == userId ? null : state.selectedUser,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to delete user';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> toggleUserStatus(String userId, bool activate) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final endpoint = activate ? '/admin/users/activate/$userId' : '/admin/users/deactivate/$userId';

      await _dio.put(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Update user status in lists
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(active: activate);
        }
        return user;
      }).toList();

      final updatedFiltered = state.filteredUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(active: activate);
        }
        return user;
      }).toList();

      ToastUtils.showSuccessToast(activate ? 'User activated successfully!' : 'User deactivated successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        selectedUser: state.selectedUser?.id == userId ?
        state.selectedUser!.copyWith(active: activate) : state.selectedUser,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to update user status';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> toggleVerification(String userId, bool verify) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final endpoint = verify ? '/admin/users/verify/$userId' : '/admin/users/unverify/$userId';

      await _dio.put(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Update user verification status in lists
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(verified: verify);
        }
        return user;
      }).toList();

      final updatedFiltered = state.filteredUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(verified: verify);
        }
        return user;
      }).toList();

      ToastUtils.showSuccessToast(verify ? 'User verified successfully!' : 'User unverified successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        selectedUser: state.selectedUser?.id == userId ?
        state.selectedUser!.copyWith(verified: verify) : state.selectedUser,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to update verification status';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> toggleArchive(String userId, bool archive) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final endpoint = archive ? '/admin/users/archive/$userId' : '/admin/users/unarchive/$userId';

      await _dio.put(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      ToastUtils.showSuccessToast(archive ? 'User archived successfully!' : 'User unarchived successfully!');

      // Refresh the list
      await refreshUsers();
    } catch (e) {
      String errorMessage = 'Failed to update archive status';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> changeUserRole(String userId, String role) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      ToastUtils.showErrorToast('Authentication required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.put(
        '/admin/users/change-role/$userId',
        data: {'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Parse the role enum
      final Role newRole = Role.values.firstWhere(
            (r) => r.name.toUpperCase() == role.toUpperCase(),
        orElse: () => Role.client,
      );

      // Update user role in lists
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(role: newRole);
        }
        return user;
      }).toList();

      final updatedFiltered = state.filteredUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(role: newRole);
        }
        return user;
      }).toList();

      ToastUtils.showSuccessToast('User role updated successfully!');

      state = state.copyWith(
        users: updatedUsers,
        filteredUsers: updatedFiltered,
        selectedUser: state.selectedUser?.id == userId ?
        state.selectedUser!.copyWith(role: newRole) : state.selectedUser,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Failed to change user role';

      if (e is DioException) {
        errorMessage = _getErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  void selectUser(UserModel? user) {
    state = state.copyWith(selectedUser: user);
  }

  void toggleUserExpansion(String userId) {
    final isExpanded = state.expandedUsers[userId] ?? false;
    final updatedExpanded = Map<String, bool>.from(state.expandedUsers)
      ..[userId] = !isExpanded;

    state = state.copyWith(expandedUsers: updatedExpanded);
  }

  void filterByRole(Role? role) {
    if (role == null) {
      state = state.copyWith(filteredUsers: state.users);
      return;
    }

    final filtered = state.users.where((user) => user.role == role).toList();
    state = state.copyWith(filteredUsers: filtered);
  }

  void filterByStatus(bool? active, bool? verified) {
    List<UserModel> filtered = state.users;

    if (active != null) {
      filtered = filtered.where((user) => user.active == active).toList();
    }

    if (verified != null) {
      filtered = filtered.where((user) => user.verified == verified).toList();
    }

    state = state.copyWith(filteredUsers: filtered);
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      switch (e.response!.statusCode) {
        case 400: return 'Invalid request. Please check your input.';
        case 401: return 'Unauthorized. Please login again.';
        case 403: return 'Access denied. Admin privileges required.';
        case 404: return 'User not found.';
        case 409: return 'Conflict with existing data.';
        case 422: return 'Validation failed.';
        case 500: return 'Server error. Please try again later.';
        default: return 'Something went wrong. Please try again.';
      }
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Network error. Please check your connection.';
    }

    return 'An unexpected error occurred.';
  }
}