import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/orders/contract_note.dart';
import 'package:iwealth/screens/stocks/orders/order_details_widgets.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../stocks/models/order.dart';
import '../../../stocks/models/stock.model.dart';

class OrderDetails extends StatefulWidget {
  final Order order;

  const OrderDetails({super.key, required this.order});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final currencyFormat = NumberFormat("#,##0.00", "en_US");
  bool _isLoading = false;
  late Order order;
  late MarketProvider marketProvider;
  late Stock stock;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    marketProvider = Provider.of<MarketProvider>(context);
    stock =
        marketProvider.stock!.firstWhere((sto) => sto.stockID == order.stockID);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        bottom: OrderDetailsWidgets.buildHeader(
          logoUrl: stock.logo ?? '',
          title: order.stockName ?? '',
          isBuyOrder: order.orderType?.toLowerCase() == 'buy',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor().lowerBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: 'Order Price',
                              leftValue: '${order.mode}'.capitalize(),
                              rightLabel: 'Exchange',
                              rightValue: 'DSE'),
                          OrderDetailsWidgets.buildDetailItem(
                            context: context,
                            leftLabel: 'Price',
                            leftValue:
                                'TZS. ${currencyFormat.format(double.tryParse(order.price ?? '0'))}',
                            rightLabel: 'Quantity',
                            rightValue: order.volume ?? '0',
                          ),
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: 'Valid Until',
                              leftValue: DateFormat("dd MMM yyyy").format(
                                  DateTime.parse('${order.validityUntil}')),
                              rightLabel: 'Amount',
                              rightValue:
                                  'TZS. ${currencyFormat.format(double.tryParse(order.payout ?? '0'))}',
                              hideBorder: true),
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: '',
                              leftValue: 'Order Status',
                              rightLabel: '',
                              rightValue:
                                  '${order.getFriendlyStatus()['label']}'
                                      .toUpperCase(),
                              isStatus: true,
                              statusColor: order.getFriendlyStatus()['color'],
                              hideBorder: true),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (_isLoading) return;
                          setState(() => _isLoading = true);
                          try {
                            var statementStatus = await StockWaiter()
                                .getStatement(
                                    order.stockID ?? '', marketProvider);
                            if (statementStatus == "1") {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ContractNote(),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print("[ORDER CONTRACT NOTE]: $e");
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              'View Contract Note',
                              style: TextStyle(
                                color: AppColor().primaryBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isLoading)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColor().primaryBlue),
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 24,
                                color: AppColor().primaryBlue,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (order.status?.toLowerCase() == 'new' &&
                  order.orderType?.toLowerCase() == 'buy')
                largeBTN(
                    double.infinity, 'Complete Payment', AppColor().blueBTN,
                    () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SingleChildScrollView(
                      child: PaymentOptionsPage(
                          paymentType: 'stock',
                          name: order.stockName ?? '',
                          amount: order.payout ?? '0',
                          orderId: order.id ?? '',
                          logoUrl: stock.logo ?? ''),
                    ),
                  );
                })
            ],
          ),
        ),
      ),
    );
  }
}
