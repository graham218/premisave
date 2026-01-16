import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth/auth_provider.dart';
import 'widgets/edit_profile_form.dart';
import 'widgets/profile_completion_bar.dart';
import 'widgets/user_avatar.dart';
import 'widgets/change_password_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isRefreshing = false;
  bool _isUploading = false;

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  Future<void> _pickImage() async {
    // Show image source options
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Handle permissions
    bool hasPermission = await _checkAndRequestPermission(source);
    if (!hasPermission) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        setState(() => _isUploading = true);

        // Show uploading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading profile picture...'),
              ],
            ),
          ),
        );

        try {
          await ref.read(authProvider.notifier).uploadProfilePicture(picked);
          if (context.mounted) {
            Navigator.pop(context); // Close loading dialog
            _refreshProfile();
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close loading dialog
            // Error is already shown by the provider
          }
        } finally {
          setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _checkAndRequestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      // Check camera permission
      PermissionStatus cameraStatus = await Permission.camera.status;

      if (cameraStatus.isPermanentlyDenied) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Permission Required'),
              content: const Text('Please enable camera permission in app settings to take photos.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return false;
      }

      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      }
    } else if (source == ImageSource.gallery) {
      // For gallery, permissions work differently on iOS and Android
      PermissionStatus photosStatus;

      // On iOS, use photos permission
      // On Android, use storage permission for older versions
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        photosStatus = await Permission.photos.status;

        if (photosStatus.isPermanentlyDenied) {
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Photo Library Permission Required'),
                content: const Text('Please enable photo library permission in app settings to choose photos.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
          return false;
        }

        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }
      } else {
        // For Android, check storage permission
        photosStatus = await Permission.storage.status;

        if (!photosStatus.isGranted) {
          photosStatus = await Permission.storage.request();
        }
      }

      if (!photosStatus.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission is required to access photos'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }

    return true;
  }

  double _calculateProfileCompletion(user) {
    int completedFields = 0;
    final fields = [
      user.username.isNotEmpty,
      user.firstName.isNotEmpty,
      user.lastName.isNotEmpty,
      user.phoneNumber.isNotEmpty,
      user.address1.isNotEmpty,
      user.address2.isNotEmpty,
      user.country.isNotEmpty,
      user.language.isNotEmpty,
      user.profilePictureUrl.isNotEmpty,
    ];
    completedFields = fields.where((field) => field).length;
    return (completedFields / fields.length) * 100;
  }

  void _showEditProfileDialog(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: EditProfileForm(
                  onSuccess: () {
                    Navigator.pop(context);
                    _refreshProfile();
                  },
                  initialData: {
                    'username': user.username,
                    'firstName': user.firstName,
                    'middleName': user.middleName,
                    'lastName': user.lastName,
                    'phoneNumber': user.phoneNumber,
                    'address1': user.address1,
                    'address2': user.address2,
                    'country': user.country,
                    'language': user.language,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: _isRefreshing || _isUploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: (_isRefreshing || _isUploading) ? null : _refreshProfile,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).confirmLogout(context),
          ),
        ],
      ),
      body: user == null
          ? _buildShimmerLoader()
          : RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
          child: Column(
            children: [
              _buildHeroSection(user, theme, isLargeScreen),
              const SizedBox(height: 24),
              _buildCompletionCard(user, theme),
              const SizedBox(height: 20),
              _buildActionCards(context, user, theme),
              const SizedBox(height: 20),
              _buildQuickActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(user, ThemeData theme, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 28 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.08), blurRadius: 24)],
      ),
      child: Column(children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.background,
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 16)],
              ),
              child: UserAvatar(
                imageUrl: user.profilePictureUrl.isNotEmpty ? user.profilePictureUrl : null,
                radius: isLargeScreen ? 70 : 56,
                onTap: _isUploading ? null : _pickImage,
              ),
            ),
            if (!_isUploading)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8)],
                  ),
                  child: Icon(Icons.edit_rounded, color: theme.colorScheme.onPrimary, size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(fontSize: isLargeScreen ? 24 : 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        if (user.username.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('@${user.username}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            _buildContactRow(Icons.email_rounded, user.email, theme, true),
            if (user.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildContactRow(Icons.phone_rounded, user.phoneNumber, theme, false),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildContactRow(IconData icon, String text, ThemeData theme, bool primary) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 18, color: primary ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 10),
      Flexible(child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: primary ? FontWeight.w500 : FontWeight.w400))),
    ]);
  }

  Widget _buildCompletionCard(user, ThemeData theme) {
    final completionPercentage = _calculateProfileCompletion(user);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Profile Completion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            ProfileCompletionBar(percentage: completionPercentage),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${completionPercentage.toInt()}% Complete', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                if (completionPercentage < 100)
                  TextButton(
                    onPressed: () => _showEditProfileDialog(context, user),
                    child: const Text('Complete Profile'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, user, ThemeData theme) {
    return Column(
      children: [
        _buildActionCard(
          title: 'Edit Profile',
          subtitle: 'Update personal information',
          icon: Icons.person_rounded,
          color: theme.colorScheme.primary,
          onTap: () => _showEditProfileDialog(context, user),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Change Password',
          subtitle: 'Update security credentials',
          icon: Icons.lock_rounded,
          color: const Color(0xFFF57C00),
          onTap: () => _showChangePasswordDialog(context),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton(icon: Icons.share_rounded, label: 'Share Profile', color: theme.colorScheme.primary, onTap: () => _showComingSoon(context, 'Share Profile')),
            _buildQuickActionButton(icon: Icons.qr_code_rounded, label: 'QR Code', color: const Color(0xFF7B1FA2), onTap: () => _showComingSoon(context, 'QR Code')),
            _buildQuickActionButton(icon: Icons.help_rounded, label: 'Support', color: const Color(0xFFF57C00), onTap: () => _showComingSoon(context, 'Support')),
            _buildQuickActionButton(icon: Icons.history_rounded, label: 'Activity', color: const Color(0xFF388E3C), onTap: () => _showComingSoon(context, 'Activity')),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }
}