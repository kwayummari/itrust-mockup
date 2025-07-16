import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/utilities/comma_sep.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:email_validator/email_validator.dart'; // Add this import at the top

class CustomTextfield {
// Field for data with less restricition like username,firstname,mname,lastname,location
  Widget name(hint, label, inputType, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) =>
                value!.isEmpty ? "This field is required" : null,
            onChanged: valueCapture,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  Widget nameNQ(hint, label, inputType, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            onChanged: valueCapture,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  Widget nameC(hint, label, inputType, controller, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) =>
                value!.isEmpty ? "This field is required" : null,
            onChanged: valueCapture,
            controller: controller,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // Amount
  Widget amountToSent(
      {hint, label, inputType, controller, minAmount, valueCapture}) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) => value!.isEmpty
                ? "This field is required"
                : double.parse(value.replaceAll(",", "")) < minAmount
                    ? "${currencyFormat(minAmount)} is the minimum amount"
                    : null,
            onChanged: valueCapture,
            controller: controller,
            keyboardType: inputType,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter()
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // nida Answer
  Widget nidaAnswer(hint, label, inputType, TextEditingController controller) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            controller: controller,
            validator: (value) =>
                value!.isEmpty ? "This field is required" : null,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // name with Initial Value
  Widget nameWithValue(hint, label, inputType, isEnabled, valueCapture, inVal) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) =>
                value!.isEmpty ? "This field is required" : null,
            onChanged: valueCapture,
            keyboardType: inputType,
            readOnly: isEnabled,
            style: TextStyle(color: AppColor().textColor),
            initialValue: inVal,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  Widget nameWithValueOpt(
      hint, label, inputType, isEnabled, valueCapture, inVal) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            onChanged: valueCapture,
            keyboardType: inputType,
            readOnly: isEnabled,
            style: TextStyle(color: AppColor().textColor),
            initialValue: inVal,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // name with Initial Value
  Widget numberOfSharesField({
    hint,
    label,
    inputType,
    valueCapture,
    orderType,
    qnty,
  }) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (val) => val!.isEmpty
                ? "Required Field"
                : orderType == "sell" && int.parse(val) > qnty
                    ? "You've only $qnty shares"
                    : (orderType == "buy" &&
                            int.parse(val) <= qnty) // Check for buy condition
                        ? "Buy at least 11 shares"
                        : null,
            onChanged: valueCapture,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          )
        ],
      ),
    );
  }

  // nida number
  Widget idVerification(
      hint, label, int maxLen, iniVal, inputType, isReadOnly, valueCapture) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, left: 18.0, right: 18.0),
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            maxLength: maxLen,
            validator: (value) => value!.length != maxLen
                ? "This field should have $maxLen numbers"
                : null,
            onChanged: valueCapture,
            initialValue: iniVal,
            keyboardType: inputType,
            style: TextStyle(color: AppColor().textColor),
            readOnly: isReadOnly,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor().gray),
                  borderRadius: BorderRadius.circular(13.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().gray,
                suffixIcon: Icon(
                  Icons.qr_code_scanner_sharp,
                  color: AppColor().textColor,
                ),
                filled: true),
          ),
        ],
      ),
    );
  }

  // nida number
  Widget idVerificationTIN(
      hint, label, int maxLen, iniVal, inputType, isReadOnly, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            maxLength: maxLen,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null; // Don't show error for empty field
              }
              if (value.length != maxLen) {
                // Dismiss keyboard before showing error
                FocusManager.instance.primaryFocus?.unfocus();
                return "This field should have $maxLen numbers";
              }
              return null;
            },
            onChanged: (val) {
              valueCapture(val);
              if (val.length == maxLen) {
                // Automatically dismiss keyboard when max length is reached
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            initialValue: iniVal,
            keyboardType: inputType,
            textInputAction: TextInputAction.done,
            style: TextStyle(color: AppColor().textColor),
            readOnly: isReadOnly,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
              hintText: hint,
              hintStyle: TextStyle(color: AppColor().grayText),
              fillColor: AppColor().inputFieldColor,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: AppColor().textColor,
                ),
                onPressed: () {
                  // Dismiss keyboard when tapping check icon
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              filled: true,
              errorStyle: const TextStyle(
                height: 0, // Reduce space taken by error text
              ),
            ),
          ),
        ],
      ),
    );
  }

// phone number
  Widget phoneNumber(
      Function(PhoneNumber) onChange, PhoneNumber initialPhoneNumber,
      {FocusNode? focusNode}) {
    // Add debouncer to reduce prints
    DateTime? lastPrint;
// Track validation state

    final TextEditingController controller = TextEditingController(
      text: initialPhoneNumber.phoneNumber?.replaceAll('+255', ''),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              "Phone Number",
              style: TextStyle(
                color: AppColor().textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InternationalPhoneNumberInput(
            focusNode: focusNode, // Pass the focus node to the input
            onInputChanged: (PhoneNumber number) {
              String? formattedNumber = number.phoneNumber;
              if (formattedNumber != null && !formattedNumber.startsWith('+')) {
                formattedNumber = '+${number.dialCode}${number.parseNumber()}';
              }

              // Validate phone number length
              if (formattedNumber != null) {
                String digitsOnly =
                    formattedNumber.replaceAll(RegExp(r'[^\d]'), '');
// Check for exactly 12 digits (including country code)
              }

              // Only update if the number has actually changed
              if (formattedNumber != initialPhoneNumber.phoneNumber) {
                onChange(PhoneNumber(
                  phoneNumber: formattedNumber,
                  isoCode: number.isoCode ?? 'TZ',
                  dialCode: number.dialCode ?? '+255',
                ));
              }
            },
            onInputValidated: (bool value) {
              // Only print validation status every 500ms
              if (kDebugMode) {
                final now = DateTime.now();
                if (lastPrint == null ||
                    now.difference(lastPrint!) >
                        const Duration(milliseconds: 500)) {
                  lastPrint = now;
                  print('Phone number valid: $value');
                }
              }
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              setSelectorButtonAsPrefixIcon: true,
              leadingPadding: 20, // Add padding before the flag
            ),
            spaceBetweenSelectorAndTextField:
                0, // Remove space between flag and input
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            textStyle: TextStyle(color: AppColor().textColor),
            selectorTextStyle: TextStyle(color: AppColor().textColor),
            initialValue: initialPhoneNumber,
            textFieldController: controller,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            inputBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(25.0), // Match continue button radius
            ),
            countries: const ['TZ'],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              // Remove any non-digit characters and check length
              String digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length != 9) {
                // Check for exactly 12 digits (including country code)
                return 'Please enter a valid phone number';
              }
              return null;
            },
            inputDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Match continue button radius
                borderSide: BorderSide(
                  color: AppColor().grayText,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Match continue button radius
                borderSide: BorderSide(
                  color: AppColor().grayText,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal:
                      0), // Remove horizontal padding to align flag properly
              hintText: "712 345 678",
              hintStyle: TextStyle(color: AppColor().grayText),
              fillColor: AppColor().inputFieldColor,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  // phone number
  Widget payPhoneNumber(onChange, phoneNumber) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              "Payment Phone Number",
              style: TextStyle(
                  color: AppColor().textColor,
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          InternationalPhoneNumberInput(
            onInputChanged: onChange,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            textStyle: TextStyle(color: AppColor().textColor),

            // Ignore blank input
            ignoreBlank: false,

            // Auto-validation mode
            autoValidateMode: AutovalidateMode.onUserInteraction,

            // Style for the country selector
            selectorTextStyle: TextStyle(color: AppColor().textColor),

            // Initial value for the phone number input
            initialValue: phoneNumber,

            // Controller for the text field
            textFieldController: TextEditingController(),

            // Decoration for the input field
            inputDecoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
              hintText: "712 345 678",
              hintStyle: TextStyle(color: AppColor().inputFieldColor),
              fillColor: AppColor().inputFieldColor,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

// Email
  Widget email(hint, label, inputType, valueCapture, {FocusNode? focusNode}) {
    return StatefulBuilder(
      builder: (context, setState) {
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextFormField(
                focusNode: focusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  valueCapture(value);
                  setState(() {});
                },
                keyboardType: inputType,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                style: TextStyle(color: AppColor().textColor),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColor().grayText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColor().blueBTN),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 18,
                  ),
                  hintText: hint,
                  hintStyle: TextStyle(color: AppColor().grayText),
                  fillColor: AppColor().inputFieldColor,
                  filled: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Email
  Widget username(hint, label, inputType, valueCapture) {
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
                  color: AppColor().textColor, fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            onChanged: valueCapture,
            validator: (value) =>
                value!.isEmpty ? "username can not be empty" : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: inputType,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle:
                    TextStyle(color: AppColor().grayText, fontSize: 15.0),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // Email
  Widget emailC(hint, label, inputType, controller, valueCapture) {
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
                  color: AppColor().textColor, fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!EmailValidator.validate(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              // Add real-time validation feedback
              if (value.isNotEmpty) {
                bool isValid = EmailValidator.validate(value);
                if (isValid) {
                  valueCapture(value);
                }
              }
            },
            keyboardType: TextInputType.emailAddress,
            controller: controller,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true,
                // Add error icon when email is invalid
                errorStyle: const TextStyle(color: Colors.red),
                suffixIcon: controller.text.isNotEmpty
                    ? Icon(
                        EmailValidator.validate(controller.text)
                            ? Icons.check_circle
                            : Icons.error,
                        color: EmailValidator.validate(controller.text)
                            ? Colors.green
                            : Colors.red,
                      )
                    : null),
          ),
        ],
      ),
    );
  }

// Password
  Widget psd(hint, label, inputType, bool isVisible, isVisbleIcon, iconClick,
      valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) => value!.length < 8
                ? "Password must be 8 or longer characters"
                : !value.contains(RegExp(r'[A-Z]'))
                    ? "Uppercase letter is missing"
                    : !value.contains(RegExp(r'[a-z]'))
                        ? "Lowercase letter is missing"
                        : !value.contains(RegExp(r'[0-9]'))
                            ? "Digit is missing"
                            : !value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))
                                ? "Special character is missing."
                                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: valueCapture,
            keyboardType: inputType,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true,
                suffixIcon:
                    IconButton(onPressed: iconClick, icon: Icon(isVisbleIcon))),
            obscureText: isVisible,
          ),
        ],
      ),
    );
  }

  // confirmPSD
  // Password
  Widget confirmPSD(hint, label, inputType, psd, bool isVisible, isVisbleIcon,
      iconClick, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) => value != psd ? "Password Don't Match" : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: valueCapture,
            keyboardType: inputType,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true,
                suffixIcon:
                    IconButton(onPressed: iconClick, icon: Icon(isVisbleIcon))),
            obscureText: isVisible,
          ),
        ],
      ),
    );
  }

  Widget pinSET({hint, label, valueCapture, required BuildContext context}) {
    final appWidth = MediaQuery.of(context).size.width;
    final defaultPinTheme = PinTheme(
        width: (appWidth - 72) / 4,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        textStyle: TextStyle(color: AppColor().textColor, fontSize: 40),
        decoration: BoxDecoration(
            color: AppColor().inputFieldColor,
            borderRadius: BorderRadius.circular(8.0)));
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Pinput(
            defaultPinTheme: defaultPinTheme,
            errorTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.red.shade800,
            ),
            length: 4,
            onChanged: valueCapture,
            obscureText: true,
            validator: (pin) {
              if (pin == null || pin.length != 4) {
                return 'PIN must be 4 digits long';
              }
              if (hasSequentialNumbers(pin)) {
                return 'PIN should not contain sequential numbers';
              }
              if (hasManySequenceNumber(pin)) {
                return 'PIN should not contain more than two identical digits in sequence';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Helper method to check for sequential numbers in a PIN
  bool hasSequentialNumbers(String pin) {
    if (pin.length < 2) return false;
    for (int i = 0; i < pin.length - 1; i++) {
      int current = int.tryParse(pin[i]) ?? -1000;
      int next = int.tryParse(pin[i + 1]) ?? -1000;
      if (current == -1000 || next == -1000) return false;
      // Check for ascending sequence
      if (next == current + 1) {
        // Check the rest of the sequence
        bool ascending = true;
        for (int j = i; j < pin.length - 1; j++) {
          int a = int.tryParse(pin[j]) ?? -1000;
          int b = int.tryParse(pin[j + 1]) ?? -1000;
          if (b != a + 1) {
            ascending = false;
            break;
          }
        }
        if (ascending) return true;
      }
      // Check for descending sequence
      if (next == current - 1) {
        bool descending = true;
        for (int j = i; j < pin.length - 1; j++) {
          int a = int.tryParse(pin[j]) ?? -1000;
          int b = int.tryParse(pin[j + 1]) ?? -1000;
          if (b != a - 1) {
            descending = false;
            break;
          }
        }
        if (descending) return true;
      }
    }
    return false;
  }

  // Helper method to check for more than two identical digits in sequence in a PIN
  bool hasManySequenceNumber(String pin) {
    if (pin.length < 3) return false;
    for (int i = 0; i < pin.length - 2; i++) {
      if (pin[i] == pin[i + 1] && pin[i] == pin[i + 2]) {
        return true;
      }
    }
    return false;
  }

  Widget confirmPIN(
      {hint, label, pin, valueCapture, required BuildContext context}) {
    final appWidth = MediaQuery.of(context).size.width;
    print(appWidth);
    final defaultPinTheme = PinTheme(
        width: (appWidth - 72) / 4,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        textStyle: TextStyle(color: AppColor().textColor, fontSize: 40),
        decoration: BoxDecoration(
            color: AppColor().inputFieldColor,
            borderRadius: BorderRadius.circular(8.0)));
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Pinput(
            validator: (value) => value != pin ? "PIN not match" : null,
            defaultPinTheme: defaultPinTheme,
            length: 4,
            onChanged: valueCapture,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  // Login Password
  Widget loginPSD(hint, label, inputType, bool isVisible, isVisbleIcon,
      iconClick, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) =>
                value!.isEmpty ? "Password can not be empty" : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: valueCapture,
            keyboardType: inputType,
            style: TextStyle(color: AppColor().textColor),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: hint,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: isVisible,
                suffixIcon:
                    IconButton(onPressed: iconClick, icon: Icon(isVisbleIcon))),
            obscureText: isVisible,
          ),
        ],
      ),
    );
  }

  // Date Picker
  Widget datePickerField(hint, label, inputType,
      TextEditingController selectedDate, pickDate, valueCapture) {
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
                  // fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            validator: (value) =>
                value!.isEmpty ? "This field is required" : null,
            controller: selectedDate,
            // onChanged: valueCapture,
            keyboardType: inputType,

            style: TextStyle(color: AppColor().textColor),
            readOnly: true,
            onTap: pickDate,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
                hintText: selectedDate.text,
                hintStyle: TextStyle(color: AppColor().grayText),
                fillColor: AppColor().inputFieldColor,
                filled: true),
          ),
        ],
      ),
    );
  }

  // OTP
  Widget OTPField() {
    return Pinput(
      length: 6,
      onCompleted: (value) => print(value),
    );
  }
}
