import 'package:flutter/foundation.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/user/otp.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_snackbar.dart';

class OTPScreenVerification extends StatefulWidget {
  String? phone, msg, otp; // Add otp parameter
  Widget screen;

  OTPScreenVerification({
    super.key,
    required this.phone,
    required this.msg,
    required this.screen,
    this.otp, // Add otp parameter
  });

  @override
  State<OTPScreenVerification> createState() => _OTPScreenVerificationState();
}

class _OTPScreenVerificationState extends State<OTPScreenVerification> {
  final formKey = GlobalKey<FormState>();
  final FocusNode _otpFocusNode = FocusNode();
  final TextEditingController _otpController =
      TextEditingController(); // Add controller
  String? otp;
  bool isLoading = false;
  bool resendLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.otp != null) {
      // Set the OTP value
      otp = widget.otp;
      _otpController.text = widget.otp!; // Set the controller text

      if (kDebugMode) {
        print("Auto-filling OTP: ${widget.otp}");
      }

      // Show the OTP dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColor().blueBTN),
                  const SizedBox(width: 8),
                  const Text("Test OTP"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("For testing purposes, use this OTP:"),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.otp!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColor().blueBTN,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Auto-verify after dialog is closed
                    if (mounted) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        verifyOTP();
                      });
                    }
                  },
                  child: Text(
                    "OK & Verify",
                    style: TextStyle(color: AppColor().blueBTN),
                  ),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    _otpController.dispose(); // Dispose the controller
    super.dispose();
  }

  void verifyOTP() async {
    loading(context);
    var otpStatus = await Waiter()
        .validateOTP(phone: widget.phone.toString(), otp: otp.toString(), context: context);

    if (otpStatus == "success") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessScreen(
                    btn: const Text(""),
                    successMessage: "${widget.msg}",
                    txtDesc: "",
                    screen: widget.screen,
                  )));
    } else {
      Navigator.pop(context);
      AppSnackbar(
        isError: true,
        response: "Verification Failed, Invalid OTP",
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor().bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor().blueBTN,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          _otpFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 48,
                        color: AppColor().blueBTN,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Verify Your Phone",
                        style: TextStyle(
                          color: AppColor().textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "We've sent a verification code to\n${widget.phone}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor().textColor.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      otpForm(
                        btn: const SizedBox(),
                        w: appWidth,
                        h: appHeight,
                        key: formKey,
                        phone: widget.phone ?? '',
                        focusNode: _otpFocusNode, // Pass focus node to OTP form
                        controller:
                            _otpController, // Pass controller to OTP form
                        otp: (val) {
                          setState(() {
                            otp = val;
                          });
                        },
                        context: context,
                        isLoading: resendLoading,
                        resendTapped: () async {
                          setState(() => resendLoading = true);
                          var status = await Waiter().resendOTP(
                            phone: widget.phone.toString(),
                            context: context,
                          );
                          if (status == "success") {
                            setState(() => resendLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: appWidth * 0.7,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColor().success,
                                content: Center(
                                  child: Text(
                                    "OTP Sent Successfully",
                                    style:
                                        TextStyle(color: AppColor().textColor),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              AppColor().blueBTN,
                              AppColor().blueBTN.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor().blueBTN.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: otp?.length == 6 ? verifyOTP : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
