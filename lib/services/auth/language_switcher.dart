import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';

class LanguageSwitcher extends StatefulWidget {
  LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  final languages = [
    'EN',
    'SW',
  ];

  var selectedLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16.0),
      child: Column(
        children: [
          Row(
              mainAxisSize: MainAxisSize.min,
              children: languages
                  .map(
                    (lan) => SizedBox(
                      width: 32,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLanguage = lan;
                            });
                          },
                          child: Text(
                            lan,
                            style: TextStyle(
                              color: selectedLanguage == lan
                                  ? AppColor().blueBTN
                                  : AppColor().grayText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList()),
          Stack(children: [
            Container(
              height: 3,
              width: 64,
              decoration: BoxDecoration(
                color: AppColor().inputFieldColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: languages.indexOf(selectedLanguage) * 36.0,
              child: Container(
                height: 2,
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
    );
  }
}
