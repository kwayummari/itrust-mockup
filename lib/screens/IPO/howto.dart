import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/pay_via_wallet.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/providers/market.dart';
import 'package:flutter/material.dart';

howToPayDialog(
    {required context,
    required String accountNumber,
    required String clientReference,
    required String fundName,
    required String fundCode,
    required String amount,
    required MarketProvider mp,
    required String purchaseId,
    required String fundId,
    required appHeight,
    required appWidth}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: SizedBox(
              width: appWidth * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: appHeight * 0.08,
                    width: appWidth,
                    decoration: BoxDecoration(
                      color: AppColor().orangeApp,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        payViaWallet(
                            mp: mp,
                            amount: amount,
                            fundCode: fundCode,
                            fundName: fundName,
                            fundId: fundId,
                            context: context);
                      },
                      icon: Icon(Icons.wallet,
                          color: AppColor().constant, size: 24),
                      label: Text(
                        "Pay By Wallet",
                        style: TextStyle(
                          color: AppColor().constant,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PayBy(
                    paymentType: 'fund',
                    name: fundName,
                    amount: amount,
                    orderId: purchaseId,
                    mp: mp,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: AppColor().textColor.withOpacity(0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                                color: AppColor().textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: AppColor().textColor.withOpacity(0.3))),
                      ],
                    ),
                  ),
                  _buildExpansionTile(
                    "BY USING MOBILE NETWORK APPLICATION",
                    [
                      Text(
                        "1. Login to your Application",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        "2. Choose Tranfer To Bank or Banking",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '3. Choose "NBC BANK" ',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      RichText(
                          text: TextSpan(
                              text: '4. Enter Fund Account Number ',
                              style: TextStyle(color: AppColor().textColor),
                              children: [
                            TextSpan(
                              text: '"$accountNumber"',
                              style: TextStyle(
                                  color: AppColor().blueBTN,
                                  fontWeight: FontWeight.w600),
                            )
                          ])),
                      Text(
                        "5. Choose Tranfer To Bank or Banking",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '6. Enter the amount',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      RichText(
                          text: TextSpan(
                              text:
                                  '7. In the Description field enter your Control Number ',
                              style: TextStyle(color: AppColor().textColor),
                              children: [
                            TextSpan(
                              text: '"$clientReference"',
                              style: TextStyle(
                                  color: AppColor().blueBTN,
                                  fontWeight: FontWeight.w600),
                            )
                          ])),
                      Text(
                        '8. Click "Next" ',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '9. Enter Your PIN & Confirm Payment/Transfer',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                    ],
                    accountNumber,
                    clientReference,
                  ),
                  const SizedBox(height: 8),
                  _buildExpansionTile(
                    "BY USING BANK MOBILE APPLICATION",
                    [
                      Text(
                        "1. Login to your Application",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        "2. Choose Tranfer/Send Money",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '3. Choose "Other Banks"  ',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '4. Choose "NBC BANK"',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      RichText(
                          text: TextSpan(
                              text: '5. Enter Fund Account Number ',
                              style: TextStyle(color: AppColor().textColor),
                              children: [
                            TextSpan(
                              text: '"$accountNumber"',
                              style: TextStyle(
                                  color: AppColor().blueBTN,
                                  fontWeight: FontWeight.w600),
                            )
                          ])),
                      Text(
                        '6. Enter Amount',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      RichText(
                          text: TextSpan(
                              text:
                                  '7. In the Description field enter your Control Number ',
                              style: TextStyle(color: AppColor().textColor),
                              children: [
                            TextSpan(
                              text: '"$clientReference"',
                              style: TextStyle(
                                  color: AppColor().blueBTN,
                                  fontWeight: FontWeight.w600),
                            )
                          ])),
                      Text(
                        '8. Click "Next" ',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '9. Enter Your PIN & Confirm Payment/Transfer',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                    ],
                    accountNumber,
                    clientReference,
                  ),
                  const SizedBox(height: 8),
                  _buildExpansionTile(
                    "TOP UP WITH BANK DEPOSIT/WAKALA",
                    [
                      _buildBankDetails(accountNumber, fundName),
                      Text(
                        "1. Locate a branch - Locate any Bank branch or Wakala around you where you can deposit the funds.",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        "2. Fill out a payment slip - Complete the form and ensure you use your Control Number provided to you by iTrust.",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        '3. Receive a confirmation - After completion of the deposit, ensure you have received a confirmation of the funds being deposited.',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                    ],
                    accountNumber,
                    clientReference,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor().blueBTN.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "If you haven't paid by wallet, please upload your proof of payment (receipt) after completing the payment. We appreciate your attention to this detail! An upload button will be shown on your subscription screen.",
                      style: TextStyle(
                        color: AppColor().blueBTN,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

Widget _buildExpansionTile(String title, List<Widget> children,
    String accountNumber, String clientReference) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColor().textColor.withOpacity(0.1)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppColor().textColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _buildBankDetails(String accountNumber, String fundName) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColor().textColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        _buildBankDetailRow('Bank', 'NBC Bank'),
        _buildBankDetailRow('Branch', 'Corporate Branch'),
        _buildBankDetailRow('Account Number', accountNumber),
        _buildBankDetailRow('Account Name', fundName),
        _buildBankDetailRow('Swift Code', 'NLCBTZTZ'),
      ],
    ),
  );
}

Widget _buildBankDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: AppColor().textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColor().textColor,
          ),
        ),
      ],
    ),
  );
}
