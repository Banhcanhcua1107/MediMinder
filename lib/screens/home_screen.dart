import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_med_screen.dart';
import 'personal_info_screen.dart';
import '../widgets/custom_toast.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../models/user_medicine.dart';
import '../providers/medicine_provider.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();

    // Fetch medicines via provider
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MedicineProvider>(
          context,
          listen: false,
        ).fetchMedicines(user.id);
      });
    }

    // Thêm dòng này
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationService = NotificationService();
    await notificationService.requestPermissions();
    await notificationService.requestBatteryPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App quay lại foreground - refresh dữ liệu
      debugPrint('🔄 App resumed - refreshing medicines');
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Provider.of<MedicineProvider>(
          context,
          listen: false,
        ).fetchMedicines(user.id);
      }

      // Khởi động lại kiểm tra notifications
      _restartNotifications();
    }
  }

  Future<void> _restartNotifications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        debugPrint('🔔 Restarting notifications check on app resume...');
        // Use provider's medicines if available, or wait for fetch
        // For simplicity, we can just trigger a fetch and let the provider handle it
        // But here we need the list to check notifications.
        // Let's access the provider directly.
        final provider = Provider.of<MedicineProvider>(context, listen: false);
        final medicines = provider.medicines;

        if (medicines.isNotEmpty) {
          final notificationService = NotificationService();
          await notificationService.initialize();

          // Trigger immediate check
          final now = DateTime.now();
          int checkCount = 0;

          for (var medicine in medicines) {
            for (int i = 0; i < medicine.scheduleTimes.length; i++) {
              final scheduleTime = medicine.scheduleTimes[i];
              final scheduledDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                scheduleTime.timeOfDay.hour,
                scheduleTime.timeOfDay.minute,
              );

              final differenceInSeconds = scheduledDateTime
                  .difference(now)
                  .inSeconds;

              // Show notification if within 5 minutes
              if (differenceInSeconds > -300 && differenceInSeconds < 300) {
                checkCount++;
              }
            }
          }

          debugPrint(
            '✅ Notification restart check completed - $checkCount medicines in notification window',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error restarting notifications: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // _loadMedicines removed as it is handled by provider

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
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.medicines.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('${l10n.error}: ${provider.error}'));
            }

            final medicines = provider.medicines;

            // Filter medicines for selected date
            final visibleMedicines = medicines.where((m) {
              return m.isScheduledForDate(_selectedDate);
            }).toList();

            // Sort by time
            visibleMedicines.sort((a, b) {
              final aNext = a.getNextIntakeTime();
              final bNext = b.getNextIntakeTime();
              if (aNext == null && bNext == null) return 0;
              if (aNext == null) return 1;
              if (bNext == null) return -1;
              final aMinutes = aNext.hour * 60 + aNext.minute;
              final bMinutes = bNext.hour * 60 + bNext.minute;
              return aMinutes.compareTo(bMinutes);
            });

            // Tính toán thuốc đã uống theo ngày được chọn
            final takenCount = _calculateTakenCount(
              visibleMedicines,
              _selectedDate,
            );
            final totalCount = _calculateTotalSchedules(visibleMedicines);
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
                _buildMedicineList(visibleMedicines),
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

  int _calculateTakenCount(List<UserMedicine> medicines, DateTime date) {
    int count = 0;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    for (var med in medicines) {
      // Kiểm tra xem có intake record cho ngày này không
      for (var intake in med.intakes) {
        final intakeDateStr =
            '${intake.scheduledDate.year}-${intake.scheduledDate.month.toString().padLeft(2, '0')}-${intake.scheduledDate.day.toString().padLeft(2, '0')}';
        if (intakeDateStr == dateStr && intake.status == 'taken') {
          count++;
        }
      }
    }
    return count;
  }

  // Widget: Header Chào mừng
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.goodMorning,
                style: const TextStyle(
                  color: kSecondaryTextColor,
                  fontSize: 16,
                ),
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
          Row(
            children: [
              // Test Immediate Notification Button
              IconButton(
                icon: const Icon(
                  Icons.notifications_active,
                  color: Colors.orange,
                ),
                onPressed: () async {
                  await NotificationService().testImmediateNotification();
                  if (context.mounted) {
                    showCustomToast(
                      context,
                      message: 'Test Ngay',
                      subtitle: 'Thông báo test hiển thị ngay',
                      isSuccess: true,
                    );
                  }
                },
                tooltip: 'Test Immediate Notification',
              ),
              // Test Alarm Button (Schedule in 5 seconds)
              IconButton(
                icon: const Icon(Icons.alarm_add, color: kPrimaryColor),
                onPressed: () async {
                  await NotificationService().scheduleTestAlarm();
                  if (context.mounted) {
                    showCustomToast(
                      context,
                      message: 'Test Sau 5 Giây',
                      subtitle: 'Thông báo sẽ nổ sau 5 giây',
                      isSuccess: true,
                    );
                  }
                },
                tooltip: 'Test Scheduled Notification',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
                    ),
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.yourProgress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tookDoses(taken.toString(), total.toString()),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.medicinesScheduled,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            if (medicines.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${medicines.length} ${l10n.medicines.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (medicines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: kSuccessColor.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.noMedicinesScheduled,
                  style: const TextStyle(
                    fontSize: 16,
                    color: kSecondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: medicines.map((medicine) {
              return _buildVerticalMedicineCard(medicine);
            }).toList(),
          ),
      ],
    );
  }

  // Widget: Thẻ thuốc dạng danh sách (new design)
  Widget _buildVerticalMedicineCard(UserMedicine medicine) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Kiểm tra xem đã uống lịch đầu tiên hay chưa
    final isTaken = medicine.intakes.any((intake) {
      final intakeDateStr =
          '${intake.scheduledDate.year}-${intake.scheduledDate.month.toString().padLeft(2, '0')}-${intake.scheduledDate.day.toString().padLeft(2, '0')}';
      return intakeDateStr == todayStr && intake.status == 'taken';
    });

    return Dismissible(
      key: Key(medicine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Xóa thuốc',
              style: TextStyle(
                color: Color(0xFF111418),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Bạn chắc chắn muốn xóa "${medicine.name}"?',
              style: const TextStyle(color: Color(0xFF666D80), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: Color(0xFF666D80)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ),
        );
        return shouldDelete ?? false;
      },
      onDismissed: (direction) async {
        try {
          await Provider.of<MedicineProvider>(
            context,
            listen: false,
          ).deleteMedicine(medicine.id);

          if (mounted) {
            showCustomToast(
              context,
              message: 'Đã xóa ${medicine.name}',
              isSuccess: true,
            );
          }
        } catch (e) {
          if (mounted) {
            showCustomToast(
              context,
              message: 'Lỗi khi xóa: $e',
              isSuccess: false,
            );
          }
        }
      },
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedScreen(medicineId: medicine.id),
            ),
          );
          if (result == true) {
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              Provider.of<MedicineProvider>(
                context,
                listen: false,
              ).fetchMedicines(user.id);
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTaken
                  ? kSuccessColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  // Icon with background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isTaken
                          ? kSuccessColor.withOpacity(0.1)
                          : kAccentColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        isTaken ? Icons.check_circle : Icons.medication,
                        color: isTaken ? kSuccessColor : kPrimaryColor,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Medicine info
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.dosageInfo}: ${medicine.quantityPerDose} × ${medicine.dosageStrength}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isTaken
                          ? kSuccessColor.withOpacity(0.1)
                          : kWarningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTaken ? l10n.taken : l10n.untaken,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isTaken ? kSuccessColor : kWarningColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Time and action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.intakeTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kSecondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: medicine.scheduleTimes.take(3).map((
                            scheduleTime,
                          ) {
                            final timeStr =
                                '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action button
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTaken
                            ? kSuccessColor
                            : kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (medicine.scheduleTimes.isNotEmpty) {
                          final firstSchedule = medicine.scheduleTimes.first;
                          await _handleToggleTaken(
                            medicine,
                            firstSchedule,
                            !isTaken,
                          );
                        }
                      },
                      child: Text(
                        isTaken ? l10n.taken : l10n.markTaken,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Future<void> _handleToggleTaken(
    UserMedicine medicine,
    MedicineScheduleTime scheduleTime,
    bool taken,
  ) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Provider.of<MedicineProvider>(
          context,
          listen: false,
        ).toggleTaken(user.id, medicine, scheduleTime, taken);

        debugPrint(taken ? '✅ Marked as taken' : '❌ Removed taken status');
      }
    } catch (e) {
      debugPrint('❌ Error toggling taken status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
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
