import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/auth/forgotPIN.dart';
import 'package:iwealth/services/auth/toggle.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BiometricStep {
  final String title;
  final String description;
  final String icon;

  BiometricStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class EnableBiometric extends StatefulWidget {
  const EnableBiometric({
    super.key,
  });

  @override
  State<EnableBiometric> createState() => _EnableBiometricState();
}

class _EnableBiometricState extends State<EnableBiometric> {
  var step = 0;

  final biometricSteps = [
    BiometricStep(
      title: "Enable Face ID",
      description: "Enjoy simpler and faster verification",
      icon: "assets/images/face-id.svg",
    ),
    BiometricStep(
      title: "Enable Fingerprint",
      description: "Enjoy simpler and faster verification",
      icon: "assets/images/finger-print.svg",
    ),
  ];

  void _goToLogin() {
    if (step == 0) {
      // Navigate to the next step
      setState(() {
        step = 1;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Forgotpin(
            nextScreen: const Toggle(),
            title: "Login",
            isCacheCleared: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Biometric'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (step > 0) {
              setState(() => step -= 1);
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (step == 0)
                Expanded(
                    key: const Key('biometric-step-1'),
                    child: _bodyWidget(
                        step: biometricSteps[0], appWidth: appWidth)),
              if (step == 1)
                Expanded(
                  key: const Key('biometric-step-2'),
                  child: _bodyWidget(
                    step: biometricSteps[1],
                    appWidth: appWidth,
                  ),
                ),
              const SizedBox(
                height: 16,
              ),
              AnimationWrapper(
                index: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your biometric info will not be collected by iTrust & will be used locally for verification purposes only.',
                      style: TextStyle(color: AppColor().grayText),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: largeBTN(double.infinity, "Enable Now",
                          AppColor().blueBTN, _goToLogin),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _goToLogin,
                          child: Text(
                            "Maybe Later",
                            style: TextStyle(
                              color: AppColor().blueBTN,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: TextButton(
              //     onPressed: () {
              //       Waiter().launchInBrowser();
              //     },
              //     child: Text(
              //       "Terms & Conditions",
              //       style: TextStyle(color: AppColor().blueBTN),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class _bodyWidget extends StatelessWidget {
  const _bodyWidget({
    super.key,
    required this.step,
    required this.appWidth,
  });

  final BiometricStep step;
  final double appWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimationWrapper(
            index: 2,
            child: SvgPicture.asset(step.icon, width: appWidth * 0.4)),
        AnimationWrapper(
          index: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 48, bottom: 8.0),
            child: Text(step.title,
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        AnimationWrapper(
          index: 3,
          child: Text(
            step.description,
            style: TextStyle(color: AppColor().grayText),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
