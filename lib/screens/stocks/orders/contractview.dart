import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Contractview extends StatefulWidget {
  const Contractview(
      {super.key,
      required this.brokerage,
      required this.cds,
      required this.cmsa,
      required this.consideration,
      required this.dse,
      required this.fidelity,
      required this.orderID,
      required this.payout,
      required this.reference,
      required this.ticker,
      required this.totalFees,
      required this.vat});

  final String ticker,
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
      orderID;
  @override
  State<Contractview> createState() => _ContractviewState();
}

class _ContractviewState extends State<Contractview> {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  bool isRotate = false;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
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
      body: Container(
        padding: const EdgeInsets.all(30.0),
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Gross Consideration",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.consideration)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Brokerage Commission",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.brokerage)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "VAT",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.vat)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DSE Fee",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.dse)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CMSA Fee",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.consideration)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fidelity Fee",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.fidelity)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CDS Fee",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.cds)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Charges",
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  currencyFormat(double.parse(widget.totalFees)),
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.01,
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            ListTile(
              title: Text(
                "Net Amount Payable(TZS)",
                style: TextStyle(color: AppColor().textColor, fontSize: 15.0),
              ),
              trailing: Text(
                currencyFormat(double.parse(widget.payout)),
                style: TextStyle(color: AppColor().textColor, fontSize: 20.0),
              ),
            ),

            Divider(
              color: AppColor().grayText,
            ),
            // SizedBox(
            //   height: appHeight * 0.04,
            // ),

            isRotate
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColor().blueBTN,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Downloading...",
                            style: TextStyle(color: AppColor().blueBTN),
                          ),
                        )
                      ],
                    ),
                  )
                : const Text(""),
            !isRotate
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton.icon(
                        onPressed: () async {
                          setState(() {
                            isRotate = true;
                          });
                          final response = await StockWaiter()
                              .downloadContractNote(
                                  orderID: widget.orderID, context: context);
                          if (response != null) {
                            final filepath = await StockWaiter().savePDF(
                                pdfStream: response,
                                ticker: widget.ticker,
                                reference: widget.reference,
                                context: context);
                            if (filepath != null) {
                              var snackDemo = SnackBar(
                                content: Text(
                                  "Successfully Downloaded, Check Contract Note in Download Folder",
                                  style: TextStyle(color: AppColor().textColor),
                                ),
                                backgroundColor: AppColor().success,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(5.0),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackDemo);
                              setState(() {
                                isRotate = false;
                              });
                              if (kDebugMode) {
                                print("PDF saved into: $filepath");
                              }
                              // Navigator.pop(context);
                            } else {
                              setState(() {
                                isRotate = false;
                              });
                            }
                          }
                        },
                        icon: Icon(
                          Icons.download,
                          color: AppColor().blueBTN,
                        ),
                        label: Text(
                          "Download Contract Note",
                          style: TextStyle(color: AppColor().blueBTN),
                        )),
                  )
                : const Text("")
          ],
        ),
      ),
    );
  }
}
