import 'package:iwealth/screens/user/bank_details_screen.dart';
import 'package:iwealth/screens/user/verification_ongoing_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class IdentificationQuestionsScreen extends StatefulWidget {
  final String question;
  final int questionNumber;
  final int totalQuestions;
  final String nin;

  const IdentificationQuestionsScreen({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.nin,
  });

  @override
  State<IdentificationQuestionsScreen> createState() =>
      _IdentificationQuestionsScreenState();
}

class _IdentificationQuestionsScreenState
    extends State<IdentificationQuestionsScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(() {
      setState(() {
        isButtonEnabled = _answerController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    // Show loading and navigate to next question or verification ongoing
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.questionNumber < widget.totalQuestions
            ? IdentificationQuestionsScreen(
                question:
                    "What is your favourite food?", // This would come from API
                questionNumber: widget.questionNumber + 1,
                totalQuestions: widget.totalQuestions,
                nin: widget.nin,
              )
            : const VerificationOngoingScreen(
                nin: '',
                verificationData: null,
              ),
      ),
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
          onPressed: () => Navigator.pop(context),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      txt: "Identification questions",
                      size: 18,
                      weight: FontWeight.w600,
                      color: AppColor().black,
                    ),
                    AppText(
                      txt: "${widget.questionNumber}/${widget.totalQuestions}",
                      size: 16,
                      weight: FontWeight.w500,
                      color: AppColor().grayText,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppText(
                  txt:
                      "Please answer the Following Identification question to verify your identity",
                  size: 14,
                  color: AppColor().grayText,
                ),
                const SizedBox(height: 32),
                AppText(
                  txt: widget.question,
                  size: 16,
                  weight: FontWeight.w500,
                  color: AppColor().black,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor().gray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextFormField(
                    controller: _answerController,
                    style: TextStyle(color: AppColor().textColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText:
                          widget.questionNumber == 1 ? "Blood Diamond" : "Rice",
                      hintStyle:
                          TextStyle(color: AppColor().grayText, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const Spacer(),
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
                      onPressed: isButtonEnabled ? _submitAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? AppColor().blueBTN
                            : AppColor().blueBTN.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
