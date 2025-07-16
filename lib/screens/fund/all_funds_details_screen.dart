import 'package:flutter/material.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/IPO/view_subsc.dart';

class FundDetailsScreen extends StatelessWidget {
  final List<IPOSubscription>? fundDetails;

  const FundDetailsScreen({super.key, this.fundDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subscriptions'),
        backgroundColor: AppColor().bgLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor().textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: fundDetails == null || fundDetails!.isEmpty
          ? const Center(child: Text('No details available'))
          : ListView.builder(
              itemCount: fundDetails!.length,
              itemBuilder: (context, index) {
                final detail = fundDetails![index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      detail.name,
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
                          'Amount: ${detail.amountPaid}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor().grayText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Date: ${detail.date}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor().grayText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Status: ${detail.status}',
                          style: TextStyle(
                            fontSize: 16,
                            color: detail.status == 'approved'
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
                            fundOrder: detail,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
