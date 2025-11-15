import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import 'health_screen.dart';

const Color kPrimaryColor = Color(0xFF2563EB);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);

class AddHealthProfileScreen extends StatefulWidget {
  const AddHealthProfileScreen({super.key});

  @override
  State<AddHealthProfileScreen> createState() => _AddHealthProfileScreenState();
}

class _AddHealthProfileScreenState extends State<AddHealthProfileScreen> {
  late TextEditingController _bmiController;
  late TextEditingController _bloodPressureController;
  late TextEditingController _heartRateController;
  late TextEditingController _glucoseController;
  late TextEditingController _cholesterolController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _bmiController = TextEditingController();
    _bloodPressureController = TextEditingController();
    _heartRateController = TextEditingController();
    _glucoseController = TextEditingController();
    _cholesterolController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _bmiController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _glucoseController.dispose();
    _cholesterolController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Validate inputs
    if (_bmiController.text.isEmpty) {
      showCustomToast(
        context,
        message: 'Vui lòng nhập',
        subtitle: 'Hãy nhập chỉ số BMI',
        isSuccess: false,
      );
      return;
    }

    if (_bloodPressureController.text.isEmpty) {
      showCustomToast(
        context,
        message: 'Vui lòng nhập',
        subtitle: 'Hãy nhập huyết áp',
        isSuccess: false,
      );
      return;
    }

    if (_heartRateController.text.isEmpty) {
      showCustomToast(
        context,
        message: 'Vui lòng nhập',
        subtitle: 'Hãy nhập nhịp tim',
        isSuccess: false,
      );
      return;
    }

    // Save success
    showCustomToast(
      context,
      message: 'Đã lưu thành công',
      subtitle: 'Các chỉ số sức khỏe của bạn đã được cập nhật',
      isSuccess: true,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
      }
    });
  }

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                        Icons.arrow_back,
                        color: kSecondaryTextColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    'Thêm Hồ sơ Sức khỏe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  SizedBox(width: 48), // Spacer
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),

                  // BMI Input
                  _buildFloatingLabelInput(
                    controller: _bmiController,
                    label: 'Chỉ số BMI',
                    placeholder: 'Nhập chỉ số BMI',
                  ),
                  const SizedBox(height: 16),

                  // Blood Pressure & Heart Rate
                  Row(
                    children: [
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _bloodPressureController,
                          label: 'Huyết áp',
                          placeholder: 'mmHg',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _heartRateController,
                          label: 'Nhịp tim',
                          placeholder: 'BPM',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Glucose Input
                  _buildFloatingLabelInput(
                    controller: _glucoseController,
                    label: 'Đường huyết',
                    placeholder: 'mg/dL',
                  ),
                  const SizedBox(height: 16),

                  // Cholesterol Input
                  _buildFloatingLabelInput(
                    controller: _cholesterolController,
                    label: 'Cholesterol',
                    placeholder: 'mg/dL',
                  ),
                  const SizedBox(height: 16),

                  // Notes Input
                  Container(
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              24,
                              20,
                              16,
                            ),
                            hintText: 'Thêm ghi chú...',
                            hintStyle: const TextStyle(
                              color: kSecondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(
                            color: kPrimaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 8,
                          child: Container(
                            color: kBackgroundColor,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: const Text(
                              'Ghi chú',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: _handleSave,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Lưu lại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLabelInput({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: kSecondaryTextColor,
                fontSize: 14,
              ),
            ),
            style: const TextStyle(color: kPrimaryTextColor, fontSize: 14),
          ),
          Positioned(
            left: 16,
            top: 8,
            child: Container(
              color: kBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSecondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
