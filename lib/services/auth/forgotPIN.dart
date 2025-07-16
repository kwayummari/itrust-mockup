import 'package:iwealth/screens/otp/otpscreen.dart';
import 'package:iwealth/services/auth/registration.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:animate_do/animate_do.dart';

class Forgotpin extends StatefulWidget {
  Widget nextScreen;
  String title;
  bool isCacheCleared;
  Forgotpin(
      {super.key,
      required this.nextScreen,
      required this.title,
      required this.isCacheCleared});

  @override
  State<Forgotpin> createState() => _ForgotpinState();
}

class _ForgotpinState extends State<Forgotpin> {
  final formKey = GlobalKey<FormState>();
  String? phone;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: "TZ");

  final FocusNode _phoneNumberFocusNode = FocusNode();

  void sendOTP() async {
    loading(context);
    phone = _phoneNumber.phoneNumber.toString().substring(1);
    var response = await Waiter().requestOTP(phone: phone, context: context);

    if (response['status'] == 'success') {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreenVerification(
            phone: phone,
            msg: widget.title == "Login"
                ? "Account Successfully Verified You can login now"
                : "Account Successfully Verified You can Reset PIN Now",
            screen: widget.nextScreen,
            otp: response['otp'],
          ),
        ),
      );
    } else {
      Navigator.pop(context);
      AppSnackbar(
        isError: true,
        response:
            response['message'],
      ).show(context);
    }
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
        leading: const Icon(
          Icons.arrow_back_ios,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Allows screen to move up with keyboard
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: () => _phoneNumberFocusNode.unfocus(),
            child: SingleChildScrollView(
              // Enables scrolling when keyboard appears
              child: Container(
                width: constraints.maxWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.0,
                    MediaQuery.of(context).padding.top + 10,
                    20.0,
                    20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTopSection(constraints),
                      _buildPhoneInputSection(constraints),
                      _buildBottomSection(constraints),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: SvgPicture.asset(
              "assets/images/itrust_logo_with_name.svg",
              height: constraints.maxHeight * 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputSection(BoxConstraints constraints) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextfield().phoneNumber(
                  (val) => _phoneNumber = val,
                  _phoneNumber,
                  focusNode: _phoneNumberFocusNode,
                ),
                const SizedBox(height: 320),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) sendOTP();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C5080),
                    minimumSize: Size(constraints.maxWidth, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BoxConstraints constraints) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have account? ",
              style: TextStyle(
                color: Color(0xFF003087),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Registration(),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Register now",
                    style: TextStyle(
                      color: Color(0xFF003087),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF003087),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
