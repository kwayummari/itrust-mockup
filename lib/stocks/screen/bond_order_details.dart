import 'package:flutter/material.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';

import '../../constants/app_color.dart';
import '../../providers/market.dart';
import '../../screens/stocks/orders/order_details_widgets.dart';

class BondOrderDetailsPage extends StatelessWidget {
  final BondOrder order;
  BondOrderDetailsPage({super.key, required this.order});

  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);

    final bond = mp.bonds.firstWhere(
      (b) => b.securityName?.toLowerCase() == order.security.toLowerCase(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        bottom: OrderDetailsWidgets.buildHeader(
          logoUrl: '${bond.logoUrl}',
          title: order.security.toUpperCase(),
          subtitle: '${bond.coupon}%, ${bond.tenure}-Year Bond',
          isBuyOrder: order.type.toLowerCase() == 'buy',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor().lowerBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        OrderDetailsWidgets.buildDetailItem(
                            context: context,
                            leftLabel: 'Payout',
                            leftValue: order.payout,
                            rightLabel: 'Face Value',
                            rightValue:
                                'TZS ${currencyFormat.format(double.tryParse(order.faceValue) ?? 0)}'),
                        OrderDetailsWidgets.buildDetailItem(
                          context: context,
                          leftLabel: 'Trade Date',
                          leftValue: DateFormat("dd MMM yyyy")
                              .format(DateTime.parse('${order.date}')),
                          rightLabel: 'Settlement Date',
                          rightValue: DateFormat("dd MMM yyyy")
                              .format(DateTime.parse('${order.date}')),
                        ),
                        OrderDetailsWidgets.buildDetailItem(
                          context: context,
                          leftLabel: 'Price',
                          leftValue:
                              'TZS ${currencyFormat.format(double.tryParse(order.price) ?? 0)}',
                          rightLabel: 'Market Type',
                          rightValue: order.marketType.capitalize(),
                        ),
                        OrderDetailsWidgets.buildDetailItem(
                          context: context, leftLabel: 'Order Type',
                          leftValue: order.type.capitalize(),
                          rightLabel: 'Amount',
                          rightValue:
                              'TZS ${currencyFormat.format(double.tryParse(order.amount) ?? 0)}',
                          // hideBorder: true
                        ),
                        OrderDetailsWidgets.buildDetailItem(
                            context: context,
                            leftLabel: '',
                            leftValue: 'Order Status',
                            rightLabel: '',
                            rightValue: '${order.getFriendlyStatus()['label']}'
                                .toUpperCase(),
                            isStatus: true,
                            statusColor: order.getFriendlyStatus()['color'],
                            hideBorder: true),
                      ],
                    ),
                  ),

                  // if (order.traded != null)
                  //   ListTile(
                  //     title: const Text('Traded'),
                  //     subtitle: Text(order.traded.toString()),
                  //   ),
                  // if (order.balance != null)
                  //   ListTile(
                  //     title: const Text('Balance'),
                  //     subtitle: Text(order.balance.toString()),
                  //   ),
                ],
              ),
            ),
            const Spacer(),
            if (order.status.toLowerCase() == 'new' &&
                order.type.toLowerCase() == 'buy')
              largeBTN(double.infinity, 'Complete Payment', AppColor().blueBTN,
                  () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SingleChildScrollView(
                    child: PaymentOptionsPage(
                        paymentType: 'bond',
                        name: order.security.toUpperCase(),
                        amount: order.payout ?? '0',
                        orderId: order.id,
                        logoUrl: bond.logoUrl ?? ''),
                  ),
                );
              })
          ],
        ),
      ),
    );
  }
}
