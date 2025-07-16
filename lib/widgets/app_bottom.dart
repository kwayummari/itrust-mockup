import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/home/home.dart';
import 'package:iwealth/screens/orders/orders_list.dart';
import 'package:iwealth/screens/stocks/ui/portfolio.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatefulWidget {
  final String? updated;
  final int? currentIndex;
  const BottomNavBarWidget({super.key, this.updated, this.currentIndex});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentIndex != null) {
      currentIndex = widget.currentIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(updated: widget.updated),
          Portfolio(
            portfolio: const [], // Pass an empty list initially
            isPreloaded: false,
          ),
          const OrdersListPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, "Home"),
                    _buildNavItem(1, Icons.bar_chart, "Portfolio"),
                    _buildNavItem(2, Icons.list_alt_rounded, "Orders"),
                  ],
                ),
                Stack(children: [
                  const SizedBox(
                    height: 5,
                    width: double.infinity,
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: ((currentIndex) * (width - 32) / 3) + 48,
                    child: Container(
                      height: 3,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppColor().blueBTN,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => currentIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColor().blueBTN : AppColor().grayText,
                size: 24,
              ),
              // const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColor().blueBTN : AppColor().grayText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
