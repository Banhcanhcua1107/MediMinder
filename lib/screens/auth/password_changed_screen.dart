import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

// --- Bảng màu thống nhất ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kSuccessColor = Color(0xFF10B981);

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success checkmark icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kSuccessColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              l10n.passwordChanged,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                l10n.passwordChangedSuccess,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8391A1),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Back to Login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 49),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF196EB0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.backToLogin,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
}
