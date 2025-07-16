import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/auth/language_switcher.dart';
import 'package:iwealth/services/auth/toggle.dart';
import 'package:iwealth/services/auth/verify_account.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwealth/screens/terms_and_conditions_page.dart';

class Choice extends StatefulWidget {
  final VoidCallback? toggled;
  const Choice({super.key, this.toggled});

  @override
  State<Choice> createState() => _ChoiceState();
}

class _ChoiceState extends State<Choice> {
  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VerifyAccount(
          nextScreen: Toggle(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [LanguageSwitcher()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: AnimationWrapper(
                      index: 1,
                      child: SvgPicture.asset(
                          "assets/images/landing_page_logo.svg")),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              AnimationWrapper(
                index: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    largeBTN(
                        double.infinity, "Register Now", AppColor().blueBTN,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditionsPage(),
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already Have an Account?",
                          style: TextStyle(color: AppColor().grayText),
                        ),
                        TextButton(
                          onPressed: _goToLogin,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Log In",
                                style: TextStyle(
                                  color: AppColor().blueBTN,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColor().blueBTN,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: TextButton(
              //     onPressed: () {
              //       Waiter().launchInBrowser();
              //     },
              //     child: Text(
              //       "Terms & Conditions",
              //       style: TextStyle(color: AppColor().blueBTN),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
