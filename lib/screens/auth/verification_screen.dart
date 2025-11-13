import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
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

  void _handleOtpInput(String value, int index) {
    if (value.isNotEmpty && index < 3) {
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

    if (otpCode.length < 4) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ mã xác nhận';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác nhận thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
          ),
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
          _errorMessage = 'Mã xác nhận không hợp lệ';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    try {
      final supabaseService = SupabaseService();
      await supabaseService.resetPassword(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã xác nhận đã được gửi lại.'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        setState(() {
          _errorMessage = null;
        });
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: Không thể gửi lại mã xác nhận'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE8ECF4),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.maybePop(context),
                        color: const Color(0xFF090A0A),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Xác Nhận',
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
                  'Nhập mã xác nhận chúng tôi vừa gửi đến địa chỉ email của bạn.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF838BA1),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => _buildOtpField(index),
                  ),
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
                      disabledBackgroundColor: const Color(0xFF196EB0).withOpacity(0.6),
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
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Không nhận được mã? ',
                          style: TextStyle(
                            color: Color(0xFF1E232C),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleResend,
                            child: const Text(
                              'Gửi lại',
                              style: TextStyle(
                                color: Color(0xFF196EB0),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
      width: 60,
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
            borderSide: const BorderSide(
              color: Color(0xFF196EB0),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF196EB0),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF196EB0),
              width: 2,
            ),
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
