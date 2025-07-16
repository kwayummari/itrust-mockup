import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:animate_do/animate_do.dart';

class ResetPINScreen extends StatefulWidget {
  final VoidCallback? onBackPress;

  const ResetPINScreen({super.key, this.onBackPress});
  @override
  State<ResetPINScreen> createState() => _ResetPINScreenState();
}

class _ResetPINScreenState extends State<ResetPINScreen> {
  final formKey = GlobalKey<FormState>();
  String? pin, confirmPIN;
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();
  bool _isPinComplete = false;

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _pinFocusNode.unfocus();
    _confirmPinFocusNode.unfocus();
  }

  final pinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColor().textColor,
    ),
    decoration: BoxDecoration(
      color: AppColor().inputFieldColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );

  void resetNow1() async {
    if (formKey.currentState!.validate()) {
      loading(context);

      // Sanitize PINs before sending
      final sanitizedPin = pin?.trim();
      final sanitizedConfirmPin = confirmPIN?.trim();

      if (sanitizedPin == null || sanitizedConfirmPin == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid PINs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        var status = await Waiter().resetPIN(
          pin: sanitizedPin,
          confirmPIN: sanitizedConfirmPin,
          context: context,
        );

        if (status == "success") {
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => AppCompletion(
          //               url: 'assets/images/pin.svg',
          //               description:
          //                   'Note: No transactions can be made 12 hours after changing the pin',
          //               onPressed: () {
          //                 Navigator.pushReplacement(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) => const LoginScreen()));
          //               },
          //               text: 'PIN Changed Successfully',
          //               text2: 'Please Log In by entering your New PIN',
          //               isIcon: false, isSvg: true, multiTitle: true,
          //             )));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reset PIN. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleBackPress() {
    if (widget.onBackPress != null) {
      widget.onBackPress!();
    }
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  @override
  Widget build(BuildContext context) {
    final appHeight = MediaQuery.of(context).size.height;
    final appWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: _handleBackPress,
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            ),
          ),
          title: Text(
            "Reset PIN",
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor().blueBTN.withOpacity(0.1),
                AppColor().inputFieldColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "Create New PIN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor().textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: appHeight * 0.02),
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "Please enter a new 4-digit PIN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor().grayText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: appHeight * 0.04),
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: Pinput(
                          length: 4,
                          focusNode: _pinFocusNode,
                          defaultPinTheme: pinTheme,
                          focusedPinTheme: pinTheme.copyWith(
                            decoration: pinTheme.decoration!.copyWith(
                              border: Border.all(
                                  color: AppColor().blueBTN, width: 2),
                            ),
                          ),
                          onCompleted: (value) {
                            setState(() {
                              pin = value;
                              _isPinComplete = true;
                            });
                            _confirmPinFocusNode.requestFocus();
                          },
                          onChanged: (value) => pin = value,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: appHeight * 0.04),
                      if (_isPinComplete) ...[
                        FadeInDown(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            "Confirm PIN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor().textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: appHeight * 0.02),
                        FadeInDown(
                          duration: const Duration(milliseconds: 300),
                          child: Pinput(
                            length: 4,
                            focusNode: _confirmPinFocusNode,
                            defaultPinTheme: pinTheme,
                            focusedPinTheme: pinTheme.copyWith(
                              decoration: pinTheme.decoration!.copyWith(
                                border: Border.all(
                                    color: AppColor().blueBTN, width: 2),
                              ),
                            ),
                            errorPinTheme: pinTheme.copyWith(
                              decoration: pinTheme.decoration!.copyWith(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                            ),
                            onCompleted: (value) => confirmPIN = value,
                            onChanged: (value) => confirmPIN = value,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != pin) {
                                return 'PINs do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: appHeight * 0.08),
                      FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => resetNow1(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor().blueBTN,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: Size(appWidth * 0.8, 56),
                            ),
                            child: const Text(
                              "Reset PIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
