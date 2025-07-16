import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/sector.dart';
import 'package:flutter/material.dart';

Widget customDropdownField(
    hint, label, inputType, List<Metadata>? data, valueCapture) {
  return Padding(
    padding: const EdgeInsets.only(top: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: AppColor().inputFieldColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<Metadata>(
            value: null,
            validator: (value) =>
                value == null ? "This field is required" : null,
            onChanged: valueCapture,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColor().textColor.withOpacity(0.7),
              size: 24,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            items: data?.map<DropdownMenuItem<Metadata>>((Metadata item) {
                  return DropdownMenuItem<Metadata>(
                    value: item,
                    child: Text(
                      item.name.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColor().textColor,
                      ),
                    ),
                  );
                }).toList() ??
                [],
            style: TextStyle(color: AppColor().textColor),
            dropdownColor: AppColor().cardColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().grayText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().grayText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().blueBTN,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColor().grayText.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              fillColor: AppColor().inputFieldColor,
              filled: true,
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(13),
            elevation: 8,
          ),
        ),
      ],
    ),
  );
}

Widget customDropdownFieldFuture(
    {required hint,
    required label,
    required inputType,
    required Future data,
    value,
    valueCapture}) {
  return Padding(
    padding: const EdgeInsets.only(top: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            label,
            style: TextStyle(
                color: AppColor().textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
        FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: AppColor().blueBTN,
                );
              } else if (snapshot.hasError) {
                return Text("Error due to: ${snapshot.error}");
              } else {
                return DropdownButtonFormField(
                  // value: value,
                  validator: (value) =>
                      value == null ? "This field is required" : null,

                  isExpanded: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: snapshot.data
                      ?.map<DropdownMenuItem<Metadata>>((Metadata sector) {
                    return DropdownMenuItem<Metadata>(
                      value: sector,
                      child: Text(sector.name),
                    );
                  }).toList(),
                  onChanged: valueCapture,
                  style: TextStyle(color: AppColor().textColor),
                  dropdownColor: AppColor().gang,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 18),
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColor().grayText),
                      fillColor: AppColor().inputFieldColor,
                      filled: true),
                );
              }
            })
      ],
    ),
  );
}

Widget workingropdownFieldFuture(
    {required hint,
    required label,
    required inputType,
    required value,
    required Future data,
    valueCapture}) {
  return Padding(
    padding: const EdgeInsets.only(top: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            label,
            style: TextStyle(
                color: AppColor().textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
        FutureBuilder(
            future: data,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: AppColor().mainColor,
                );
              } else if (snapshot.hasError) {
                return Text("Error due to: ${snapshot.error}");
              } else {
                return DropdownButtonFormField<String>(
                  value: value,
                  validator: (value) =>
                      value == null ? "This field is required" : null,
                  // value: "Dar es salaam",

                  isExpanded: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: <DropdownMenuItem<String>>[
                    for (var i = 0; i < snapshot.data.length; i++)
                      DropdownMenuItem(
                          value: snapshot.data[i].id.toString(),
                          child: Text(snapshot.data[i].name)),
                  ],
                  onChanged: valueCapture,
                  style: TextStyle(color: AppColor().textColor),
                  dropdownColor: AppColor().gang,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 18),
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColor().grayText),
                      fillColor: AppColor().inputFieldColor,
                      filled: true),
                );
              }
            })
      ],
    ),
  );
}

Widget staticCustomField(hint, label, inputType, dataItems, valueCapture) {
  return Padding(
    padding: const EdgeInsets.only(top: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: AppColor().inputFieldColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField(
            validator: (value) => value == null ? "This field Required" : null,
            onChanged: valueCapture,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColor().textColor.withOpacity(0.7),
              size: 24,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            items: dataItems.map<DropdownMenuItem<String>>((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColor().textColor,
                  ),
                ),
              );
            }).toList(),
            style: TextStyle(color: AppColor().textColor),
            dropdownColor: AppColor().cardColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().grayText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().grayText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: BorderSide(
                  color: AppColor().blueBTN,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColor().grayText.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              fillColor: AppColor().inputFieldColor,
              filled: true,
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(13),
            elevation: 8,
          ),
        ),
      ],
    ),
  );
}
