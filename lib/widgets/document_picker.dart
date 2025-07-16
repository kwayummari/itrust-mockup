import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentPicker {
  static const int _maxFileSizeBytes = 1024 * 1024; // 1 MB in bytes

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<void> _showFileSizeWarning(BuildContext context, int fileSize) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('File Too Large'),
          content: Text(
              'The selected file size (${_formatFileSize(fileSize)}) exceeds the maximum allowed size of 1 MB. Please compress the file and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showPermissionDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Permission Denied',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            'Please enable photo library access in your device settings to select images from gallery.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> _validateFileSize(
      BuildContext context, int fileSize) async {
    if (fileSize > _maxFileSizeBytes) {
      await _showFileSizeWarning(context, fileSize);
      return false;
    }
    return true;
  }

  static Future<File?> pickDocument({
    required BuildContext context,
    required List<String> allowedExtensions,
    bool allowCamera = true,
  }) async {
    if (kDebugMode) {
      print(
          'Opening document picker with allowed extensions: $allowedExtensions');
    }

    return await showModalBottomSheet<File?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (allowCamera)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Picture'),
                  onTap: () async {
                    if (kDebugMode) {
                      print('Camera option selected');
                    }
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );
                    if (image != null) {
                      final file = File(image.path);
                      final size = await file.length();

                      if (kDebugMode) {
                        print('Image captured: ${image.path}');
                        print('Image size: ${_formatFileSize(size)}');
                      }

                      if (!await _validateFileSize(context, size)) {
                        return;
                      }

                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    } else {
                      if (kDebugMode) {
                        print('No image captured');
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  if (kDebugMode) {
                    print('Gallery option selected');
                  }
                  try {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (image != null) {
                      final file = File(image.path);
                      final size = await file.length();

                      if (kDebugMode) {
                        print('Image selected from gallery: ${image.path}');
                        print('Image size: ${_formatFileSize(size)}');
                      }

                      if (!await _validateFileSize(context, size)) {
                        return;
                      }

                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    } else {
                      if (kDebugMode) {
                        print('No image selected from gallery');
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print('Error picking image: $e');
                    }
                    if (e.toString().contains('photo_access_denied')) {
                      if (context.mounted) {
                        await _showPermissionDeniedDialog(context);
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: const Text('Choose Document'),
                onTap: () async {
                  if (kDebugMode) {
                    print('Document option selected');
                  }
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: allowedExtensions,
                  );
                  if (result != null) {
                    final file = File(result.files.single.path!);
                    final size = await file.length();

                    if (kDebugMode) {
                      print('Document selected: ${result.files.single.path}');
                      print('Document size: ${_formatFileSize(size)}');
                      print(
                          'Document extension: ${result.files.single.extension}');
                    }

                    if (!await _validateFileSize(context, size)) {
                      return;
                    }

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  } else {
                    if (kDebugMode) {
                      print('No document selected');
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget newPickDocument({
    required BuildContext context,
    required List<String> allowedExtensions,
    bool allowCamera = true,
    required Function onFileSelected,
  }) {
    if (kDebugMode) {
      print(
          'Opening document picker with allowed extensions: $allowedExtensions');
    }

    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if (allowCamera)
          IconButton.filledTonal(
            icon: const Icon(Icons.camera_alt),
            color: AppColor().blueBTN,
            style: IconButton.styleFrom(
              backgroundColor: AppColor().blueBTN.withAlpha(30),
            ),
            onPressed: () async {
              try {
                if (kDebugMode) {
                  print('Camera option selected');
                }
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (image != null) {
                  final file = File(image.path);
                  final size = await file.length();

                  if (kDebugMode) {
                    print('Image captured: ${image.path}');
                    print('Image size: ${_formatFileSize(size)}');
                  }

                  if (!await _validateFileSize(context, size)) {
                    return;
                  }

                  // if (context.mounted) {
                  //   Navigator.pop(context, file);
                  // }
                  onFileSelected(file);
                } else {
                  if (kDebugMode) {
                    onFileSelected(null);
                    print('No image captured');
                  }
                  // if (context.mounted) Navigator.pop(context);
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error picking image: $e');
                }
                if (e.toString().contains('camera_access_denied')) {
                  if (context.mounted) {
                    await _showPermissionDeniedDialog(context);
                  }
                }
                onFileSelected(null);
              }
            },
          ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: const Icon(Icons.photo_library),
          color: AppColor().blueBTN,
          style: IconButton.styleFrom(
            backgroundColor: AppColor().blueBTN.withAlpha(30),
          ),
          onPressed: () async {
            if (kDebugMode) {
              print('Gallery option selected');
            }
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 70,
              );
              if (image != null) {
                final file = File(image.path);
                final size = await file.length();

                if (kDebugMode) {
                  print('Image selected from gallery: ${image.path}');
                  print('Image size: ${_formatFileSize(size)}');
                }

                if (!await _validateFileSize(context, size)) {
                  return;
                }
                onFileSelected(file);

                // if (context.mounted) {
                //   Navigator.pop(context, file);
                // }
              } else {
                if (kDebugMode) {
                  print('No image selected from gallery');
                }
                // if (context.mounted) Navigator.pop(context);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error picking image: $e');
              }
              if (e.toString().contains('photo_access_denied')) {
                if (context.mounted) {
                  await _showPermissionDeniedDialog(context);
                }
              }
              onFileSelected(null);

              // if (context.mounted) Navigator.pop(context);
            }
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColor().blueBTN.withAlpha(30),
              foregroundColor: AppColor().blueBTN,
              shape: RoundedRectangleBorder(
                // side: BorderSide(
                //   color: AppColor().blueBTN,
                //   width: 1,
                // ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 24,
              ),
            ),
            child: const Text('Choose Document',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            onPressed: () async {
              if (kDebugMode) {
                print('Document option selected');
              }
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: allowedExtensions,
              );
              if (result != null) {
                final file = File(result.files.single.path!);
                final size = await file.length();

                if (kDebugMode) {
                  print('Document selected: ${result.files.single.path}');
                  print('Document size: ${_formatFileSize(size)}');
                  print('Document extension: ${result.files.single.extension}');
                }

                if (!await _validateFileSize(context, size)) {
                  return;
                }

                // if (context.mounted) {
                //   Navigator.pop(context, file);
                // }
                onFileSelected(file);
              } else {
                if (kDebugMode) {
                  print('No document selected');
                }
                onFileSelected(null);

                // if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }
}
