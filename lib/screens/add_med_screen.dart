import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';

class AddMedScreen extends StatefulWidget {
  const AddMedScreen({super.key});

  @override
  State<AddMedScreen> createState() => _AddMedScreenState();
}

class _AddMedScreenState extends State<AddMedScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  String? _selectedType;
  String _selectedFrequency = 'Hàng ngày';
  final List<String> _reminders = ['08:00 AM', '08:00 PM'];
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _medicineTypes = [
    'Viên nén',
    'Viên nang',
    'Siro',
    'Thuốc tiêm',
  ];

  final List<String> _frequencies = ['Hàng ngày', 'Cách ngày', 'Tùy chỉnh'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final timeStr = _reminders[index]
        .replaceAll(' AM', '')
        .replaceAll(' PM', '');
    final timeParts = timeStr.split(':');
    int hour = int.parse(timeParts[0]);
    final isAm = _reminders[index].contains('AM');

    if (!isAm && hour != 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: int.parse(timeParts[1])),
    );

    if (result != null) {
      final period = result.hour < 12 ? 'AM' : 'PM';
      final displayHour = result.hour % 12 == 0 ? 12 : result.hour % 12;
      setState(() {
        _reminders[index] =
            '${displayHour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

  void _addReminder() {
    setState(() {
      _reminders.add('12:00 PM');
    });
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên thuốc';
      });
      return;
    }

    if (_selectedType == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn loại thuốc';
      });
      return;
    }

    if (_dosageController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập liều lượng';
      });
      return;
    }

    if (_quantityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số lượng tồn kho';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      showCustomToast(
        context,
        message: 'Thêm thuốc thành công',
        subtitle: 'Thuốc đã được thêm vào danh sách của bạn',
        isSuccess: true,
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Color(0xFF111418), size: 28),
        ),
        title: const Text(
          'Thêm thuốc mới',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _handleSave,
              child: const Center(
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    color: Color(0xFF137fec),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PHẦN 1: Thông tin thuốc
              const Text(
                'Thông tin thuốc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111418),
                ),
              ),
              const SizedBox(height: 16),

              // Tên thuốc
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tên thuốc',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên thuốc',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDBE0E6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDBE0E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF137fec),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Loại thuốc
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Loại thuốc',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDBE0E6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedType,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Chọn loại thuốc'),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      },
                      items: _medicineTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Liều lượng và Số lượng tồn kho
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liều lượng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111418),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dosageController,
                          decoration: InputDecoration(
                            hintText: 'ví dụ: 500mg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDBE0E6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDBE0E6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF137fec),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Số lượng tồn kho',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111418),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'ví dụ: 30',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDBE0E6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDBE0E6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF137fec),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Divider
              Container(height: 1, color: const Color(0xFFDBE0E6)),
              const SizedBox(height: 32),

              // PHẦN 2: Lịch uống thuốc
              const Text(
                'Lịch uống thuốc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111418),
                ),
              ),
              const SizedBox(height: 16),

              // Tần suất
              const Text(
                'Tần suất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111418),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _frequencies.map((String freq) {
                  final isSelected = freq == _selectedFrequency;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFrequency = freq;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF137fec)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF137fec)
                              : const Color(0xFFDBE0E6),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        freq,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF111418),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Thời gian uống
              const Text(
                'Thời gian uống',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111418),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectTime(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDBE0E6)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _reminders[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111418),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _deleteReminder(index),
                              child: const Icon(
                                Icons.delete,
                                color: Color(0xFF617589),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _addReminder,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF137fec),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF137fec).withValues(alpha: 0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_circle,
                        color: Color(0xFF137fec),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Thêm thời gian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF137fec),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // PHẦN 3: Ghi chú thêm
              const Text(
                'Ghi chú thêm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111418),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'ví dụ: Uống sau khi ăn no...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE0E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE0E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF137fec),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Lỗi
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF5350)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEA4335),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137fec),
                    disabledBackgroundColor: const Color(
                      0xFF137fec,
                    ).withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Lưu Lịch Uống Thuốc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
