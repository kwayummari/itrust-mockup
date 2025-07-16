import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().stockCardColor,
        title: Text(
          "Terms And Condition",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
          children: [
            Text(
              "These terms and conditions (“Agreement”) apply to the electronic services relationship between you and iTrust Finance Limited (“iTrust, we or us”) and will be regarded as accepted by you at the time of providing us with the relevant mandate or upon registering for electronic services, whichever occurs first.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "1. Using new channels to communicate",
              style: TextStyle(fontSize: 17.0, color: AppColor().textColor),
            ),
            Text(
              "iTrust services may be accessible electronically through our website, electronic servicesor through any other device which you select to access iTrust services including a computer, cellphone, telephone, or similar technologies (“the device”) and the medium through which you access electronic services may include the Internet, wireless application protocol, wireless Internet gateway, short messaging system, voice over an automated voice recognition/response system or similar technologies (“the medium”). We will refer to the device and the medium collectively as 'the access channel'. For the avoidance of doubt, reference to access channel includes our website through which iTrust services are provided. To access the corporate portal, please download corporateinternet services software from our website www.itrust.co.tz. iTrust will not be liable for any fraudulent activities as of non-adherence to this requirement.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text("2. Please read this Agreement with other relevant terms",
                style: TextStyle(fontSize: 17.0, color: AppColor().textColor)),
            Text(
              "This Agreement forms part of and must be read with the terms and conditions (“service terms”) governing any investment products, credit facility, other products, other services  or channels (collectively referred to as the “service”) provided via the access channels from time to time. For convenience, we will refer to such services collectively as “electronic services”. You acknowledge that the access channels may enable you viewer access to investment products, credit facilities, accounts, products, services and channels offered by the ITrust, and that such facilities, accounts, products, services and channels will be governed by separate terms and conditions. Different security systems may also apply to these facilities, accounts, products services and channels. If there is any conflict between these terms and conditions and those of the other facilities, accounts, products, services and channels, the terms and conditions of those facilities,accounts, products, services and channels used will prevail. In the event of conflict or inconsistency between the provisions of this Agreement and any service terms relating to the access channel, the provisions of this Agreement will prevail, to the extent of removing such conflict or inconsistency. The objective of this Agreement is to deal with our respective rights and obligations pertaining to the use of the access channel, the exchange of electronic messages between us and the use of supporting technologies irrespective of the nature of the service. Where service terms require amendments or additions thereto to be reduced to writing and/or signed, your acceptance of this Agreement shall be deemed to satisfy such requirements. You agree to this irrespective of whether you have concluded service terms before or after having entered into this Agreement. Whenever contractual terms, disclaimers or notices are displayed or hyperlinked via an access channel, such contractual terms, disclaimers, or notices shall be deemed to be accepted on your use of any service. For purposes of this Agreement, the service terms include:",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text("3. Linked text",
                style: TextStyle(fontSize: 17.0, color: AppColor().textColor)),
            Text(
              "For ease of use, we may include automated links (hyperlinks) in this Agreement or on the website to information hosted or made available elsewhere through the access channel. You are obliged to view the relevant parts of the hyperlinked information, which information will be regarded as forming part of this Agreement. If your access channel cannot access the hyperlinks, you must visit our website at www.itrust.co.tz or contact our customer service desk via email on info@itrust.co.tz.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "4. Your authority",
              style: TextStyle(fontSize: 17.0, color: AppColor().textColor),
            ),
            Text(
              "Use of an access channel means we do not interact face-to-face. Unless you notify us before we give effect to an instruction, you authorise us to rely on and perform all instructions that appear to originate from you (even if someone else is impersonating you). Accordingly, you permit us to regard all activities you conduct or instructions sent through the access channel as being duly authorised by you and intended to have legal force and effect.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "5. Sending and processing instructions",
              style: TextStyle(fontSize: 17.0, color: AppColor().textColor),
            ),
            Text(
              "Your instructions to us will be subject to the same turn-around times and processes that apply to your customer profile, the type of service, account or transaction involved. More information on the turn-around times for processing of instructions may be provided on our website. From time to time we may apply limits to instructions that are sent from certain access channels or for certain services. We may vary these limits at any time with immediate effect. Instructions for transactions over the set limits will have to be sent to us in the manner we specify. Unless expressly authorised or required in the service terms or user manual, you may not send instructions in respect of services to us by email and we will not be under any obligation to give effect to such instructions.Please distinguish this prohibition from making enquiries by means of email, which you are permitted to do provided: such enquiry does not constitute an instruction to perform a transaction or otherwise perform a banking service and provided the email address has been designated by us for customer enquiry purposes. We may impose restrictions on the nature of transactions to be submitted by you, on the type of account against which credit transactions may be posted, and on the value of any one transaction or set of transactions. We are entitled to vary these restrictions from time to time by giving you not less than 30 (thirty) days’ written notice.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "6. Confirmation of receipt of your instructions",
              style: TextStyle(fontSize: 17.0, color: AppColor().textColor),
            ),
            Text(
              "An instruction is deemed to be received by us only once we have confirmed we have received it. If we fail to confirm receipt of your instruction, do not re-send the same instruction before checking your statements and contacting our Customer service desk.This is because the initial instruction may still be processed and re-sending the instruction may lead to a double transaction for which we will not be held liable.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "7. Fees",
              style: TextStyle(fontSize: 17.0, color: AppColor().textColor),
            ),
            Text(
              "The fees payable for the relevant services as agreed to between us, may be varied by us from time to time, subject to notification thereof to you. You authorise us to deduct such fees and value added tax at the prescribed rate from your account(s) with us on a monthly basis.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
            Text(
              "8. ITrust statements and account balances",
              style: TextStyle(color: AppColor().textColor, fontSize: 17.0),
              textAlign: TextAlign.justify,
            ),
            Text(
              "You agree that, subject to any regulatory or statutory requirements, we may make your iTrust statements in respect of the services available only by electronic means (replacing paper forms and posting thereof). For your convenience we may provide you with an indication of the balances on your account from time to time. If you choose to view an account balance which you have with another financial institution then note that the account balance displayed on the access channels may not be up to date on a real time basis. This is because we only receive updates of account balances periodically.You must therefore verify the account balance with the financial institution in question before placing reliance thereon.",
              style: TextStyle(color: AppColor().textColor),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: appHeight * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
