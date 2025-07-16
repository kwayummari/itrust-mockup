import 'dart:convert';
import 'package:iwealth/screens/user/kyc_verified_screen.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ConfirmDetailsScreen extends StatefulWidget {
  final String nin;
  final dynamic userData;
  final String? photo; // Add photo parameter for base64 image

  const ConfirmDetailsScreen({
    super.key,
    required this.nin,
    required this.userData,
    this.photo,
  });

  @override
  State<ConfirmDetailsScreen> createState() => _ConfirmDetailsScreenState();
}

class _ConfirmDetailsScreenState extends State<ConfirmDetailsScreen> {
  bool isConsentChecked = false;
  bool isSubmitting = false;

  void _confirmDetails() async {
    // if (!isConsentChecked || isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      if (kDebugMode) {
        print("Confirming details with NIDA data:");
        print("NIN: ${widget.nin}");
        print("User data: ${widget.userData}");
      }

      // Save the NIDA data to session since verification is complete
      if (widget.userData != null) {
        await SessionPref.setNIDA(widget.userData, widget.nin);
        if (kDebugMode) {
          print("NIDA data saved to session successfully");
        }
      }

      // Small delay to show the loading state
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        isSubmitting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const KYCVerifiedScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error confirming details: $e");
      }

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Failed to confirm verification details. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFullName() {
    if (widget.userData == null) return "N/A";

    if (widget.userData.fname != null) {
      return "${widget.userData.fname ?? ''} ${widget.userData.mname ?? ''} ${widget.userData.lname ?? ''}"
          .trim();
    }

    return "${widget.userData['firstName'] ?? ''} ${widget.userData['middleName'] ?? ''} ${widget.userData['surName'] ?? ''}"
        .trim();
  }

  String _getFieldValue(String field) {
    if (widget.userData == null) return "N/A";

    switch (field) {
      case 'phone':
        return SessionPref.getUserProfile()?[4] ?? "N/A";
      case 'dob':
        return widget.userData.dob ?? widget.userData['dateOfBirth'] ?? "N/A";
      case 'nationality':
        return "Tanzanian"; // Default nationality
      case 'nin':
        return widget.userData.nin ?? widget.nin ?? "N/A";
      default:
        return "N/A";
    }
  }

  Widget _buildProfileImage() {
    if (widget.userData.photo != null && widget.userData.photo!.isNotEmpty) {
      try {
        // Decode base64 image
        final bytes = base64Decode(widget.userData.photo!);
        return Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding base64 image: $e");
        }
        return _buildPlaceholderImage();
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        color: Colors.grey.shade100,
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "Review Your Information",
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: index < 5
                            ? AppColor().blueBTN
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Description text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppText(
                    txt:
                        "Please review the details below to make sure everything is correct before completing your verification.",
                    size: 14,
                    color: AppColor().grayText,
                    align: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Profile image
                _buildProfileImage(),

                const SizedBox(height: 24),

                // Information card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColor().white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Full Name", _getFullName()),
                      _buildDivider(),
                      _buildInfoRow("Date of Birth", _getFieldValue('dob')),
                      _buildDivider(),
                      _buildInfoRow(
                          "Nationality", _getFieldValue('nationality')),
                      _buildDivider(),
                      _buildInfoRow("NIDA Number", _getFieldValue('nin')),
                      _buildDivider(),
                      _buildInfoRow("Phone Number", _getFieldValue('phone')),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Consent message (keeping the original confirmation message)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColor().blueBTN,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          txt:
                              "By confirming, you provide consent for conducting eKYC using NIDA. This process is necessary for identification verification and access to services. You agree to the collection and use of your personal data.",
                          size: 12,
                          color: AppColor().grayText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _confirmDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor().blueBTN,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                                txt: "Confirming...",
                                color: AppColor().white,
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ],
                          )
                        : AppText(
                            txt: "Confirm and Continue",
                            color: AppColor().white,
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        isSubmitting ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      elevation: 0,
                    ),
                    child: AppText(
                      txt: "Cancel",
                      color: AppColor().grayText,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: AppText(
                txt: label,
                size: 14,
                color: AppColor().grayText,
                weight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: AppText(
              txt: value.isEmpty ? "N/A" : value,
              size: 14,
              weight: FontWeight.w600,
              color: AppColor().black,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
