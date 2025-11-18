import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'med_info_screen.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';

// --- Bảng màu được cải tiến để nhất quán ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kAccentColor = Color(0xFFE0E7FF);

// --- Model dữ liệu (giữ nguyên) ---
class Medicine {
  final String name;
  final String dosage;
  final String time;
  final String icon;
  final bool isTaken; // Thêm trạng thái đã uống hay chưa

  Medicine({
    required this.name,
    required this.dosage,
    required this.time,
    required this.icon,
    this.isTaken = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _userName = 'Người dùng';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userService = UserService();
        final userInfo = await userService.getUserInfo(user.id);

        if (userInfo != null && mounted) {
          setState(() {
            _userName = userInfo['full_name'] ?? 'Người dùng';
            _avatarUrl = userInfo['avatar_url'];
          });
          debugPrint('✅ Home: User info loaded - $_userName');
          debugPrint('🖼️ Home: Avatar URL - $_avatarUrl');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user info in home: $e');
    }
  }

  // --- Dữ liệu mẫu với trạng thái isTaken ---
  final List<Medicine> _medicines = [
    Medicine(
      name: 'Vitamin D',
      dosage: '1 Viên, 1000mg',
      time: '09:41',
      icon: '💊',
      isTaken: true, // Ví dụ: thuốc này đã được uống
    ),
    Medicine(
      name: 'B12 Drops',
      dosage: '5 Giọt, 1200mg',
      time: '18:30',
      icon: '💧',
      isTaken: false, // Ví dụ: thuốc này chưa uống
    ),
    Medicine(
      name: 'Omega-3',
      dosage: '2 Viên, 600mg',
      time: '20:00',
      icon: '🐟',
      isTaken: false,
    ),
  ];

  // Tính toán tiến độ uống thuốc
  double get _progress {
    if (_medicines.isEmpty) return 0;
    final takenCount = _medicines.where((m) => m.isTaken).length;
    return takenCount / _medicines.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        // Sử dụng ListView để có hiệu ứng cuộn mượt mà hơn
        child: ListView(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 120,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDateScroller(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildMedicineList(),
          ],
        ),
      ),
    );
  }

  // Widget: Header Chào mừng
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào buổi sáng 👋',
                style: TextStyle(color: kSecondaryTextColor, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: const TextStyle(
                  color: kPrimaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE2E8F0),
              ),
              child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: kSecondaryTextColor,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: kSecondaryTextColor,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Thanh chọn ngày
  Widget _buildDateScroller() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          const weekDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
          final dayName = weekDays[date.weekday % 7];

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : kCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget: Thẻ tiến độ uống thuốc
  Widget _buildProgressCard() {
    int totalMeds = _medicines.length;
    int takenMeds = _medicines.where((m) => m.isTaken).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // Vòng tròn tiến độ
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: MedicineProgressPainter(progress: _progress),
              child: Center(
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Thông tin tiến độ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đã uống $takenMeds trên $totalMeds liều.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kSecondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Thanh tiến độ tuyến tính
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: kAccentColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Danh sách thuốc
  Widget _buildMedicineList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch trình hôm nay',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        if (_medicines.isEmpty)
          const Center(child: Text('Không có lịch trình nào cho hôm nay.'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              return _buildMedicineItem(_medicines[index]);
            },
          ),
      ],
    );
  }

  // Widget: Mục thuốc trong danh sách
  Widget _buildMedicineItem(Medicine medicine) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kCardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedInfoScreen(
                medData: {
                  'name': medicine.name,
                  'dosage': medicine.dosage,
                  'type': 'Viên Uống',
                  'amount': 30,
                  'reminders': [
                    {
                      'time': medicine.time,
                      'frequency': 'Hàng ngày',
                      'enabled': true,
                    },
                  ],
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    medicine.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Tên và liều lượng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.dosage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Thời gian và trạng thái
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    medicine.time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        medicine.isTaken ? Icons.check_circle : Icons.alarm,
                        size: 16,
                        color: medicine.isTaken ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        medicine.isTaken ? 'Đã uống' : 'Sắp tới',
                        style: TextStyle(
                          fontSize: 12,
                          color: medicine.isTaken
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Lớp Painter để vẽ vòng tròn tiến độ
class MedicineProgressPainter extends CustomPainter {
  final double progress;

  MedicineProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = kAccentColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = kPrimaryColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Vẽ vòng tròn nền
    canvas.drawCircle(center, radius, backgroundPaint);

    // Vẽ vòng tròn tiến độ
    const startAngle = -pi / 2; // Bắt đầu từ đỉnh
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
