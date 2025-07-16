import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/user/terms_condition.dart';
import 'package:iwealth/services/auth/language_switcher.dart';
import 'package:iwealth/services/auth/quick_service.dart';
import 'package:iwealth/services/auth/registration.dart';
import 'package:iwealth/services/auth/token_service.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/btmSheet.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String? username, pin;
  bool isRotating = false;
  bool isItVisible = true;
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _pinFocusNode.unfocus();
  }

  void activateAuthentication(mp) async {
    if (formKey.currentState!.validate()) {
      loading(context);
      try {
        var res = await Waiter()
            .authenticateInvestor(context: context, pin: pin.toString());
        if (res["status"] == true) {
          var decodeBody = res["data"];
          await SessionPref.createSession("Logged-IN");
          await SessionPref.setToken(decodeBody["access_token"],
              decodeBody["refresh_token"], "${decodeBody["expires_in"]}");

          // Start auto refresh after successful login
          TokenService.startAutoRefresh();

          var profileStatus =
              await Waiter().getUserProfile(SessionPref.getToken()![0]);
          if (profileStatus == "1") {
            // Load basic features in parallel for faster login
            try {
              await Future.wait([
                StockWaiter().getStocks(mp: mp, context: context),
                StockWaiter().getMarketStatus(mp: mp, context: context),
                StockWaiter().stockPerformance(
                    identity: "movers", provider: mp, context: context),
              ]);
            } catch (e) {
              if (kDebugMode) {
                print("Error loading market data: $e");
              }
            }

            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarWidget()));

            // Load portfolio in background after navigation for faster perceived performance
            var userProfile = SessionPref.getUserProfile();
            if (userProfile != null &&
                userProfile.length > 6 &&
                userProfile[6] != "pending") {
              // Use unawaited to avoid blocking UI
              StockWaiter().getPortfolio(context: context, provider: mp).catchError((e) {
                if (kDebugMode) {
                  print("Error loading portfolio: $e");
                }
              });
            }
          } else {
            Navigator.pop(context);
            AppSnackbar(
              isError: true,
              response:
                  "Failed to load your profile. Check your Password and try again.",
            ).show(context);
          }
        } else {
          throw Exception(res["message"] ?? "Authentication failed");
        }
      } catch (e) {
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response:
              "Failed to load your profile. Check your Password and try again.",
        ).show(context);
        setState(() {
          isRotating = false;
        });
      }
    }
  }

  String _getUniqueHeroTag(String baseTag) {
    const uuid = Uuid();
    return '${baseTag}_${uuid.v4()}';
  }

  final pinTheme = PinTheme(
    width: 80,
    height: 80,
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColor().textColor,
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appHeight = MediaQuery.of(context).size.height;
    final appWidth = MediaQuery.of(context).size.width;
    final marketProvider = Provider.of<MarketProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [LanguageSwitcher()],
      ),
      body: GestureDetector(
        onTap: _hideKeyboard,
        child: Container(
          height: appHeight,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Hero(
                      tag: _getUniqueHeroTag('logo'),
                      child: SvgPicture.asset(
                        "assets/images/itrust_logo_with_name.svg",
                        // width: 180,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: appHeight - 100,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Welcome ${SessionPref.getUserProfile()?[0] != null ? 'back,' : ''} ${SessionPref.getUserProfile()?[0] ?? ''}",
                            style: TextStyle(
                              color: AppColor().textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: appHeight * 0.02),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Pinput(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  focusNode: _pinFocusNode,
                                  autofocus: false,
                                  length: 4,
                                  defaultPinTheme: pinTheme,
                                  focusedPinTheme: pinTheme.copyWith(
                                    decoration: pinTheme.decoration!.copyWith(
                                      border: Border.all(
                                          color: AppColor().blueBTN, width: 2),
                                    ),
                                  ),
                                  errorPinTheme: pinTheme.copyWith(
                                    decoration: pinTheme.decoration!.copyWith(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  onCompleted: (value) {
                                    pin = value;
                                    if (!isRotating) {
                                      activateAuthentication(marketProvider);
                                    }
                                  },
                                  onChanged: (value) => pin = value,
                                  obscureText: true,
                                  showCursor: true,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.length != 4) {
                                      return 'Please enter 4 digits';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: appHeight * 0.01),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTextButton(
                                      "Quick Services",
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const QuickService(),
                                        ),
                                      ),
                                    ),
                                    _buildTextButton(
                                        "Forgot PIN?",
                                        //show confirm dialog
                                        () => Btmsheet().showConfirm(
                                              context,
                                              'Forgot PIN?',
                                              'No transactions can be made 12 hours after changing the PIN.',
                                              appWidth,
                                              appHeight,
                                              title:
                                                  'Would you like to reset your PIN?',
                                              onConfirm: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Registration(
                                                            resetPin: true),
                                                  ),
                                                );
                                              },
                                            )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: appHeight * 0.02),
                          Container(
                            width: appWidth * 1,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor().blueBTN.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isRotating
                                  ? null
                                  : () =>
                                      activateAuthentication(marketProvider),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isRotating
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: appHeight * 0.03),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: _buildTextButton(
                    "Terms & Conditions",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndCondition(),
                      ),
                    ),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed, {Color? color}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? AppColor().blueBTN,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}
