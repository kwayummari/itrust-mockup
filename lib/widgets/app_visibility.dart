import 'package:flutter/material.dart';

class AppVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  const AppVisibility({super.key, required this.child, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: child
      );
  }
}