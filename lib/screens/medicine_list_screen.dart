import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'add_med_screen.dart';
import 'history_screen.dart';
import '../models/user_medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/custom_toast.dart';
import '../l10n/app_localizations.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
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
  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MedicineProvider>(
          context,
          listen: false,
        ).fetchMedicines(user.id);
      });
    }
  }

  // _loadMedicines removed as it is handled by provider

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.medicines.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('${l10n.error}: ${provider.error}'));
            }

            final medicines = provider.medicines;

            return ListView(
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
                          Text(
                            l10n.yourMedicines,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medicines.length} ${l10n.medicinesInUse}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
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
                if (medicines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        l10n.noMedicinesAdded,
                        style: TextStyle(
                          fontSize: 14,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                  )
                else
                  ...medicines.map((med) => _buildMedicineCard(context, med)),

                // Floating Action Button
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddMedScreen(),
                          ),
                        );

                        if (result == true) {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            Provider.of<MedicineProvider>(
                              context,
                              listen: false,
                            ).fetchMedicines(user.id);
                          }
                        }
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
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, UserMedicine medicine) {
    final nextTime = medicine.getNextIntakeTime();
    final timeUntilText = medicine.getTimeUntilNextIntakeText();

    return Dismissible(
      key: Key(medicine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
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
              'Bạn chắc chắn muốn xóa "${medicine.name}"?',
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
        return shouldDelete ?? false;
      },
      onDismissed: (direction) async {
        try {
          // Xóa thuốc via provider
          await Provider.of<MedicineProvider>(
            context,
            listen: false,
          ).deleteMedicine(medicine.id);

          if (mounted) {
            showCustomToast(
              context,
              message: 'Đã xóa ${medicine.name}',
              isSuccess: true,
            );
          }
        } catch (e) {
          if (mounted) {
            showCustomToast(
              context,
              message: 'Lỗi khi xóa: $e',
              isSuccess: false,
            );
          }
        }
      },
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedScreen(medicineId: medicine.id),
            ),
          );

          if (result == true) {
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              Provider.of<MedicineProvider>(
                context,
                listen: false,
              ).fetchMedicines(user.id);
            }
          }
        },
        child: Container(
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
                  color: const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMedicineIcon(medicine.dosageForm),
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Medicine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
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
                  if (nextTime != null)
                    Text(
                      '${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryTextColor,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    timeUntilText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMedicineIcon(String dosageForm) {
    switch (dosageForm.toLowerCase()) {
      case 'tablet':
      case 'viên nén':
        return Icons.medication;
      case 'capsule':
      case 'viên nang':
        return Icons.vaccines;
      case 'liquid':
      case 'siro':
        return Icons.local_drink;
      case 'injection':
      case 'thuốc tiêm':
        return Icons.medical_services;
      default:
        return Icons.medication;
    }
  }
}
