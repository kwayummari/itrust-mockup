import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:flutter/material.dart';

class HandSelectionScreen extends StatefulWidget {
  final String nin;

  const HandSelectionScreen({
    super.key,
    required this.nin,
  });

  @override
  State<HandSelectionScreen> createState() => _HandSelectionScreenState();
}

class _HandSelectionScreenState extends State<HandSelectionScreen> {
  String? selectedHand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColor().white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "Biometric Verification",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
            AppText(
              txt: "Choose Hand for Verification",
              size: 24,
              weight: FontWeight.w600,
              color: AppColor().black,
              align: TextAlign.center,
            ),

            const SizedBox(height: 16),

            AppText(
              txt:
                  "We'll scan 4 fingers (excluding thumb) from your selected hand for identity verification.",
              size: 14,
              color: AppColor().grayText,
              align: TextAlign.center,
            ),

            const SizedBox(height: 60),

            // Hand selection cards
            _buildHandOption(
              "Left Hand",
              "left",
              Icons.back_hand,
              "Index, Middle, Ring & Little fingers",
            ),

            const SizedBox(height: 20),

            _buildHandOption(
              "Right Hand",
              "right",
              Icons.front_hand,
              "Index, Middle, Ring & Little fingers",
            ),

            const SizedBox(height: 40),

            // Information card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor().blueBTN.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor().blueBTN.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColor().blueBTN, size: 20),
                      const SizedBox(width: 8),
                      AppText(
                        txt: "What to expect:",
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColor().blueBTN,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    txt:
                        "• Camera will open to capture your fingerprints\n• Place your selected hand in front of the camera\n• Keep your hand steady during capture\n• All 4 fingers will be scanned simultaneously\n• The process takes about 10-15 seconds",
                    size: 12,
                    color: AppColor().textColor,
                  ),
                ],
              ),
            ),

            const Spacer(),

            Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedHand != null
                      ? () {
                          // FIXED: Navigate to the correct screen
                          // Option 1: Use the original BiometricVerificationScreen (if you're keeping the original)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BiometricVerificationScreen(
                                nin: widget.nin,
                                selectedHand:
                                    selectedHand, // Pass the selected hand
                              ),
                            ),
                          );

                          // OR Option 2: Use the enhanced version (recommended)
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => EnhancedBiometricVerificationScreen(
                          //       nin: widget.nin,
                          //     ),
                          //   ),
                          // );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedHand != null
                        ? AppColor().blueBTN
                        : AppColor().blueBTN.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: selectedHand != null ? 3 : 0,
                  ),
                  child: AppText(
                    txt: "Continue with ${selectedHand ?? 'Selected'} Hand",
                    color: AppColor().white,
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandOption(
      String title, String value, IconData icon, String description) {
    bool isSelected = selectedHand == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHand = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor().blueBTN.withOpacity(0.1)
              : AppColor().gray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor().blueBTN : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColor().blueBTN : AppColor().white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColor().white : AppColor().grayText,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    txt: title,
                    size: 16,
                    weight: FontWeight.w600,
                    color: isSelected ? AppColor().blueBTN : AppColor().black,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    txt: description,
                    size: 12,
                    color: AppColor().grayText,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColor().blueBTN,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
