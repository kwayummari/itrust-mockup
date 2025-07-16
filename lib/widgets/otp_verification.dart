import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';

Widget otpVerification(
  label,
  String? contact,
  valueCapture,
  BuildContext context,
  VoidCallback onResendOTP,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimationWrapper(
          index: 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              "Please enter OTP sent to your phone Number ending with ${contact?.replaceRange(0, 9, "****")}",
              style: TextStyle(color: AppColor().grayText),
            ),
          ),
        ),
        AnimationWrapper(
          index: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              label,
              style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        AnimationWrapper(
          index: 2,
          child: PinFieldAutoFill(
            decoration: BoxLooseDecoration(
              radius: const Radius.circular(4.0),
              bgColorBuilder: FixedColorBuilder(AppColor().inputFieldColor),
              // colorBuilder: FixedColorBuilder(AppColor().inputFieldColor),
              textStyle: const TextStyle(fontSize: 20, color: Colors.black),
              gapSpace: 12,

              strokeColorBuilder: FixedColorBuilder(AppColor().inputFieldColor),
            ),

            // currentCode: ,
            onCodeSubmitted: (code) {},
            onCodeChanged: (code) {
              valueCapture(code);
              // if (code!.length == 6) {
              // FocusScope.of(context).requestFocus(FocusNode());
              // }
            },
          ),
        ),
        // TextFormField(
        //   validator: (value) =>
        //       value!.isEmpty ? "This field is required" : null,
        //   onChanged: valueCapture,
        //   keyboardType: inputType,
        //   style: TextStyle(color: AppColor().textColor),
        //   maxLength: 6,
        //   decoration: InputDecoration(
        //       border:
        //           OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
        //       contentPadding:
        //           const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
        //       hintText: hint,
        //       hintStyle: TextStyle(color: AppColor().grayText),
        //       counterText: "",
        //       fillColor: AppColor().inputFieldColor,
        //       filled: true),
        // ),
        const SizedBox(height: 12),
        AnimationWrapper(
          index: 2,
          child: Countdown(
            seconds: 30,
            build: (BuildContext context, time) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (time.toInt() == 0)
                  AnimationWrapper(
                    key: const Key('resend-otp'),
                    index: 1,
                    type: 'fadeIn',
                    child: TextButton(
                      onPressed: onResendOTP,
                      child: Text(
                        "Resend OTP ",
                        style: TextStyle(
                            color: AppColor().blueBTN,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ),
                if (time.toInt() > 0)
                  AnimationWrapper(
                    key: const Key('otp-timer'),
                    index: 1,
                    type: 'fadeIn',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Resend OTP in ",
                          style: TextStyle(
                              color: time.toInt() == 0
                                  ? AppColor().blueBTN
                                  : AppColor().grayText,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        Icon(Icons.watch_later_outlined,
                            color: AppColor().grayText),
                        Text(
                          " 00:${time.toInt() < 10 ? '0' : ''}${time.toInt()}",
                          style: TextStyle(
                              color: AppColor().grayText,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            onFinished: () {},
          ),
        )
      ],
    ),
  );
}
