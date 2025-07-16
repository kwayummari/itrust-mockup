import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double? elevation;
  final double border;

  const AppCard(
      {super.key, required this.child, this.elevation, required this.color, required this.border});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(border),
      ),
      elevation: elevation ?? 1,
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: child,
      ),
    );
  }
}
