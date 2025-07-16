import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/auth/login.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/widgets/app_completion_screen.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/otp_verification.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyAccount extends StatefulWidget {
  final Widget nextScreen;

  const VerifyAccount({
    super.key,
    required this.nextScreen,
  });

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount>
    with SingleTickerProviderStateMixin {
  bool itRotate = false;

  final formKey = GlobalKey<FormState>();
  String? phone;
  int step = 1;

  bool isItVisible = true;

  String msg = "";
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: "TZ");

  String _code = "";

  final FocusNode _phoneNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    SmsAutoFill().unregisterListener();

    super.dispose();
  }

  // step 01 VerifyAccount
  Future<void> _requestOTPProcess() async {
    try {
      phone = _phoneNumber.phoneNumber.toString().substring(1);
      setState(() {
        itRotate = true;
      });

      final signature = await SmsAutoFill().getAppSignature;

      var otpstatus = await Waiter()
          .requestOTP(phone: phone, appSignature: signature, context: context);
      if (otpstatus['status'] == "success") {
        await SmsAutoFill().listenForCode();
        setState(() {
          step = 2;
          itRotate = false;
        });
      } else {
        throw Exception(otpstatus['message']);
      }
    } catch (e) {
      setState(() {
        itRotate = false;
      });

      AppSnackbar(
        isError: true,
        response:
            "Account Verification Failed.",
      ).show(context);

      if (kDebugMode) {
        print("OTP request error: $e");
      }
    }
  }

  // step 02 OTP verification
  void verifyOTP() async {
    setState(() {
      itRotate = true;
    });
    var otpStatus =
        await Waiter().validateOTP(phone: phone.toString(), otp: _code, context: context);

    if (otpStatus == "success") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AppCompletion(
                    url: '',
                    description:
                        'Account Successfully Verified You can login now',
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    text: 'Account Successfully Verified You can login now',
                    isIcon: true,
                    isSvg: false,
                    multiTitle: false,
                  )));
    } else {
      setState(() {
        itRotate = false;
      });
      AppSnackbar(
        isError: true,
        response: "Account Verification Failed. \n Invalid OTP",
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Changed to true to handle keyboard
      appBar: AppBar(
        backgroundColor: AppColor().mainColor,
        leading: IconButton(
          onPressed: () {
            if (step > 1) {
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
        title: Text(step == 1 ? "Login" : "OTP Verification"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _phoneNumberFocusNode.unfocus();
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: Column(
              children: [
                if (step == 1) const Spacer(),
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8),
                    child: Column(
                      children: [
                        if (step == 1)
                          Column(
                            children: [
                              SvgPicture.asset(
                                "assets/images/itrust_logo_with_name.svg",
                                width: appWidth * 0.7,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              Form(
                                key: formKey,
                                child: CustomTextfield().phoneNumber(
                                  (val) => setState(() => _phoneNumber = val),
                                  _phoneNumber,
                                  focusNode: _phoneNumberFocusNode,
                                ),
                              ),
                            ],
                          ),
                        // add otp
                        if (step == 2)
                          Form(
                            child: otpVerification(
                                "Enter OTP",
                                phone,
                                (val) => _code = val,
                                context,
                                _requestOTPProcess),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Spacer(),
                itRotate
                    ? CircularProgressIndicator(color: AppColor().blueBTN)
                    : largeBTN(appWidth, step != 2 ? 'Continue' : 'Verify',
                        AppColor().blueBTN, () async {
                        if (step == 1) {
                          _requestOTPProcess();
                        } else {
                          verifyOTP();
                        }
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
