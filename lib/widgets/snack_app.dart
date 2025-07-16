import 'package:flutter/material.dart';

void appSnackBar({required String msg, required BuildContext context}) {
  // Remove any existing SnackBars before showing a new one
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  // Show new SnackBar with safe duration
  Future.delayed(const Duration(milliseconds: 100), () {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}
