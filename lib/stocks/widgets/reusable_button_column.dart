import 'package:flutter/material.dart';

class ReusableButtonColumn extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onPressed;
  final bool isComingSoon;
  final bool isDisabled; // Add this property

  const ReusableButtonColumn({
    super.key,
    required this.imagePath,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
    this.isComingSoon = false,
    this.isDisabled = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0, // Add opacity when disabled
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isComingSoon || isDisabled
                    ? null
                    : onPressed, // Disable if coming soon or disabled
                style: ElevatedButton.styleFrom(
                  elevation: 1,
                  shape: const CircleBorder(),
                  backgroundColor: isComingSoon || isDisabled
                      ? buttonColor.withOpacity(0.5)
                      : buttonColor, // Reduce opacity if coming soon or disabled
                ),
                child: Opacity(
                  opacity: isComingSoon || isDisabled
                      ? 0.5
                      : 1.0, // Reduce icon opacity if coming soon or disabled
                  child: Image.asset(imagePath),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isComingSoon || isDisabled
                      ? const Color.fromARGB(255, 52, 60, 66).withOpacity(0.5)
                      : const Color.fromARGB(255, 52, 60, 66),
                ),
              ),
            ],
          ),
          if (isComingSoon)
            Positioned(
              top: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 79, 78, 78),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: const Text(
                  'Coming soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
