import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AnimationWrapper extends StatelessWidget {
  const AnimationWrapper({
    super.key,
    required this.child,
    required this.index,
    this.delayPerItem = 100,
    this.duration = 300,
    this.type = 'fadeInUp',
  });

  final Widget child;
  final int index;
  final int delayPerItem;
  final int duration;
  final String type;

  @override
  Widget build(BuildContext context) {
    return type == 'zoomIn'
        ? ZoomIn(
            delay: Duration(milliseconds: index * delayPerItem),
            duration: Duration(milliseconds: duration),
            child: child)
        : type == 'fadeIn'
            ? FadeIn(
                delay: Duration(milliseconds: index * delayPerItem),
                duration: Duration(milliseconds: duration),
                child: child,
              )
            : FadeInUp(
                from: 20,
                delay: Duration(milliseconds: index * delayPerItem),
                duration: Duration(milliseconds: duration),
                child: child,
              );
  }
}
