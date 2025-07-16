import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

  Future<void>  callFace(BuildContext context) async {
    // Creates an instance of platform channel with Identy Channel name
    const platform = MethodChannel("identy_finger");
    if (!await Permission.camera.status.isGranted) {
      await Permission.camera.request();
    }

    dynamic response;

    try {

      final result = await platform.invokeMethod('capture','left');

      response = "success $result";

    } on PlatformException catch (e) {

      // print("DEBUG Error in flutter $e");
      response = e.message ?? 'error sin mensaje';
    }

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        var okButton = TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );

        final message = response.toString().length > 200
            ? response.substring(0, 200)
            : response;

        return AlertDialog(title: Text(message), actions: [okButton]);
      },
    );
  }