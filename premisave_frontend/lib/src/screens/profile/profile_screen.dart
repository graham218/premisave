import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:premisave_flutter/src/models/auth/user_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth/auth_provider.dart';
import 'widgets/edit_profile_form.dart';
import 'widgets/profile_completion_bar.dart';
import 'widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      final url = await ref.read(authProvider.notifier).uploadProfilePicture(picked);
      if (url != null) {
        _refreshProfile();
      }
    }
  }

  double _calculateProfileCompletion(UserModel user) {
    int completedFields = 0;
    int totalFields = 9;

    if (user.username.isNotEmpty) completedFields++;
    if (user.firstName.isNotEmpty) completedFields++;
    if (user.lastName.isNotEmpty) completedFields++;
    if (user.phoneNumber.isNotEmpty) completedFields++;
    if (user.address1.isNotEmpty) completedFields++;
    if (user.address2.isNotEmpty) completedFields++;
    if (user.country.isNotEmpty) completedFields++;
    if (user.language.isNotEmpty) completedFields++;
    if (user.profilePictureUrl.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  String? _getProfileImageUrl(UserModel user) {
    return user.profilePictureUrl.isNotEmpty ? user.profilePictureUrl : null;
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPasswordField(label: 'Current Password'),
              const SizedBox(height: 16),
              _buildPasswordField(label: 'New Password'),
              const SizedBox(height: 16),
              _buildPasswordField(label: 'Confirm New Password'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required String label}) {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            icon: _isRefreshing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshProfile,
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
              _buildPersonalInfoCard(user, theme),
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

  Widget _buildHeroSection(UserModel user, ThemeData theme, bool isLargeScreen) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 28 : 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.08), blurRadius: 24),
          ],
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.background,
                    boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 16)],
                  ),
                  child: UserAvatar(
                    imageUrl: _getProfileImageUrl(user),
                    radius: isLargeScreen ? 70 : 56,
                    onTap: _pickImage,
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8)],
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
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
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
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, ThemeData theme, bool primary) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 18, color: primary ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 10),
      Flexible(child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: primary ? FontWeight.w500 : FontWeight.w400))),
    ]);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required ThemeData theme,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPrimary
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isPrimary
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(UserModel user, ThemeData theme) {
    final completionPercentage = _calculateProfileCompletion(user);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
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
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserModel user, ThemeData theme) {
    final infoItems = [
      if (user.phoneNumber.isNotEmpty) _buildInfoItem('Phone', user.phoneNumber, Icons.phone_rounded, theme),
      if (user.address1.isNotEmpty) _buildInfoItem('Address', user.address1, Icons.home_rounded, theme),
      if (user.country.isNotEmpty) _buildInfoItem('Country', user.country, Icons.location_on_rounded, theme),
      if (user.language.isNotEmpty) _buildInfoItem('Language', user.language, Icons.language_rounded, theme),
    ];

    if (infoItems.isEmpty) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 16),
              ...infoItems,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, UserModel user, ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Settings',
            subtitle: 'App preferences',
            icon: Icons.settings_rounded,
            color: const Color(0xFF388E3C),
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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
              _buildQuickActionButton(icon: Icons.help_rounded, label: 'Support', color: const Color(0xFFF57C00), onTap: () => context.go('/support')),
              _buildQuickActionButton(icon: Icons.history_rounded, label: 'Activity', color: const Color(0xFF388E3C), onTap: () => context.go('/activity')),
            ],
          ),
        ],
      ),
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