import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';

// --- Bảng màu được cải tiến để nhất quán ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kAccentColor = Color(0xFFE0E7FF);
const Color kSuccessColor = Color(0xFF10B981);
const Color kWarningColor = Color(0xFFF59E0B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  String _userName = 'Người dùng';
  String? _avatarUrl;
  late MedicineRepository _medicineRepository;
  late Future<List<UserMedicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final supabase = Supabase.instance.client;
    _medicineRepository = MedicineRepository(supabase);
    _loadUserInfo();
    _loadMedicines();

    // Thêm dòng này
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await NotificationService().requestPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App quay lại foreground - refresh dữ liệu
      debugPrint('🔄 App resumed - refreshing medicines');
      _loadMedicines();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadMedicines() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _medicinesFuture = _medicineRepository.getTodayMedicines(user.id);
      });
    }
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
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user info in home: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<UserMedicine>>(
          future: _medicinesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final medicines = snapshot.data ?? [];

            // Tính toán thuốc đã uống theo ngày được chọn
            final takenCount = _calculateTakenCount(medicines);
            final totalCount = _calculateTotalSchedules(medicines);
            final progress = totalCount > 0 ? takenCount / totalCount : 0.0;

            return ListView(
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
                _buildProgressCard(progress, takenCount, totalCount),
                const SizedBox(height: 24),
                _buildMedicineList(medicines),
              ],
            );
          },
        ),
      ),
    );
  }

  int _calculateTotalSchedules(List<UserMedicine> medicines) {
    int total = 0;
    for (var med in medicines) {
      total += med.scheduleTimes.length;
    }
    return total;
  }

  int _calculateTakenCount(List<UserMedicine> medicines) {
    int count = 0;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    for (var med in medicines) {
      // Kiểm tra xem có intake record cho hôm nay không
      for (var intake in med.intakes) {
        final intakeDateStr =
            '${intake.scheduledDate.year}-${intake.scheduledDate.month.toString().padLeft(2, '0')}-${intake.scheduledDate.day.toString().padLeft(2, '0')}';
        if (intakeDateStr == todayStr && intake.status == 'taken') {
          count++;
        }
      }
    }
    return count;
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
  Widget _buildProgressCard(double progress, int taken, int total) {
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
              painter: MedicineProgressPainter(progress: progress),
              child: Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
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
                  'Đã uống $taken trên $total liều.',
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
                    value: progress,
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
  Widget _buildMedicineList(List<UserMedicine> medicines) {
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
        if (medicines.isEmpty)
          const Center(child: Text('Không có lịch trình nào cho hôm nay.'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              return _buildMedicineCard(medicines[index]);
            },
          ),
      ],
    );
  }

  // Widget: Thẻ thuốc với checkbox xác nhận
  Widget _buildMedicineCard(UserMedicine medicine) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kCardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    child: Icon(
                      _getMedicineIcon(medicine.dosageForm),
                      color: kPrimaryColor,
                      size: 24,
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
                        '${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Danh sách thời gian với checkbox
            ...medicine.scheduleTimes.map((scheduleTime) {
              final timeStr =
                  '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}';

              // Kiểm tra xem đã uống hay chưa
              final now = DateTime.now();
              final todayStr =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              final isTaken = medicine.intakes.any((intake) {
                final intakeDateStr =
                    '${intake.scheduledDate.year}-${intake.scheduledDate.month.toString().padLeft(2, '0')}-${intake.scheduledDate.day.toString().padLeft(2, '0')}';
                return intakeDateStr == todayStr && intake.status == 'taken';
              });

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: isTaken,
                      onChanged: (value) async {
                        await _handleToggleTaken(
                          medicine,
                          scheduleTime,
                          value ?? false,
                        );
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return kSuccessColor;
                        }
                        return Colors.transparent;
                      }),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTaken
                            ? kSuccessColor.withOpacity(0.1)
                            : kWarningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isTaken ? 'Đã uống' : 'Sắp tới',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isTaken ? kSuccessColor : kWarningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleTaken(
    UserMedicine medicine,
    MedicineScheduleTime scheduleTime,
    bool taken,
  ) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (taken) {
          // Tạo intake record với status 'taken'
          await Supabase.instance.client.from('medicine_intakes').insert({
            'user_id': user.id,
            'user_medicine_id': medicine.id,
            'medicine_name': medicine.name,
            'dosage_strength': medicine.dosageStrength,
            'quantity_per_dose': medicine.quantityPerDose,
            'scheduled_date':
                '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            'scheduled_time':
                '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}:00',
            'status': 'taken',
            'taken_at': DateTime.now().toIso8601String(),
          });
          debugPrint(
            '✅ Marked as taken: ${medicine.name} at ${scheduleTime.timeOfDay}',
          );
        } else {
          // Xóa intake record
          final dateStr =
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
          final timeStr =
              '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}:00';

          await Supabase.instance.client
              .from('medicine_intakes')
              .delete()
              .eq('user_id', user.id)
              .eq('user_medicine_id', medicine.id)
              .eq('scheduled_date', dateStr)
              .eq('scheduled_time', timeStr)
              .eq('status', 'taken');

          debugPrint('❌ Removed taken status: ${medicine.name}');
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error toggling taken status: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  IconData _getMedicineIcon(String dosageForm) {
    switch (dosageForm.toLowerCase()) {
      case 'tablet':
      case 'viên nén':
        return Icons.medication;
      case 'capsule':
      case 'viên nang':
        return Icons.vaccines;
      case 'liquid':
      case 'siro':
        return Icons.local_drink;
      case 'injection':
      case 'thuốc tiêm':
        return Icons.medical_services;
      default:
        return Icons.medication;
    }
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
