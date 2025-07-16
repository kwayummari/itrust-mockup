import 'package:flutter/material.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/app_completion_screen.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/User/model/user_kyc.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:provider/provider.dart';

class TINDSEScreen extends StatefulWidget {
  final Map<String, dynamic>? bankDetails;
  final Map<String, dynamic>? employmentDetails;
  final Map<String, dynamic>? nextOfKinDetails;
  final String title;

  const TINDSEScreen(
      {super.key,
      this.bankDetails,
      this.employmentDetails,
      this.nextOfKinDetails,
      required this.title});

  @override
  State<TINDSEScreen> createState() => _TINDSEScreenState();
}

class _TINDSEScreenState extends State<TINDSEScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dseCdsController = TextEditingController();
  final TextEditingController tinController = TextEditingController();

  bool hasDSEAccount = true;
  bool isSubmitting = false;

  void _showCDSInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColor().blueBTN),
              const SizedBox(width: 10),
              const Text('DSE CDS Number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A CDS (Central Depository System) account number is required to trade on the Dar es Salaam Stock Exchange (DSE) platform.',
                  style: TextStyle(
                    color: AppColor().textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'To obtain a CDS account:',
                  style: TextStyle(
                    color: AppColor().textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Open a securities account with a licensed Dealing Member (stockbroking firm)',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                      Text(
                        '• Complete KYC requirements with your chosen broker',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                      Text(
                        '• Your broker will be your main point of contact for trading',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: AppColor().blueBTN, fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  Future<void> _submitCompleteKYC() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced progress indicator with background circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColor().blueBTN.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: AppColor().blueBTN,
                        strokeWidth: 3,
                        backgroundColor: AppColor().blueBTN.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                AppText(
                  txt: "Submitting KYC...",
                  size: 16,
                  color: AppColor().textColor,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 6),

                AppText(
                  txt: "Please wait while we process your information",
                  size: 13,
                  color: AppColor().textColor.withOpacity(0.7),
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      final nidaData = SessionPref.getNIDA();
      if (nidaData == null) {
        throw Exception(
            "NIDA verification data not found. Please restart the verification process.");
      }

      final metadataProvider =
          Provider.of<MetadataProvider>(context, listen: false);

      USERKYC userkyc = USERKYC(
        fname: nidaData[4],
        mname: nidaData[6],
        lname: nidaData[5],
        dob: nidaData[3],
        gender: nidaData[13],
        nida: nidaData[7],
        placeOfBirth: nidaData[8],
        nationality: "Tanzanian",
        country: "TZ",

        investorPhone: SessionPref.getUserProfile()?[4] ?? '',

        address: "${nidaData[10]}, ${nidaData[11]}, ${nidaData[12]}".trim(),
        region: nidaData[10],
        district: nidaData[11],
        ward: nidaData[12],

        // Bank details
        banckAcNo: widget.bankDetails?['accountNumber'] ?? '',
        bankAcName: widget.bankDetails?['accountName'] ?? '',
        bank: widget.bankDetails?['bankId'] ?? '',
        bankBranch: widget.bankDetails?['branchName'] ?? '',

        // Employment details from your employment screen
        employmentStatus: widget.employmentDetails?['employmentStatus'] ?? '',
        employerName: widget.employmentDetails?['employerName'] ?? '',
        occupation: widget.employmentDetails?['occupation'] ?? '',
        businessSector: widget.employmentDetails?['sectorName'] ??
            '', // This maps to your text input
        sourceOfIncome: widget.employmentDetails?['sourceOfIncomeId'] ?? '',
        incomeFreq: widget.employmentDetails?['monthlyIncomeRange'] ?? '',

        // Next of kin details
        nextKinName: widget.nextOfKinDetails?['fullName'] ?? '',
        nextKinMobile: widget.nextOfKinDetails?['phoneNumber'] ?? '',
        kinEmail: widget.nextOfKinDetails?['email'] ?? '',
        kinRelationship: widget.nextOfKinDetails?['relationship'] ?? '',

        // Optional fields
        dseAccount: hasDSEAccount ? dseCdsController.text.trim() : "",
        tinNumber: tinController.text.trim().isEmpty
            ? null
            : tinController.text.trim(),
        title: widget.title ?? '',

        // Documents
        // passportSizeDoc: null,
        signatureDoc: null,
      );

      final response = await Waiter().submitKYC(
        userkyc: userkyc,
        mp: metadataProvider,
        context: context,
      );
      Navigator.pop(context);

      setState(() {
        isSubmitting = false;
      });

      if (response['success'] == true) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateProfileStatus("submitted");

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AppCompletion(
                      url: 'assets/images/kyc.svg',
                      description:
                          'Your NIDA data has been successfully updated! Your digital account has been activated.',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BottomNavBarWidget(
                                    updated: 'submitted',
                                  )),
                          (route) => false,
                        );
                      },
                      text: 'KYC verified successfully',
                      isIcon: false,
                      isSvg: true,
                      multiTitle: false,
                    )));

        // _showCompletionDialog();
      } else {
        String errorMessage = response['message'] ?? 'KYC submission failed';

        if (response['errors'] != null) {
          String detailedErrors = '';
          final errors = response['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            if (value is List) {
              detailedErrors += '• ${value.join('\n')}\n';
            }
          });
          if (detailedErrors.isNotEmpty) {
            errorMessage = detailedErrors.trim();
          }
        }
        AppSnackbar(
          isError: true,
          response: "KYC Submission Failed",
        ).show(context);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        isSubmitting = false;
      });
      AppSnackbar(
        isError: true,
        response: "Something went wrong, Please try again",
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColor().white,
        leading: IconButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "Additional Details",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  AppText(
                    txt:
                        "Please update your TIN and DSE CDS Number to be able to make Investments on the iTrust App.",
                    size: 14,
                    color: AppColor().grayText,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          txt: "Do you have a DSE CDS Account? ",
                          size: 14,
                          weight: FontWeight.w500,
                          color: AppColor().black,
                        ),
                      ),
                      AppText(
                        txt: "(Optional)",
                        size: 14,
                        color: AppColor().grayText,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showCDSInfoDialog,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColor().grayText,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: AppColor().white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: hasDSEAccount,
                        activeColor: AppColor().blueBTN,
                        onChanged: isSubmitting
                            ? null
                            : (bool? value) {
                                setState(() {
                                  hasDSEAccount = value!;
                                });
                              },
                      ),
                      AppText(txt: "Yes", size: 14, color: AppColor().black),
                      const SizedBox(width: 32),
                      Radio<bool>(
                        value: false,
                        groupValue: hasDSEAccount,
                        activeColor: AppColor().blueBTN,
                        onChanged: isSubmitting
                            ? null
                            : (bool? value) {
                                setState(() {
                                  hasDSEAccount = value!;
                                });
                              },
                      ),
                      AppText(txt: "No", size: 14, color: AppColor().black),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (hasDSEAccount) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor().inputFieldColor,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: AppColor().grayText.withOpacity(0.3)),
                      ),
                      child: TextFormField(
                        controller: dseCdsController,
                        enabled: !isSubmitting,
                        style: TextStyle(color: AppColor().textColor),
                        decoration: InputDecoration(
                          hintText: "Enter your DSE CDS Number",
                          hintStyle: TextStyle(color: AppColor().grayText),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          txt: "Tax Identification Number (TIN) ",
                          size: 14,
                          weight: FontWeight.w500,
                          color: AppColor().black,
                        ),
                      ),
                      AppText(
                        txt: "(Optional)",
                        size: 14,
                        color: AppColor().grayText,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColor().grayText,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppColor().white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor().inputFieldColor,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: AppColor().grayText.withOpacity(0.3)),
                    ),
                    child: TextFormField(
                      controller: tinController,
                      enabled: !isSubmitting,
                      style: TextStyle(color: AppColor().textColor),
                      decoration: InputDecoration(
                        hintText: "Enter your TIN",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitCompleteKYC,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmitting
                              ? AppColor().blueBTN.withOpacity(0.3)
                              : AppColor().blueBTN,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: isSubmitting ? 0 : 3,
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
                                txt: "Complete KYC",
                                color: AppColor().white,
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
      ),
    );
  }
}
