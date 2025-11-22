import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_health_profile_screen.dart';
import '../repositories/health_metrics_repository.dart';
import '../models/health_metric.dart';

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
      setState(() {
        _healthProfile = profile;
        _weeklyMetrics = weekly;
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
              const Text(
                'Chưa có thông tin sức khỏe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Thêm thông tin để bắt đầu theo dõi',
                style: TextStyle(fontSize: 14, color: kSecondaryTextColor),
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
                  child: const Text(
                    'Nhập thông tin',
                    style: TextStyle(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sức khỏe của tôi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cập nhật: ${_healthProfile?.lastUpdatedAt.toString().split(' ')[0]}',
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
            _healthProfile!.heartRate != null) ...[
          _buildVitalsRow(),
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
                  const Text(
                    'BMI',
                    style: TextStyle(
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
          const SizedBox(height: 14),
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
    return Row(
      children: [
        if (_healthProfile!.bloodPressureSystolic != null)
          Expanded(
            child: _buildVitalCard(
              icon: Icons.favorite,
              color: Colors.red,
              bg: const Color(0xFFFFE4E6),
              title: 'Huyết áp',
              value:
                  '${_healthProfile!.bloodPressureSystolic}/${_healthProfile!.bloodPressureDiastolic ?? 0}',
              unit: 'mmHg',
            ),
          ),
        if (_healthProfile!.bloodPressureSystolic != null &&
            _healthProfile!.heartRate != null)
          const SizedBox(width: 12),
        if (_healthProfile!.heartRate != null)
          Expanded(
            child: _buildVitalCard(
              icon: Icons.favorite,
              color: Colors.pink,
              bg: const Color(0xFFFFEAF2),
              title: 'Nhịp tim',
              value: _healthProfile!.heartRate.toString(),
              unit: 'BPM',
            ),
          ),
      ],
    );
  }

  Widget _buildVitalCard({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String value,
    required String unit,
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
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final grouped = <String, List<HealthMetric>>{};
    for (var m in _weeklyMetrics) {
      final d = m.measuredAt.toString().split(' ')[0];
      grouped.putIfAbsent(d, () => []).add(m);
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến độ tuần',
            style: TextStyle(
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
}
