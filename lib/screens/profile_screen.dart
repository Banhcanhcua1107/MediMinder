import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'personal_info_screen.dart';
import '../widgets/custom_toast.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../services/google_signin_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _userName = 'User';
  String _userEmail = 'email@example.com';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && mounted) {
        String name =
            user.userMetadata?['full_name'] ??
            user.email?.split('@').first ??
            'User';
        String email = user.email ?? 'email@example.com';

        String? avatarUrl;
        try {
          final userService = UserService();
          final userId = user.id;
          final userInfo = await userService.getUserInfo(userId);
          if (userInfo != null) {
            avatarUrl = userInfo['avatar_url'];
            name = userInfo['full_name'] ?? name;
            email = userInfo['email'] ?? email;
          }
        } catch (e) {
          debugPrint('⚠️ Error loading user from DB: $e');
        }

        if (mounted) {
          setState(() {
            _userName = name;
            _userEmail = email;
            _avatarUrl = avatarUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user info: $e');
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                    title: Text(l10n.vietnamese),
                    trailing: languageProvider.locale.languageCode == 'vi'
                        ? const Icon(Icons.check, color: kPrimaryColor)
                        : null,
                    onTap: () {
                      languageProvider.setLocale(const Locale('vi'));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                    title: Text(l10n.english),
                    trailing: languageProvider.locale.languageCode == 'en'
                        ? const Icon(Icons.check, color: kPrimaryColor)
                        : null,
                    onTap: () {
                      languageProvider.setLocale(const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.locale.languageCode == 'vi'
        ? l10n.vietnamese
        : l10n.english;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: 120,
          ),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Column(
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        color: kSecondaryTextColor,
                                        size: 32,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: kSecondaryTextColor,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chevron
                        const Icon(
                          Icons.chevron_right,
                          color: kSecondaryTextColor,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Section
                _buildSectionHeader(l10n.account),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildMenuItem(
                    icon: Icons.shield,
                    title: l10n.security,
                    isFirst: true,
                    isLast: true,
                  ),
                ),
                const SizedBox(height: 24),

                // General Settings Section
                _buildSectionHeader(l10n.generalSettings),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.notifications,
                        title: l10n.notifications,
                        isFirst: true,
                      ),
                      _buildDarkModeToggle(l10n.darkMode),
                      _buildMenuItemWithTrailing(
                        icon: Icons.translate,
                        title: l10n.language,
                        trailing: currentLanguage,
                        isLast: true,
                        onTap: () => _showLanguageBottomSheet(context),
                      ),
                      // Test Alarm Button
                      Divider(height: 1, color: kBorderColor, indent: 64),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await NotificationService().showNotification(
                              id: 999999,
                              title: '🔔 ${l10n.testAlarm}',
                              body: l10n.testNotificationBody,
                              useAlarm: true,
                            );
                            if (context.mounted) {
                              showCustomToast(
                                context,
                                message: l10n.testNotificationSent,
                                subtitle: l10n.checkSound,
                                isSuccess: true,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showCustomToast(
                                context,
                                message: l10n.errorTesting,
                                subtitle: e.toString(),
                                isSuccess: false,
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: Color(0xFFE11D48),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  l10n.testAlarm,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: kPrimaryTextColor,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: kSecondaryTextColor,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Section
                _buildSectionHeader(l10n.info),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: l10n.helpSupport,
                        isFirst: true,
                      ),
                      _buildMenuItem(
                        icon: Icons.description,
                        title: l10n.termsPolicy,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                GestureDetector(
                  onTap: () => _showLogoutDialog(l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.logout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kSecondaryTextColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: kBorderColor, indent: 64),
        GestureDetector(
          onTap: () {
            showCustomToast(
              context,
              message: title,
              subtitle: AppLocalizations.of(context)!.featureInDevelopment,
              isSuccess: true,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: kSecondaryTextColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemWithTrailing({
    required IconData icon,
    required String title,
    required String trailing,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: kBorderColor, indent: 64),
        GestureDetector(
          onTap:
              onTap ??
              () {
                showCustomToast(
                  context,
                  message: title,
                  subtitle: AppLocalizations.of(context)!.featureInDevelopment,
                  isSuccess: true,
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      trailing,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: kSecondaryTextColor,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle(String title) {
    return Column(
      children: [
        Divider(height: 1, color: kBorderColor, indent: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dark_mode,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  final l10n = AppLocalizations.of(context)!;
                  showCustomToast(
                    context,
                    message: value ? l10n.turnOnDarkMode : l10n.turnOffDarkMode,
                    subtitle: l10n.settingsSaved,
                    isSuccess: true,
                  );
                },
                activeThumbColor: kPrimaryColor,
                activeTrackColor: kPrimaryColor.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (mounted) {
                  Navigator.pop(dialogContext);
                }

                debugPrint('🔐 Starting logout process...');

                try {
                  final googleSignInService = GoogleSignInService();
                  if (await googleSignInService.isGoogleSignedIn()) {
                    debugPrint('🔐 Signing out from Google...');
                    await googleSignInService.signOutGoogle();
                    debugPrint('✅ Signed out from Google');
                  }
                } catch (e) {
                  debugPrint('⚠️ Google sign out error (not critical): $e');
                }

                if (mounted) {
                  debugPrint('🔐 Signing out from Supabase...');
                  await context.read<AuthProvider>().signOut();
                  debugPrint('✅ Signed out from Supabase');
                }

                if (mounted) {
                  debugPrint('✅ Logout completed - Navigating to welcome...');
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } catch (e) {
                debugPrint('❌ Logout error: $e');
                if (mounted) {
                  showCustomToast(
                    context,
                    message: AppLocalizations.of(context)!.logoutError,
                    subtitle: e.toString(),
                    isSuccess: false,
                  );
                }
              }
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}
