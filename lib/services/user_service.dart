import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final _supabase = Supabase.instance.client;

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  /// Lấy thông tin user từ Supabase
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ User not found in database');
        return null;
      }

      debugPrint('✅ User info loaded: ${response['full_name']}');
      return response;
    } catch (e) {
      debugPrint('❌ Error loading user info: $e');
      return null;
    }
  }

  /// Cập nhật thông tin user lên Supabase
  Future<bool> updateUserInfo({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? bloodType,
    String? allergies,
    String? medicalNotes,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      // Chỉ thêm những field có giá trị (không null và không rỗng)
      if (fullName != null && fullName.isNotEmpty) {
        updateData['full_name'] = fullName;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updateData['phone_number'] = phoneNumber;
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        updateData['date_of_birth'] = dateOfBirth;
      }
      if (gender != null && gender.isNotEmpty) {
        updateData['gender'] = gender;
      }
      if (address != null && address.isNotEmpty) {
        updateData['address'] = address;
      }
      if (city != null && city.isNotEmpty) {
        updateData['city'] = city;
      }
      if (country != null && country.isNotEmpty) {
        updateData['country'] = country;
      }
      if (postalCode != null && postalCode.isNotEmpty) {
        updateData['postal_code'] = postalCode;
      }
      if (bloodType != null && bloodType.isNotEmpty) {
        updateData['blood_type'] = bloodType;
      }
      if (allergies != null && allergies.isNotEmpty) {
        updateData['allergies'] = allergies;
      }
      if (medicalNotes != null && medicalNotes.isNotEmpty) {
        updateData['medical_notes'] = medicalNotes;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updateData['avatar_url'] = avatarUrl;
      }

      if (updateData.isEmpty) {
        debugPrint('⚠️ No data to update');
        return false;
      }

      debugPrint('📝 Updating fields: ${updateData.keys.toList()}');
      await _supabase.from('users').update(updateData).eq('id', userId);

      debugPrint('✅ User info updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user info: $e');
      return false;
    }
  }

  /// Lấy current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Lấy current user email
  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  /// Lấy current user full_name từ auth metadata
  String? getCurrentUserFullName() {
    return _supabase.auth.currentUser?.userMetadata?['full_name'] as String?;
  }
}
