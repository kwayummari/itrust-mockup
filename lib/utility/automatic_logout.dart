import 'dart:async';

import 'package:flutter/material.dart';

class AutomaticLogout extends StatefulWidget {
  Widget child;
  Duration timeDuration;
  VoidCallback onTimout;
  AutomaticLogout(
      {super.key,
      required this.child,
      required this.onTimout,
      required this.timeDuration});

  @override
  State<AutomaticLogout> createState() => _AutomaticLogoutState();
}

class _AutomaticLogoutState extends State<AutomaticLogout> {
  Timer? _timer;
  void _startTimer() {
    if (_timer != null) {
      print("There's activity");
      _timer?.cancel();
      _timer = null;
    }

    _timer = Timer(widget.timeDuration, () {
      print("No Activity .. ");
      widget.onTimout();
    });
  }

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      print("There's activity");
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        _startTimer();
      },
      child: widget.child,
    );
  }
}
