import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ManageMedScreen extends StatefulWidget {
  const ManageMedScreen({super.key});

  @override
  State<ManageMedScreen> createState() => _ManageMedScreenState();
}

class _ManageMedScreenState extends State<ManageMedScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFEAECF0), width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Calendar Icon
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
                      child: Icon(
                        Icons.calendar_today,
                        color: const Color(0xFFCDCDD0),
                        size: 24,
                      ),
                    ),

                    // Mood Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF2FC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text('😇', style: TextStyle(fontSize: 24)),
                    ),

                    // Settings Icon
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
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to settings
                        },
                        child: Icon(
                          Icons.settings,
                          color: const Color(0xFFCDCDD0),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Medicine Illustration
                    Container(
                      width: 242,
                      height: 235,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        'https://www.figma.com/api/mcp/asset/0fee8ae2-9e7c-473f-b63d-14e3cd89b812',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      l10n.manageHealth,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF196EB0),
                            height: 1.3,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 49),
                      child: Text(
                        'Thêm thuốc của bạn để được nhắc nhở đúng lúc và theo dõi sức khỏe',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFB8B8B8),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Add Medicine Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 49),
                      child: SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-med');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBBC05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFEAECF0),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                l10n.addMedicine,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Sign Out Button
                    GestureDetector(
                      onTap: () {
                        // Show sign out confirmation dialog
                        _showSignOutDialog(context);
                      },
                      child: Text(
                        l10n.logout,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFEA4335),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.signOutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform sign out
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                l10n.logout,
                style: TextStyle(color: Color(0xFFEA4335)),
              ),
            ),
          ],
        );
      },
    );
  }
}
