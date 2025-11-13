/// File ví dụ - Cách integrate Supabase & Cloudinary vào project
///
/// Bạn có thể copy-paste những đoạn code này vào screens của bạn

// ============================================================
// EXAMPLE 1: Upload ảnh profile và lưu vào database Supabase
// ============================================================

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _namController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _uploadedImageUrl;

  Future<void> _uploadAndSaveProfile() async {
    try {
      // Bước 1: Upload ảnh lên Cloudinary
      final imageProvider = context.read<ImageUploadProvider>();
      final imagePath = _uploadedImageUrl; // Lấy từ _pickImage()

      bool uploadSuccess = await imageProvider.uploadImage(imagePath!);
      if (!uploadSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload: ${imageProvider.errorMessage}')),
        );
        return;
      }

      final imageUrl = imageProvider.uploadedImageUrl;

      // Bước 2: Lưu profile vào Supabase
      final supabase = SupabaseService();
      final user = supabase.getCurrentUser();

      await supabase.insertIntoTable('profiles', {
        'user_id': user?.id,
        'full_name': _namController.text,
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật profile thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedImageUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ảnh đại diện
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: _uploadedImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_uploadedImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _uploadedImageUrl == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            // Input tên
            TextField(
              controller: _namController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Nút lưu
            ElevatedButton(
              onPressed: _uploadAndSaveProfile,
              child: const Text('Cập nhật Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============================================================
// EXAMPLE 2: Lấy danh sách ảnh của user từ database
// ============================================================

/*
Future<List<String>> getUserImages(String userId) async {
  final supabase = SupabaseService().client;
  
  final data = await supabase
      .from('user_images')
      .select('image_url')
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  final List<String> imageUrls = [];
  for (var item in data) {
    imageUrls.add(item['image_url']);
  }

  return imageUrls;
}
*/

// ============================================================
// EXAMPLE 3: Authentication flow
// ============================================================

/*
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final authProvider = context.read<AuthProvider>();
    
    bool success = await authProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success) {
      // Điều hướng đến home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Lỗi đăng nhập')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============================================================
// EXAMPLE 4: Real-time updates từ Supabase
// ============================================================

/*
class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({Key? key}) : super(key: key);

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  late RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    final supabase = SupabaseService().client;
    
    _channel = supabase.channel('medicines').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'medicines',
      ),
      (payload, [ref]) {
        print('Medicines changed: ${payload.eventType}');
        // Cập nhật UI khi dữ liệu thay đổi
        setState(() {});
      },
    ).subscribe();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách thuốc')),
      body: FutureBuilder(
        future: SupabaseService().getFromTable('medicines'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final medicines = snapshot.data as List;

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return ListTile(
                title: Text(medicine['name']),
                subtitle: Text(medicine['dosage']),
              );
            },
          );
        },
      ),
    );
  }
}
*/

// ============================================================
// EXAMPLE 5: Xóa ảnh từ Cloudinary
// ============================================================

/*
Future<void> deleteUserImage(String publicId) async {
  final cloudinary = CloudinaryService();
  
  try {
    await cloudinary.deleteImage(publicId);
    print('Xóa ảnh thành công');
  } catch (e) {
    print('Lỗi xóa ảnh: $e');
  }
}
*/

// ============================================================
// EXAMPLE 6: Upload nhiều ảnh cùng lúc
// ============================================================

/*
Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
  final cloudinary = CloudinaryService();
  final uploadedUrls = <String>[];

  for (String path in imagePaths) {
    try {
      final url = await cloudinary.uploadImage(
        filePath: path,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}',
      );
      uploadedUrls.add(url);
    } catch (e) {
      print('Lỗi upload ảnh $path: $e');
    }
  }

  return uploadedUrls;
}
*/

void _exampleNothing() {}
