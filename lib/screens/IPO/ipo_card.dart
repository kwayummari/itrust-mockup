import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/constants/texts.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget ipoCard(
    {required IconData icon,
    required double h,
    required double w,
    required String ipoHeader,
    required VoidCallback onTapped,
    context}) {
  return InkWell(
    onTap: onTapped,
    child: Container(
      margin: const EdgeInsets.all(5.0),
      height: h * 0.1,
      width: w,
      decoration: BoxDecoration(
        color: AppColor().blueBTN,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColor().bgLight,
          ),
          Text(
            " $ipoHeader",
            style: TextStyle(color: AppColor().bgLight, fontSize: 18.0),
          )
        ],
      ),
    ),
  );
}

Widget ipoProduct(
    {required String productTitle,
    required String productDesc,
    required VoidCallback whenTapped}) {
  return Card(
    elevation: 3.0,
    margin: const EdgeInsets.only(left: 10.0, bottom: 5.0, right: 10.0),
    child: ListTile(
      onTap: whenTapped,
      leading: const Icon(Icons.graphic_eq),
      title: Text(productTitle),
      subtitle: Text(productDesc),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColor().textColor,
      ),
    ),
  );
}

ipoSubscriptionForm(
    {context,
    msg,
    formKey,
    restrictAmount,
    ipoAmount,
    description,
    btnPressed,
    appWidths,
    appHeights}) {
  return showDialog(
      barrierColor: AppColor().selected,
      context: context,
      // backgroundColor: AppColor().bgLight,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: appWidths,
                // height: appHeights * 0.3,
                padding:
                    const EdgeInsets.only(top: 20, left: 20.0, right: 20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SvgPicture.asset(
                          "assets/images/icon-top-black-name.svg",
                          width: 80,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextfield().amountToSent(
                            hint: "Enter Amount",
                            label: Words().ipoFundAmountLabel,
                            inputType: TextInputType.number,
                            controller: ipoAmount,
                            minAmount: restrictAmount,
                            valueCapture: (val) {}),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: CustomTextfield().nameC("Write Description", "Description", TextInputType.name, description, (val){}),
                      // ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().blueBTN),
                        // style: ButtonStyle(),
                        onPressed: btnPressed,
                        child: Text(
                          "Invest",
                          style: TextStyle(color: AppColor().constant),
                        ),
                      ),
                      SizedBox(
                        height: appHeights * 0.05,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      });
}
