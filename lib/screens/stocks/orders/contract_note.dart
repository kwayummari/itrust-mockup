import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/orders/contractview.dart';
import 'package:iwealth/stocks/widgets/feecard.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContractNote extends StatefulWidget {
  const ContractNote({super.key});

  @override
  State<ContractNote> createState() => _ContractNoteState();
}

class _ContractNoteState extends State<ContractNote> {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  bool isRotate = true;
  contract(
      {ticker,
      reference,
      consideration,
      brokerage,
      vat,
      dse,
      cmsa,
      fidelity,
      totalFees,
      payout,
      cds,
      orderID,
      h,
      w}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColor().mainColor,
            content: SizedBox(
              height: h * 0.8,
              width: w,
              child: ListView(
                children: [
                  SvgPicture.asset(
                    "assets/images/icon-top-itr-down.svg",
                    width: 80,
                  ),
                  largeFeeCard(
                      infoName: "Gross Consideration",
                      infoData: currencyFormat(double.parse(consideration)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "Brokerage Commision",
                      infoData: currencyFormat(double.parse(brokerage)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "VAT",
                      infoData: currencyFormat(double.parse(vat)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "DSE Fee",
                      infoData: currencyFormat(double.parse(dse)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "CMSA Fee",
                      infoData: currencyFormat(double.parse(cmsa)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "Fidelity Fee",
                      infoData: currencyFormat(double.parse(fidelity)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "CDS Fee",
                      infoData: currencyFormat(double.parse(cds)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  largeFeeCard(
                      infoName: "Total Charges",
                      infoData: currencyFormat(double.parse(totalFees)),
                      subInfo: "",
                      infoFontSize: 14.0),
                  Divider(
                    color: AppColor().inputFieldColor,
                  ),
                  feeCard(
                      infoName: "Net Amount Payable(TZS)",
                      infoData: currencyFormat(double.parse(payout)),
                      infoFontSize: 15.0),
                  isRotate
                      ? Center(
                          child: Row(
                            children: [
                              CircularProgressIndicator(
                                color: AppColor().blueBTN,
                              ),
                              Text(
                                "Downloading...",
                                style: TextStyle(color: AppColor().blueBTN),
                              )
                            ],
                          ),
                        )
                      : const Text("")
                  //  ============== NEXT PATCH

                  // TextButton.icon(onPressed: (){}, label: Text("Download Contract Note", style: TextStyle(color: AppColor().blueBTN, fontSize: 16.0),), icon: Icon(Icons.download_sharp, color: AppColor().blueBTN,),)
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                  onPressed: () async {},
                  icon: Icon(
                    Icons.download,
                    color: AppColor().blueBTN,
                  ),
                  label: Text(
                    "Download Contract Note",
                    style: TextStyle(color: AppColor().blueBTN),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Thanks",
                    style: TextStyle(color: AppColor().blueBTN),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().bgLight,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
        title: Text(
          "Contract Note",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: mp.contractNotes.isNotEmpty
          ? ListView.builder(
              itemCount: mp.contractNotes.length,
              itemBuilder: (context, i) {
                return Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppColor().grayText))),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Contractview(
                                  consideration:
                                      mp.contractNotes[i].consideration,
                                  brokerage: mp.contractNotes[i].brokerage,
                                  vat: mp.contractNotes[i].vat,
                                  dse: mp.contractNotes[i].dse,
                                  cmsa: mp.contractNotes[i].cmsa,
                                  fidelity: mp.contractNotes[i].fidelity,
                                  totalFees: mp.contractNotes[i].totalFees,
                                  payout: mp.contractNotes[i].payout,
                                  cds: mp.contractNotes[i].cds,
                                  orderID: "${mp.contractNotes[i].contractId}",
                                  ticker: "${mp.contractNotes[i].ticker}",
                                  reference:
                                      "${mp.contractNotes[i].reference}")));
                    },
                    title: Text(
                      "${mp.contractNotes[i].ticker}-${mp.contractNotes[i].reference}",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    subtitle: Text(
                      "${mp.contractNotes[i].executed} QNTY  | ${mp.contractNotes[i].date}",
                      style: TextStyle(color: AppColor().blueBTN),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor().textColor,
                    ),
                  ),
                );
              })
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_outlined,
                  color: AppColor().textColor,
                  size: 90.0,
                ),
                Center(
                    child: Text(
                  "No Contract Note For this Order",
                  style: TextStyle(color: AppColor().textColor),
                )),
              ],
            ),
    );
  }
}
