import 'package:flutter_svg/svg.dart';
import 'package:iwealth/screens/user/bank_details_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class KYCVerifiedScreen extends StatelessWidget {
  const KYCVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double appWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor().white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/kyc.svg',
                width: appWidth * 0.7,
              ),

              const SizedBox(height: 60),

              AppText(
                txt: "NIDA verified successfully",
                size: 20,
                weight: FontWeight.w600,
                color: AppColor().black,
                align: TextAlign.center,
              ),

              const SizedBox(height: 16),

              AppText(
                txt:
                    "Your NIDA data has been successfully updated! Your digital account has been activated.",
                size: 16,
                color: AppColor().grayText,
                align: TextAlign.center,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor().white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BankDetailsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().blueBTN,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: AppText(
                txt: "Continue",
                color: AppColor().white,
                size: 16,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
