import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/screens/user/profile.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/providers/theme_provider.dart';

class AccountAndSettings extends StatefulWidget {
  const AccountAndSettings({super.key});

  @override
  State<AccountAndSettings> createState() => _AccountAndSettingsState();
}

class _AccountAndSettingsState extends State<AccountAndSettings> {
  List<dynamic>? subscriptions;

  @override
  void initState() {
    super.initState();
    subscriptions = SessionPref.getUserSubscriptions();
    // Add debug log
    if (kDebugMode) {
      print("DEBUG: Subscriptions data from SessionPref:");
      print(subscriptions);
    }
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: ListTile(
        onTap: () {
          // showGeneralDialog(
          //   context: context,
          //   barrierDismissible: true,
          //   barrierLabel: "Drawer",
          //   transitionDuration: const Duration(milliseconds: 300),
          //   pageBuilder: (context, animation, secondaryAnimation) {
          //     return Align(
          //       alignment: Alignment.centerLeft,
          //       child: SizedBox(
          //         width: MediaQuery.of(context).size.width,
          //         height: MediaQuery.of(context).size.height,
          //         child: Material(
          //           child: const UserProfile(),
          //         ),
          //       ),
          //     );
          //   },
          //   transitionBuilder: (context, animation, secondaryAnimation, child) {
          //     return SlideTransition(
          //       position: Tween(begin: Offset(-1, 0), end: Offset.zero)
          //           .animate(animation),
          //       child: child,
          //     );
          //   },
          // );

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UserProfile()));
        },
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: AppColor().inputFieldColor, width: 1),
        ),
        tileColor: AppColor().lowerBg,
        leading: CircleAvatar(
          backgroundColor: AppColor().blueBTN.withAlpha(20),
          radius: 30,
          child: SvgPicture.asset(
            "assets/images/Logo.svg",
            height: 30,
          ),
        ),
        title: Text(
          "${SessionPref.getUserProfile()![0]} ${SessionPref.getUserProfile()![2]}"
              .toLowerCase()
              .capitalize(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Account No: ${SessionPref.getUserProfile()![9]}",
              style: TextStyle(
                color: AppColor().grayText,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColor().textColor),
      ),
    );
  }

  // Update the subscription card builder with correct data mapping
  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    // Debug log the individual subscription
    if (kDebugMode) {
      print("Processing subscription:");
      print(subscription);
    }

    // Update the key mappings to match the actual data structure
    final fundReferenceNumber =
        subscription['client_code'] ?? 'N/A'; // or the correct key
    final fundCode = subscription['fund_code'] ?? 'Fund Code';
    final accountNumber = subscription['fund_account_number'] ?? 'N/A';
    final fundName = subscription['name'] ?? 'Fund name';
    Provider.of<MarketProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor().mainColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor().inputFieldColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund Name and Code Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fundName,
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor().blueBTN.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fundCode,
                    style: TextStyle(
                      color: AppColor().blueBTN,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              label: "Control Number",
              value: fundReferenceNumber,
              isReference: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              label: "Account Number",
              value: accountNumber,
              isReference: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isReference = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor().grayText,
            fontSize: 12,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColor().textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isReference) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColor().blueBTN.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  bool hasValidSubscriptions() {
    if (subscriptions == null || subscriptions!.isEmpty) return false;
    return subscriptions!.any((sub) => sub['client_code'] != null);
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // child: ListTile(
          //   title: Text(
          //     'Dark Mode',
          //     style: TextStyle(
          //       fontSize: 16,
          //       color: Theme.of(context).textTheme.bodyLarge?.color,
          //     ),
          //   ),
          //   trailing: Switch(
          //     value: themeProvider.isDarkMode,
          //     onChanged: (value) => themeProvider.toggleTheme(),
          //     activeColor: AppColor().blueBTN,
          //   ),
          // ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColor().orangeApp,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColor().orangeApp.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColor().orangeApp,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                color: AppColor().orangeApp,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor().orangeApp.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColor().orangeApp,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(
                    color: AppColor().grayText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: AppColor().blueBTN),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: AppColor().blueBTN),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Waiter().logOUT(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor().orangeApp,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
          iconSize: 20,
          padding: const EdgeInsets.only(left: 16),
        ),
        title: const Text(
          "Account & Settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Static Content
            _buildProfileCard(),
            // _buildThemeToggle(),

            // Scrollable Investment Accounts Section
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Your Fund Subscriptions Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor().textColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8), // Space for logout button
                      child: !hasValidSubscriptions()
                          ? _buildEmptySubscriptionState()
                          : ListView.builder(
                              itemCount: subscriptions!
                                  .where((sub) => sub['client_code'] != null)
                                  .length,
                              itemBuilder: (context, index) {
                                final validSubs = subscriptions!
                                    .where((sub) => sub['client_code'] != null)
                                    .toList();
                                return _buildSubscriptionCard(validSubs[index]);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColor().mainColor,
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubscriptionState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().mainColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor().inputFieldColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColor().grayText,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No subscriptions found',
              style: TextStyle(
                color: AppColor().grayText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
