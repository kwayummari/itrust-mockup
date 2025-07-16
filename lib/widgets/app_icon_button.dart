import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final bool disabled;

  const AppIconButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scale(0.85),
      alignment: Alignment.center,
      child: IconButton(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(0),
          onPressed: disabled ? null : () => onPressed(),
          icon: Icon(
            icon,
          )),
    );
  }
}
