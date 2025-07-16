import 'package:flutter/material.dart';
import 'package:iwealth/screens/fund/payment_popup.dart';

class FundPaymentOptionsScreen extends StatelessWidget {
  final String amount;
  const FundPaymentOptionsScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Funds'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(
              right: 16,
            ),
            child: Icon(
              Icons.help_outline,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const Text(
                    'Add Funds to Wallet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TZS $amount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MOBILE WALLET',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(context, 'tigo', 'Tigo', true),
                    _buildPaymentOption(context, 'azampesa', 'AzamPesa', false),
                    const SizedBox(height: 24),
                    const Text(
                      'BANK TRANSFER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      context,
                      'banking_apps',
                      'Banking Apps',
                      false,
                      icon: Icons.account_balance,
                    ),
                    _buildPaymentOption(
                      context,
                      'in_person_deposits',
                      'In-Person Deposits',
                      false,
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, String logo, String label, isEnabled,
      {IconData? icon}) {
    final double appWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: Colors.white,
        elevation: 0,
        child: ListTile(
          enabled: isEnabled,
          leading: icon == null
              ? Image.asset(
                  'assets/images/$logo.png',
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      label[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                )
              : Icon(
                  icon,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
          title: Text(label),
          trailing: const Icon(
            color: Colors.blue,
            Icons.arrow_forward_ios,
            size: 16,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Payment Via $label",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    width: appWidth * 0.7,
                    child: PaymentPopupScreen(initialAmount: amount),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
