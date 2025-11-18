import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../config/constants.dart';

/// Service quản lý upload ảnh lên Cloudinary
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  final ImagePicker _imagePicker = ImagePicker();

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal();

  /// Pick image từ gallery hoặc camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        debugPrint('📷 Image picked: ${image.path}');
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      return null;
    }
  }

  /// Upload ảnh từ file path
  Future<String?> uploadImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      debugPrint('📤 Uploading image to Cloudinary: $fileName');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.cloudinary.com/v1_1/${AppConstants.CLOUDINARY_CLOUD_NAME}/image/upload',
        ),
      );

      // Thêm file
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Thêm upload preset (không cần API key với upload preset)
      request.fields['upload_preset'] = AppConstants.CLOUDINARY_UPLOAD_PRESET;
      request.fields['public_id'] = fileName;
      request.fields['folder'] = 'mediminder/avatars';

      debugPrint('📡 Sending request to Cloudinary...');
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      final responseBody = await response.stream.bytesToString();
      debugPrint('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;
        debugPrint('✅ Image uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('❌ Upload failed: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Upload ảnh từ URL
  Future<String> uploadImageFromUrl({
    required String imageUrl,
    required String fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.cloudinary.com/v1_1/${AppConstants.CLOUDINARY_CLOUD_NAME}/image/upload',
        ),
      );

      // Thêm URL ảnh
      request.fields['file'] = imageUrl;
      request.fields['upload_preset'] = AppConstants.CLOUDINARY_UPLOAD_PRESET;
      request.fields['public_id'] = fileName;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Upload from URL failed: $e');
    }
  }

  /// Xóa ảnh khỏi Cloudinary (cần public_id)
  Future<void> deleteImage(String publicId) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.cloudinary.com/v1_1/${AppConstants.CLOUDINARY_CLOUD_NAME}/image/destroy',
        ),
      );

      request.fields['public_id'] = publicId;
      request.fields['api_key'] = AppConstants.CLOUDINARY_API_KEY;
      request.fields['timestamp'] =
          '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete image failed: $e');
    }
  }

  /// Lấy tất cả ảnh từ một folder
  Future<List<String>> getImagesByFolder(String folderName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://res.cloudinary.com/${AppConstants.CLOUDINARY_CLOUD_NAME}/image/list/$folderName.json',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<String> urls = [];

        for (var resource in jsonResponse['resources']) {
          urls.add(resource['url']);
        }

        return urls;
      } else {
        throw Exception('Failed to fetch images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get images failed: $e');
    }
  }
}
