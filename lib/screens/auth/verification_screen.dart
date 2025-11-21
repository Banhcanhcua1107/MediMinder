import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_toast.dart';
import '../../l10n/app_localizations.dart';

// --- Bảng màu thống nhất ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Bắt đầu đếm ngược
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          }
        });
      }
      return _remainingSeconds > 0;
    });
  }

  void _handleOtpInput(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _handleBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerify() async {
    final otpCode = _getOtpCode();

    if (otpCode.length < 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ 6 chữ số';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = SupabaseService();

      // Verify OTP code
      await supabaseService.client.auth.verifyOTP(
        email: widget.email,
        token: otpCode,
        type: OtpType.email,
      );

      if (mounted) {
        showCustomToast(
          context,
          message: 'Xác nhẫn thành công!',
          subtitle: 'Vui lòng đăng nhập',
          isSuccess: true,
        );

        // Navigate to login or home
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Mã xác nhẫn không hợp lệ: ${e.toString()}';
          _isLoading = false;
        });

        showCustomToast(
          context,
          message: 'Mã xác nhẫn sai',
          subtitle: 'Vui lòng thử lại',
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (_remainingSeconds > 0) return;

    try {
      final supabaseService = SupabaseService();

      // Gửi lại OTP qua Supabase
      await supabaseService.client.auth.signUp(
        email: widget.email,
        password: DateTime.now().toString(), // Tạm thời
      );

      if (mounted) {
        showCustomToast(
          context,
          message: 'Gửi lại mã thành công',
          subtitle: 'Kiểm tra email của bạn',
          isSuccess: true,
        );

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        setState(() {
          _errorMessage = null;
          _remainingSeconds = 60;
        });
        _focusNodes[0].requestFocus();
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        showCustomToast(
          context,
          message: 'Lỗi gửi lại',
          subtitle: 'Vui lòng thử lại sau',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 41,
                      width: 41,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        border: Border.all(color: kBorderColor, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.maybePop(context),
                        color: kPrimaryTextColor,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.verifyCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF196EB0),
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Nhập mã 6 chữ số chúng tôi vừa gửi đến:\n${widget.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF838BA1),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Fields (6 fields)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOtpField(index)),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF196EB0),
                      disabledBackgroundColor: const Color(
                        0xFF196EB0,
                      ).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Xác Nhận',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resend link
                Center(
                  child: Column(
                    children: [
                      Text(
                        _remainingSeconds > 0
                            ? 'Gửi lại mã trong ${_remainingSeconds}s'
                            : 'Không nhận được mã?',
                        style: const TextStyle(
                          color: Color(0xFF8391A1),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_remainingSeconds == 0)
                        GestureDetector(
                          onTap: _handleResend,
                          child: const Text(
                            'Gửi lại',
                            style: TextStyle(
                              color: Color(0xFF196EB0),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        enabled: !_isLoading,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF196EB0), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF196EB0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF196EB0), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          color: Color(0xFF1E232C),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Urbanist',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _handleOtpInput(value, index);
          } else {
            _handleBackspace(value, index);
          }
        },
      ),
    );
  }
}
