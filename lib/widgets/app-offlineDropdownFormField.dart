import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/widgets/app_text.dart';

class AppDropdownTextFormField extends StatelessWidget {
  final String labelText;
  final List<String> options;
  final String value;
  final void Function(String?)? onChanged;

  const AppDropdownTextFormField({
    required this.labelText,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColor().white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: AppColor().blueBTN),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: AppText(
              txt: labelText,
              color: AppColor().black,
              size: 15,
            ),
            isDense: true,
            onChanged: onChanged,
            items: [
              ...options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: AppText(
                    txt: option,
                    size: 15,
                    color: AppColor().black,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
