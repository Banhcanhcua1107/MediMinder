import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? text;

  const GoogleButton({super.key, this.onTap, this.text});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonText = text ?? l10n.continueWithGoogle;
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.language,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
