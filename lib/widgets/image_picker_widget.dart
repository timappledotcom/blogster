import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/image_service.dart';

enum ImageUploadPlatform { microblog, nostrBuild, imgur }

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImageInserted;
  final String? microblogToken;
  final bool showMicroblogOption;

  const ImagePickerWidget({
    super.key,
    required this.onImageInserted,
    this.microblogToken,
    this.showMicroblogOption = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageService _imageService = ImageService();
  bool _isUploading = false;
  String? _uploadError;
  ImageUploadPlatform _selectedPlatform = ImageUploadPlatform.nostrBuild;

  @override
  void initState() {
    super.initState();
    // Default to Micro.blog if token is available
    if (widget.showMicroblogOption && widget.microblogToken != null) {
      _selectedPlatform = ImageUploadPlatform.microblog;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image),
                const SizedBox(width: 8),
                const Text(
                  'Insert Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Platform selection
            const Text(
              'Upload to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                if (widget.showMicroblogOption && widget.microblogToken != null)
                  RadioListTile<ImageUploadPlatform>(
                    title: const Text('Micro.blog'),
                    subtitle:
                        const Text('Upload to your Micro.blog media library'),
                    value: ImageUploadPlatform.microblog,
                    groupValue: _selectedPlatform,
                    onChanged: (value) {
                      setState(() {
                        _selectedPlatform = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                RadioListTile<ImageUploadPlatform>(
                  title: const Text('nostr.build'),
                  subtitle: const Text('Popular Nostr image hosting service'),
                  value: ImageUploadPlatform.nostrBuild,
                  groupValue: _selectedPlatform,
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ImageUploadPlatform>(
                  title: const Text('Imgur'),
                  subtitle: const Text('Anonymous upload to Imgur'),
                  value: ImageUploadPlatform.imgur,
                  groupValue: _selectedPlatform,
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error message
            if (_uploadError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label:
                    Text(_isUploading ? 'Uploading...' : 'Pick & Upload Image'),
              ),
            ),
            const SizedBox(height: 8),

            // Manual URL input
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Or enter image URL manually:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _insertImageFromUrl,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Get text from the text field and insert
                    // This is a simplified version - you might want to use a controller
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Insert URL',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      // Pick image
      final imageFile = await _imageService.pickImage();
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Validate image
      if (!_imageService.isValidImageFile(imageFile)) {
        setState(() {
          _uploadError =
              'Please select a valid image file (JPG, PNG, GIF, WebP)';
          _isUploading = false;
        });
        return;
      }

      if (!_imageService.isFileSizeValid(imageFile, maxSizeMB: 10.0)) {
        setState(() {
          _uploadError = 'Image file is too large. Maximum size is 10MB.';
          _isUploading = false;
        });
        return;
      }

      // Upload image based on selected platform
      ImageUploadResult result;
      switch (_selectedPlatform) {
        case ImageUploadPlatform.microblog:
          if (widget.microblogToken == null) {
            throw Exception('No Micro.blog token available');
          }
          result = await _imageService.uploadToMicroblog(
            imageFile: imageFile,
            appToken: widget.microblogToken!,
          );
          break;
        case ImageUploadPlatform.nostrBuild:
          result = await _imageService.uploadToNostrBuild(imageFile: imageFile);
          break;
        case ImageUploadPlatform.imgur:
          result = await _imageService.uploadToImgur(imageFile: imageFile);
          break;
      }

      if (result.success && result.url != null) {
        // Generate markdown and insert
        final markdown = _imageService.generateImageMarkdown(
          url: result.url!,
          altText: result.filename ?? 'Image',
        );

        widget.onImageInserted(markdown);

        // Copy URL to clipboard for convenience
        await Clipboard.setData(ClipboardData(text: result.url!));

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Image uploaded and inserted! URL copied to clipboard.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _uploadError = result.error ?? 'Upload failed';
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _insertImageFromUrl(String url) {
    if (url.trim().isNotEmpty) {
      final markdown = _imageService.generateImageMarkdown(
        url: url.trim(),
        altText: 'Image',
      );
      widget.onImageInserted(markdown);
      Navigator.pop(context);
    }
  }
}
