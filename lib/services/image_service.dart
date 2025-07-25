import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ImageUploadResult {
  final bool success;
  final String? url;
  final String? error;
  final String? filename;

  ImageUploadResult({
    required this.success,
    this.url,
    this.error,
    this.filename,
  });
}

class ImageService {
  static const String _nostrBuildUrl =
      'https://nostr.build/api/v2/upload/files';
  static const String _microblogMediaUrl = 'https://micro.blog/micropub/media';

  /// Pick an image file from the device
  Future<File?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload image to Micro.blog
  Future<ImageUploadResult> uploadToMicroblog({
    required File imageFile,
    required String appToken,
  }) async {
    try {
      final uri = Uri.parse(_microblogMediaUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $appToken';

      // Add content type for multipart
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add the image file with correct field name for Micro.blog
      final filename = path.basename(imageFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // Micro.blog expects 'file' field name
        imageFile.path,
        filename: filename,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 202) {
        // Micro.blog returns the media URL in the Location header
        final location = response.headers['location'];
        if (location != null) {
          return ImageUploadResult(
            success: true,
            url: location,
            filename: filename,
          );
        }

        // Try to parse JSON response for URL
        try {
          final data = jsonDecode(response.body);
          final url = data['url'] ?? data['location'] ?? data['link'];
          if (url != null) {
            return ImageUploadResult(
              success: true,
              url: url,
              filename: filename,
            );
          }
        } catch (e) {
          // Ignore JSON parsing errors
        }

        return ImageUploadResult(
          success: false,
          error:
              'Upload succeeded but no URL returned. Response: ${response.body}',
        );
      } else {
        String errorMessage = 'Upload failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ??
              errorData['error_description'] ??
              errorData['message'] ??
              errorMessage;
        } catch (e) {
          errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}. Body: ${response.body}';
        }

        return ImageUploadResult(
          success: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  /// Upload image to nostr.build (popular Nostr image host)
  Future<ImageUploadResult> uploadToNostrBuild({
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse(_nostrBuildUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add the image file
      final filename = path.basename(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'fileToUpload',
          imageFile.path,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // nostr.build API response format
          if (data['status'] == 'success' && data['data'] != null) {
            final imageData = data['data'][0]; // First uploaded image
            final url = imageData['url'];

            return ImageUploadResult(
              success: true,
              url: url,
              filename: filename,
            );
          } else {
            return ImageUploadResult(
              success: false,
              error: data['message'] ?? 'Upload failed',
            );
          }
        } catch (e) {
          return ImageUploadResult(
            success: false,
            error: 'Failed to parse response: $e',
          );
        }
      } else {
        return ImageUploadResult(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  /// Upload image to imgur (alternative for Nostr)
  Future<ImageUploadResult> uploadToImgur({
    required File imageFile,
    String? clientId,
  }) async {
    try {
      // Use anonymous upload if no client ID provided
      final uri = Uri.parse('https://api.imgur.com/3/image');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      if (clientId != null) {
        request.headers['Authorization'] = 'Client-ID $clientId';
      } else {
        // Anonymous upload - you might want to use your own client ID
        request.headers['Authorization'] = 'Client-ID 546c25a59c58ad7';
      }

      // Add the image file
      final filename = path.basename(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data['success'] == true && data['data'] != null) {
            final url = data['data']['link'];

            return ImageUploadResult(
              success: true,
              url: url,
              filename: filename,
            );
          } else {
            return ImageUploadResult(
              success: false,
              error: data['data']['error'] ?? 'Upload failed',
            );
          }
        } catch (e) {
          return ImageUploadResult(
            success: false,
            error: 'Failed to parse response: $e',
          );
        }
      } else {
        return ImageUploadResult(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  /// Generate markdown for an uploaded image
  String generateImageMarkdown({
    required String url,
    String? altText,
    String? title,
  }) {
    final alt = altText ?? 'Image';
    if (title != null) {
      return '![$alt]($url "$title")';
    } else {
      return '![$alt]($url)';
    }
  }

  /// Validate image file
  bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.contains(extension);
  }

  /// Get file size in MB
  double getFileSizeMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Check if file size is within limits
  bool isFileSizeValid(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeMB(file) <= maxSizeMB;
  }
}
