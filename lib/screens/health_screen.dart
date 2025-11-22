import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_health_profile_screen.dart';
import '../repositories/health_metrics_repository.dart';
import '../models/health_metric.dart';
import '../services/health_assessment_service.dart';
import '../l10n/app_localizations.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kEmptyStateColor = Color(0xFFCBD5E1);
const Color kBorderColor = Color(0xFFE2E8F0);

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _healthRepo = HealthMetricsRepository();
  late String _userId;
  HealthProfile? _healthProfile;
  List<HealthMetric> _weeklyMetrics = [];
  bool _isLoading = true;
  BMIAssessment? _bmiAssessment;
  BloodPressureAssessment? _bpAssessment;
  HeartRateAssessment? _hrAssessment;
  GlucoseAssessment? _glucoseAssessment;
  CholesterolAssessment? _cholesterolAssessment;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _healthRepo.getUserHealthProfile(_userId);
      final weekly = await _healthRepo.getWeeklyMetrics(_userId);

      BMIAssessment? bmiAssessment;
      BloodPressureAssessment? bpAssessment;
      HeartRateAssessment? hrAssessment;
      GlucoseAssessment? glucoseAssessment;
      CholesterolAssessment? cholesterolAssessment;

      if (profile != null && profile.bmi != null) {
        bmiAssessment = HealthAssessmentService.assessBMI(profile.bmi!);
      }
      if (profile != null &&
          profile.bloodPressureSystolic != null &&
          profile.bloodPressureDiastolic != null) {
        bpAssessment = HealthAssessmentService.assessBloodPressure(
          profile.bloodPressureSystolic!,
          profile.bloodPressureDiastolic!,
        );
      }
      if (profile != null && profile.heartRate != null) {
        hrAssessment = HealthAssessmentService.assessHeartRate(
          profile.heartRate!,
        );
      }
      if (profile != null && profile.glucoseLevel != null) {
        glucoseAssessment = HealthAssessmentService.assessGlucose(
          profile.glucoseLevel!,
        );
      }
      if (profile != null && profile.cholesterolLevel != null) {
        cholesterolAssessment = HealthAssessmentService.assessCholesterol(
          profile.cholesterolLevel!,
        );
      }

      setState(() {
        _healthProfile = profile;
        _weeklyMetrics = weekly;
        _bmiAssessment = bmiAssessment;
        _bpAssessment = bpAssessment;
        _hrAssessment = hrAssessment;
        _glucoseAssessment = glucoseAssessment;
        _cholesterolAssessment = cholesterolAssessment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
      );
    }

    if (_healthProfile == null || !_healthProfile!.hasData) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 60,
                color: kEmptyStateColor,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noHealthInfo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.addInfoToStart,
                style: const TextStyle(
                  fontSize: 14,
                  color: kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHealthProfileScreen(),
                    ),
                  ).then((_) => _loadData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    l10n.enterInfo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myHealth,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.lastUpdated}: ${_healthProfile?.lastUpdatedAt.toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 13, color: kSecondaryTextColor),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddHealthProfileScreen(),
              ),
            ).then((_) => _loadData());
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: const Icon(Icons.add, size: 20, color: kPrimaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        if (_healthProfile!.bmi != null) ...[
          _buildBMICard(),
          const SizedBox(height: 16),
        ],
        if (_healthProfile!.bloodPressureSystolic != null ||
            _healthProfile!.heartRate != null ||
            _healthProfile!.glucoseLevel != null ||
            _healthProfile!.cholesterolLevel != null) ...[
          _buildVitalsRow(),
          const SizedBox(height: 16),
        ],
        if (_bmiAssessment != null ||
            _bpAssessment != null ||
            _hrAssessment != null ||
            _glucoseAssessment != null ||
            _cholesterolAssessment != null) ...[
          _buildAssessmentCard(),
          const SizedBox(height: 16),
        ],
        if (_weeklyMetrics.isNotEmpty)
          _buildWeeklyChart()
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildBMICard() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.scale,
                      color: Color(0xFF6366F1),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.bmiStatus,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ],
              ),
              Text(
                _healthProfile!.bmi?.toStringAsFixed(1) ?? '0',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_bmiAssessment != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    '●',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(_bmiAssessment!.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLocalizedText(l10n, _bmiAssessment!.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(_bmiAssessment!.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_healthProfile!.bmi ?? 0) / 40,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsRow() {
    final l10n = AppLocalizations.of(context)!;

    // Collect all available vitals
    final vitals = <Widget>[];

    if (_healthProfile!.bloodPressureSystolic != null) {
      vitals.add(
        _buildVitalCard(
          icon: Icons.favorite,
          color: Colors.red,
          bg: const Color(0xFFFFE4E6),
          title: l10n.bloodPressureStatus,
          value:
              '${_healthProfile!.bloodPressureSystolic}/${_healthProfile!.bloodPressureDiastolic ?? 0}',
          unit: l10n.mmHg,
          assessment: _bpAssessment,
          l10n: l10n,
        ),
      );
    }

    if (_healthProfile!.heartRate != null) {
      vitals.add(
        _buildVitalCard(
          icon: Icons.favorite,
          color: Colors.pink,
          bg: const Color(0xFFFFEAF2),
          title: l10n.heartRateStatus,
          value: _healthProfile!.heartRate.toString(),
          unit: l10n.bpm,
          assessment: _hrAssessment,
          l10n: l10n,
        ),
      );
    }

    if (_healthProfile!.glucoseLevel != null) {
      vitals.add(
        _buildVitalCard(
          icon: Icons.bloodtype_outlined,
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFEF3C7),
          title: l10n.glucoseStatus,
          value: _healthProfile!.glucoseLevel!.toStringAsFixed(0),
          unit: l10n.mgDL,
          assessment: _glucoseAssessment,
          l10n: l10n,
        ),
      );
    }

    if (_healthProfile!.cholesterolLevel != null) {
      vitals.add(
        _buildVitalCard(
          icon: Icons.medical_services_outlined,
          color: const Color(0xFF8B5CF6),
          bg: const Color(0xFFF3E8FF),
          title: l10n.cholesterolStatus,
          value: _healthProfile!.cholesterolLevel!.toStringAsFixed(0),
          unit: l10n.mgDL,
          assessment: _cholesterolAssessment,
          l10n: l10n,
        ),
      );
    }

    // Create grid based on number of vitals
    if (vitals.isEmpty) return const SizedBox.shrink();

    if (vitals.length == 1) {
      return vitals[0];
    } else if (vitals.length == 2) {
      return Row(
        children: [
          Expanded(child: vitals[0]),
          const SizedBox(width: 12),
          Expanded(child: vitals[1]),
        ],
      );
    } else if (vitals.length == 3) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: vitals[0]),
              const SizedBox(width: 12),
              Expanded(child: vitals[1]),
            ],
          ),
          const SizedBox(height: 12),
          vitals[2],
        ],
      );
    } else {
      // 4 vitals - 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: vitals[0]),
              const SizedBox(width: 12),
              Expanded(child: vitals[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: vitals[2]),
              const SizedBox(width: 12),
              Expanded(child: vitals[3]),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildVitalCard({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String value,
    required String unit,
    dynamic assessment,
    dynamic l10n,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(fontSize: 11, color: kSecondaryTextColor),
          ),
          if (assessment != null) ...[
            const SizedBox(height: 8),
            Text(
              _getLocalizedText(l10n, assessment.category),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(assessment.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final l10n = AppLocalizations.of(context)!;
    final grouped = <String, List<HealthMetric>>{};
    for (var m in _weeklyMetrics) {
      final d = m.measuredAt.toString().split(' ')[0];
      grouped.putIfAbsent(d, () => []).add(m);
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyProgress,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: grouped.entries
                  .map((e) => _buildBar(e.key, e.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String date, List<HealthMetric> metrics) {
    final avg = metrics.where((m) => m.valueNumeric != null).isEmpty
        ? 0.0
        : metrics
                  .where((m) => m.valueNumeric != null)
                  .map((m) => m.valueNumeric!)
                  .reduce((a, b) => a + b) /
              metrics.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              width: 30,
              color: kPrimaryColor,
              child: FractionallySizedBox(
                heightFactor: (avg / 100).clamp(0.0, 1.0),
                alignment: Alignment.bottomCenter,
                child: Container(color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date.split('-').last,
            style: const TextStyle(fontSize: 10, color: kSecondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Build health assessment card showing all evaluations
  Widget _buildAssessmentCard() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthAssessment,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          if (_bmiAssessment != null) ...[
            _buildAssessmentRow(
              l10n.bmiStatus,
              _getLocalizedText(l10n, _bmiAssessment!.category),
              _bmiAssessment!.status,
              l10n.bmiRecommendation,
            ),
            const SizedBox(height: 12),
          ],
          if (_bpAssessment != null) ...[
            _buildAssessmentRow(
              l10n.bloodPressureStatus,
              _getLocalizedText(l10n, _bpAssessment!.category),
              _bpAssessment!.status,
              l10n.bpRecommendation,
            ),
            const SizedBox(height: 12),
          ],
          if (_hrAssessment != null) ...[
            _buildAssessmentRow(
              l10n.heartRateStatus,
              _getLocalizedText(l10n, _hrAssessment!.category),
              _hrAssessment!.status,
              l10n.hrRecommendation,
            ),
            const SizedBox(height: 12),
          ],
          if (_glucoseAssessment != null) ...[
            _buildAssessmentRow(
              l10n.glucoseStatus,
              _getLocalizedText(l10n, _glucoseAssessment!.category),
              _glucoseAssessment!.status,
              l10n.glucoseRecommendation,
            ),
            const SizedBox(height: 12),
          ],
          if (_cholesterolAssessment != null) ...[
            _buildAssessmentRow(
              l10n.cholesterolStatus,
              _getLocalizedText(l10n, _cholesterolAssessment!.category),
              _cholesterolAssessment!.status,
              l10n.cholesterolRecommendation,
            ),
          ],
        ],
      ),
    );
  }

  /// Build individual assessment row
  Widget _buildAssessmentRow(
    String title,
    String status,
    String statusLevel,
    String recommendation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kPrimaryTextColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(statusLevel).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(statusLevel),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          recommendation,
          style: const TextStyle(
            fontSize: 11,
            color: kSecondaryTextColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'good':
        return const Color(0xFF10B981); // Green
      case 'normal':
        return const Color(0xFF3B82F6); // Blue
      case 'caution':
        return const Color(0xFFF59E0B); // Amber
      case 'warning':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Helper method to get localized text for health categories
  String _getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      case 'bmiUnderweight':
        return l10n.bmiUnderweight;
      case 'bmiNormal':
        return l10n.bmiNormal;
      case 'bmiOverweight':
        return l10n.bmiOverweight;
      case 'bmiObese':
        return l10n.bmiObese;
      case 'bpNormal':
        return l10n.bpNormal;
      case 'bpElevated':
        return l10n.bpElevated;
      case 'bpStage1':
        return l10n.bpStage1;
      case 'bpStage2':
        return l10n.bpStage2;
      case 'bpCritical':
        return l10n.bpCritical;
      case 'hrNormal':
        return l10n.hrNormal;
      case 'hrSlow':
        return l10n.hrSlow;
      case 'hrFast':
        return l10n.hrFast;
      case 'glucoseLow':
        return l10n.glucoseLow;
      case 'glucoseNormal':
        return l10n.glucoseNormal;
      case 'glucosePrediabetic':
        return l10n.glucosePrediabetic;
      case 'glucoseDiabetic':
        return l10n.glucoseDiabetic;
      case 'glucoseHigh':
        return l10n.glucoseHigh;
      case 'cholesterolDesirable':
        return l10n.cholesterolDesirable;
      case 'cholesterolBorderline':
        return l10n.cholesterolBorderline;
      case 'cholesterolHigh':
        return l10n.cholesterolHigh;
      default:
        return key;
    }
  }
}
