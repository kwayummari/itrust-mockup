import 'dart:convert';
import 'dart:io';
import 'package:iwealth/screens/user/nida_user_kyc.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/screens/user/identy_finger.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NIDAUserKYC extends StatefulWidget {
  const NIDAUserKYC({super.key});

  @override
  State<NIDAUserKYC> createState() => _NIDAUserKYCState();
}

class _NIDAUserKYCState extends State<NIDAUserKYC> {
  final formKey = GlobalKey<FormState>();
  final nidaForm = GlobalKey<FormState>();
  final TextEditingController _nidaController = TextEditingController();
  String qn = "";
  String? nin;
  TextEditingController ans = TextEditingController();
  bool isVisible = true;
  bool isReadonly = false;
  bool ansCircle = false;
  bool reqCircle = false;
  bool isButtonEnabled = false;
  final String _handType = 'left';

  @override
  void initState() {
    super.initState();
    _nidaController.addListener(_onNidaNumberChanged);
  }

  @override
  void dispose() {
    _nidaController.removeListener(_onNidaNumberChanged);
    _nidaController.dispose();
    super.dispose();
  }

  void _onNidaNumberChanged() {
    String text = _nidaController.text.replaceAll('-', '');
    setState(() {
      isButtonEnabled = text.length == 20;
      nin = text;
    });
  }

  String _formatNidaNumber(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 20) {
      digits = digits.substring(0, 20);
    }

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 8 || i == 13 || i == 18) {
        formatted += '-';
      }
      formatted += digits[i];
    }

    return formatted;
  }

  void _showNidaExplanation() {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       backgroundColor: AppColor().white,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(16),
    //       ),
    //       title: AppText(
    //         txt: "What is NIDA Number?",
    //         size: 18,
    //         weight: FontWeight.w600,
    //         color: AppColor().black,
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           AppText(
    //             txt:
    //                 "NIDA stands for National Identification Authority. It's Tanzania's official identification system.",
    //             size: 14,
    //             color: AppColor().textColor,
    //           ),
    //           const SizedBox(height: 12),
    //           AppText(
    //             txt:
    //                 "Your NIDA number is a unique 20-digit identifier found on your National ID card. It's used for:",
    //             size: 14,
    //             color: AppColor().textColor,
    //           ),
    //           const SizedBox(height: 8),
    //           AppText(
    //             txt:
    //                 "• Identity verification\n• Banking services\n• Government services\n• Official documentation",
    //             size: 14,
    //             color: AppColor().textColor,
    //           ),
    //           const SizedBox(height: 12),
    //           AppText(
    //             txt: "Format: XXXXXXXX-XXXXX-XXXXX-XX",
    //             size: 14,
    //             weight: FontWeight.w500,
    //             color: AppColor().blueBTN,
    //           ),
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: AppText(
    //             txt: "Got it",
    //             size: 16,
    //             weight: FontWeight.w500,
    //             color: AppColor().blueBTN,
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              txt: "What is NIDA Number?",
              size: 18,
              weight: FontWeight.w600,
              color: AppColor().black,
            ),
            AppText(
              txt:
                  "NIDA stands for National Identification Authority. It's Tanzania's official identification system.",
              size: 14,
              color: AppColor().textColor,
            ),
            const SizedBox(height: 12),
            AppText(
              txt:
                  "Your NIDA number is a unique 20-digit identifier found on your National ID card. It's used for:",
              size: 14,
              color: AppColor().textColor,
            ),
            const SizedBox(height: 8),
            AppText(
              txt:
                  "• Identity verification\n• Banking services\n• Government services\n• Official documentation",
              size: 14,
              color: AppColor().textColor,
            ),
            const SizedBox(height: 12),
            AppText(
              txt: "Format: XXXXXXXX-XXXXX-XXXXX-XX",
              size: 14,
              weight: FontWeight.w500,
              color: AppColor().blueBTN,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText(
                txt: "Got it",
                size: 16,
                weight: FontWeight.w500,
                color: AppColor().blueBTN,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> captureFingerprint() async {
    if (Platform.isAndroid) {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            AppSnackbar(
              isError: true,
              response: "Camera permission is required for fingerprint capture. Please enable it in settings.",
            ).show(context);
          }
          return null;
        }
      }
    }

    try {
      dynamic rawResult;
      if (Platform.isAndroid) {
        const platform = MethodChannel("identy_finger");
        rawResult = await platform.invokeMethod('capture', _handType);
        if (rawResult is Map) {
          return Map<String, String>.from(rawResult.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ));
        }
      } else if (Platform.isIOS) {
        rawResult = await IdentyFinger.capture(_handType);
      }

      if (rawResult == null) {
        return null;
      }

      if (kDebugMode) {
        print("Raw capture result: $rawResult");
      }

      if (rawResult is String) {
        try {
          final decoded = jsonDecode(rawResult);
          if (decoded is Map) {
            return Map<String, String>.from(decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ));
          }
        } catch (e) {
          if (kDebugMode) {
            print("Failed to parse result: $e");
          }
          return {"R1": rawResult.toString()};
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Capture error: $e");
      }
      return null;
    }
  }

  void nidaCheckBio(UserProvider up, GlobalKey<FormState> fk) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationMethodScreen(nin: nin!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor().white,
        appBar: AppBar(
          elevation: 3,
          backgroundColor: AppColor().white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().black,
              size: 20,
            ),
          ),
          title: AppText(
            txt: SessionPref.getNIDA()?[0] != null
                ? "NIDA Retrieval"
                : "NIDA Verification",
            color: AppColor().black,
            weight: FontWeight.w600,
            size: 18,
          ),
          centerTitle: true,
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                AppText(
                  txt: "NIDA Number",
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColor().black,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor().gray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _nidaController,
                    readOnly: isReadonly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String formatted = _formatNidaNumber(newValue.text);
                        return TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }),
                    ],
                    validator: (value) {
                      String digits = value?.replaceAll('-', '') ?? '';
                      if (digits.isEmpty) {
                        return 'Please enter NIDA number';
                      }
                      if (digits.length != 20) {
                        return 'NIDA number must be 20 digits';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter 20 Digit NIDA Number",
                      hintStyle: TextStyle(
                        color: AppColor().grayText,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      counterText: "",
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor().white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.credit_card,
                          color: AppColor().grayText,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _showNidaExplanation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          txt: "What is NIDA Number ?",
                          size: 16,
                          weight: FontWeight.w500,
                          color: AppColor().black,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColor().grayText,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (reqCircle)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColor().blueBTN,
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        txt: "Verifying NIDA...",
                        color: AppColor().textColor,
                        size: 14,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                if (isVisible)
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isButtonEnabled
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () => nidaCheckBio(up, formKey)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled
                              ? AppColor().blueBTN
                              : AppColor().blueBTN.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: isButtonEnabled ? 3 : 0,
                          disabledBackgroundColor:
                              AppColor().blueBTN.withOpacity(0.3),
                        ),
                        child: AppText(
                          txt: "Continue",
                          color: isButtonEnabled
                              ? AppColor().white
                              : AppColor().white.withOpacity(0.7),
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
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
