import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'health_screen.dart';
import 'profile_screen.dart';
import 'add_med_screen.dart';
import '../widgets/custom_toast.dart';

const Color kPrimaryColor = Color(0xFF2563EB);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  // Sample medicine data
  final List<Map<String, dynamic>> _medicines = [
    {
      'name': 'Paracetamol',
      'dosage': '500mg, 1 viên',
      'time': '08:00 Sáng',
      'status': 'Sắp tới',
      'icon': Icons.medication,
      'iconBg': const Color(0xFFDEEBFF),
    },
    {
      'name': 'Vitamin C',
      'dosage': '1000mg, 1 viên',
      'time': '12:00 Trưa',
      'status': 'Trong 4 giờ',
      'icon': Icons.vaccines,
      'iconBg': const Color(0xFFDEEBFF),
    },
    {
      'name': 'Amoxicillin',
      'dosage': '250mg, 2 viên',
      'time': '20:00 Tối',
      'status': 'Trong 12 giờ',
      'icon': Icons.local_drink,
      'iconBg': const Color(0xFFDEEBFF),
    },
  ];

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thuốc của bạn',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_medicines.length} loại thuốc đang dùng',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showCustomToast(
                        context,
                        message: 'Lịch sử thuốc',
                        subtitle: 'Tính năng đang phát triển',
                        isSuccess: true,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.history,
                        color: kSecondaryTextColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Medicine List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  return _buildMedicineCard(_medicines[index]);
                },
              ),
            ),

            // Floating Action Button
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 120),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMedScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medicine['iconBg'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(medicine['icon'], color: kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Medicine Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine['dosage'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: kSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Time & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                medicine['time'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medicine['status'],
                style: const TextStyle(
                  fontSize: 12,
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
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

            // Medicine (Active)
            _buildBottomBarItem(
              icon: Icons.medication,
              label: 'Thuốc',
              isActive: true,
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
