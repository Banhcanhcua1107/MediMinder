import 'package:flutter/material.dart';
import 'add_med_screen.dart';

const Color kPrimaryColor = Color(0xFF1256DB);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  // Sample medicine data
  final List<Map<String, dynamic>> _medicines = [
    {
      'name': 'Paracetamol',
      'dosage': '500mg, 1 viên',
      'time': '08:00 Sáng',
      'status': 'Sắp tới',
      'icon': Icons.medication,
      'iconBg': const Color(0xFFDEEBFF),
    },
    {
      'name': 'Vitamin C',
      'dosage': '1000mg, 1 viên',
      'time': '12:00 Trưa',
      'status': 'Trong 4 giờ',
      'icon': Icons.vaccines,
      'iconBg': const Color(0xFFDEEBFF),
    },
    {
      'name': 'Amoxicillin',
      'dosage': '250mg, 2 viên',
      'time': '20:00 Tối',
      'status': 'Trong 12 giờ',
      'icon': Icons.local_drink,
      'iconBg': const Color(0xFFDEEBFF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: 120,
          ),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thuốc của bạn',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_medicines.length} loại thuốc đang dùng',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement history feature
                    },
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
                        Icons.history,
                        color: kSecondaryTextColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Medicine List
            ..._medicines.map((med) => _buildMedicineCard(med)),

            // Floating Action Button
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMedScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medicine['iconBg'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(medicine['icon'], color: kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Medicine Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine['dosage'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: kSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Time & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                medicine['time'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medicine['status'],
                style: const TextStyle(
                  fontSize: 12,
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
