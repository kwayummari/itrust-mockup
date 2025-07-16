import 'package:flutter/material.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/stocks/screen/stockdetails.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:uuid/uuid.dart';

Widget fundCard({
  required FundModel fund,
  required double appWidth,
  required BuildContext context,
  required Color tagColor,
  required ShapeBorder tagShape,
  required String tagText,
  required Color cardColor,
}) {
  // final List<Widget> fundIcons = [
  //   Image.asset("assets/images/icash_icon.png", width: 36, height: 36),
  //   Image.asset("assets/images/igrowth_icon.png", width: 36, height: 36),
  //   Image.asset("assets/images/isave_icon.png", width: 36, height: 36),
  //   Image.asset("assets/images/iincome_icon.png", width: 36, height: 36),
  //   Image.asset("assets/images/imaan_icon.png", width: 36, height: 36),
  // ];
  int iconIndex = 0;
  if (fund.name.toLowerCase().contains("cash")) {
    iconIndex = 0;
  } else if (fund.name.toLowerCase().contains("growth")) {
    iconIndex = 1;
  } else if (fund.name.toLowerCase().contains("save")) {
    iconIndex = 2;
  } else if (fund.name.toLowerCase().contains("income")) {
    iconIndex = 3;
  } else if (fund.name.toLowerCase().contains("maan")) {
    iconIndex = 4;
  }

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockDetailScreen(
            companyName: fund.name,
            logo: fund.logoUrl,
            tickerSymbol: fund.name,
            stockID: fund.shareClassCode,
            screen: "fund",
          ),
        ),
      );
    },
    child: Container(
      width: appWidth * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Row with icon and fund name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: tagColor.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: fund.logoUrl.isNotEmpty
                                  ? Image.network(
                                      fund.logoUrl,
                                      width: 50,
                                      height: 50,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 36),
                                    )
                                  : const Icon(Icons.image, size: 36),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                fund.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                          height: 18,
                        ),
                        // Titles outside the colored background
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Minimum Investment",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Net Asset Value (NAV)",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Values with light blue background, touching card edges
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F0FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      "TZS ${currencyFormat(double.tryParse(fund.initialMinContribution) ?? 0.0)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: tagColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    double.tryParse(fund.nav)
                                            ?.toStringAsFixed(4) ??
                                        "-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tagColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _getUniqueHeroTag(String baseTag) {
  const uuid = Uuid();
  return '${baseTag}_${uuid.v4()}';
}

Widget _buildInfoRow(String title, String value, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
