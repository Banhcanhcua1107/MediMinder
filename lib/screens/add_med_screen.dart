import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

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

  int? _medicineTypeIndex; // 0=tablet, 1=capsule, 2=syrup, 3=injection
  String _selectedFrequency = '';
  int _frequencyIndex = 0; // 0 = daily, 1 = every other day, 2 = custom
  List<bool> _selectedWeekDays = List.filled(7, false);
  List<String> _reminders = [];
  bool _isLoading = false;
  bool _isFetchingData = false;
  String? _errorMessage;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  late MedicineRepository _medicineRepository;
  UserMedicine? _editingMedicine;
  MedicineSchedule? _existingSchedule;

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    _medicineRepository = MedicineRepository(supabase);

    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();

    // Set default frequency after localization is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted && _selectedFrequency.isEmpty) {
        setState(() {
          _selectedFrequency = l10n.daily;
        });
      }
    });

    // Mặc định không có giờ uống
    _reminders = [];

    if (widget.medicineId != null) {
      _isFetchingData = true;
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
          // Map dosage form to index (0=tablet, 1=capsule, 2=syrup, 3=injection)
          final dosageForm = _editingMedicine!.dosageForm.toLowerCase();
          if (dosageForm.contains('capsule') ||
              dosageForm.contains('viên nang')) {
            _medicineTypeIndex = 1;
          } else if (dosageForm.contains('syrup') ||
              dosageForm.contains('siro')) {
            _medicineTypeIndex = 2;
          } else if (dosageForm.contains('injection') ||
              dosageForm.contains('tiêm')) {
            _medicineTypeIndex = 3;
          } else {
            _medicineTypeIndex = 0; // default to tablet
          }
          _startDate = _editingMedicine!.startDate;
          _endDate = _editingMedicine!.endDate;

          if (_editingMedicine!.scheduleTimes.isNotEmpty) {
            _reminders = _editingMedicine!.scheduleTimes
                .map((t) => t.getTimeText())
                .toList();
          }

          if (_editingMedicine!.schedules.isNotEmpty) {
            _existingSchedule = _editingMedicine!.schedules.first;
            // Map frequency type to index
            if (_existingSchedule!.frequencyType == 'daily') {
              _frequencyIndex = 0;
            } else if (_existingSchedule!.frequencyType == 'alternate_days') {
              _frequencyIndex = 1;
            } else {
              _frequencyIndex = 2;
            }

            if (_existingSchedule!.daysOfWeek != null &&
                _existingSchedule!.daysOfWeek!.length == 7) {
              _selectedWeekDays = _existingSchedule!.daysOfWeek!
                  .split('')
                  .map((e) => e == '1')
                  .toList();
            }
          }
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error loading medicine: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingData = false;
        });
      }
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

  List<String> _getMedicineTypes(AppLocalizations l10n) => [
    l10n.tablet,
    l10n.capsule,
    l10n.syrup,
    l10n.injection,
  ];

  List<String> _getFrequencies(AppLocalizations l10n) => [
    l10n.daily,
    l10n.everyOtherDay,
    l10n.custom,
  ];

  Future<void> _selectTime(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final timeStr = _reminders[index];
    final parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectIntakeTimes,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF196EB0),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: DateTime(2024, 1, 1, hour, minute),
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  itemExtent: 50,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      _reminders[index] =
                          '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF196EB0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.done,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
    // Validation
    if (_nameController.text.isEmpty ||
        _medicineTypeIndex == null ||
        _dosageController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _reminders.isEmpty) {
      setState(() => _errorMessage = l10n.emptyField);
      return;
    }

    if (_frequencyIndex == 2 && !_selectedWeekDays.contains(true)) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _errorMessage = l10n.selectAtLeastOneDay);
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
          dosageForm: _getMedicineTypes(l10n)[_medicineTypeIndex ?? 0],
          quantityPerDose: int.parse(_quantityController.text),
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        currentMedicineId = medicine.id;

        final schedule = await _medicineRepository.createSchedule(
          medicine.id,
          frequencyType: _frequencyIndex == 0
              ? 'daily'
              : _frequencyIndex == 1
              ? 'alternate_days'
              : 'custom',
          daysOfWeek: _frequencyIndex == 2
              ? _selectedWeekDays.map((e) => e ? '1' : '0').join('')
              : null,
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
          dosageForm: _getMedicineTypes(l10n)[_medicineTypeIndex ?? 0],
          quantityPerDose: int.parse(_quantityController.text),
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        if (_existingSchedule != null) {
          await _medicineRepository.updateSchedule(
            _existingSchedule!.id,
            frequencyType: _frequencyIndex == 0
                ? 'daily'
                : _frequencyIndex == 1
                ? 'alternate_days'
                : 'custom',
            daysOfWeek: _frequencyIndex == 2
                ? _selectedWeekDays.map((e) => e ? '1' : '0').join('')
                : null,
          );

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
          message: l10n.addMedicineSuccess,
          subtitle: l10n.reminderSet,
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving medicine: $e');
      setState(() => _errorMessage = '${l10n.error}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          l10n.deleteConfirmTitle,
          style: const TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          l10n.deleteConfirmMessage('"${_nameController.text}"'),
          style: const TextStyle(color: Color(0xFF666D80), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF666D80)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.confirmDelete,
              style: const TextStyle(color: Color(0xFFDC2626)),
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
        final l10n = AppLocalizations.of(context)!;
        showCustomToast(
          context,
          message: l10n.medicineDeletedSuccessfully,
          isSuccess: true,
        );
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
    final l10n = AppLocalizations.of(context)!;
    if (_isFetchingData) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7F8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF196EB0)),
        ),
      );
    }

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
          widget.medicineId == null ? l10n.addNewMedicine : l10n.editMedicine,
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
                  l10n.save,
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
              _buildSectionTitle(l10n.medicineInfo),
              const SizedBox(height: 16),
              _buildTextField(
                l10n.medicineName,
                _nameController,
                l10n.enterMedicineName,
              ),
              const SizedBox(height: 16),
              _buildDropdown(l10n.medicineType, _medicineTypeIndex, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.dosage,
                      _dosageController,
                      l10n.exampleDosage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      l10n.quantity,
                      _quantityController,
                      l10n.exampleQuantity,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle(l10n.timeFrame),
              const SizedBox(height: 16),
              _buildDurationSelector(l10n),
              const SizedBox(height: 16),
              _buildDatePicker(l10n.startDate, _startDate, _selectStartDate),
              const SizedBox(height: 16),
              _buildDatePicker(l10n.endDate, _endDate, _selectEndDate),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle(l10n.medicineSchedule),
              const SizedBox(height: 16),
              _buildFrequencySelector(l10n),
              const SizedBox(height: 20),
              Text(
                l10n.timeTaken,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildReminderList(),
              const SizedBox(height: 12),
              _buildAddReminderButton(l10n),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildSectionTitle(l10n.additionalNotes),
              const SizedBox(height: 12),
              _buildTextField(
                l10n.notes,
                _notesController,
                l10n.exampleNotes,
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
                          widget.medicineId == null
                              ? l10n.addMedicine
                              : l10n.update,
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
                    child: Text(
                      l10n.deleteMedicine,
                      style: const TextStyle(
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

  Widget _buildDropdown(String label, int? value, AppLocalizations l10n) {
    final items = _getMedicineTypes(l10n);
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
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.selectType),
              ),
              items: items.asMap().entries.map((entry) {
                int index = entry.key;
                String text = entry.value;
                return DropdownMenuItem<int>(
                  value: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(text),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _medicineTypeIndex = v),
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

  Widget _buildFrequencySelector(AppLocalizations l10n) {
    final frequencies = _getFrequencies(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: frequencies.asMap().entries.map((entry) {
            int index = entry.key;
            String freq = entry.value;
            final isSelected = index == _frequencyIndex;
            return GestureDetector(
              onTap: () => setState(() => _frequencyIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_frequencyIndex == 2) ...[
          const SizedBox(height: 16),
          Text(
            l10n.selectDaysOfWeek,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildWeekDaySelector(),
        ],
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _selectedWeekDays[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedWeekDays[index] = !_selectedWeekDays[index];
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF196EB0) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF196EB0)
                    : const Color(0xFFDBE0E6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
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

  Widget _buildAddReminderButton(AppLocalizations l10n) {
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
          children: [
            const Icon(Icons.add, color: Color(0xFF196EB0)),
            const SizedBox(width: 8),
            Text(
              l10n.addTime,
              style: const TextStyle(
                color: Color(0xFF196EB0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(AppLocalizations l10n) {
    final durations = [7, 14, 30];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.timeTaken,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...durations.map((days) {
                final isSelected =
                    _endDate != null &&
                    _endDate!.difference(_startDate).inDays == days;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$days ${l10n.durationDays}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _endDate = _startDate.add(Duration(days: days));
                        });
                      }
                    },
                    selectedColor: const Color(0xFF196EB0),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
              ChoiceChip(
                label: Text(l10n.custom),
                selected:
                    _endDate != null &&
                    !durations.contains(
                      _endDate!.difference(_startDate).inDays,
                    ),
                onSelected: (selected) {
                  if (selected) {
                    _selectEndDate();
                  }
                },
                selectedColor: const Color(0xFF196EB0),
                labelStyle: TextStyle(
                  color:
                      (_endDate != null &&
                          !durations.contains(
                            _endDate!.difference(_startDate).inDays,
                          ))
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
