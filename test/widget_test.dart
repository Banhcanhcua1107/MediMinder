
import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/app.dart'; // ✅ thêm dòng này

void main() {
  testWidgets('App khởi tạo thành công', (WidgetTester tester) async {
    // Build ứng dụng và tạo frame
    await tester.pumpWidget(const MediMinderApp());

    // Kiểm tra xem widget đầu tiên hiển thị có text 'Welcome To' không
    expect(find.text('Welcome To'), findsOneWidget);
  });
}
