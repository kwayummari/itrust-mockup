import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/orders/order_details_widgets.dart';
import 'package:iwealth/stocks/screen/upload_proof_payment.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';

class PaymentOptionsPage extends StatefulWidget {
  final String paymentType;
  final String name;
  final String amount;
  final String orderId;
  final String logoUrl;

  const PaymentOptionsPage(
      {super.key,
      required this.logoUrl,
      required this.paymentType,
      required this.name,
      required this.amount,
      required this.orderId});

  @override
  State<PaymentOptionsPage> createState() => _OrderPaymentOptionsPageState();
}

class _OrderPaymentOptionsPageState extends State<PaymentOptionsPage> {
  Widget _buildPaymentSection(MarketProvider mp) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PayBy(
                paymentType: widget.paymentType,
                name: widget.name,
                amount: widget.amount,
                orderId: widget.orderId,
                mp: mp,
                logoUrl: widget.logoUrl,
              ),
            );
          },
          child: _buildPaymentOptionItem("USSD Push", Icons.phone_android,
              subtitle: 'Mobile Money'),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => UploadProofPayment(
                paymentType: widget.paymentType,
                name: widget.name,
                amount: widget.amount,
                orderId: widget.orderId,
                mp: mp,
                logoUrl: widget.logoUrl,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: _buildPaymentOptionItem(
            "Upload Payment Proof",
            Icons.upload_file,
            subtitle: 'Bank Payment',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionItem(String title, IconData icon,
      {bool hasFile = false, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasFile
              ? AppColor().success.withAlpha(100)
              : AppColor().blueBTN.withAlpha(100),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: hasFile ? AppColor().success : AppColor().blueBTN,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColor().textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColor().grayText,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                hasFile ? Icons.edit : Icons.arrow_forward_ios,
                color: hasFile ? AppColor().success : AppColor().blueBTN,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor().mainColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            OrderDetailsWidgets.buildHeader(
                logoUrl: widget.logoUrl,
                title: widget.name,
                isBuyOrder: true,
                margin: const EdgeInsets.all(0),
                bgColor: Colors.transparent),
            const SizedBox(height: 16),
            _buildPaymentSection(mp),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => (),
              icon: const Icon(
                Icons.help_outline,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColor().blueBTN,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              label: const Text("Need help with payment?",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            largeBTN(double.infinity, 'Cancel', AppColor().orangeApp, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }
}
