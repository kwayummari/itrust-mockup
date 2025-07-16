import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';

class TabBarWidget extends StatelessWidget {
  final BuildContext context;
  final List<String> tabs;
  final TabController tabController;

  const TabBarWidget(
      {super.key,
      required this.context,
      required this.tabs,
      required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor().lowerBg,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TabBar(
        // isScrollable: true,
        controller: tabController,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        overlayColor: WidgetStateProperty.all<Color>(
          Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        indicator: BoxDecoration(
          color: AppColor().blueBTN,
          borderRadius: BorderRadius.circular(12.0),
        ),
        tabs: tabs
            .map(
              (item) => Tab(text: item.capitalize()),
            )
            .toList(),
      ),
    );
  }
}
