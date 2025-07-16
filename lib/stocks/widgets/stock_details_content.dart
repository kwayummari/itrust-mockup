import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:intl/intl.dart';

class StockDetailsContent extends StatelessWidget {
  final String? highPrice;
  final String? lowPrice;
  final String? volume;
  final String? mcap;
  final String? price;
  final String? change;

  const StockDetailsContent({
    super.key,
    this.highPrice,
    this.lowPrice,
    this.volume,
    this.mcap,
    this.price,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    final currFormat = NumberFormat("#,##0.00", "en_US");
    final bool isPositiveChange =
        double.tryParse(change ?? '0')?.isNegative == false;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  "High",
                  highPrice ?? "0",
                  currFormat,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInfoCard(
                  "Low",
                  lowPrice ?? "0",
                  currFormat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  "Volume",
                  volume ?? "0",
                  currFormat,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInfoCard(
                  "Market Cap",
                  mcap ?? "0",
                  currFormat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Change",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isPositiveChange
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: isPositiveChange ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${isPositiveChange ? '+' : ''}$change%",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPositiveChange ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat("#,##0", "en_US").format(double.tryParse(value) ?? 0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor().textColor,
            ),
          ),
        ],
      ),
    );
  }
}
