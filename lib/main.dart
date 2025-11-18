import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'config/constants.dart';
import 'services/notification_service.dart';
import 'services/background_task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables từ .env file
  try {
    await dotenv.load(fileName: "lib/.env");
    debugPrint('✅ Environment variables loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Warning: Could not load .env file: $e');
    // Không return, vẫn tiếp tục chạy app
  }

  // Khởi tạo Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Supabase: $e');
    // Không return, vẫn tiếp tục chạy app
  }

  // Khởi tạo Notification Service
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    debugPrint('✅ Notification Service initialized');
  } catch (e) {
    debugPrint('❌ Error initializing Notification Service: $e');
  }

  // Khởi tạo Background Task Service
  try {
    final backgroundTaskService = BackgroundTaskService();
    await backgroundTaskService.initialize();
    // Lên lịch background tasks
    await backgroundTaskService.scheduleMedicineCheckTask();
    await backgroundTaskService.scheduleMedicineSyncTask();
    debugPrint('✅ Background Task Service initialized and scheduled');
  } catch (e) {
    debugPrint('❌ Error initializing Background Task Service: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const MediMinderAppOverride(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MediMinderAppOverride extends StatefulWidget {
  const MediMinderAppOverride({super.key});

  @override
  State<MediMinderAppOverride> createState() => _MediMinderAppOverrideState();
}

class _MediMinderAppOverrideState extends State<MediMinderAppOverride> {
  bool _isInitialized = false;
  late Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    // Lấy session hiện tại ngay lập tức
    final currentSession = supabase.auth.currentSession;
    debugPrint(
      '🔐 Initial session check: ${currentSession != null ? "Logged in - ${currentSession.user.email}" : "Not logged in"}',
    );

    // Tạo stream mới từ authStateChange
    _authStream = supabase.auth.onAuthStateChange;

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'MediMinder',
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'MediMinder',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: _authStream,
        builder: (context, snapshot) {
          // Kiểm tra xem có dữ liệu không
          if (snapshot.hasData) {
            final authState = snapshot.data;
            final session = authState?.session;
            final isLoggedIn = session != null;

            debugPrint(
              '🔐 Auth event - Event: ${authState?.event.name}, Logged in: $isLoggedIn, Session: ${session?.user.email ?? "null"}',
            );

            // Nếu đã đăng nhập → Home
            if (isLoggedIn) {
              debugPrint('✅ Navigating to /home - User: ${session.user.email}');
              return const MediMinderApp(initialRoute: '/home');
            }
            // Nếu chưa đăng nhập → Welcome
            else {
              debugPrint('✅ Navigating to / - Not authenticated');
              return const MediMinderApp(initialRoute: '/');
            }
          }

          // Nếu có lỗi
          if (snapshot.hasError) {
            debugPrint('❌ Auth error: ${snapshot.error}');
            // Fallback: check current session
            final currentSession = supabase.auth.currentSession;
            if (currentSession != null) {
              debugPrint('✅ Fallback to /home with current session');
              return const MediMinderApp(initialRoute: '/home');
            }
            debugPrint('✅ Fallback to / - No session');
            return const MediMinderApp(initialRoute: '/');
          }

          // Waiting state - show minimal UI
          debugPrint('⏳ Auth stream waiting for data...');
          return MaterialApp(
            title: 'MediMinder',
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
