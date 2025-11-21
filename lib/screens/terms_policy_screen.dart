import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsAndPrivacy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: l10n.termsOfService,
              content: '''
1. Chấp nhận điều khoản
Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản sử dụng của chúng tôi.

2. Sử dụng ứng dụng
Bạn cam kết sử dụng ứng dụng cho mục đích cá nhân và không vi phạm pháp luật.

3. Thay đổi điều khoản
Chúng tôi có quyền thay đổi các điều khoản này bất cứ lúc nào.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: l10n.privacyPolicy,
              content: '''
1. Thu thập thông tin
Chúng tôi thu thập thông tin cơ bản để cung cấp dịch vụ tốt nhất cho bạn.

2. Bảo mật thông tin
Thông tin của bạn được bảo mật và không chia sẻ với bên thứ ba nếu không có sự đồng ý của bạn.

3. Quyền của người dùng
Bạn có quyền yêu cầu xóa dữ liệu của mình bất cứ lúc nào.
              ''',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
