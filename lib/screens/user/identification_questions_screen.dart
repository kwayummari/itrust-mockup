import 'package:flutter/foundation.dart';
import 'package:iwealth/screens/user/verification_ongoing_screen.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/btmSheet.dart';
import 'package:provider/provider.dart';

class IdentificationQuestionsScreen extends StatefulWidget {
  final String question;
  final int questionNumber;
  final int totalQuestions;
  final String nin;
  final String? questionCode;

  const IdentificationQuestionsScreen({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.nin,
    this.questionCode,
  });

  @override
  State<IdentificationQuestionsScreen> createState() =>
      _IdentificationQuestionsScreenState();
}

class _IdentificationQuestionsScreenState
    extends State<IdentificationQuestionsScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool isButtonEnabled = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(() {
      setState(() {
        isButtonEnabled =
            _answerController.text.trim().isNotEmpty && !isSubmitting;
      });
    });
    print("Question Code: ${widget.questionCode}");
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    if (_answerController.text.trim().isEmpty || isSubmitting) return;

    setState(() {
      isSubmitting = true;
      isButtonEnabled = false;
    });

    try {
      final up = Provider.of<UserProvider>(context, listen: false);

      // Get the current question code from the provider or use the passed one
      String questionCode =
          widget.questionCode ?? up.nidaqns?.questionCode ?? "";

      if (questionCode.isEmpty) {
        if (kDebugMode) {
          print("No question code available");
        }
        setState(() {
          isSubmitting = false;
        });
        if (!mounted) return;
        AppSnackbar(
          isError: true,
          response: "Something went wrong. Please try again.",
        ).show(context);
        return;
      }

      if (kDebugMode) {
        print("Submitting answer for question: ${widget.question}");
        print("Question code: $questionCode");
        print("Answer: ${_answerController.text.trim()}");
      }

      final result = await Waiter().nidaAnswerQuestion(
        nin: widget.nin,
        questionCode: questionCode,
        answer: _answerController.text.trim(),
        up: up,
        context: context,
      );

      setState(() {
        isSubmitting = false;
      });
      if (!mounted) return;

      if (result.status == "00") {
        // Verification successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationOngoingScreen(
              nin: widget.nin,
              verificationData: result.data,
            ),
          ),
        );
      } else if (result.status == "question") {
        // Another question to answer
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IdentificationQuestionsScreen(
              question: result.data.enQuestion ?? "Security question",
              questionNumber: widget.questionNumber + 1,
              totalQuestions: widget.totalQuestions,
              nin: widget.nin,
              questionCode: result.data.questionCode,
            ),
          ),
        );
      } else if (result.status == "wrong_answer") {
        // Wrong answer - allow retry
        Btmsheet().errorSheet(
          context,
          "Incorrect Answer",
          result.message,
          showRetry: true,
          onRetry: () {
            _answerController.clear();
            setState(() {
              isButtonEnabled = false;
            });
          },
        );
      } else if (result.status == "repeat") {
        // Max attempts reached
        _showMaxAttemptsDialog();
      } else if (result.status == "failed") {
        // Verification failed - offer biometric option
        _showVerificationFailedDialog();
      } else {
        _showVerificationFailedDialog();
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      if (!mounted) return;

      if (kDebugMode) {
        print("Error submitting answer: $e");
      }

      AppSnackbar(
        isError: true,
        response: "Something went wrong. Please try again.",
      ).show(context);
    }
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor().white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: AppText(
            txt: "Maximum Attempts Reached",
            size: 18,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
          content: AppText(
            txt:
                "You have reached the maximum number of attempts for question verification. Please try again later or use biometric verification.",
            size: 14,
            color: AppColor().grayText,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: AppText(
                txt: "Try Later",
                size: 14,
                color: AppColor().grayText,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BiometricVerificationScreen(nin: widget.nin),
                  ),
                );
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

  void _showVerificationFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor().white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: AppText(
            txt: "Verification Failed",
            size: 18,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
          content: AppText(
            txt:
                "Question-based verification failed. Would you like to try biometric verification instead?",
            size: 14,
            color: AppColor().grayText,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BiometricVerificationScreen(nin: widget.nin),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().blueBTN,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: AppText(
                txt: "Try Biometric",
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
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "NIDA Verification",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        txt: "Identification Questions",
                        size: 18,
                        weight: FontWeight.w600,
                        color: AppColor().black,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColor().blueBTN.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          txt:
                              "${widget.questionNumber}/${widget.totalQuestions}",
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColor().blueBTN,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  AppText(
                    txt:
                        "Please answer the following identification question to verify your identity",
                    size: 14,
                    color: AppColor().grayText,
                  ),

                  const SizedBox(height: 32),

                  // Question container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor().blueBTN.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColor().blueBTN.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline,
                                color: AppColor().blueBTN, size: 20),
                            const SizedBox(width: 8),
                            AppText(
                              txt: "Question:",
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColor().blueBTN,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          txt: widget.question,
                          size: 16,
                          weight: FontWeight.w500,
                          color: AppColor().black,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer input
                  AppText(
                    txt: "Your Answer",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColor().gray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextFormField(
                      controller: _answerController,
                      enabled: !isSubmitting,
                      style:
                          TextStyle(color: AppColor().textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Enter your answer here",
                        hintStyle:
                            TextStyle(color: AppColor().grayText, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Help text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            txt:
                                "Please provide the exact answer as it appears in your records.",
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Replace Spacer with SizedBox
                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (isButtonEnabled && !isSubmitting)
                          ? _submitAnswer
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isButtonEnabled && !isSubmitting)
                            ? AppColor().blueBTN
                            : AppColor().blueBTN.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: (isButtonEnabled && !isSubmitting) ? 3 : 0,
                        disabledBackgroundColor:
                            AppColor().blueBTN.withOpacity(0.3),
                      ),
                      child: isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColor().white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AppText(
                                  txt: "Submitting...",
                                  color: AppColor().white,
                                  size: 16,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            )
                          : AppText(
                              txt: "Submit Answer",
                              color: (isButtonEnabled && !isSubmitting)
                                  ? AppColor().white
                                  : AppColor().white.withOpacity(0.7),
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                    ),
                  ),

                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
