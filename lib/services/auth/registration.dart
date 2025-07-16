import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/user.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/auth/login.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';
import 'package:iwealth/widgets/app_completion_screen.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/otp_verification.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Registration extends StatefulWidget {
  final bool resetPin;

  const Registration({super.key, this.resetPin = false});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin {
  bool itRotate = false;

  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  String? phone, password, confirmationPassword, fname, mname, lname, email;
  int step = 1;
  String title =
      "Create New Account";
  bool isItVisible = true;
  String msg = "";
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: "TZ");
  String _code = "";
  final FocusNode _phoneNumberFocusNode = FocusNode();

  @override
  void initState() {
    step = widget.resetPin ? 2 : 1;
    phone = !widget.resetPin ? phone : SessionPref.getOnboardData()?[0];
    if (widget.resetPin) {
      _requestOTPProcess();
    }
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    SmsAutoFill().unregisterListener();

    super.dispose();
  }

  // step 01 registration
  Future<void> regActivity(uprovider) async {
    if (formKey.currentState!.validate()) {
      phone = _phoneNumber.phoneNumber.toString().substring(1);
      uprovider.user = User(
          banckAcNo: "",
          bankAcName: "",
          bankBranch: "",
          bankID: "",
          country: _phoneNumber.isoCode,
          custodianApproved: "",
          customerType: "",
          dseAccount: "",
          email: email,
          fname: fname,
          hasCustodian: "",
          lname: lname,
          mname: mname,
          phone: phone,
          profileImg: "",
          riskStatus: "",
          status: "",
          subscription: "",
          userID: "");

      try {
        var response = await Waiter().registInvestor(
            user: uprovider.user, context: context, pin: '', confirmPIN: '');
        if (kDebugMode) {
          print("Registration response: $response");
        }

        if (response["code"] == 100) {
          await SessionPref.saveOnboardData(phone: phone, email: email);

          if (step == 1) {
            await _requestOTPProcess();
          }
        } else {
          AppSnackbar(
            isError: true,
            response: response["message"].toString(),
          ).show(context);
          throw Exception(response["message"]);
        }
      } catch (e) {
        setState(() {
          itRotate = false;
        });
      }
    }
  }

  Future<void> _requestOTPProcess() async {
    try {
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
        throw Exception('OTP request failed');
      }
    } catch (e) {
      setState(() {
        itRotate = false;
      });

      AppSnackbar(
        isError: true,
        response: "Registration Failed",
      ).show(context);
    }
  }

  void verifyOTP() async {
    setState(() {
      itRotate = true;
    });
    var otpStatus = await Waiter()
        .validateOTP(phone: phone.toString(), otp: _code, context: context);

    if (otpStatus == "success") {
      setState(() {
        itRotate = false;
        step = 3;
      });
    } else {
      setState(() {
        itRotate = false;
      });
      AppSnackbar(
        isError: true,
        response: "Verification Failed \n Invalid OTP",
      ).show(context);
    }
  }

  void resetNow() async {
    if (formKey2.currentState!.validate()) {
      try {
        var status = await Waiter().resetPIN(
          pin: password.toString(),
          confirmPIN: confirmationPassword.toString(),
          context: context,
        );

        if (status == "success") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AppCompletion(
                        url: 'assets/images/pin.svg',
                        description: widget.resetPin
                            ? 'Note: For your security, transactions are temporarily disabled for 12 hours after a PIN change'
                            : 'Great! Your PIN is ready. Welcome to the iTrust family',
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        text: widget.resetPin
                            ? 'PIN Set Successfully'
                            : 'PIN Changed Successfully',
                        text2: 'Please Log In by entering your New PIN',
                        isIcon: false,
                        isSvg: true,
                        multiTitle: true,
                      )));
        } else {
          Navigator.pop(context);
          AppSnackbar(
            isError: true,
            response: "Failed to reset PIN. Please try again.",
          ).show(context);
        }
      } catch (e) {
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "An error occurred. Please try again.",
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Changed to true to handle keyboard
      appBar: AppBar(
        backgroundColor: AppColor().mainColor,
        leading: step == 3
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  if (step > (widget.resetPin ? 2 : 1)) {
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
        title: Text(
          step == 1
              ? "Create New Account"
              : step == 2
                  ? "OTP Verification"
                  : step == 3
                      ? "Setup PIN"
                      : 'Confirm PIN',
        ),
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
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                AnimationWrapper(
                                  index: 2,
                                  child: CustomTextfield().phoneNumber(
                                    (val) => setState(() => _phoneNumber = val),
                                    _phoneNumber,
                                    focusNode: _phoneNumberFocusNode,
                                  ),
                                ),
                                AnimationWrapper(
                                  index: 3,
                                  child: CustomTextfield().email(
                                    'Enter your email',
                                    'Email',
                                    TextInputType.emailAddress,
                                    (val) => setState(() => email = val),
                                  ),
                                ),
                              ],
                            ),
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

                        // add PIN setup
                        if (step == 3)
                          Form(
                            key: formKey2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Column(
                                children: [
                                  AnimationWrapper(
                                    index: 1,
                                    child: Text(
                                      'Your 4 digit PIN will be used to login to the app, make payments, investments, etc.,',
                                      style:
                                          TextStyle(color: AppColor().grayText),
                                    ),
                                  ),
                                  AnimationWrapper(
                                    index: 2,
                                    child: CustomTextfield().pinSET(
                                      hint: "",
                                      label: "Enter PIN",
                                      valueCapture: (val) =>
                                          setState(() => password = val),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // CONFIRM PIN
                        if (step == 4)
                          Form(
                            key: formKey2,
                            child: Column(
                              children: [
                                AnimationWrapper(
                                  index: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      "Your 4 digit PIN will be used to login to the app, make payments, investments, etc.,",
                                      style:
                                          TextStyle(color: AppColor().grayText),
                                    ),
                                  ),
                                ),
                                AnimationWrapper(
                                  index: 2,
                                  child: CustomTextfield().confirmPIN(
                                    hint: "",
                                    label: "Confirm PIN",
                                    pin: password,
                                    valueCapture: (val) => setState(
                                        () => confirmationPassword = val),
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                itRotate
                    ? CircularProgressIndicator(color: AppColor().blueBTN)
                    : largeBTN(appWidth, step != 2 ? 'Continue' : 'Verify',
                        AppColor().blueBTN,
                        // step > 2 && !formKey2.currentState!.validate()
                        //     ? null
                        //     :
                        () async {
                        if (step == 1) {
                          regActivity(userProvider);
                        } else if (step == 2) {
                          verifyOTP();
                        } else if (step == 3) {
                          if (formKey2.currentState!.validate()) {
                            setState(() {
                              step = 4;
                            });
                          }
                        } else {
                          resetNow();
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
