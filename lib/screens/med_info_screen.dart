import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';

class MedInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? medData;
  const MedInfoScreen({super.key, this.medData});

  @override
  State<MedInfoScreen> createState() => _MedInfoScreenState();
}

class _MedInfoScreenState extends State<MedInfoScreen> {
  late String medicineName;
  late String dosage;
  late String medicineType;
  late int quantity;
  late List<Map<String, dynamic>> reminders;
  late bool alarmEnabled;

  @override
  void initState() {
    super.initState();
    final data = widget.medData ?? {};
    medicineName = data['name'] ?? 'Vitamin D';
    dosage = data['dosage'] ?? '1 Viên, 1000mg';
    medicineType = data['type'] ?? 'Viên Uống';
    quantity = data['amount'] ?? 30;

    // Parse reminders an cách an toàn
    if (data['reminders'] != null && data['reminders'] is List) {
      try {
        reminders = List<Map<String, dynamic>>.from(data['reminders'] as List);
      } catch (e) {
        reminders = [
          {'time': '09:41', 'frequency': 'Hàng ngày'},
          {'time': 'Thứ 3 06:13 AM', 'frequency': 'Hàng ngày'},
        ];
      }
    } else {
      reminders = [
        {'time': '09:41', 'frequency': 'Hàng ngày'},
        {'time': 'Thứ 3 06:13 AM', 'frequency': 'Hàng ngày'},
      ];
    }

    alarmEnabled = data['alarmEnabled'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông Tin Thuốc',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thuốc Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('💊', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicineName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$medicineType • $dosage',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Số lượng + Chỉnh sửa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEEBF7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Số lượng: $quantity',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF196EB0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _onEditPressed,
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF196EB0),
                      ),
                      label: const Text(
                        'Chỉnh Sửa',
                        style: TextStyle(
                          color: Color(0xFF196EB0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nhắc tiếp theo
              const Text(
                'Nhắc tiếp theo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF196EB0),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminders.isNotEmpty
                                  ? reminders[0]['time'].toString()
                                  : '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Đã lên lịch',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showEditReminder(0),
                      child: const Text(
                        'Chỉnh Sửa',
                        style: TextStyle(
                          color: Color(0xFF196EB0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Danh sách nhắc
              const Text(
                'Danh sách nhắc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: List.generate(reminders.length, (index) {
                    final reminder = reminders[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.notifications,
                                    color: Color(0xFF196EB0),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reminder['time'].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reminder['frequency'].toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _showEditReminder(index),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF64748B),
                                      size: 20,
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: alarmEnabled,
                                      onChanged: (value) {
                                        setState(() {
                                          alarmEnabled = value;
                                        });
                                      },
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: const Color(0xFF196EB0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (index < reminders.length - 1)
                          Divider(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                            indent: 48,
                            endIndent: 12,
                          ),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Ghi chú
              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Không có ghi chú nào. Bạn có thể thêm ghi chú khi chỉnh sửa thuốc.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onTakenPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF196EB0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đã Uống',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onEditPressed,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF196EB0),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Chỉnh Sửa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF196EB0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _onDeletePressed,
                child: const Text(
                  'Xóa Thuốc',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEditPressed() {
    showCustomToast(
      context,
      message: 'Chỉnh sửa thuốc',
      subtitle: 'Tính năng đang phát triển',
      isSuccess: true,
    );
  }

  void _onTakenPressed() {
    setState(() {
      if (quantity > 0) quantity -= 1;
    });
    showCustomToast(
      context,
      message: 'Đã ghi nhận',
      subtitle: 'Bạn đã uống 1 liều',
      isSuccess: true,
    );
  }

  void _onDeletePressed() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Thuốc'),
        content: const Text(
          'Bạn có chắc muốn xóa thuốc này? Hành động không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
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
    if (ok == true) {
      if (mounted) {
        Navigator.pop(context);
        showCustomToast(
          context,
          message: 'Xóa thuốc thành công',
          subtitle: 'Thuốc đã bị xóa khỏi danh sách',
          isSuccess: true,
        );
      }
    }
  }

  void _showEditReminder(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa nhắc #${index + 1} (chưa triển khai)')),
    );
  }
}
