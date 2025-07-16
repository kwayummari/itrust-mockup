import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/widgets/btmSheet.dart';

class QuickService extends StatefulWidget {
  const QuickService({super.key});

  @override
  State<QuickService> createState() => _QuickServiceState();
}

class _QuickServiceState extends State<QuickService> {
  bool showAllFaqs = false;
  int visibleFaqCount = 3;

  @override
  Widget build(BuildContext context) {
    final double appHeight = MediaQuery.of(context).size.height;
    final double appWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor().blueBTN,
                AppColor().blueBTN.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor().blueBTN.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColor().constant,
                    size: 20,
                  ),
                ),
              ),
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support,
                      color: AppColor().constant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Quick Service",
                    style: TextStyle(
                      color: AppColor().constant,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactActionCard(
                            icon: Icons.graphic_eq,
                            title: "Market\nData",
                            onTap: () {},
                            iconSize: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactActionCard(
                            icon: Icons.chat,
                            title: "Ask\niTrustGPT",
                            onTap: () async => await Waiter().launchITRGPT(),
                            iconSize: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactActionCard(
                            icon: Icons.question_answer,
                            title: "View\nFAQ",
                            onTap: () {},
                            iconSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader("FAQs"),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showAllFaqs = !showAllFaqs;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            showAllFaqs ? "Show Less" : "View All",
                            style: TextStyle(
                              color: AppColor().blueBTN,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0;
                                i <
                                    (showAllFaqs
                                        ? faqs.length
                                        : visibleFaqCount);
                                i++)
                              _buildCompactFaqTile(faqs[i]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColor().blueBTN.withOpacity(0.9),
                            AppColor().blueBTN,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor().blueBTN.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ContactBottomSheet.show(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Contact Support",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    double iconSize = 24,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor().blueBTN.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColor().blueBTN,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor().blueBTN,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFaqTile(Map<String, String> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text(
            faq["qn"]!,
            style: TextStyle(
              color: AppColor().blueBTN,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq["ans"]!,
                style: const TextStyle(
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor().textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List faqs = [
    {
      "qn":
          "What are the Requirements for an Investor to Open a Trading Account with us?",
      "ans":
          "To open a trading account, Investors must submit KYC documents, complete relevant forms and agreements that outline terms of the trading relationship. After this process, investors can start trading with us."
    },
    {
      "qn": "How do I place an order to buy or sell securities?",
      "ans":
          "Upon opening an account, you can place your order via email by sending your instructions to dealing@itrust.co.tz ."
    },
    {
      "qn": "What Amounts Can an Investor Buy?",
      "ans":
          "The amount of shares an investor can buy varies and is subject to the availability of shares and the investor's financial capacity. Different shares may have different pricing and minimum purchase requirements."
    },
    {
      "qn": "When will my trade be settled?",
      "ans":
          "Regarding shares, your trade will be settled the third day after it have traded (T+3). Please note, a trade will settle on the next day if the settlement date falls on a weekend or public holiday."
    },
    {
      "qn": "What are the risks of investing in the stock market?",
      "ans":
          "Investing in the stock market carries inherent risks, Market fluctuations can affect the value of investments. We provide client with comprehensive information and guidance to help make you make informed decision."
    },
    {
      "qn":
          "What kind of support can I expect from the iTrust Finance advisory team?",
      "ans":
          "Clients can expect ongoing support from our advisory team. This includes regular reviews of your investment portfolio, timely adjustments to your investment strategy in response to market changes or personal circumstances, and accessible customer service for any queries or concerns."
    }
  ];
}
