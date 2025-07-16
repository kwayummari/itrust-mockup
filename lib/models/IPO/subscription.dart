import 'package:flutter/material.dart';

class IPOSubscription {
  String name,
      clientRef,
      accountNumber,
      fundId,
      id,
      fundCode,
      date,
      status,
      reference,
      amount,
      amountPaid,
      paymentProof,
      transactionType;

  IPOSubscription({
    required this.accountNumber,
    required this.clientRef,
    required this.date,
    required this.fundCode,
    required this.id,
    required this.fundId,
    required this.name,
    required this.status,
    required this.amount,
    required this.amountPaid,
    required this.reference,
    required this.paymentProof,
    required this.transactionType,
  });

  factory IPOSubscription.fromJson(Map<String, dynamic> json) {
    return IPOSubscription(
      accountNumber: json['fund_account_number'] ?? '',
      clientRef: json['client_code'] ?? '',
      date: json['date'] ?? '',
      fundCode: json['fund_code'] ?? '',
      id: json['id'] ?? '',
      fundId: json['fund_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'] ?? '',
      amountPaid: json['amount_paid'] ?? '',
      reference: json['reference'] ?? '',
      paymentProof: json['attachment'] ?? 'pending',
      transactionType: json['tran_type'] ?? 'buy',
    );
  }

  // Factory to create an instance from the fundBuy API response JSON
  factory IPOSubscription.fromFundBuyJson(Map<String, dynamic> json) {
    return IPOSubscription(
      name: json['Fund'] ?? '', // Fund name from API response
      clientRef: json['ClientIdentifier'] ?? '',
      accountNumber: '', // Not provided, so set as empty.
      fundId: json['FundShareClassCode']?.toString() ?? '',
      id: json['RequestReference']?.toString() ?? '',
      fundCode: json['FundShareClassCode']?.toString() ?? '',
      date: json['TransactionDate'] ?? '',
      status: json['TransactionStatus']?.toString() ?? '',
      reference: json['TransactionReference']?.toString() ?? '',
      amount: json['TransactionAmount']?.toString() ?? '',
      amountPaid: json['TransactionAmount']?.toString() ?? '',
      paymentProof: '', // No proof provided.
      transactionType: json['TransactionType']?.toLowerCase() == "contribution"
          ? "buy"
          : (json['TransactionType'] ?? '').toLowerCase(),
    );
  }

  // Updated factory for brokerage API response JSON
  factory IPOSubscription.fromBrokerageJson(Map<String, dynamic> json) {
    return IPOSubscription(
      name: json['name'] ?? '',
      clientRef: json['client_code'] ?? '',
      accountNumber: json['fund_account_number'] ?? '',
      fundId: json['fund_id'] ?? '',
      id: json['id'] ?? '',
      fundCode: json['fund_code'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
      amount: json['amount']?.toString() ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '',
      paymentProof: json['paymentProof'] ?? '',
      transactionType: json["tran_type"],
    );
  }

  // Updated factory for redemption API response JSON
  factory IPOSubscription.fromRedemptionJson(Map<String, dynamic> json) {
    return IPOSubscription(
      name: json['Fund'] ?? '', // Fund name from API response
      clientRef: json['ClientIdentifier'] ?? '',
      accountNumber: '', // Not provided, so set as empty.
      fundId: json['FundShareClassCode']?.toString() ?? '',
      id: json['RequestReference']?.toString() ?? '',
      fundCode: json['FundShareClassCode']?.toString() ?? '',
      date: json['TransactionDate'] ?? '',
      status: json['TransactionStatus']?.toString() ?? '',
      reference: json['TransactionReference']?.toString() ?? '',
      amount: json['TransactionAmount']?.toString() ?? '',
      amountPaid: json['TransactionAmount']?.toString() ?? '',
      paymentProof: '', // No proof provided.
      transactionType: json['TransactionType']?.toLowerCase() == "redemption"
          ? "sale"
          : (json['TransactionType'] ?? '').toLowerCase(),
    );
  }

  // Updated method: returns friendly status based on order type.
  Map<String, dynamic> getFriendlyStatus() {
    if (transactionType.toLowerCase() == 'sale') {
      // Redemption orders mapping
      switch (status) {
        case '1' || 'pending':
          return {'label': 'PENDING', 'color': Colors.blue};
        case '2' || 'submitted':
          return {'label': 'PROCESSING', 'color': Colors.blue};
        case '3':
          return {'label': 'PROCESSED', 'color': Colors.green};
        case '4':
          return {'label': 'PROCESSING FAILED', 'color': Colors.red};
        case '5':
          return {'label': 'PENDING APPROVAL', 'color': Colors.blue};
        case '6':
          return {'label': 'PENDING WITHDRAWAL', 'color': Colors.blue};
        case '7':
          return {'label': 'PENDING F A VERIFICATION', 'color': Colors.blue};
        case '8':
          return {
            'label': 'PENDING APPROVAL BY OTHER MEMBERS',
            'color': Colors.blue
          };
        case '9':
          return {'label': 'PENDING APPROVAL FROM YOU', 'color': Colors.blue};
        case '10':
          return {'label': 'CANCELED', 'color': Colors.red};
        case '11':
          return {'label': 'DEFFERED', 'color': Colors.blue};
        case '12' || 'rejected':
          return {'label': 'REJECTED', 'color': Colors.grey};
        case '13':
          return {'label': 'REVERSED', 'color': Colors.blue};
        default:
          return {'label': status, 'color': Colors.black};
      }
    } else {
      // Original orders mapping
      switch (status) {
        case '1':
          return {'label': 'DEFERRED', 'color': Colors.grey};
        case '2' ||'submitted':
          return {'label': 'PROCESSING', 'color': Colors.blue};
        case '3':
          return {'label': 'PROCESSED', 'color': Colors.green};
        case '4':
          return {'label': 'PROCESSING FAILED', 'color': Colors.red};
        case '5' || 'reviewed':
          return {'label': 'PENDING APPROVAL', 'color': Colors.blue};
        case '6' || 'approved':
          return {'label': 'APPROVED', 'color': Colors.blue};
        case '7':
          return {'label': 'PENDING PAYMENT', 'color': Colors.blue};
        case '8':
          return {'label': 'PROCESSING PAYMENT', 'color': Colors.blue};
        case '9':
          return {'label': 'PAYMENT FAILED', 'color': Colors.blue};
        case '10':
          return {
            'label': 'PENDING APPROVAL BY OTHER MEMBERS',
            'color': 'lightyellow'
          };
        case '11':
          return {'label': 'PENDING APPROVAL FROM YOU', 'color': Colors.blue};
        case '12':
          return {'label': 'CANCELED', 'color': Colors.grey};
        case '13' || 'pending':
          return {'label': 'PENDING', 'color': Colors.blue};
        case 'rejected':
          return {'label': 'REJECTED', 'color': Colors.red};
        default:
          return {'label': status, 'color': Colors.black};
      }
    }
  }
}

class UserSubscriber {
  String fundCode, subs, inMinContr, clientRef, fundName, amount;
  UserSubscriber(
      {required this.fundCode,
      required this.inMinContr,
      required this.subs,
      required this.clientRef,
      required this.amount,
      required this.fundName});
}

class IPOCLIENTINFO {
  // String clientRef,accountNumber
}
