import 'package:iwealth/screens/choice.dart';
import 'package:iwealth/services/auth/login.dart';
import 'package:flutter/material.dart';

class Toggle extends StatefulWidget {
  const Toggle({super.key});

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  bool toggled = true;

  void toggling() {
    setState(() {
      toggled = !toggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (toggled) {

      return LoginScreen();
    } else {

      // Creat account
      return Choice(toggled: toggling);
    }
  }
}
