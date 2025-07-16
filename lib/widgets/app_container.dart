import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double bottom;
  const AppContainer({super.key, required this.child, this.width, this.height, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding:  EdgeInsets.fromLTRB(16, 0, 16, bottom),
        child: child,
      ),
    );
  }
}
