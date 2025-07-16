import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';

class ProfileImageWidget extends StatelessWidget {
  final String photo;
  final double width;
  final double height;
  final double radius;

  const ProfileImageWidget({
    super.key,
    required this.photo,
    this.width = 120,
    this.height = 150,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (photo.isNotEmpty) {
      try {
        // Decode base64 image
        final bytes = base64Decode(photo);
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding base64 image: $e");
        }
        return _buildPlaceholderImage();
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          color: AppColor().lowerBg,
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: width * 0.55,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
