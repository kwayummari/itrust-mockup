import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/widgets/fund_card.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/screens/fund/all_funds.dart';

Widget fundScreen(
    {required double appHeight,
    required double appWidth,
    required MarketProvider marketProvider,
    required context}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      _buildSectionHeader(
        "Featured Funds",
        "Our top performing investment options",
        AppColor().textColor,
      ),
      Container(
        height: 280,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: marketProvider.fund.length,
              itemBuilder: (context, i) {
                return SizedBox(
                  width: appWidth * 0.85,
                  child: fundCard(
                    fund: marketProvider.fund[i],
                    appWidth: appWidth,
                    context: context,
                    tagColor: AppColor().tagColor,
                    tagShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    tagText: "Featured",
                    cardColor: AppColor().blueBTN,
                  ),
                );
              },
            ),
            // Scroll indicators
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade100.withOpacity(0),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColor().blueBTN.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 32,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade100.withOpacity(0),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColor().blueBTN.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader(
        "All Funds",
        "Explore our complete range of funds",
        AppColor().textColor,
      ),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: marketProvider.fund.length.clamp(0, 3),
        itemBuilder: (context, i) {
          return fundCard(
            fund: marketProvider.fund[i],
            appWidth: appWidth,
            context: context,
            tagColor: AppColor().tagColor,
            tagShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            tagText: "Popular",
            cardColor: AppColor().cardColor,
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllFundsScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor().blueBTN,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "View All Funds",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSectionHeader(String title, String subtitle, Color textColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
