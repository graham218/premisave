import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:premisave_flutter/src/models/auth/user_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
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
  late Animation<Color?> _colorAnimation;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isRefreshing = false;

  final usernameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final languageCtrl = TextEditingController();

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

    _colorAnimation = ColorTween(
      begin: const Color(0xFFE3F2FD),
      end: const Color(0xFF1976D2),
    ).animate(_animationController);

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    if (authState.currentUser != null) {
      final user = authState.currentUser!;

      setState(() {
        usernameCtrl.text = user.username;
        firstNameCtrl.text = user.firstName;
        middleNameCtrl.text = user.middleName;
        lastNameCtrl.text = user.lastName;
        phoneCtrl.text = user.phoneNumber;
        address1Ctrl.text = user.address1;
        address2Ctrl.text = user.address2;
        countryCtrl.text = user.country;
        languageCtrl.text = user.language;
      });
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _loadUserData();
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

  double _calculateProfileCompletion() {
    final user = ref.read(authProvider).currentUser;
    if (user == null) return 0.0;

    int completedFields = 0;
    int totalFields = 9; // username, firstName, lastName, phone, address1, address2, country, language, profilePicture

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

  String? _getProfileImageUrl() {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    if (user != null && user.profilePictureUrl.isNotEmpty) {
      return user.profilePictureUrl;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameCtrl.dispose();
    firstNameCtrl.dispose();
    middleNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    countryCtrl.dispose();
    languageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;
    final isMediumScreen = screenSize.width > 480;
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
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
            onPressed: () => authNotifier.confirmLogout(context),
          ),
        ],
      ),
      body: user == null
          ? _buildShimmerLoader(isLargeScreen, isMediumScreen)
          : RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
          child: Column(
            children: [
              _buildHeroSection(user, theme, isLargeScreen, isMediumScreen),
              const SizedBox(height: 24),
              _buildCompletionCard(user, theme),
              const SizedBox(height: 20),
              _buildPersonalInfoCard(user, theme),
              const SizedBox(height: 20),
              _buildActionCards(context, theme, isLargeScreen),
              const SizedBox(height: 20),
              _buildQuickActions(theme, isLargeScreen),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(UserModel user, ThemeData theme, bool isLargeScreen, bool isMediumScreen) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: UserAvatar(
                    imageUrl: _getProfileImageUrl(),
                    radius: isLargeScreen ? 70 : (isMediumScreen ? 60 : 50),
                    onTap: _pickImage,
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Icon(Icons.edit_rounded, color: Colors.white, size: isLargeScreen ? 20 : 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user.username.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '@${user.username}',
                        style: TextStyle(fontSize: isLargeScreen ? 16 : 14, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_rounded, color: Colors.white.withValues(alpha: 0.8), size: isLargeScreen ? 18 : 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user.email,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: isLargeScreen ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (user.phoneNumber.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, color: Colors.white.withValues(alpha: 0.8), size: isLargeScreen ? 16 : 14),
                          const SizedBox(width: 6),
                          Text(
                            user.phoneNumber,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: isLargeScreen ? 14 : 12),
                          ),
                        ],
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

  Widget _buildCompletionCard(UserModel user, ThemeData theme) {
    final completionPercentage = _calculateProfileCompletion();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Card(
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.cardColor, _colorAnimation.value!.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
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
                        Text(
                          'Profile Completion',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProfileCompletionBar(percentage: completionPercentage),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${completionPercentage.toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (completionPercentage < 100)
                          TextButton(
                            onPressed: () => _showEditProfileDialog(context),
                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                            child: const Text('Complete Profile'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserModel user, ThemeData theme) {
    final personalInfo = [
      _buildInfoItem('Phone Number', user.phoneNumber, Icons.phone_rounded, theme),
      _buildInfoItem('Address Line 1', user.address1, Icons.home_rounded, theme),
      if (user.address2.isNotEmpty) _buildInfoItem('Address Line 2', user.address2, Icons.home_rounded, theme),
      _buildInfoItem('Country', user.country, Icons.location_on_rounded, theme),
      _buildInfoItem('Language', user.language, Icons.language_rounded, theme),
    ].where((item) => item != null).cast<Widget>().toList();

    if (personalInfo.isEmpty) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 6,
        shadowColor: theme.shadowColor.withValues(alpha: 0.1),
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
                  Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...personalInfo,
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildInfoItem(String label, String? value, IconData icon, ThemeData theme) {
    if (value == null || value.isEmpty) return null;
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

  Widget _buildActionCards(BuildContext context, ThemeData theme, bool isLargeScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildActionCard(
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            icon: Icons.person_rounded,
            color: theme.colorScheme.primary,
            onTap: () => _showEditProfileDialog(context),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            icon: Icons.lock_rounded,
            color: const Color(0xFFF57C00),
            onTap: () => _showChangePasswordDialog(context),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Settings',
            subtitle: 'App preferences and configuration',
            icon: Icons.settings_rounded,
            color: const Color(0xFF388E3C),
            onTap: () => context.go('/settings'),
            theme: theme,
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
    required ThemeData theme,
  }) {
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

  Widget _buildQuickActions(ThemeData theme, bool isLargeScreen) {
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
              _buildQuickActionButton(icon: Icons.share_rounded, label: 'Share Profile', color: theme.colorScheme.primary, onTap: () => _showComingSoon(context, 'Share Profile'), theme: theme),
              _buildQuickActionButton(icon: Icons.qr_code_rounded, label: 'QR Code', color: const Color(0xFF7B1FA2), onTap: () => _showComingSoon(context, 'QR Code'), theme: theme),
              _buildQuickActionButton(icon: Icons.help_rounded, label: 'Support', color: const Color(0xFFF57C00), onTap: () => context.go('/support'), theme: theme),
              _buildQuickActionButton(icon: Icons.history_rounded, label: 'Activity', color: const Color(0xFF388E3C), onTap: () => context.go('/activity'), theme: theme),
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
    required ThemeData theme,
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

  Widget _buildShimmerLoader(bool isLargeScreen, bool isMediumScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16, vertical: 16),
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

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: usernameCtrl,
                label: 'Username',
                hintText: 'Enter username',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: firstNameCtrl,
                label: 'First Name',
                hintText: 'Enter first name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: middleNameCtrl,
                label: 'Middle Name',
                hintText: 'Optional',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lastNameCtrl,
                label: 'Last Name',
                hintText: 'Enter last name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: phoneCtrl,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: address1Ctrl,
                label: 'Address Line 1',
                hintText: 'Enter address',
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: address2Ctrl,
                label: 'Address Line 2',
                hintText: 'Optional',
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: countryCtrl,
                label: 'Country',
                hintText: 'Enter country',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: languageCtrl,
                label: 'Language',
                hintText: 'e.g. English',
                prefixIcon: const Icon(Icons.language_outlined),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authNotifier = ref.read(authProvider.notifier);
              final data = {
                'username': usernameCtrl.text.trim(),
                'firstName': firstNameCtrl.text.trim(),
                'middleName': middleNameCtrl.text.trim(),
                'lastName': lastNameCtrl.text.trim(),
                'phoneNumber': phoneCtrl.text.trim(),
                'address1': address1Ctrl.text.trim(),
                'address2': address2Ctrl.text.trim(),
                'country': countryCtrl.text.trim(),
                'language': languageCtrl.text.trim(),
              };
              authNotifier.updateProfile(data);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final theme = Theme.of(context);

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
                  Icon(Icons.lock_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: oldPasswordCtrl,
                label: 'Current Password',
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: newPasswordCtrl,
                label: 'New Password',
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: confirmPasswordCtrl,
                label: 'Confirm New Password',
                theme: theme,
                validator: (value) => value != newPasswordCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final authNotifier = ref.read(authProvider.notifier);
                        authNotifier.changePassword(
                          oldPasswordCtrl.text.trim(),
                          newPasswordCtrl.text.trim(),
                          confirmPasswordCtrl.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature functionality coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}