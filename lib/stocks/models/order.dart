import 'package:flutter/material.dart';

class Order {
  bool? hasCustodian;
  String? id,
      orderType,
      stockID,
      // securityID,
      mode,
      vat,
      cmsa,
      dse,
      fidelity,
      cds,
      totalFees,
      brokerage,
      payout,
      amountBeforeCharge,
      date,
      status,
      stockName,
      validityUntil,
      price,
      volume,
      paymentOption,
      mobile,
      executed;

  Order(
      {this.id,
      required this.hasCustodian,
      required this.mode,
      required this.orderType,
      required this.price,
      required this.stockID,
      // required this.securityID,
      required this.volume,
      this.paymentOption,
      this.mobile,
      this.amountBeforeCharge,
      this.brokerage,
      this.cds,
      this.cmsa,
      this.date,
      this.dse,
      this.executed,
      this.fidelity,
      this.payout,
      this.status,
      this.stockName,
      this.totalFees,
      this.validityUntil,
      this.vat});

  // Factory constructor to create an Order from JSON (or dynamic map)
  factory Order.fromMap(
    Map<String, dynamic> map, {
    String mSecurityId = '',
  }) {
    return Order(
        id: map['id'] ?? '',
        hasCustodian: map['hasCustodian'] ?? false,
        mode: map['mode'] ?? '',
        orderType: map['orderType'] ?? '',
        price: map['price']?.toString() ?? '0',
        stockID: map['stockID'] ?? '',
        // securityID: mSecurityId,
        volume: map['volume']?.toString() ?? '0',
        paymentOption: map['paymentOption'] ?? '',
        mobile: map['mobile'] ?? '',
        amountBeforeCharge: map['amountBeforeCharge']?.toString() ?? '0',
        brokerage: map['brokerage']?.toString() ?? '0',
        cds: map['cds']?.toString() ?? '0',
        cmsa: map['cmsa']?.toString() ?? '0',
        date: map['date'] ?? '',
        dse: map['dse']?.toString() ?? '0',
        executed: map['executed']?.toString() ?? '0',
        fidelity: map['fidelity']?.toString() ?? '0',
        payout: map['payout']?.toString() ?? '0',
        status: map['status'] ?? '',
        stockName: map['stockName'] ?? '',
        totalFees: map['totalFees']?.toString() ?? '0',
        validityUntil: map['validityUntil'] ?? '',
        vat: map['vat']?.toString() ?? '');
  }

  // Helper to get a user-friendly status with color and icon
  Map<String, dynamic> getFriendlyStatus() {
    if (orderType != 'buy' && status == 'new') {
      return {
        'label': 'Processing',
        'color': Colors.blue,
        'icon': Icons.hourglass_top
      };
    }
    switch (status?.toLowerCase()) {
      case 'new':
        return {
          'label': 'Awaiting Payment',
          'color': Colors.blue,
          'icon': Icons.hourglass_top
        };
      case 'pending':
        return {
          'label': 'Submitted',
          'color': Colors.blue,
          'icon': Icons.pending
        };
      case 'complete':
        return {
          'label': 'completed',
          'color': Colors.green,
          'icon': Icons.check_circle
        };
      case 'cancelled':
        return {
          'label': 'Cancelled',
          'color': Colors.red,
          'icon': Icons.cancel
        };
      default:
        return {'label': status, 'color': Colors.blue, 'icon': Icons.info};
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'stockID': stockID,
      // 'securityID': securityID,
      'stockName': stockName,
      'orderType': orderType,
      'volume': volume,
      'price': price,
      'date': date,
      'status': status,
      'validityUntil': validityUntil,
      'mode': mode,
    };
  }

  Order toFeeOrder() {
    return Order(
      id: id,
      hasCustodian: hasCustodian,
      mode: mode,
      orderType: orderType,
      price: price,
      stockID: stockID,
      // securityID: securityID,
      volume: volume,
      paymentOption: paymentOption,
      mobile: mobile,
      amountBeforeCharge: amountBeforeCharge,
      brokerage: brokerage,
      cds: cds,
      cmsa: cmsa,
      date: date,
      dse: dse,
      executed: executed,
      fidelity: fidelity,
      payout: payout,
      status: status,
      stockName: stockName,
      totalFees: totalFees,
      validityUntil: validityUntil,
      vat: vat,
    );
  }
}
