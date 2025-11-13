import 'dart:math';
import 'package:flutter/foundation.dart';

/// Service generate và quản lý OTP
class OTPService {
  static final OTPService _instance = OTPService._internal();

  factory OTPService() {
    return _instance;
  }

  OTPService._internal();

  /// Generate OTP 6 chữ số
  String generateOTP({int length = 6}) {
    final random = Random();
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString();
    }
    debugPrint('📌 OTP generated: $otp');
    return otp;
  }

  /// Xác thực OTP
  bool verifyOTP(String enteredOTP, String correctOTP) {
    return enteredOTP == correctOTP;
  }

  /// Gửi OTP qua email (dùng Supabase)
  Future<bool> sendOTPToEmail({
    required String email,
    required String otp,
  }) async {
    try {
      // TODO: Integrate với Supabase edge function để gửi email
      debugPrint('✅ OTP sent to $email: $otp');
      return true;
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      return false;
    }
  }
}
