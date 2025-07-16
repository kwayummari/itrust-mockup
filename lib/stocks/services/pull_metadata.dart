import 'package:iwealth/screens/user/idOpts.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:flutter/material.dart';

class PullMetadata {
  Future<bool> nidabtnPressed(provider, context) async {
    try {
      var bankStatus = await Waiter().getSectors("bank", provider);
      if (bankStatus != "1") {
        print("[STEP 1 BANKS]: FAILED TO PULL BANKS DATA :(");
        return false;
      }
      print("[STEP 1 BANKS]: BANKS NAME PULLED SUCCESSFULLY !!");

      var sectorStatus = await Waiter().getSectors("sector", provider);
      if (sectorStatus != "1") {
        print("[STEP 2 SECTOR]: FAILED TO PULL SECTOR DATA :(");
        return false;
      }
      print("[STEP 2a SECTOR]: SECTOR PULLED SUCCESSFULLY !!");

      var metadataStatus = await Waiter().getRegionBR(mp: provider);
      if (metadataStatus != "success") {
        print("[STEP 2b METADATA]: FAILED TO PULL METADATA :(");
        return false;
      }
      print("[STEP 2b METADATA]: METADATA PULLED SUCCESSFULLY !!");

      var kinStatus = await Waiter().getSourceOfIncome("kin", provider);
      if (kinStatus != "1") {
        print("[STEP 3 NEXTKINS]: FAILED TO PULL NEXT OF KINS INFOS :(");
        return false;
      }
      print("[STEP 3 NEXTKINS]: NEXT OF KINS INFOS PULLED SUCCESSFULLY !!");

      var incomeStatus = await Waiter().getSourceOfIncome("source", provider);
      if (incomeStatus != "1") {
        print("[STEP 4 INCOME]: FAILED TO PULL SOURCE OF INCOME :(");
        return false;
      }
      print("[STEP 4 INCOME]: SOURCE OF INCOME PULLED SUCCESSFULLY !!");

      var freqStatus =
          await Waiter().getSourceOfIncome("income_frequency", provider);
      if (freqStatus != "1") {
        print("[STEP 5 INCOME-FREQUENCY]: FAILED TO PULL INCOME FREQUENCY :(");
        return false;
      }
      print(
          "[STEP 5 INCOME-FREQUENCY]: INCOME FREQUENCIES PULLED SUCCESSFULLY !!");

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const IDOpts()));
      return true; // Success
    } catch (e) {
      print("Error in nidabtnPressed: $e");
      return false;
    }
  }
}
