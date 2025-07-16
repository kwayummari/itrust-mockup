import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/IPO/view_subsc.dart';
import 'package:iwealth/widgets/app_bottom.dart';

class FundDetailsScreen extends StatelessWidget {
  final List<IPOSubscription>? fundDetails;

  const FundDetailsScreen({super.key, this.fundDetails});

  Widget _buildHeader(BuildContext context) {
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
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavBarWidget(),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColor().constant,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Fund Details',
                style: TextStyle(
                  color: AppColor().constant,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentFund =
        fundDetails?.isNotEmpty == true ? fundDetails!.first : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: recentFund == null
                ? const Center(child: Text('No details available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          title: Text(
                            recentFund.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColor().textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                'Amount: TZS.${NumberFormat('#,##0.00').format(double.parse(recentFund.amount))}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor().grayText,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Date: ${recentFund.date}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor().grayText,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Status: ${recentFund.status}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: recentFund.status == 'approved'
                                      ? AppColor().success
                                      : AppColor().orangeApp,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: AppColor().textColor),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewSubscription(
                                  fundOrder: recentFund,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
