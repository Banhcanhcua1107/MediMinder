import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import '../l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/health_metrics_repository.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
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
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodPressureController;
  late TextEditingController _heartRateController;
  late TextEditingController _glucoseController;
  late TextEditingController _cholesterolController;
  late TextEditingController _notesController;

  double? _calculatedBmi;
  bool _isSaving = false;
  final _healthRepo = HealthMetricsRepository();

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bloodPressureController = TextEditingController();
    _heartRateController = TextEditingController();
    _glucoseController = TextEditingController();
    _cholesterolController = TextEditingController();
    _notesController = TextEditingController();

    // Listen to height and weight changes to recalculate BMI
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _glucoseController.dispose();
    _cholesterolController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Tính BMI từ chiều cao (cm) và cân nặng (kg)
  /// BMI = cân nặng (kg) / (chiều cao (m))^2
  void _calculateBmi() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      setState(() {
        _calculatedBmi = double.parse(bmi.toStringAsFixed(1));
      });
    } else {
      setState(() {
        _calculatedBmi = null;
      });
    }
  }

  void _handleSave() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate required inputs
    if (_heightController.text.isEmpty) {
      showCustomToast(
        context,
        message: l10n.pleaseEnter,
        subtitle: l10n.pleaseEnterHeight,
        isSuccess: false,
      );
      return;
    }

    if (_weightController.text.isEmpty) {
      showCustomToast(
        context,
        message: l10n.pleaseEnter,
        subtitle: l10n.pleaseEnterWeight,
        isSuccess: false,
      );
      return;
    }

    // Validate numeric inputs
    final heightVal = double.tryParse(_heightController.text);
    final weightVal = double.tryParse(_weightController.text);

    if (heightVal == null || heightVal <= 0) {
      showCustomToast(
        context,
        message: l10n.invalidHeight,
        subtitle: l10n.enterPositiveNumber,
        isSuccess: false,
      );
      return;
    }

    if (weightVal == null || weightVal <= 0) {
      showCustomToast(
        context,
        message: l10n.invalidWeight,
        subtitle: l10n.enterPositiveNumber,
        isSuccess: false,
      );
      return;
    }

    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Parse optional fields
      int? systolic;
      int? diastolic;
      if (_bloodPressureController.text.isNotEmpty) {
        final parts = _bloodPressureController.text.split('/');
        if (parts.length == 2) {
          systolic = int.tryParse(parts[0].trim());
          diastolic = int.tryParse(parts[1].trim());
        }
      }

      int? heartRate;
      if (_heartRateController.text.isNotEmpty) {
        heartRate = int.tryParse(_heartRateController.text);
      }

      double? glucose;
      if (_glucoseController.text.isNotEmpty) {
        glucose = double.tryParse(_glucoseController.text);
      }

      double? cholesterol;
      if (_cholesterolController.text.isNotEmpty) {
        cholesterol = double.tryParse(_cholesterolController.text);
      }

      // Save to database
      final existingProfile = await _healthRepo.getUserHealthProfile(userId);

      if (existingProfile == null) {
        // Create new profile
        await _healthRepo.createHealthProfile(
          userId,
          bmi: _calculatedBmi,
          bloodPressureSystolic: systolic,
          bloodPressureDiastolic: diastolic,
          heartRate: heartRate,
          glucoseLevel: glucose,
          cholesterolLevel: cholesterol,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // Update existing profile
        await _healthRepo.updateHealthProfile(
          userId,
          bmi: _calculatedBmi,
          bloodPressureSystolic: systolic,
          bloodPressureDiastolic: diastolic,
          heartRate: heartRate,
          glucoseLevel: glucose,
          cholesterolLevel: cholesterol,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      }

      if (!mounted) return;

      // Show success message
      showCustomToast(
        context,
        message: l10n.savedSuccessfully,
        subtitle: l10n.healthMetricsUpdated,
        isSuccess: true,
        duration: const Duration(seconds: 2),
      );

      // Navigate back after delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Pop back to HealthScreen (which is inside DashboardScreen with bottom bar)
      Navigator.pop(context);
    } catch (e) {
      print('Error saving health profile: $e');
      if (!mounted) return;

      showCustomToast(
        context,
        message: l10n.errorSaving,
        subtitle: '${l10n.tryAgain}: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(
                    l10n.manageHealth,
                    style: const TextStyle(
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

                  // Height & Weight Input
                  Row(
                    children: [
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _heightController,
                          label: l10n.height,
                          placeholder: 'cm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _weightController,
                          label: l10n.weight,
                          placeholder: 'kg',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BMI Display (calculated)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _calculatedBmi != null
                          ? const Color(0xFFE8F5E9)
                          : kCardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _calculatedBmi != null
                            ? Colors.green
                            : kBorderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bmiIndex,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: kSecondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_calculatedBmi != null)
                          Text(
                            '$_calculatedBmi (kg/m²)',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          )
                        else
                          Text(
                            l10n.enterHeightAndWeight,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kSecondaryTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blood Pressure & Heart Rate
                  Row(
                    children: [
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _bloodPressureController,
                          label: l10n.bloodPressure,
                          placeholder: 'mmHg',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFloatingLabelInput(
                          controller: _heartRateController,
                          label: l10n.heartRate,
                          placeholder: 'BPM',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Glucose Input
                  _buildFloatingLabelInput(
                    controller: _glucoseController,
                    label: l10n.glucoseLevel,
                    placeholder: 'mg/dL',
                  ),
                  const SizedBox(height: 16),

                  // Cholesterol Input
                  _buildFloatingLabelInput(
                    controller: _cholesterolController,
                    label: l10n.cholesterolLevel,
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
                            hintText: l10n.addNotes,
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
                            child: Text(
                              l10n.notes,
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
                  onTap: _isSaving ? null : _handleSave,
                  child: Opacity(
                    opacity: _isSaving ? 0.6 : 1.0,
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
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.save,
                                style: const TextStyle(
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
