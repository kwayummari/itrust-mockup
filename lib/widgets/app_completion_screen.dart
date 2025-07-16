import 'package:flutter_svg/svg.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class AppCompletion extends StatelessWidget {
  final String url;
  final String text;
  final String? text2;
  final String description;
  final Function onPressed;
  final bool isIcon;
  final bool isSvg;
  final bool multiTitle;
  const AppCompletion(
      {super.key,
      required this.url,
      required this.description,
      required this.onPressed,
      required this.text,
      required this.isIcon,
      required this.isSvg,
      required this.multiTitle,
      this.text2});

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
              isIcon
                  ? Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColor().blueBTN,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor().blueBTN.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    )
                  : isSvg
                      ? SvgPicture.asset(
                          url,
                          width: appWidth * 0.7,
                        )
                      : Image.asset(
                          url,
                        ),
              const SizedBox(height: 60),
              AppText(
                txt: text,
                size: 20,
                weight: FontWeight.w600,
                color: AppColor().black,
                align: TextAlign.center,
              ),
              SizedBox(height: multiTitle ? 16 : 0),
              AppText(
                txt: multiTitle ? text2 : '',
                size: 14,
                color: AppColor().grayText,
                weight: FontWeight.w400,
                align: TextAlign.center,
              ),
              const SizedBox(height: 13),
              AppText(
                txt: description,
                size: 14,
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
              onPressed: () => onPressed(),
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
