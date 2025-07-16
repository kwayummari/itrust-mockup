import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final Widget contents;

   const CustomPopup({super.key, required this.title, required this.contents});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: contents,
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
