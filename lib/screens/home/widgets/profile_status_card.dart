import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/User/providers/metadata.dart';

enum ProfileStatus {
  pending,
  submitted,
  active,
  unknown,
}

class ProfileStatusCard extends StatelessWidget {
  final ProfileStatus status;
  final double appHeight;
  final double appWidth;
  final MetadataProvider metadataProvider;
  final MarketProvider marketProvider;
  final bool rotate;
  final Function() onCompleteProfile;
  final bool isVisible;
  final Function() onVisibilityToggle;
  final PageController pageController;
  final bool isRefreshing;

  const ProfileStatusCard({
    super.key,
    required this.status,
    required this.appHeight,
    required this.appWidth,
    required this.metadataProvider,
    required this.marketProvider,
    required this.rotate,
    required this.onCompleteProfile,
    required this.isVisible,
    required this.onVisibilityToggle,
    required this.pageController,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ProfileStatus.pending:
        return _buildPendingCard(context);
      case ProfileStatus.submitted:
        return _buildSubmittedCard();
      case ProfileStatus.active:
        return _buildActiveCard();
      case ProfileStatus.unknown:
        return _buildUnknownStatusCard();
    }
  }

  Widget _buildPendingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      height: MediaQuery.of(context).size.height*0.25,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor().blueBTN,
            AppColor().blueBTN.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor().blueBTN.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/profile.gif",
                height: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Complete Your Profile",
                      style: TextStyle(
                        color: AppColor().constant,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Complete your KYC to start investing",
                      style: TextStyle(
                        color: AppColor().constant.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: MaterialButton(
              onPressed: onCompleteProfile,
              height: 40.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: AppColor().selected,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Complete Profile",
                    style: TextStyle(
                      color: AppColor().constant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (rotate) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColor().constant,
                        strokeWidth: 2,
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor().orangeApp,
            AppColor().orangeApp.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor().orangeApp.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions,
                color: AppColor().constant,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KYC Under Review",
                      style: TextStyle(
                        color: AppColor().constant,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We're reviewing your KYC form. Please wait for verification.",
                      style: TextStyle(
                        color: AppColor().constant.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor().constant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRefreshing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColor().constant,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.access_time,
                    color: AppColor().constant,
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Text(
                  isRefreshing
                      ? "Checking status..."
                      : "Verification in progress",
                  style: TextStyle(
                    color: AppColor().constant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    // Return the wallet and portfolio card here
    // ... existing active card implementation
    return const SizedBox.shrink(); // Placeholder
  }

  Widget _buildUnknownStatusCard() {
    return Text(
      "Unknown Status on Your KYC",
      style: TextStyle(color: AppColor().textColor),
    );
  }
}
