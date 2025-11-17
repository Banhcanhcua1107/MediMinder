import 'package:flutter/material.dart';
import 'add_health_profile_screen.dart';
import '../widgets/custom_toast.dart';

// --- Bảng màu ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kAccentColor = Color(0xFFE0E7FF);

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String _selectedMonth = 'Tháng 7';

  // Dữ liệu tuần: chiều cao các cột (từ 0-100)
  final List<Map<String, dynamic>> _weekData = [
    {'day': 'T2', 'value': 60},
    {'day': 'T3', 'value': 75},
    {'day': 'T4', 'value': 85},
    {'day': 'T5', 'value': 95, 'isCurrentDay': true},
    {'day': 'T6', 'value': 75},
    {'day': 'T7', 'value': 60},
    {'day': 'CN', 'value': 50},
  ];

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(),
            const SizedBox(height: 24),

            // BMI Card
            _buildBMICard(),
            const SizedBox(height: 16),

            // Blood Pressure & Heart Rate
            _buildVitalsGrid(),
            const SizedBox(height: 16),

            // Weekly Progress
            _buildWeeklyProgressCard(),
          ],
        ),
      ),
    );
  }

  // Widget: Header
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sức khỏe của bạn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cập nhật ngày 15/07',
                  style: TextStyle(fontSize: 13, color: kSecondaryTextColor),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showCustomToast(
                      context,
                      message: 'Thông báo',
                      subtitle: 'Bạn chưa có thông báo nào',
                      isSuccess: true,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: kSecondaryTextColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddHealthProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: kSecondaryTextColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Widget: BMI Card
  Widget _buildBMICard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + label and BMI value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEBFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.scale,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Chỉ số BMI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bình thường',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                '21.5',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar with slider
          SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF06B6D4)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // BMI ranges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '18.5',
                style: TextStyle(fontSize: 11, color: kSecondaryTextColor),
              ),
              Text(
                '25',
                style: TextStyle(fontSize: 11, color: kSecondaryTextColor),
              ),
              Text(
                '30',
                style: TextStyle(fontSize: 11, color: kSecondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Blood Pressure & Heart Rate Grid
  Widget _buildVitalsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildVitalCard(
            icon: Icons.favorite,
            iconColor: Colors.red,
            backgroundColor: const Color(0xFFFFE4E6),
            title: 'Huyết áp',
            value: '120/80',
            unit: 'mmHg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVitalCard(
            icon: Icons.favorite,
            iconColor: Colors.pink,
            backgroundColor: const Color(0xFFFFEAF2),
            title: 'Nhịp tim',
            value: '72',
            unit: 'BPM',
          ),
        ),
      ],
    );
  }

  // Widget: Individual Vital Card
  Widget _buildVitalCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(fontSize: 11, color: kSecondaryTextColor),
          ),
        ],
      ),
    );
  }

  // Widget: Weekly Progress Card
  Widget _buildWeeklyProgressCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ tuần',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showMonthPicker();
                },
                child: Row(
                  children: [
                    Text(
                      _selectedMonth,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 18,
                      color: kSecondaryTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar chart
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weekData.map((data) {
                final isCurrentDay = data['isCurrentDay'] ?? false;
                final barHeight = (data['value'] as int) / 100 * 115;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bar
                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isCurrentDay
                            ? kPrimaryColor
                            : const Color(0xFFE2E8F0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Day label
                    Text(
                      data['day'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrentDay
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isCurrentDay
                            ? kPrimaryColor
                            : kSecondaryTextColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Show month picker
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn tháng'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: List.generate(12, (index) {
                final month = 'Tháng ${index + 1}';
                return ListTile(
                  title: Text(month),
                  onTap: () {
                    setState(() => _selectedMonth = month);
                    Navigator.pop(context);
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
