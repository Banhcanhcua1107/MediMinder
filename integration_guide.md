# Hướng Dẫn Tích Hợp Nhắc Nhở Uống Thuốc (Flutter)

## 1. Thêm phụ thuộc vào `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^15.1.0+1   # phiên bản mới nhất
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  timezone: ^0.9.2
  get: ^4.6.5   # để lấy locale (không bắt buộc)
```
> **Lưu ý**: chạy `flutter pub get` sau khi sửa.

## 2. Cấu hình Hive & Timezone (thường trong `main.dart`)
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Đăng ký adapters (NotificationModel, DateTimeComponents, …)
  Hive.registerAdapter(NotificationModelAdapter());
  Hive.registerAdapter(DateTimeComponentsAdapter());
  await Hive.openBox<NotificationModel>('notifications');

  tz.initializeTimeZones();
  await _initFlutterLocalNotifications();

  runApp(MyApp());
}

Future<void> _initFlutterLocalNotifications() async {
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: initSettingsAndroid);
  await FlutterLocalNotificationsPlugin()
      .initialize(initSettings, onDidReceiveNotificationResponse: _onSelectNotification);
}

void _onSelectNotification(NotificationResponse response) {
  // Xử lý payload khi người dùng nhấn thông báo
  // Ví dụ: mở chi tiết thuốc dựa trên `response.payload`
}
``` 

## 3. Sao chép các file hỗ trợ từ dự án mẫu
- `lib/core/models/notification_model.dart`
- `lib/core/utils/notifications_helper.dart`
- `lib/features/notifications/entrypoints/notification_background_handler.dart`
- `lib/features/notifications/entrypoints/reschedule_notifications_entrypoint.dart`
- `lib/features/notifications/presentation/screens/notifications_tab.dart`

> **Cách**: tạo các thư mục tương tự trong dự án của bạn và dán nội dung file (đã có trong repo gốc).

## 4. Đăng ký background entry‑point (Android)
Mở `android/app/src/main/AndroidManifest.xml` và thêm:
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsReceiver" android:exported="true" />
```
Và trong `android/app/build.gradle` đảm bảo `minSdkVersion >= 21`.

## 5. Lên lịch thông báo khi người dùng thêm thuốc
```dart
import 'package:pills_reminder/core/utils/notifications_helper.dart';
import 'package:pills_reminder/core/models/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleMedicationReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  DateTimeComponents? repeat,
}) async {
  final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
  final notification = NotificationsHelper.buildNotification(
    id: id,
    title: title,
    body: body,
    time: tzTime,
    matchComponents: repeat,
    type: NotificationType.medication,
  );

  final box = await Hive.openBox<NotificationModel>('notifications');
  await box.put(id, notification);

  await FlutterLocalNotificationsPlugin().zonedSchedule(
    notification.id,
    notification.title,
    notification.body,
    notification.time,
    NotificationsHelper.getNotificationDetails(),
    payload: notification.payload,
    androidAllowWhileIdle: true,
    matchDateTimeComponents: notification.matchComponents,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```
- **`repeat`**: dùng `DateTimeComponents.time` (hàng ngày), `DateTimeComponents.dayOfWeekAndTime` (hàng tuần) …
- Khi người dùng nhấn **"Remind me in 30 minutes"**, gọi lại hàm trên với `scheduledTime = DateTime.now().add(Duration(minutes: 30))`.

## 6. Xử lý hành động "Mark as taken"
Trong `notifications_helper.dart` đã khai báo `AndroidNotificationAction('mark_done', ...)`. Khi người dùng chọn, callback `onDidReceiveNotificationResponse` sẽ nhận `actionId`. Thêm logic:
```dart
if (response.actionId == 'mark_done') {
  final payload = jsonDecode(response.payload!);
  final id = payload['id'];
  // Xóa thông báo và cập nhật trạng thái thuốc trong DB của bạn
}
```

## 7. Hiển thị danh sách thông báo trong UI
Sử dụng `notifications_tab.dart` làm mẫu:
```dart
class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NotificationModel>('notifications');
    return ValueListenableBuilder<Box<NotificationModel>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        final notifications = box.values.toList()
          ..sort((a, b) => a.time.compareTo(b.time));
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(notifications[i].title),
            subtitle: Text(notifications[i].body),
            trailing: Text(DateFormat.Hm().format(notifications[i].time)),
            onTap: () => _openMedicationDetail(notifications[i].payload),
          ),
        );
      },
    );
  }
}
```

## 8. Kiểm tra trên thiết bị thực
1. **Android**: bật **Allow background activity** cho app.
2. **iOS**: thêm quyền `UNUserNotificationCenter` và `requestPermissions` trong `AppDelegate`.
3. Kiểm tra 2 hành động (Mark as taken / Remind again) hoạt động đúng.

---
### Tổng kết
- Thêm phụ thuộc → cấu hình Hive & timezone → sao chép các helper.
- Lên lịch bằng `FlutterLocalNotificationsPlugin.zonedSchedule`.
- Xử lý background và hành động người dùng.
- Hiển thị UI danh sách.

Bạn chỉ cần sao chép các file trên, cập nhật `pubspec.yaml`, và gọi `scheduleMedicationReminder` khi người dùng nhập lịch uống thuốc.
