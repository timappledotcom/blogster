import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MicroblogCredential {
  final String id;
  final String name;
  final String appToken;
  final String blogUrl;
  final DateTime createdAt;

  MicroblogCredential({
    required this.id,
    required this.name,
    required this.appToken,
    required this.blogUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'appToken': appToken,
        'blogUrl': blogUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MicroblogCredential.fromJson(Map<String, dynamic> json) =>
      MicroblogCredential(
        id: json['id'],
        name: json['name'],
        appToken: json['appToken'],
        blogUrl: json['blogUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class MicroblogService {
  static const String _baseUrl = 'https://micro.blog';

  /// Publish a post to Micro.blog
  Future<void> publishPost({
    required String content,
    required String appToken,
    String? title,
    List<String>? categories,
    bool isDraft = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/micropub');

      // Prepare the post data
      final Map<String, dynamic> postData = {
        'type': ['h-entry'],
        'properties': {
          'content': [content],
        },
      };

      // Add title if provided
      if (title != null && title.trim().isNotEmpty) {
        postData['properties']['name'] = [title.trim()];
      }

      // Add categories (tags) if provided
      if (categories != null && categories.isNotEmpty) {
        postData['properties']['category'] = categories;
      }

      // Set as draft if requested
      if (isDraft) {
        postData['properties']['post-status'] = ['draft'];
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201 || response.statusCode == 202) {
        // Success - post created
        print('Successfully published to Micro.blog');
        return;
      } else {
        // Handle error response
        String errorMessage = 'Failed to publish to Micro.blog';

        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error_description'] != null) {
            errorMessage = errorData['error_description'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // If we can't parse the error, use the status code
          errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is HttpException) {
        throw Exception('HTTP error: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  /// Test the connection with the provided app token
  Future<Map<String, dynamic>> testConnection(String appToken) async {
    try {
      final url = Uri.parse('$_baseUrl/micropub?q=config');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user info from Micro.blog
  Future<Map<String, dynamic>> getUserInfo(String appToken) async {
    try {
      final url = Uri.parse('$_baseUrl/account/verify');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'username': data['username'] ?? 'Unknown',
          'url': data['url'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to verify account',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get available categories from Micro.blog
  Future<Map<String, dynamic>> getCategories(String appToken) async {
    try {
      final url = Uri.parse('$_baseUrl/micropub?q=category');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Micro.blog returns categories in different formats
        List<String> categories = [];

        if (data['categories'] != null) {
          // Standard format: {"categories": ["category1", "category2"]}
          categories = List<String>.from(data['categories']);
        } else if (data is List) {
          // Alternative format: ["category1", "category2"]
          categories = List<String>.from(data);
        }

        return {
          'success': true,
          'categories': categories,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'categories': <String>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'categories': <String>[],
      };
    }
  }
}
