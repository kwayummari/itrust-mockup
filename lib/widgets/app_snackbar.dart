import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_text.dart';

class AppSnackbar extends SnackBar {
  final String? response;
  final bool? isError;

  // Static set to track shown messages per page
  static final Set<String> _shownMessages = <String>{};

  AppSnackbar({
    super.key,
    required this.response,
    required this.isError,
  }) : super(
          backgroundColor: isError == false ? Colors.green : Colors.red,
          content: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: AppText(
                key: UniqueKey(),
                txt: response.toString(),
                color: Colors.white,
                size: 15,
                align: TextAlign.center,
              ),
            ),
          ),
          duration: const Duration(seconds: 2),
        );

  void show(BuildContext context) {
    final String messageKey = response.toString();

    // Check if this message has already been shown
    if (_shownMessages.contains(messageKey)) {
      return; // Don't show duplicate message
    }

    // Add message to shown set
    _shownMessages.add(messageKey);

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(this);

    // Optional: Remove message from set after snackbar duration + buffer
    // This allows the same message to be shown again after some time
    Future.delayed(const Duration(seconds: 30), () {
      _shownMessages.remove(messageKey);
    });
  }

  // Static method to clear all shown messages (useful for page changes)
  static void clearShownMessages() {
    _shownMessages.clear();
  }

  // Static method to clear a specific message
  static void clearMessage(String message) {
    _shownMessages.remove(message);
  }
}
