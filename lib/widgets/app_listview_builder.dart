import 'package:flutter/material.dart';

class AppListviewBuilder extends StatelessWidget {
  final bool disabled;
  final int itemnumber;
  final Axis direction;
  final Widget Function(BuildContext context, int index) itemBuilder;
  const AppListviewBuilder(
      {super.key,
      this.direction = Axis.vertical,
      this.disabled = false,
      required this.itemnumber,
      required this.itemBuilder,
      });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: direction,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: itemBuilder,
      itemCount: itemnumber != 0 ? itemnumber : null,
    );
  }
}
