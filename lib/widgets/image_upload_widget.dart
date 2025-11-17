import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:image_picker/image_picker.dart';

/// Widget ví dụ upload ảnh lên Cloudinary
class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({super.key});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  /// Chọn ảnh từ camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image != null && mounted) {
        context.read<ImageUploadProvider>().uploadImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  /// Chọn ảnh từ thư viện
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null && mounted) {
        context.read<ImageUploadProvider>().uploadImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageUploadProvider>(
      builder: (context, imageProvider, _) {
        return Column(
          children: [
            // Hiển thị ảnh đã upload
            if (imageProvider.uploadedImageUrl != null)
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageProvider.uploadedImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Hiển thị lỗi
            if (imageProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lỗi: ${imageProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Progress bar
            if (imageProvider.isUploading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Đang upload... ${(imageProvider.uploadProgress * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),

            // Nút chọn ảnh
            if (!imageProvider.isUploading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text('Thư viện'),
                      ),
                    ),
                  ],
                ),
              ),

            // Nút reset
            if (imageProvider.uploadedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    imageProvider.resetUploadState();
                  },
                  child: const Text('Upload ảnh khác'),
                ),
              ),
          ],
        );
      },
    );
  }
}
