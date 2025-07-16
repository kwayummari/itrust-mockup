import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/view_subsc.dart';
import 'package:iwealth/services/IPO/ipo_waiter.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:provider/provider.dart';

class IPOSubscriptionListScreen extends StatefulWidget {
  List<IPOSubscription> subsData = [];
  IPOSubscriptionListScreen({super.key, required this.subsData});

  @override
  State<IPOSubscriptionListScreen> createState() => _IPOSubscriptionState();
}

class _IPOSubscriptionState extends State<IPOSubscriptionListScreen> {
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor().blueBTN,
            AppColor().blueBTN.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor().blueBTN.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColor().constant,
                size: 20,
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarWidget(currentIndex: 2)),
                (route) => false,
              ),
            ),
            Text(
              "Subscriptions",
              style: TextStyle(
                color: AppColor().constant,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 40), // Balance the header
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
      IPOSubscription subscription, MarketProvider mp) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSubscription(
              fundOrder: subscription,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subscription.name,
                      style: TextStyle(
                        color: AppColor().blueBTN,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(subscription.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                  "Date",
                  DateFormat.yMMMEd()
                      .format(DateTime.parse(subscription.date))),
              _buildInfoRow("Amount",
                  "TZS ${currencyFormat(double.parse(subscription.amount))}"),
              _buildInfoRow("Amount Paid",
                  "TZS ${currencyFormat(double.parse(subscription.amountPaid))}"),
              _buildInfoRow("Reference", subscription.clientRef,
                  isReference: true),
              _buildInfoRow("Account", subscription.accountNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case "pending":
        chipColor = AppColor().orangeApp;
        statusText = "Pending";
        statusIcon = Icons.pending_actions;
        break;
      case "submitted":
      case "reviewed":
        chipColor = const Color(0xFFF1A603);
        statusText = "On Review";
        statusIcon = Icons.sync;
        break;
      case "approved":
        chipColor = AppColor().success;
        statusText = "Done";
        statusIcon = Icons.check_circle;
        break;
      default:
        chipColor = AppColor().grayText;
        statusText = "Unknown";
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isReference = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: AppColor().textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isReference ? AppColor().blueBTN : AppColor().textColor,
                fontSize: 13,
                fontWeight: isReference ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await IpoWaiter().getSubscriptionList(mp: mp, context: context);
              },
              color: AppColor().blueBTN,
              child: widget.subsData.isEmpty
                  ? Center(
                      child: Text(
                        'No subscriptions found',
                        style: TextStyle(
                          color: AppColor().textColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: widget.subsData.length,
                      itemBuilder: (context, index) {
                        return _buildSubscriptionCard(
                            widget.subsData[index], mp);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
