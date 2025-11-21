import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpAndSupport)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: l10n.faq,
            children: [
              _buildExpansionTile(
                'Làm sao để thêm thuốc?',
                'Nhấn vào nút + ở màn hình chính để thêm thuốc mới.',
              ),
              _buildExpansionTile(
                'Tôi có thể đổi ngôn ngữ không?',
                'Có, bạn có thể đổi ngôn ngữ trong phần Cài đặt -> Ngôn ngữ.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: l10n.contactUs,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: const Text('support@mediminder.com'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Hotline'),
                subtitle: const Text('1900 1234'),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(content, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
