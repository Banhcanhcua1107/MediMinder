import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddMedScreen extends StatefulWidget {
  const AddMedScreen({Key? key}) : super(key: key);

  @override
  State<AddMedScreen> createState() => _AddMedScreenState();
}

class _AddMedScreenState extends State<AddMedScreen> {
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;

  String? _selectedType;
  bool _alarmEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _medicineTypes = [
    'Viên Uống',
    'Hạt',
    'Viên Nén',
    'Dung Dịch',
    'Cao Dán',
    'Tiêm',
    'Khác',
  ];

  bool _isDropdownOpen = false;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _doseController = TextEditingController();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime tempSelectedDate = _selectedDate;
    TimeOfDay tempSelectedTime = _selectedTime;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: 750,
                height: 320,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                color: Color(0xFF196EB0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Text(
                            'Chọn Ngày Giờ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = tempSelectedDate;
                                _selectedTime = tempSelectedTime;
                                _dateController.text =
                                    '${tempSelectedDate.day.toString().padLeft(2, '0')}/${tempSelectedDate.month.toString().padLeft(2, '0')}/${tempSelectedDate.year}, ${tempSelectedTime.hour.toString().padLeft(2, '0')}:${tempSelectedTime.minute.toString().padLeft(2, '0')}';
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Xác Nhận',
                              style: TextStyle(
                                color: Color(0xFF196EB0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Pickers
                    Expanded(
                      child: Row(
                        children: [
                          // Date Picker
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem:
                                    tempSelectedDate.difference(now).inDays +
                                    10,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (int index) {
                                setDialogState(() {
                                  tempSelectedDate = now.add(
                                    Duration(days: index - 10),
                                  );
                                });
                              },
                              children: List<Widget>.generate(21, (int index) {
                                DateTime date = now.add(
                                  Duration(days: index - 10),
                                );
                                String dayName = '';
                                int daysDiff = date.difference(now).inDays;

                                if (daysDiff == 0) {
                                  dayName = 'Hôm Nay';
                                } else if (daysDiff == 1) {
                                  dayName = 'Ngày Mai';
                                } else if (daysDiff == -1) {
                                  dayName = 'Hôm Qua';
                                } else {
                                  const weekDays = [
                                    'Thứ 2',
                                    'Thứ 3',
                                    'Thứ 4',
                                    'Thứ 5',
                                    'Thứ 6',
                                    'Thứ 7',
                                    'CN',
                                  ];
                                  dayName = weekDays[date.weekday % 7];
                                }

                                return Center(
                                  child: Text(
                                    '$dayName ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: index == 10
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: index == 10
                                          ? const Color(0xFF196EB0)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Hour Picker
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: tempSelectedTime.hour,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (int index) {
                                setDialogState(() {
                                  tempSelectedTime = tempSelectedTime.replacing(
                                    hour: index,
                                  );
                                });
                              },
                              children: List<Widget>.generate(24, (int index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: index == tempSelectedTime.hour
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: index == tempSelectedTime.hour
                                          ? const Color(0xFF196EB0)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Minute Picker
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: tempSelectedTime.minute ~/ 5,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (int index) {
                                setDialogState(() {
                                  tempSelectedTime = tempSelectedTime.replacing(
                                    minute: index * 5,
                                  );
                                });
                              },
                              children: List<Widget>.generate(12, (int index) {
                                int minute = index * 5;
                                return Center(
                                  child: Text(
                                    minute.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          minute == tempSelectedTime.minute
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: minute == tempSelectedTime.minute
                                          ? const Color(0xFF196EB0)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleSave() {
    // Validation
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

    if (_doseController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập liều lượng';
      });
      return;
    }

    if (_amountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số lượng';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Save medicine to database
    // For now, just show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thuốc đã được thêm thành công!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _isLoading = false;
    });

    // Go back to home
    Navigator.pop(context);
  }

  Widget _buildCustomDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main dropdown button
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDropdownOpen || _selectedType != null
                    ? const Color(0xFF196EB0)
                    : const Color(0xFF9D9D9D),
                width: _isDropdownOpen || _selectedType != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedType ?? 'Chọn Loại Thuốc',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedType != null
                          ? Colors.black
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF196EB0),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // Dropdown list
        if (_isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medicineTypes.length,
              itemBuilder: (context, index) {
                final item = _medicineTypes[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = item;
                      _isDropdownOpen = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: index != _medicineTypes.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: const Color(0xFFEAECF0),
                                width: 1,
                              ),
                            )
                          : null,
                      color: item == _selectedType
                          ? const Color(0xFFDDF2FC)
                          : Colors.white,
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: item == _selectedType
                            ? const Color(0xFF196EB0)
                            : Colors.black,
                        fontWeight: item == _selectedType
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFEAECF0),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF040415),
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Thêm Thuốc Mới',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF196EB0),
                            letterSpacing: -1,
                          ),
                    ),
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Điền các trường và bấm nút Lưu để thêm!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF313131),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Name Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tên*',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'Tên thuốc (ví dụ: Ibuprofen)',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(77, 0, 0, 0),
                          fontSize: 19,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Type Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loại Thuốc*',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCustomDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dose Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liều Lượng*',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _doseController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'Liều lượng (ví dụ: 100mg)',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(77, 0, 0, 0),
                          fontSize: 19,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số Lượng*',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Số lượng (ví dụ: 3)',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(77, 0, 0, 0),
                          fontSize: 19,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Reminders Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Nhắc Nhở',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Date Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày Giờ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: const Color(0xFFBBBBBB),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dateController.text.isEmpty
                                    ? 'dd/mm/yyyy , 00:00'
                                    : _dateController.text,
                                style: const TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Alarm Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bật Chuông Báo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Switch(
                        value: _alarmEnabled,
                        onChanged: _isLoading
                            ? null
                            : (bool value) {
                                setState(() {
                                  _alarmEnabled = value;
                                });
                              },
                        activeColor: const Color(0xFF196EB0),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Error Message
              if (_errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF196EB0),
                      disabledBackgroundColor: const Color(
                        0xFF196EB0,
                      ).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Lưu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
