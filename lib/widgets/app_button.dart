import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';

class AppButton extends StatelessWidget {
  final Function onPress;
  final Widget label;
  final Color bcolor;
  final double borderRadius;
  final Color textColor;
  final Color? borderColor;
  final double? elevation;

  const AppButton({
    super.key,
    required this.onPress,
    required this.label,
    required this.borderRadius,
    required this.textColor,
    required this.bcolor,
    this.borderColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(elevation ?? 2.0),
        backgroundColor: WidgetStateProperty.all<Color>(bcolor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: borderColor != null
                ? BorderSide(
                    color: borderColor ?? AppColor().transparent,
                    width: 1,
                  )
                : BorderSide(color: AppColor().transparent, width: 1),
          ),
        ),
      ),
      onPressed: () => onPress(),
      child: label,
    );
  }
}
