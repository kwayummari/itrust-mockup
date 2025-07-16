// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:iwealth/constants/app_color.dart';

class ProductsTicker extends StatefulWidget {
  final List<ProductsTickerItem> products;
  const ProductsTicker({
    super.key,
    required this.products,
  });

  @override
  _ProductsTickerState createState() => _ProductsTickerState();
}

class _ProductsTickerState extends State<ProductsTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  final double scrollSpeed = 20; // pixels per second

  bool _isUserTouching = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);
    if (widget.products.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoScroll();
      });
    }
  }

  void _startAutoScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;

    final duration = Duration(
      milliseconds: (maxScroll / scrollSpeed * 1000).round(),
    );

    _animationController
      ..duration = duration
      ..addListener(() {
        if (!_isUserTouching) {
          final offset = _animationController.value * maxScroll;
          _scrollController.jumpTo(offset);
        }
      })
      ..repeat();
  }

  void _pauseAutoScroll() {
    _isUserTouching = true;
    _animationController.stop();
  }

  void _resumeAutoScroll() {
    _isUserTouching = false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offsetRatio = _scrollController.offset / maxScroll;

    _animationController.forward(from: offsetRatio);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.products.length, // repeat to simulate endless scroll
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return Row(
            children: [
              GestureDetector(
                // onTap: () => _pauseAutoScroll(),
                // onTapDown: (_) => _pauseAutoScroll(),
                // onTapUp: (_) => _resumeAutoScroll(),
                // onTapCancel: () => _resumeAutoScroll(),
                // onLongPressStart: (_) => _pauseAutoScroll(),
                // onLongPressEnd: (_) => _resumeAutoScroll(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(product.price.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            )),
                      ),
                      Text(
                        '${product.change >= 0 ? '↑' : '↓'}${product.change.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color:
                              product.change >= 0 ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 15,
                decoration: BoxDecoration(
                  color: AppColor().lowerBg.withAlpha(250),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class ProductsTickerItem {
  final String name;
  final double price;
  final double change;

  ProductsTickerItem(
      {required this.name, required this.price, required this.change});
}
