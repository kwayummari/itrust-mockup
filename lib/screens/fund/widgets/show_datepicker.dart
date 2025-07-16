import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/constants/app_color.dart';

Future<DateTime?> showMyDatePicker(BuildContext context, DateTime initialDate,
    {DateTime? minimumDate, DateTime? maxDate}) async {
  DateTime selectedDate = initialDate; // Default selected date

  return showCupertinoModalPopup<DateTime?>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: Theme.of(context).brightness,
                      ),
                      child: CupertinoDatePicker(
                        minimumDate: minimumDate,
                        maximumDate: maxDate,
                        initialDateTime: initialDate,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            selectedDate = newDateTime;
                          });
                        },
                        mode: CupertinoDatePickerMode.date,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            // height: 40,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              // border: Border.all(
                              //   color: Theme.of(context).colorScheme.outline,
                              // ),
                              color: AppColor().inputFieldColor,
                            ),
                            child: Text(
                              DateFormat('MMMM dd, yyyy').format(selectedDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        IconButton.filled(

                          style: IconButton.styleFrom(

                            backgroundColor:AppColor().blueBTN.withAlpha(40),
                            foregroundColor: AppColor().blueBTN,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.all(10),
                          ),
                          onPressed: () {
                            Navigator.pop(context,
                                selectedDate); // Close the modal and return the selected date
                          },

                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      );
    },
  );
}