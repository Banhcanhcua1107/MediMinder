import 'package:flutter/material.dart';

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
      backgroundColor: _isDarkMode
          ? const Color(0xFF1A202C)
          : const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isDarkMode
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF1A202C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài đặt & Hồ sơ',
          style: TextStyle(
            color: _isDarkMode
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: _isDarkMode
                ? const Color(0xFF4A5568)
                : const Color(0xFFEDF2F7),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần hồ sơ người dùng
            Container(
              color: _isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4299E1),
                            width: 4,
                          ),
                        ),
                        child: const Center(
                          child: Text('👤', style: TextStyle(fontSize: 64)),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4299E1),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chỉnh sửa ảnh đại diện'),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lê An',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'le.an@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Phần TÀI KHOẢN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'TÀI KHOẢN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF2D3748)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDarkMode
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFEDF2F7),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItemAccount(
                          icon: Icons.person,
                          title: 'Thông tin cá nhân',
                          isDarkMode: _isDarkMode,
                          isFirst: true,
                        ),
                        _buildMenuItemAccount(
                          icon: Icons.lock,
                          title: 'Bảo mật & Mật khẩu',
                          isDarkMode: _isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Phần ỨNG DỤNG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'ỨNG DỤNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF2D3748)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDarkMode
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFEDF2F7),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItemApp(
                          icon: Icons.notifications,
                          title: 'Cài đặt thông báo',
                          isDarkMode: _isDarkMode,
                          isFirst: true,
                        ),
                        _buildMenuItemApp(
                          icon: Icons.language,
                          title: 'Ngôn ngữ',
                          trailing: 'Tiếng Việt',
                          isDarkMode: _isDarkMode,
                        ),
                        _buildDarkModeToggle(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Phần HỖ TRỢ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'HỖ TRỢ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF2D3748)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDarkMode
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFEDF2F7),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItemApp(
                          icon: Icons.help,
                          title: 'Trợ giúp & Phản hồi',
                          isDarkMode: _isDarkMode,
                          isFirst: true,
                        ),
                        _buildMenuItemApp(
                          icon: Icons.info,
                          title: 'Về chúng tôi',
                          isDarkMode: _isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Nút đăng xuất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isDarkMode ? const Color(0xFF2D3748) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDarkMode
                        ? const Color(0xFF4A5568)
                        : const Color(0xFFEDF2F7),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showLogoutDialog(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Color(0xFFD0021B),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD0021B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemAccount({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: isDarkMode
                ? const Color(0xFF4A5568)
                : const Color(0xFFEDF2F7),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(title)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4299E1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF4299E1), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF718096),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemApp({
    required IconData icon,
    required String title,
    String? trailing,
    required bool isDarkMode,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: isDarkMode
                ? const Color(0xFF4A5568)
                : const Color(0xFFEDF2F7),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(title)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4299E1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF4299E1), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        trailing,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF718096),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle() {
    return Column(
      children: [
        Divider(
          height: 1,
          color: _isDarkMode
              ? const Color(0xFF4A5568)
              : const Color(0xFFEDF2F7),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4299E1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dark_mode,
                  color: Color(0xFF4299E1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Chế độ tối',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isDarkMode
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1A202C),
                  ),
                ),
              ),
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                activeColor: const Color(0xFF4299E1),
                activeTrackColor: const Color(
                  0xFF4299E1,
                ).withValues(alpha: 0.4),
              ),
            ],
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
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFFD0021B)),
            ),
          ),
        ],
      ),
    );
  }
}
