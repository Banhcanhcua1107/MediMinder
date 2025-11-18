import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_toast.dart';
import '../services/user_service.dart';
import '../services/cloudinary_service.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;
  String? _avatarUrl; // Lưu URL avatar

  // Form controllers
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _fullNameController = TextEditingController(text: '');
    _dobController = TextEditingController(text: '');
    _genderController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    // Then load data from Supabase
    _initializeUser();
  }

  /// Initialize user: create in public.users if not exists, then load data
  Future<void> _initializeUser() async {
    try {
      final userService = UserService();
      final userId = userService.getCurrentUserId();
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (userId == null || currentUser == null) {
        debugPrint('❌ User not authenticated');
        return;
      }

      // Try to get existing user from public.users
      var userInfo = await userService.getUserInfo(userId);

      // If user doesn't exist in public.users, create it
      if (userInfo == null) {
        debugPrint('📝 User not found in public.users, creating...');
        final fullName =
            currentUser.userMetadata?['full_name'] ??
            currentUser.email?.split('@').first ??
            'User';

        try {
          await Supabase.instance.client.from('users').insert({
            'id': userId,
            'email': currentUser.email,
            'full_name': fullName,
            'is_verified': false,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('✅ User created in public.users');

          // Reload user info
          userInfo = await userService.getUserInfo(userId);
        } catch (e) {
          debugPrint('⚠️ Error creating user in public.users: $e');
        }
      }

      // Load user data
      if (userInfo != null && mounted) {
        _fullNameController.text = userInfo['full_name'] ?? '';
        _emailController.text = userInfo['email'] ?? '';
        _avatarUrl = userInfo['avatar_url']; // Load avatar URL từ DB
        _dobController.text = userInfo['date_of_birth'] ?? '';
        _genderController.text = userInfo['gender'] ?? '';
        _phoneController.text = userInfo['phone_number'] ?? '';

        debugPrint(
          '✅ User data loaded from Supabase: ${userInfo['full_name']}',
        );
        debugPrint('🖼️ Avatar URL: $_avatarUrl');
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    try {
      final userService = UserService();
      final userId = userService.getCurrentUserId();

      if (userId == null) {
        debugPrint('❌ User ID not found');
        return;
      }

      // Update user info on Supabase - gửi TẤT CẢ các field
      final success = await userService.updateUserInfo(
        userId: userId,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        dateOfBirth: _dobController.text.isNotEmpty
            ? _dobController.text
            : null,
        gender: _genderController.text.isNotEmpty
            ? _genderController.text
            : null,
      );

      if (success && mounted) {
        setState(() {
          _isEditing = false;
        });
        showCustomToast(
          context,
          message: 'Cập nhật thành công',
          subtitle: 'Thông tin của bạn đã được lưu',
          isSuccess: true,
        );
        debugPrint('✅ User data saved to Supabase');
      }
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      if (mounted) {
        showCustomToast(
          context,
          message: 'Lỗi khi lưu',
          subtitle: 'Vui lòng thử lại',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorderColor, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: kPrimaryTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const Text(
                    'Thông tin Cá nhân',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                      if (!_isEditing) {
                        showCustomToast(
                          context,
                          message: 'Thông tin đã được cập nhật',
                          subtitle: 'Thay đổi đã được lưu',
                          isSuccess: true,
                        );
                      }
                    },
                    child: Text(
                      _isEditing ? 'Hủy' : 'Sửa',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Avatar Section
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryColor,
                                width: 4,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFCBD5E1),
                              ),
                              child:
                                  _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        _avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                color: kSecondaryTextColor,
                                                size: 56,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: kSecondaryTextColor,
                                      size: 56,
                                    ),
                            ),
                          ),
                          if (_isEditing)
                            GestureDetector(
                              onTap: _uploadAvatar,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kPrimaryColor,
                                  border: Border.all(
                                    color: kCardColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.photo_camera,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Info Section
                    _buildSectionHeader('THÔNG TIN CƠ BẢN'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoField(
                            label: 'Họ và tên',
                            controller: _fullNameController,
                            isFirst: true,
                          ),
                          _buildDatePickerField(
                            label: 'Ngày sinh',
                            controller: _dobController,
                          ),
                          _buildGenderDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Info Section
                    _buildSectionHeader('THÔNG TIN LIÊN HỆ'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoField(
                            label: 'Email',
                            controller: _emailController,
                            isFirst: true,
                          ),
                          _buildInfoField(
                            label: 'Số điện thoại',
                            controller: _phoneController,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    if (_isEditing)
                      GestureDetector(
                        onTap: _saveUserData,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kSecondaryTextColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: kBorderColor, indent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      )
                    : Text(
                        controller.text,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// DatePicker field cho ngày sinh
  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Divider(height: 1, color: kBorderColor, indent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: controller.text.isNotEmpty
                                ? DateTime.parse(controller.text)
                                : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kBorderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  controller.text.isEmpty
                                      ? 'Chọn ngày'
                                      : controller.text,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.text.isEmpty
                                        ? kSecondaryTextColor
                                        : kPrimaryTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: kSecondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        controller.text,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dropdown field cho giới tính
  Widget _buildGenderDropdown() {
    final genderMap = {'Nam': 'male', 'Nữ': 'female', 'Khác': 'other'};
    final genderDisplay = {'male': 'Nam', 'female': 'Nữ', 'other': 'Khác'};

    return Column(
      children: [
        Divider(height: 1, color: kBorderColor, indent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Giới tính',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _genderController.text.isEmpty
                              ? null
                              : _genderController.text,
                          hint: const Text(
                            'Chọn giới tính',
                            style: TextStyle(color: kSecondaryTextColor),
                          ),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: genderMap.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry
                                      .value, // Lưu 'male', 'female', 'other'
                                  child: Text(
                                    entry.key,
                                  ), // Hiển thị 'Nam', 'Nữ', 'Khác'
                                ),
                              )
                              .toList(),
                          onChanged: _isEditing
                              ? (value) {
                                  if (value != null) {
                                    _genderController.text = value;
                                    setState(() {});
                                  }
                                }
                              : null,
                        ),
                      )
                    : Text(
                        genderDisplay[_genderController.text] ??
                            _genderController.text,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          color: kSecondaryTextColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Upload avatar lên Cloudinary
  Future<void> _uploadAvatar() async {
    try {
      final cloudinaryService = CloudinaryService();

      // Pick image
      final imageFile = await cloudinaryService.pickImage();
      if (imageFile == null) {
        debugPrint('⚠️ No image selected');
        return;
      }

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) =>
            const Center(child: CircularProgressIndicator()),
      );

      debugPrint('📤 Starting upload...');

      // Upload to Cloudinary
      final imageUrl = await cloudinaryService.uploadImage(
        filePath: imageFile.path,
        fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Close loading dialog safely
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (imageUrl != null) {
        debugPrint('✅ Upload successful: $imageUrl');

        // Save URL to Supabase
        final userService = UserService();
        final userId = userService.getCurrentUserId();

        if (userId != null) {
          final success = await userService.updateUserInfo(
            userId: userId,
            avatarUrl: imageUrl,
          );

          if (success && mounted) {
            // Cập nhật state để hiển thị avatar
            setState(() {
              _avatarUrl = imageUrl;
            });
            showCustomToast(
              context,
              message: 'Upload ảnh thành công',
              subtitle: 'Avatar của bạn đã được cập nhật',
              isSuccess: true,
            );
            debugPrint('✅ Avatar saved to Supabase');
          }
        }
      } else {
        if (mounted) {
          showCustomToast(
            context,
            message: 'Lỗi upload ảnh',
            subtitle: 'Vui lòng thử lại',
            isSuccess: false,
          );
        }
        debugPrint('❌ Upload returned null');
      }
    } catch (e) {
      debugPrint('❌ Error uploading avatar: $e');

      // Close dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Dialog không tồn tại, bỏ qua
        }
      }

      if (mounted) {
        showCustomToast(
          context,
          message: 'Lỗi khi upload',
          subtitle: e.toString(),
          isSuccess: false,
        );
      }
    }
  }
}
