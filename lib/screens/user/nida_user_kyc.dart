import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/screens/user/identification_questions_screen.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:provider/provider.dart';

class VerificationMethodScreen extends StatefulWidget {
  final String nin;

  const VerificationMethodScreen({
    super.key,
    required this.nin,
  });

  @override
  State<VerificationMethodScreen> createState() =>
      _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethodScreen> {
  bool isLoadingQuestions = false;

  void _selectBiometricVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BiometricVerificationScreen(nin: widget.nin),
      ),
    );
  }

  void _selectSecurityQuestions() async {
    setState(() {
      isLoadingQuestions = true;
    });

    try {
      final up = Provider.of<UserProvider>(context, listen: false);

      final result = await Waiter().nidaGetQuestions(
        nin: widget.nin,
        up: up,
        context: context,
      );

      setState(() {
        isLoadingQuestions = false;
      });

      if (result.status == "success") {
        final questionData = result.data;

        if (kDebugMode) {
          print('Questions fetched successfully: $questionData');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IdentificationQuestionsScreen(
              question: questionData.enQuestion ?? "Security question",
              questionNumber: 1,
              totalQuestions: 5,
              nin: widget.nin,
              questionCode: questionData.questionCode,
            ),
          ),
        );
      } else if (result.status == "no_questions") {
        // No questions available - show message and suggest biometric
        _showNoQuestionsDialog();
      } else {
        AppSnackbar(
          isError: true,
          response:
              "Something went wrong, Please try again",
        ).show(context);
      }
    } catch (e) {
      setState(() {
        isLoadingQuestions = false;
      });

      if (kDebugMode) {
        print('Error fetching questions: $e');
      }
      AppSnackbar(
        isError: true,
        response: "Something went wrong, Please try again",
      ).show(context);
    }
  }

  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor().white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: AppText(
            txt: "No Security Questions Available",
            size: 18,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
          content: AppText(
            txt:
                "Security questions are not available for your account. Please use biometric verification instead.",
            size: 14,
            color: AppColor().grayText,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: AppText(
                txt: "Cancel",
                size: 14,
                color: AppColor().grayText,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _selectBiometricVerification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().blueBTN,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: AppText(
                txt: "Use Biometric",
                size: 14,
                color: AppColor().white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColor().white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: isLoadingQuestions ? null : () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColor().black,
            size: 20,
          ),
        ),
        title: AppText(
          txt: "NIDA Verification",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Title
            AppText(
              txt: "Choose a method to Verify Your Identity",
              size: 18,
              weight: FontWeight.w600,
              color: AppColor().black,
            ),

            const SizedBox(height: 32),

            // Biometric Verification Option
            GestureDetector(
              onTap: isLoadingQuestions ? null : _selectBiometricVerification,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLoadingQuestions
                      ? AppColor().gray.withOpacity(0.5)
                      : AppColor().gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor().white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        color: isLoadingQuestions
                            ? AppColor().black.withOpacity(0.5)
                            : AppColor().black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppText(
                        txt: "Biometric Verification",
                        color: isLoadingQuestions
                            ? AppColor().black.withOpacity(0.5)
                            : AppColor().black,
                        size: 16,
                        weight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isLoadingQuestions
                          ? AppColor().grayText.withOpacity(0.5)
                          : AppColor().grayText,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Answer Security Questions Option
            GestureDetector(
              onTap: isLoadingQuestions ? null : _selectSecurityQuestions,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLoadingQuestions
                      ? AppColor().gray.withOpacity(0.5)
                      : AppColor().gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor().white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isLoadingQuestions
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColor().blueBTN,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.quiz,
                              color: AppColor().black,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppText(
                        txt: isLoadingQuestions
                            ? "Loading Security Questions..."
                            : "Answer Security Questions",
                        color: isLoadingQuestions
                            ? AppColor().blueBTN
                            : AppColor().black,
                        size: 16,
                        weight: FontWeight.w500,
                      ),
                    ),
                    if (!isLoadingQuestions)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor().grayText,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),

            // Information card
            if (isLoadingQuestions) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor().blueBTN.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColor().blueBTN.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColor().blueBTN, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        txt:
                            "Fetching your security questions from NIDA. This may take a moment...",
                        size: 12,
                        color: AppColor().blueBTN,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
