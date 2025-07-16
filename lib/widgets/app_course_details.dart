import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/widgets/app_text.dart';
class AppCourseDetails extends StatelessWidget {
  final Icon icon;
  final String text;

  const AppCourseDetails({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 20),
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 20,
          ),
          AppText(
            txt: text,
            size: 20,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
        ],
      ),
    );
  }
}
