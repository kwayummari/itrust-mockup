import 'package:iwealth/screens/user/confirm_details_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class VerificationOngoingScreen extends StatefulWidget {
  final String nin;
  final dynamic verificationData;

  const VerificationOngoingScreen({
    super.key,
    required this.nin,
    required this.verificationData,
  });

  @override
  State<VerificationOngoingScreen> createState() =>
      _VerificationOngoingScreenState();
}

class _VerificationOngoingScreenState extends State<VerificationOngoingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print("Verification ongoing screen initialized");
      print("NIN: ${widget.nin}");
      print("Verification data: ${widget.verificationData}");
    }

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmDetailsScreen(
              nin: widget.nin,
              userData: widget.verificationData, // Pass the verified NIDA data
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated verification icon
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating gear
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * 3.14159,
                        child: Icon(
                          Icons.settings,
                          size: 80,
                          color: AppColor().blueBTN,
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: -20,
                    right: -20,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_animationController.value * 2 * 3.14159,
                          child: const Icon(
                            Icons.settings,
                            size: 50,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: -15,
                    left: -15,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 1.5 * 3.14159,
                          child: const Icon(
                            Icons.settings,
                            size: 40,
                            color: Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              AppText(
                txt: "Verification Ongoing",
                size: 24,
                weight: FontWeight.w600,
                color: AppColor().black,
                align: TextAlign.center,
              ),

              const SizedBox(height: 16),

              AppText(
                txt: "Processing your biometric verification data...",
                size: 16,
                color: AppColor().grayText,
                align: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColor().blueBTN,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    txt: "Please wait...",
                    size: 14,
                    color: AppColor().blueBTN,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
