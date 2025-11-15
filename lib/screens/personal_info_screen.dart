import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'health_screen.dart';
import 'medicine_list_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_toast.dart'; // ignore: unused_import

const Color kPrimaryColor = Color(0xFF2563EB);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;

  // Form controllers
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: 'Nguyễn Văn An');
    _dobController = TextEditingController(text: '01/01/1990');
    _genderController = TextEditingController(text: 'Nam');
    _emailController = TextEditingController(text: 'nguyenvanan@email.com');
    _phoneController = TextEditingController(text: '0901234567');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Thông tin Cá nhân',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                      if (!_isEditing) {
                        showCustomToast(
                          context,
                          message: 'Thông tin đã được cập nhật',
                          subtitle: 'Thay đổi đã được lưu',
                          isSuccess: true,
                        );
                      }
                    },
                    child: Text(
                      _isEditing ? 'Hủy' : 'Sửa',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Avatar Section
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryColor,
                                width: 4,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFCBD5E1),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: kSecondaryTextColor,
                                size: 56,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kPrimaryColor,
                                border: Border.all(color: kCardColor, width: 2),
                              ),
                              child: const Icon(
                                Icons.photo_camera,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Info Section
                    _buildSectionHeader('THÔNG TIN CƠ BẢN'),
                    const SizedBox(height: 12),
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
                          _buildInfoField(
                            label: 'Họ và tên',
                            controller: _fullNameController,
                            isFirst: true,
                          ),
                          _buildInfoField(
                            label: 'Ngày sinh',
                            controller: _dobController,
                          ),
                          _buildInfoField(
                            label: 'Giới tính',
                            controller: _genderController,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Info Section
                    _buildSectionHeader('THÔNG TIN LIÊN HỆ'),
                    const SizedBox(height: 12),
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
                          _buildInfoField(
                            label: 'Email',
                            controller: _emailController,
                            isFirst: true,
                          ),
                          _buildInfoField(
                            label: 'Số điện thoại',
                            controller: _phoneController,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    if (_isEditing)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = false;
                          });
                          showCustomToast(
                            context,
                            message: 'Lưu thay đổi thành công',
                            subtitle: 'Thông tin của bạn đã được cập nhật',
                            isSuccess: true,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
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

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: kBorderColor,
            indent: 16,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      )
                    : Text(
                        controller.text,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      ),
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
        border: Border(
          top: BorderSide(color: kBorderColor, width: 0.5),
        ),
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
                  MaterialPageRoute(
                    builder: (context) => const HealthScreen(),
                  ),
                );
              },
              child: _buildBottomBarItem(
                icon: Icons.favorite,
                label: 'Sức khỏe',
                isActive: false,
              ),
            ),

            // Profile
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: _buildBottomBarItem(
                icon: Icons.person,
                label: 'Hồ sơ',
                isActive: false,
              ),
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
}
