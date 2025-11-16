import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'health_screen.dart';
import 'medicine_list_screen.dart';
import 'personal_info_screen.dart';
import '../widgets/custom_toast.dart';

const Color kPrimaryColor = Color(0xFF2563EB);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorderColor, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: kPrimaryTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const Text(
                    'Cài đặt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  SizedBox(width: 40), // Spacer
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),

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
                            child: const Icon(
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
                              children: const [
                                Text(
                                  'Nguyễn Văn An',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Thông tin cá nhân',
                                  style: TextStyle(
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
                  _buildSectionHeader('Tài khoản'),
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
                      title: 'Bảo mật',
                      isFirst: true,
                      isLast: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // General Settings Section
                  _buildSectionHeader('Cài đặt chung'),
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
                          title: 'Thông báo',
                          isFirst: true,
                        ),
                        _buildDarkModeToggle(),
                        _buildMenuItemWithTrailing(
                          icon: Icons.translate,
                          title: 'Ngôn ngữ',
                          trailing: 'Tiếng Việt',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Section
                  _buildSectionHeader('Thông tin'),
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
                          title: 'Trợ giúp & Hỗ trợ',
                          isFirst: true,
                        ),
                        _buildMenuItem(
                          icon: Icons.description,
                          title: 'Điều khoản & Chính sách',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  GestureDetector(
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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
              subtitle: 'Tính năng đang phát triển',
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
  }) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: kBorderColor, indent: 64),
        GestureDetector(
          onTap: () {
            showCustomToast(
              context,
              message: title,
              subtitle: 'Tính năng đang phát triển',
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

  Widget _buildDarkModeToggle() {
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
                  'Chế độ tối',
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
                  showCustomToast(
                    context,
                    message: value ? 'Bật chế độ tối' : 'Tắt chế độ tối',
                    subtitle: 'Cài đặt đã được lưu',
                    isSuccess: true,
                  );
                },
                activeColor: kPrimaryColor,
                activeTrackColor: kPrimaryColor.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(top: BorderSide(color: kBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: _buildBottomBarItem(
                icon: Icons.home,
                label: 'Trang chủ',
                isActive: false,
              ),
            ),

            // Medicine
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicineListScreen(),
                  ),
                );
              },
              child: _buildBottomBarItem(
                icon: Icons.medication,
                label: 'Thuốc',
                isActive: false,
              ),
            ),

            // Health
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthScreen()),
                );
              },
              child: _buildBottomBarItem(
                icon: Icons.favorite,
                label: 'Sức khỏe',
                isActive: false,
              ),
            ),

            // Profile (Active)
            _buildBottomBarItem(
              icon: Icons.person,
              label: 'Hồ sơ',
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kAccentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 24),
          )
        else
          Icon(icon, color: kSecondaryTextColor, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? kPrimaryColor : kSecondaryTextColor,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showCustomToast(
                context,
                message: 'Đã đăng xuất',
                subtitle: 'Tạm biệt!',
                isSuccess: true,
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}
