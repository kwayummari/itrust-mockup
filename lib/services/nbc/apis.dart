import 'dart:convert';

import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/models/payment/payment.dart';
import 'package:iwealth/models/sector.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/providers/payment.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:http/http.dart' as http;
import 'package:iwealth/widgets/app_snackbar.dart';

class NBC {
  var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
  _postReq({required endpoint, required reqBody}) async {
    var url = Uri.https(API().brokerLinkMainDoor, endpoint);
    var res = await http.post(url, body: reqBody, headers: {
      'Authorization': 'Bearer ${SessionPref.getToken()![0]}',
      "id": userId,
      "Content-Type": "application/json"
    });

    return res;
  }

  // Send OTP
  sendOTP({context}) async {
    var body = jsonEncode({
      "idNumber": SessionPref.getNIDA()?[7],
      "phoneNumber": SessionPref.getUserProfile()?[4],
      "emailAddress": SessionPref.getUserProfile()?[3]
    });

    try {
      var res = await _postReq(endpoint: API().sendOTP, reqBody: body);

      jsonDecode(res.body);
      if (res.statusCode == 200) {
        return "success";
      } else {
        return "fail";
      }
    } catch (e) {
      AppSnackbar(
        isError: true,
        response: "Something went wrong, Please try again",
      ).show(context);
    }
  }

  verifyOTP({required otp, required MetadataProvider mp, context}) async {
    var body = jsonEncode({
      "idNumber": SessionPref.getNIDA()?[7],
      "phoneNumber": SessionPref.getUserProfile()?[4],
      "otp": otp
    });
    try {
      String status;
      var res = await _postReq(endpoint: API().verifyOTP, reqBody: body);
      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        if (decoded["verified"] == true) {
          mp.copOTP = Metadata(id: decoded["copreference"], name: otp);
          status = "success";
        } else {
          status = "fail";
        }
      } else {
        status = "fail";
      }
      return status;
    } catch (e) {
      AppSnackbar(
        isError: true,
        response: "Something went wrong, Please try again",
      ).show(context);
    }
  }

  initiateTransfer(
      {required String amount,
      required String to,
      required String narration,
      required String from,
      required PaymentProvider pp}) async {
    var url = Uri.https(API().brokerLinkMainDoor, API().sendQuotationEndpoint);
    var body = jsonEncode({
      "amount": amount,
      "currency": "TZS",
      "narration": narration,
      "receiverAccount": to,
      "senderAccount": from
    });
    try {
      var res = await http.post(url, body: body, headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${SessionPref.getToken()![0]}',
        "id": userId,
      });

      var decoded = jsonDecode(res.body);

      var status = "";

      if (res.statusCode == 200) {
        // code == 602 Validation Failed
        // code == 600 Successfully
        if (decoded["data"]["statusCode"] == "600") {
          Check check = Check(
              amount: decoded["data"]["amount"],
              channelRef: decoded["data"]["channelRef"],
              narration: narration,
              receiverAccount: decoded["data"]["body"]["account"],
              receiverName: decoded["data"]["body"]["fullName"],
              senderAccount: decoded["data"]["payer"]
                  ["account"], // "011102000913
              senderName: decoded["data"]["payer"]["fullName"]);

          pp.cheque = check;
          status = "success";
        } else if (decoded["data"]["statusCode"] == "602") {
          status = "validFail";
        } else {
          status = "fail";
        }
      } else {
        status = "codeError";
      }

      return status;
    } catch (e) {}
  }

  verifyInformation({
    required String channelRef,
  }) async {
    var url = Uri.https(API().brokerLinkMainDoor, API().verifyInformation);
    var body = jsonEncode({"channelRef": channelRef});
    try {
      var res = await http.post(url, body: body, headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${SessionPref.getToken()![0]}',
        "id": userId,
      });

      jsonDecode(res.body);

      if (res.statusCode == 200) {
        return "success";
      } else {
        return "fail";
      }
    } catch (e) {}
  }

  transferMoney(
      {required String channelRef,
      required String vcode,
      required MarketProvider mp,
      context}) async {
    var url = Uri.https(API().brokerLinkMainDoor, API().transfer);
    var body =
        jsonEncode({"channelRef": channelRef, "verificationCode": vcode});
    try {
      var res = await http.post(url, body: body, headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${SessionPref.getToken()![0]}',
        "id": userId,
      });

      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded["data"]["statusCode"] == 600) {
        await Waiter().getUserProfile(SessionPref.getToken()![0]);
        await await StockWaiter().getPortfolio(provider: mp, context: context);
        return "success";
      } else {
        return decoded["status"]["message"];
      }
    } catch (e) {}
  }

  // // metadata
  // Future getMetadata({required MetadataProvider mp, required context}) async {
  //   try {
  //     var res = await _getReq(endpoint: API().metadataNBC, reqBody: null);
  //     var decoded = jsonDecode(res.body);

  //     if (res.statusCode == 200) {
  //       List<Metadata> regions = [];
  //       List<Metadata> district = [];
  //       List<Metadata> ward = [];
  //       List<Metadata> occupation = [];
  //       List<Metadata> source = [];
  //       // List<Metadata>
  //       for (var each in decoded["regions"]) {
  //         Metadata metadata = Metadata(id: each["name"], name: each["name"]);
  //         regions.add(metadata);
  //       }
  //       for (var each in decoded["districts"]) {
  //         Metadata metadata = Metadata(id: each["name"], name: each["name"]);
  //         district.add(metadata);
  //       }
  //       for (var each in decoded["wards"]) {
  //         Metadata metadata = Metadata(id: each["name"], name: each["name"]);
  //         ward.add(metadata);
  //       }
  //       for (var each in decoded["occupations"]) {
  //         Metadata metadata =
  //             Metadata(id: "${each["code"]}", name: each["name"]);
  //         occupation.add(metadata);
  //       }
  //       for (var each in decoded["sourceOfFund"]) {
  //         Metadata metadata = Metadata(id: each["name"], name: each["name"]);
  //         source.add(metadata);
  //       }
  //       mp.districts = district;
  //       mp.regions = regions;
  //       mp.occupations = occupation;
  //       mp.wards = ward;
  //       mp.incomeSource = source;
  //       return "success";
  //     } else {
  //       print("Error on METADATA: $decoded");
  //       return "fail";
  //     }
  //   } catch (e) {
  //     print("EXCEPTION METADATA DUE TO: $e");
  //     Btmsheet().errorSheet(context, "Metadata",
  //         "ooops Something went wrong, Please try again later");
  //   }
  // }
}
