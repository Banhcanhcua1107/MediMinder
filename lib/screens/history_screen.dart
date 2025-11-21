import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../repositories/medicine_repository.dart';
import '../models/user_medicine.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final MedicineRepository _repository;
  late Future<List<MedicineIntake>> _intakesFuture;

  @override
  void initState() {
    super.initState();
    _repository = MedicineRepository(Supabase.instance.client);
    _loadIntakes();
  }

  void _loadIntakes() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _intakesFuture = _repository.getMedicineIntakes(user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicineHistory),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<MedicineIntake>>(
        future: _intakesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }

          final intakes = snapshot.data ?? [];

          if (intakes.isEmpty) {
            return Center(child: Text(l10n.noHistory));
          }

          // Group by date
          final groupedIntakes = <String, List<MedicineIntake>>{};
          for (var intake in intakes) {
            final dateStr = DateFormat(
              'dd/MM/yyyy',
            ).format(intake.scheduledDate);
            if (!groupedIntakes.containsKey(dateStr)) {
              groupedIntakes[dateStr] = [];
            }
            groupedIntakes[dateStr]!.add(intake);
          }

          // Sort dates descending
          final sortedDates = groupedIntakes.keys.toList()
            ..sort((a, b) {
              final dateA = DateFormat('dd/MM/yyyy').parse(a);
              final dateB = DateFormat('dd/MM/yyyy').parse(b);
              return dateB.compareTo(dateA);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateIntakes = groupedIntakes[date]!;

              // Sort intakes by time descending
              dateIntakes.sort((a, b) {
                final aMinutes =
                    a.scheduledTime.hour * 60 + a.scheduledTime.minute;
                final bMinutes =
                    b.scheduledTime.hour * 60 + b.scheduledTime.minute;
                return bMinutes.compareTo(aMinutes);
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  ...dateIntakes.map((intake) => _buildIntakeCard(intake)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIntakeCard(MedicineIntake intake) {
    final isTaken = intake.status == 'taken';
    final timeStr =
        '${intake.scheduledTime.hour.toString().padLeft(2, '0')}:${intake.scheduledTime.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTaken
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFF59E0B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTaken ? Icons.check : Icons.close,
            color: isTaken ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          ),
        ),
        title: Text(
          intake.medicineName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${intake.dosageStrength} • $timeStr',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        trailing: Text(
          isTaken ? 'Đã uống' : 'Bỏ qua',
          style: TextStyle(
            color: isTaken ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
