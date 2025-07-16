import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/User/providers/metadata.dart';

class StatusBannerHelper {
  static void checkAndShowStatusBanner({
    required BuildContext context,
    required bool mounted,
    required VoidCallback showStatusBanner,
    required VoidCallback hideStatusBanner,
    required String updated,
  }) {
    final profileStatus = SessionPref.getUserProfile()?[6];
    final kycStatus = SessionPref.getUserProfile()?[7];

    if (profileStatus == "pending" ||
        profileStatus == "submitted" ||
        kycStatus == "pending") {
      showStatusBanner();
    }
  }

  static void showStatusBanner({
    required bool mounted,
    required bool isStatusBannerVisible,
    required Function(VoidCallback) setState,
    required AnimationController statusBannerController,
    required Function(bool) setStatusBannerVisible,
  }) {
    if (!isStatusBannerVisible && mounted) {
      setState(() {
        setStatusBannerVisible(true);
      });
      statusBannerController.forward();
    }
  }

  static void hideStatusBanner({
    required bool mounted,
    required bool isStatusBannerVisible,
    required AnimationController statusBannerController,
    required Function(VoidCallback) setState,
    required Function(bool) setStatusBannerVisible,
  }) {
    if (isStatusBannerVisible && mounted) {
      statusBannerController.reverse().then((_) {
        if (mounted) {
          setState(() {
            setStatusBannerVisible(false);
          });
        }
      });
    }
  }

  static Widget buildStatusBanner({
    required BuildContext context,
    required Animation<double> statusBannerAnimation,
    required bool rotate,
    required MetadataProvider metadataProvider,
    required VoidCallback onCompletePressed,
    required VoidCallback onClosePressed,
    required String updated,
  }) {
    final profileStatus = SessionPref.getUserProfile()?[6];
    final kycStatus = SessionPref.getUserProfile()?[7];

    if (profileStatus == "finished" && kycStatus == "active") {
      return const SizedBox.shrink();
    }

    Color bannerColor;
    IconData bannerIcon;
    String bannerTitle;
    String bannerMessage;
    bool showAction = false;

    if (profileStatus == "pending") {
      bannerColor = AppColor().blueBTN;
      bannerIcon = Icons.person;
      bannerTitle = "Complete Your Profile";
      bannerMessage = "Complete your KYC to start investing";
      showAction = true;
    } else if (profileStatus == "submitted" ||
        kycStatus == "pending" ||
        updated == 'submitted') {
      bannerColor = AppColor().orangeApp;
      bannerIcon = Icons.pending_actions;
      bannerTitle = "KYC Under Review";
      bannerMessage = "We're reviewing your documents";
      showAction = false;
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: statusBannerAnimation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Transform.translate(
          offset: Offset(0, -80 * (1 - statusBannerAnimation.value)),
          child: Opacity(
            opacity: statusBannerAnimation.value,
            child: Container(
              height: screenHeight*0.2,
              width: screenWidth,
              margin: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: screenHeight * 0.005,
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: bannerColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(
                      bannerIcon,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bannerTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          bannerMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: screenWidth * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showAction)
                    SizedBox(
                      height: screenHeight * 0.04,
                      child: ElevatedButton(
                        onPressed: onCompletePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: bannerColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Complete",
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (rotate) ...[
                              SizedBox(width: screenWidth * 0.02),
                              SizedBox(
                                width: screenWidth * 0.03,
                                height: screenWidth * 0.03,
                                child: CircularProgressIndicator(
                                  color: bannerColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  // SizedBox(width: screenWidth * 0.02),
                  // InkWell(
                  //   onTap: onClosePressed,
                  //   child: Container(
                  //     padding: EdgeInsets.all(screenWidth * 0.01),
                  //     child: Icon(
                  //       Icons.close,
                  //       color: Colors.white.withOpacity(0.8),
                  //       size: screenWidth * 0.04,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
