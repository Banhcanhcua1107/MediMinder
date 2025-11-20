import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';
import '../services/notification_service.dart';

class AddMedScreen extends StatefulWidget {
  final String? medicineId;

  const AddMedScreen({super.key, this.medicineId});

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
  List<String> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  late MedicineRepository _medicineRepository;
  UserMedicine? _editingMedicine;
  MedicineSchedule? _existingSchedule;

  final List<String> _medicineTypes = [
    'Viên nén',
    'Viên nang',
    'Siro',
    'Thuốc tiêm',
  ];

  final List<String> _frequencies = ['Hàng ngày', 'Cách ngày', 'Tuỳ chỉnh'];

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    _medicineRepository = MedicineRepository(supabase);

    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();

    // Mặc định gợi ý giờ uống
    _reminders = ['08:00', '20:00'];

    if (widget.medicineId != null) {
      _loadMedicineData();
    }
  }

  Future<void> _loadMedicineData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final medicines = await _medicineRepository.getUserMedicines(user.id);
        _editingMedicine = medicines.firstWhere(
          (m) => m.id == widget.medicineId,
          orElse: () => throw Exception('Medicine not found'),
        );

        if (_editingMedicine != null) {
          _nameController.text = _editingMedicine!.name;
          _dosageController.text = _editingMedicine!.dosageStrength;
          _quantityController.text = _editingMedicine!.quantityPerDose
              .toString();
          _notesController.text = _editingMedicine!.notes ?? '';
          _selectedType = _medicineTypes.contains(_editingMedicine!.dosageForm)
              ? _editingMedicine!.dosageForm
              : 'Viên nén';
          _startDate = _editingMedicine!.startDate;
          _endDate = _editingMedicine!.endDate;

          if (_editingMedicine!.scheduleTimes.isNotEmpty) {
            _reminders = _editingMedicine!.scheduleTimes
                .map((t) => t.getTimeText())
                .toList();
          }

          if (_editingMedicine!.schedules.isNotEmpty) {
            _existingSchedule = _editingMedicine!.schedules.first;
            _selectedFrequency = _existingSchedule!.getFrequencyText();
          }
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error loading medicine: $e');
    }
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
    final timeStr = _reminders[index];
    final parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (result != null) {
      setState(() {
        _reminders[index] =
            '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _deleteReminder(int index) {
    setState(() => _reminders.removeAt(index));
  }

  void _addReminder() {
    setState(() => _reminders.add('12:00'));
  }

  Future<void> _selectStartDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _startDate = result);
  }

  Future<void> _selectEndDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _endDate = result);
  }

  void _handleSave() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _selectedType == null ||
        _dosageController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _reminders.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String currentMedicineId;

      // 1. Lưu vào Supabase
      if (widget.medicineId == null) {
        // Tạo mới
        final medicine = await _medicineRepository.createMedicine(
          userId: user.id,
          name: _nameController.text,
          dosageStrength: _dosageController.text,
          dosageForm: _selectedType!,
          quantityPerDose: int.parse(_quantityController.text),
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        currentMedicineId = medicine.id;

        final schedule = await _medicineRepository.createSchedule(
          medicine.id,
          frequencyType: _selectedFrequency == 'Hàng ngày'
              ? 'daily'
              : _selectedFrequency == 'Cách ngày'
              ? 'alternate_days'
              : 'custom',
        );

        for (int i = 0; i < _reminders.length; i++) {
          final parts = _reminders[i].split(':');
          await _medicineRepository.createScheduleTime(
            schedule.id,
            timeOfDay: TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            ),
            orderIndex: i,
          );
        }
      } else {
        // Cập nhật
        currentMedicineId = widget.medicineId!;
        await _medicineRepository.updateMedicine(
          widget.medicineId!,
          name: _nameController.text,
          dosageStrength: _dosageController.text,
          dosageForm: _selectedType!,
          quantityPerDose: int.parse(_quantityController.text),
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        if (_existingSchedule != null) {
          // Xóa giờ cũ, thêm giờ mới (Đơn giản hóa logic update)
          for (var time in _editingMedicine!.scheduleTimes) {
            await _medicineRepository.deleteScheduleTime(time.id);
          }
          for (int i = 0; i < _reminders.length; i++) {
            final parts = _reminders[i].split(':');
            await _medicineRepository.createScheduleTime(
              _existingSchedule!.id,
              timeOfDay: TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              ),
              orderIndex: i,
            );
          }
        }
      }

      // 2. Xử lý Thông báo (Phần quan trọng đã sửa)
      final notificationService = NotificationService();

      // Hủy các thông báo cũ của thuốc này để tránh trùng lặp ID
      // (Vòng lặp giả định tối đa 20 mốc giờ để hủy sạch sẽ)
      for (int i = 0; i < 20; i++) {
        await notificationService.cancelNotification(
          NotificationService.generateNotificationId(currentMedicineId, i),
        );
      }

      // Thông báo Test ngay lập tức để người dùng yên tâm
      await notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '✅ Đã lưu thuốc',
        body: 'Sẽ nhắc vào: ${_reminders.join(", ")}',
      );

      // Lên lịch LẶP LẠI HÀNG NGÀY
      for (int i = 0; i < _reminders.length; i++) {
        final timeParts = _reminders[i].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        await notificationService.scheduleDailyNotification(
          id: NotificationService.generateNotificationId(currentMedicineId, i),
          title: 'Đến giờ uống thuốc! 💊',
          body:
              '${_nameController.text} - ${_dosageController.text}, ${_quantityController.text} viên',
          time: TimeOfDay(hour: hour, minute: minute),
          payload: 'medicine:${currentMedicineId}',
        );
      }

      // Debug: Ghi log lại danh sách thông báo đã lên lịch
      await notificationService.logPendingNotifications();

      if (mounted) {
        showCustomToast(
          context,
          message: 'Lưu thành công',
          subtitle: 'Đã đặt lịch nhắc thuốc',
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving medicine: $e');
      setState(() => _errorMessage = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleDelete() async {
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
          'Bạn chắc chắn muốn xóa "${_nameController.text}"? Hành động này không thể hoàn tác.',
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

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Xóa tất cả notifications của thuốc này
      final notificationService = NotificationService();
      for (int i = 0; i < 20; i++) {
        await notificationService.cancelNotification(
          NotificationService.generateNotificationId(widget.medicineId!, i),
        );
      }

      // Xóa thuốc khỏi database
      await _medicineRepository.deleteMedicine(widget.medicineId!);

      if (mounted) {
        showCustomToast(context, message: 'Xóa thành công', isSuccess: true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error deleting medicine: $e');
      setState(() => _errorMessage = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: Text(
          widget.medicineId == null ? 'Thêm thuốc mới' : 'Chỉnh sửa thuốc',
          style: const TextStyle(
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
              onTap: _isLoading ? null : _handleSave,
              child: Center(
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    color: _isLoading ? Colors.grey : const Color(0xFF196EB0),
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
              _buildSectionTitle('Thông tin thuốc'),
              const SizedBox(height: 16),
              _buildTextField('Tên thuốc', _nameController, 'Nhập tên thuốc'),
              const SizedBox(height: 16),
              _buildDropdown('Loại thuốc', _selectedType),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Liều lượng',
                      _dosageController,
                      'ví dụ: 500mg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Số viên/lần',
                      _quantityController,
                      'ví dụ: 1',
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle('Khoảng thời gian'),
              const SizedBox(height: 16),
              _buildDatePicker('Ngày bắt đầu', _startDate, _selectStartDate),
              const SizedBox(height: 16),
              _buildDatePicker(
                'Ngày kết thúc (tuỳ chọn)',
                _endDate,
                _selectEndDate,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle('Lịch uống thuốc'),
              const SizedBox(height: 16),
              _buildFrequencySelector(),
              const SizedBox(height: 20),
              const Text(
                'Thời gian uống',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildReminderList(),
              const SizedBox(height: 12),
              _buildAddReminderButton(),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle('Ghi chú thêm'),
              const SizedBox(height: 12),
              _buildTextField(
                'Ghi chú',
                _notesController,
                'Ví dụ: Uống sau ăn...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF196EB0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          widget.medicineId == null ? 'Thêm thuốc' : 'Cập nhật',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (widget.medicineId != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                        color: Color(0xFFDC2626),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xóa thuốc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets để code gọn hơn
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDBE0E6)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Chọn loại'),
              ),
              items: _medicineTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(e),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDBE0E6)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Không xác định',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 8,
      children: _frequencies.map((freq) {
        final isSelected = freq == _selectedFrequency;
        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = freq),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF196EB0) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF196EB0)
                    : const Color(0xFFDBE0E6),
              ),
            ),
            child: Text(
              freq,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectTime(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _deleteReminder(index),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddReminderButton() {
    return GestureDetector(
      onTap: _addReminder,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF196EB0), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF196EB0).withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Color(0xFF196EB0)),
            SizedBox(width: 8),
            Text(
              'Thêm thời gian',
              style: TextStyle(
                color: Color(0xFF196EB0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
