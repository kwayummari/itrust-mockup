import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/session/app_session.dart'; // Keep your import
import 'package:iwealth/stocks/models/bond_model.dart'; // Keep your import
import 'package:iwealth/stocks/screen/buy_bond.dart'; // Keep your import

class BondDetailsScreen extends StatelessWidget {
  final Bond bond;

  const BondDetailsScreen({super.key, required this.bond});

  bool _isProfileComplete() {
    final status = SessionPref.getUserProfile()![6];
    final kycStatus = SessionPref.getUserProfile()![7];
    return status == "finished" && kycStatus == "active";
  }

  void _onBuyPressed(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BuyBondScreen(bond: bond)));
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0.00');
    final dateFormat = DateFormat.yMMMd();
    final isProfileComplete = _isProfileComplete();
    final ThemeData theme = Theme.of(context);

    final TextStyle labelStyle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.w500, color: Colors.blueGrey[400]);
    final TextStyle valueStyle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.w600, color: Colors.blueGrey[700]);
    final TextStyle cardSectionTitleStyle = theme.textTheme.titleSmall!
        .copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColorDark.withOpacity(0.8));

    final Color accentButtonColor = AppColor().blueBTN;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          bond.securityName ?? 'Bond Details',
          style: TextStyle(
              color: Colors.blueGrey[800], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.blueGrey[700], size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildScreenHeader(context, theme),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Key Metrics', style: cardSectionTitleStyle),
                        const SizedBox(height: 10),
                        _buildMetricRow(
                            'Price',
                            numberFormat.format(bond.price),
                            labelStyle,
                            valueStyle),
                        _buildMetricRow(
                            'Yield to Maturity',
                            '${numberFormat.format(bond.yieldToMaturity)}%',
                            labelStyle,
                            valueStyle),
                        _buildMetricRow(
                            'Coupon Rate',
                            '${numberFormat.format(bond.coupon)}%',
                            labelStyle,
                            valueStyle),
                        _buildMetricRow('Tenure', '${bond.tenure} years',
                            labelStyle, valueStyle),
                        Divider(
                            height: 24,
                            thickness: 0.5,
                            color: Colors.grey[300]),
                        Text('Important Dates', style: cardSectionTitleStyle),
                        const SizedBox(height: 10),
                        bond.issueDate != null
                            ? _buildDateRow('Issue Date', bond.issueDate!,
                                dateFormat, labelStyle, valueStyle)
                            : _buildMetricRow(
                                'Issue Date', 'N/A', labelStyle, valueStyle),
                        _buildDateRow('Maturity Date', bond.maturityDate!,
                            dateFormat, labelStyle, valueStyle),
                        Divider(
                          height: 24,
                          thickness: 0.5,
                          color: Colors.grey[300],
                        ),
                        Text('Additional Information',
                            style: cardSectionTitleStyle),
                        const SizedBox(height: 10),
                        _buildCompactInfoRow(
                            'ISIN', bond.isin ?? 'N/A', labelStyle, valueStyle),
                        _buildCompactInfoRow(
                            'Market',
                            bond.market.toString().split('.').last,
                            labelStyle,
                            valueStyle),
                        _buildCompactInfoRow(
                            'Category',
                            bond.category.toString().split('.').last,
                            labelStyle,
                            valueStyle),
                        _buildCompactInfoRow(
                            'Type',
                            bond.type.toString().split('.').last,
                            labelStyle,
                            valueStyle),
                        _buildCompactInfoRow(
                            'Tax Status',
                            bond.taxStatus.toString().split('.').last,
                            labelStyle,
                            valueStyle),
                        _buildCompactInfoRow(
                            'Issued Amount',
                            numberFormat.format(bond.issuedAmount),
                            labelStyle,
                            valueStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ElevatedButton(
                onPressed:
                    isProfileComplete ? () => _onBuyPressed(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProfileComplete
                      ? accentButtonColor
                      : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isProfileComplete ? 2 : 0,
                ),
                child: Text(
                  'Place Bid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isProfileComplete ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenHeader(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            bond.logoUrl ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.business_outlined,
                  color: Colors.blueGrey[300], size: 30),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bond.isin ?? "N/A",
                style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.blueGrey[800]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (bond.isin != null)
                Text(
                  "Issuer Identification Number",
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: Colors.blueGrey[400]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
      String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(
      String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, DateFormat dateFormat,
      TextStyle labelStyle, TextStyle valueStyle) {
    return _buildMetricRow(
        label, dateFormat.format(date), labelStyle, valueStyle);
  }
}
