import 'dart:convert';
import 'dart:io';
import 'package:iwealth/models/IPO/ipo_model.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/http_client.dart';
import 'package:iwealth/services/error_handler.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:flutter/material.dart';

class IpoWaiter {
  final _userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));

  Future<Map<String, dynamic>> _getData({required String ep}) async {
    return await HttpClientService.get(
      endpoint: ep,
      requiresAuth: true,
      additionalHeaders: {'id': _userId},
    );
  }

  Future<Map<String, dynamic>> _postData(
      {required String ep, required reqBody}) async {
    return await HttpClientService.post(
      endpoint: ep,
      body: reqBody,
      requiresAuth: true,
      additionalHeaders: {'id': _userId},
    );
  }

  Future<String> getIPOFund(
      {required BuildContext context, required MarketProvider mp}) async {
    try {
      final response = await _getData(ep: APIEndpoints.brokerageList);

      if (response['success']) {
        final decoded = response['data'];
        List<FUNDIPO> ipoFunds = [];

        for (var each in decoded["data"]) {
          FUNDIPO fundipo = FUNDIPO(
            accountNumber: each["fund_account_number"],
            description: each["description"] ?? "",
            category: each["category"] ?? "",
            closeDate: each["closing_date"] ?? "",
            coolOffEnd: each["cool_off_end_date"] ?? "",
            coolOffStart: each["cool_off_start_date"] ?? "",
            entryFee: each["entry_fee"] ?? "",
            exitFee: each["exit_fee"] ?? "",
            fundId: each["fund_id"] ?? "",
            fundCode: each["fund_code"] ?? "",
            id: each["id"] ?? "",
            minInitContribution: each["initial_min_contribution"] ?? "",
            name: each["name"] ?? "",
            nav: each["initial_nav_amount"] ?? "",
            openDate: each["opening_date"] ?? "",
            redemptionDate: each["redemption_date"] ?? "",
            subsequentAmount: each["subsequent_amount"] ?? "",
          );
          ipoFunds.add(fundipo);
        }

        mp.fundIPO = ipoFunds;
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to retrieve IPO fund list. Please try again later.");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while retrieving IPO fund list. Please try again later.",
          error: e);
      return "fail";
    }
  }

  Future<List<String>> contributeToIPO({
    required String fundCode,
    required String ipoId,
    required String amount,
    required String description,
    required BuildContext context,
  }) async {
    try {
      var reqBody = {
        "fund_code": fundCode,
        "ipo_id": ipoId,
        "amount": amount,
      };

      final response =
          await _postData(ep: APIEndpoints.brokeragePurchase, reqBody: reqBody);

      if (response['success']) {
        final decoded = response['data'];
        ErrorHandler.showSuccess(context, "IPO contribution successful");
        return ["success", decoded["purchase_id"]];
      } else {
        ErrorHandler.showError(
            context, "Failed to contribute to IPO. Please try again later.");
        return ["fail"];
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while contributing to IPO. Please try again later.",
          error: e);
      return ["fail"];
    }
  }

  Future<String> getSubscriptionList(
      {required BuildContext context, required MarketProvider mp}) async {
    try {
      final response = await _getData(ep: APIEndpoints.brokerageFundBuyOrder);

      if (response['success']) {
        final decoded = response['data'];
        List<IPOSubscription> iposbs = [];

        for (var each in decoded["data"]) {
          IPOSubscription ipoSubscription = IPOSubscription(
            clientRef: each["client_code"],
            accountNumber: each["fund_account_number"],
            paymentProof: each["attachment"] ?? "pending",
            date: each["date"],
            fundCode: each["fund_code"],
            id: each["id"],
            fundId: each["fund_id"],
            name: each["name"] ?? "",
            status: each["status"] ?? "",
            amount: each["amount"] ?? "",
            amountPaid: each["amount_paid"] ?? "",
            transactionType: each["tran_type"] ?? "",
            reference: each["reference"] ?? "",
          );
          iposbs.add(ipoSubscription);
        }

        mp.ipoSubsc = iposbs;
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to retrieve subscription list. Please try again later.");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while retrieving subscription list. Please try again later.",
          error: e);
      return "fail";
    }
  }

  Future<String> uploadProofOfPayment({
    required File receipt,
    required String amount,
    required String description,
    required String purchaseId,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.postMultipart(
        endpoint: APIEndpoints.uploadProofEp,
        fields: {
          "amount_paid": amount,
          "description": description,
          "purchase_id": purchaseId,
        },
        files: {
          "attachment": receipt,
        },
        requiresAuth: true,
        additionalHeaders: {
          'id': _userId,
          'purchasesid': _userId,
        },
      );

      if (response['success']) {
        ErrorHandler.showSuccess(
            context, "Proof of payment uploaded successfully");
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to upload proof of payment. Please try again later.");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while uploading proof of payment. Please try again later.",
          error: e);
      return "fail";
    }
  }

  Future<void> userSubscribed({required MarketProvider mp}) async {
    try {
      final response = await _getData(ep: APIEndpoints.brokerageFundBuyOrder);

      if (response['success']) {
        final decoded = response['data'];
        List<UserSubscriber> usrsubs = [];
        double totalContr = 0;

        for (var each in decoded["data"]) {
          UserSubscriber subscriber = UserSubscriber(
            amount: "${each["invested_amount"]}",
            fundName: each["name"],
            clientRef: each["client_code"],
            fundCode: each["fund_code"],
            inMinContr: each["initial_min_contribution"],
            subs: each["subsequent_amount"],
          );
          usrsubs.add(subscriber);
          totalContr += double.parse(each["invested_amount"]);
        }

        mp.usrSub = usrsubs;
        mp.totalContributions = totalContr;
      }
    } catch (e) {
      // Silent failure for this method as it seems to be called without context
      // Consider adding proper error handling if context is available
    }
  }
}
