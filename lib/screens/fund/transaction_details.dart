import 'package:flutter/material.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String name;
  final String amount;
  final String date;
  final bool isReceived;

  const TransactionDetailsScreen({
    super.key,
    required this.name,
    required this.amount,
    required this.date,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name'),
            Text('Amount: ${isReceived ? "+ " : ""}TZS $amount'),
            Text('Date: $date'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
