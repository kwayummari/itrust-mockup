import 'package:iwealth/constants/app_color.dart';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

Widget otpForm({
  required double w,
  required double h,
  required GlobalKey key,
  required String phone,
  required Function(String) otp,
  required BuildContext context,
  required bool isLoading,
  required VoidCallback resendTapped,
  required Widget btn,
  FocusNode? focusNode, // Add focusNode parameter
  TextEditingController? controller, // Add controller parameter
}) {
  final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(color: AppColor().textColor),
      decoration: BoxDecoration(
          color: AppColor().pinColor,
          borderRadius: BorderRadius.circular(10.0)));

  return Form(
    key: key,
    child: Column(
      children: [
        Text(
          "Pleased enter OTP sent to your Phone Number ending with ${phone.replaceRange(0, 9, "********")}",
          style: TextStyle(color: AppColor().grayText),
          textAlign: TextAlign.justify,
        ),
        SizedBox(
          height: h * 0.02,
        ),
        Pinput(
          focusNode: focusNode,
          controller: controller,
          defaultPinTheme: defaultPinTheme,
          length: 6,
          onChanged: otp,
          showCursor: true,
          enabled: true,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor().blueBTN.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextButton(
            onPressed: isLoading ? null : resendTapped,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColor().blueBTN,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: AppColor().blueBTN,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColor().blueBTN,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: btn,
        )
      ],
    ),
  );
}

Widget paymentCode({
  required w,
  required h,
  required otp,
  required context,
}) {
  // = false;
  final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(color: AppColor().textColor),
      decoration: BoxDecoration(
          color: AppColor().stockCardColor,
          borderRadius: BorderRadius.circular(10.0)));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Please enter code Sent to your registerd number",
        style: TextStyle(color: AppColor().grayText),
        textAlign: TextAlign.justify,
      ),
      SizedBox(
        height: h * 0.02,
      ),
      Pinput(
        defaultPinTheme: defaultPinTheme,
        length: 6,
        onChanged: otp,
        validator: (value) => value!.length != 6 ? "Enter Code" : null,
      ),
    ],
  );
}
