import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpenOrderScreen extends StatefulWidget {
  const OpenOrderScreen({super.key});

  @override
  State<OpenOrderScreen> createState() => _OpenOrderScreenState();
}

class _OpenOrderScreenState extends State<OpenOrderScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var orderStatus = await StockWaiter().getOrders(marketProvider);
      if (orderStatus != "1") {
        setState(() => _error = "Failed to fetch orders");
      }
    } catch (e) {
      setState(() => _error = "Error loading orders: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final marketProvider = Provider.of<MarketProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: Container(
            height: appHeight,
            width: appWidth,
            decoration: BoxDecoration(
                border: Border.all(color: AppColor().inputFieldColor),
                borderRadius: BorderRadius.circular(10.0)),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor().textColor,
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: TextStyle(color: AppColor().textColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : marketProvider.order.isEmpty
                        ? Center(
                            child: Text(
                              "No orders available",
                              style: TextStyle(color: AppColor().textColor),
                            ),
                          )
                        : ListView.builder(
                            itemCount: marketProvider.order.length,
                            itemBuilder: (context, i) {
                              if (marketProvider
                                          .order[i].status ==
                                      "complete" ||
                                  marketProvider.order[i].status ==
                                      "rejected" ||
                                  marketProvider.order[i].status ==
                                      "approved") {
                                return const SizedBox();
                              } else {
                                return orderCard(
                                    context, marketProvider.order[i]);
                              }
                            }),
          ),
        ),
      ),
    );
  }
}
