// ignore_for_file: unused_import

import 'dart:io';
import 'package:iwealth/services/auth/login.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/document_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:iwealth/User/model/user_kyc.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/User/widget/step1_kyc.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/sector.dart';
import 'package:iwealth/screens/user/otp.dart';
import 'package:iwealth/screens/user/kyc.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/nbc/apis.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/widgets/error_msg.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/dropdown_field.dart';
import 'package:iwealth/widgets/pop_up_dialog.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:iwealth/widgets/upload_btn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey5 = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();
  int step = 3;

  List<Metadata> regions = [];
  List<Metadata> districts = [];
  List<Metadata> wards = [];

  @override
  void initState() {
    super.initState();
    fetchRegionsData();
    restoreFormState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    saveFormState();
    super.dispose();
  }

  void fetchRegionsData() async {
    try {
      regions = await Waiter().fetchRegions();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load regions: $e");
      }
    }
  }

  Future<void> fetchDistrictsData(String regionCode) async {
    try {
      setState(() {
        districts = [];
        wards = [];
        district = null;
        ward = null;
      });

      districts = await Waiter().fetchDistricts(regionCode);
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load districts: $e");
      }
    }
  }

  Future<void> fetchWardsData(String districtCode) async {
    try {
      setState(() {
        wards = [];
        ward = null;
      });

      wards = await Waiter().fetchWards(districtCode);
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load wards: $e");
      }
    }
  }

  TextEditingController datePickerController = TextEditingController();

  void verifyOTP({required MetadataProvider mp}) async {
    var otpStatus = await NBC().verifyOTP(otp: otp, context: context, mp: mp);
    if (otpStatus == "success") {
      Navigator.pop(context);
      setState(() {
        step = 3;
        title = "NIDA";
      });
    } else {
      Navigator.pop(context);
      AppSnackbar(
        isError: true,
        response: "Invalid OTP. Please try again.",
      ).show(context);
    }
  }

  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate:
          DateTime(int.parse(DateFormat("yyyy").format(DateTime.now())) - 17),
      firstDate: DateTime(1930),
    );
    if (pickedDate == null) return;
    setState(() {
      datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    });
    if (kDebugMode) {
      print("TODAY YEAR: ${datePickerController.text}");
    }
  }

  File?
      //   tinDoc,
      passportDoc,
      signatureDoc;
  String?
      // tinFileName,
      tinExt,
      passExt,
      signExt,
      relationship,
      sourceOfIncome,
      gender,
      bankName,
      incomeFreq,
      dseCDS,
      region,
      district,
      ward,
      // tinNumber,
      pob;
  String title = "Verification";
  String otp = "";
  bool isChecked = false;
  int hasDSEAccount = 1;
  bool isRotate = false;
  String? nida, investorTitle, fullname;
  PhoneNumber _kinPhoneNumber = PhoneNumber(isoCode: "TZ");

  TextEditingController other = TextEditingController();

  // TextEditingController dseCDS = TextEditingController();
  TextEditingController kinEmail = TextEditingController();
  TextEditingController address = TextEditingController();

  TextEditingController accNumber = TextEditingController();
  TextEditingController accName = TextEditingController();

  // =========== FORM VALIDATION CHECKER ===============
  void validateForm(formType, formKey, int nextStep, nextTitle) {
    if (formKey.currentState!.validate()) {
      if (kDebugMode) {
        print(
            "$formType Form Validating Test PASSED !!, Next Step is: $nextStep, Next Title is: $nextTitle");
      }
      setState(() {
        step = nextStep;
        title = nextTitle;

        // Scroll to top when moving to step 4
        if (nextStep == 4) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      });
    } else {
      if (kDebugMode) {
        print("Failed To Validate");
      }
    }
  }

  void showErrorWithoutKeyboard(String title, String message) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      AppSnackbar(
        isError: true,
        response: "Something went wrong. Please try again.",
      ).show(context);
    });
  }

  Future<void> _updateProfileStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? profile = SessionPref.getUserProfile();
    if (profile != null && profile.length > 6) {
      profile[6] = status;
      await prefs.setStringList('user_profile', profile);
    }
  }

  void submitForm({required appwidth, required MetadataProvider mp}) async {
    FocusScope.of(context).unfocus();

    // if (tinFileName == null) {
    //   showErrorWithoutKeyboard("Missing Documents",
    //       "Please upload all required documents before proceeding.");
    //   return;
    // }

    if (!formKey5.currentState!.validate()) {
      return;
    }

    // Show loading dialog
    loading(context);

    try {
      // Create KYC object
      USERKYC userkyc = USERKYC(
        address: address.text,
        country: "TZ",
        dob: SessionPref.getNIDA()?[3],
        fname: SessionPref.getNIDA()?[4],
        lname: SessionPref.getNIDA()?[5],
        gender: SessionPref.getNIDA()?[13],
        investorPhone: SessionPref.getUserProfile()?[4],
        mname: SessionPref.getNIDA()?[6],
        nationality: "Tanzanian",
        // kinEmail: kinEmail.text,
        // nextKinMobile: _kinPhoneNumber.phoneNumber,
        nida: SessionPref.getNIDA()?[7],
        // passportSizeDoc: passportDoc,
        // kinRelationship: relationship,
        signatureDoc: signatureDoc,
        // tinNumber: tinNumber,
        // tinDoc: tinDoc,
        title: investorTitle,
        banckAcNo: accNumber.text,
        bank: bankName,
        bankAcName: accName.text,
        // bankBranch: branchName.text,
        dseAccount: dseCDS,
        sourceOfIncome: sourceOfIncome,
        district: district,
        placeOfBirth: (SessionPref.getNIDA()?[8] != null &&
                SessionPref.getNIDA()?[8] != "")
            ? "${SessionPref.getNIDA()?[8]}"
            : pob,
        region: region,
        ward: ward,
        incomeFreq: incomeFreq,
        // other: other.text.isEmpty ? "NOT PROVIDED" : other.text,
      );

      final response =
          await Waiter().submitKYC(userkyc: userkyc, mp: mp, context: context);

      // Remove loading dialog
      Navigator.pop(context);

      if (!response['success']) {
        if (response['errors'] != null) {
          // Show specific validation errors
          String errorMessage = '';
          final errors = response['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            errorMessage += '• ${value.join('\n')}\n';
          });
          showErrorWithoutKeyboard("Validation Error", errorMessage.trim());
        } else {
          // Show general error message
          showErrorWithoutKeyboard(
              "KYC Submission Failed",
              response['message'] ??
                  "There was an error submitting your KYC. Please try again.");
        }
        return;
      }

      // Success case
      await Future.wait<void>([
        SessionPref.clearNIDA(),
        clearFormState(),
      ]);

      await _updateProfileStatus("submitted");

      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => SuccessScreen(
                  btn: const Text(""),
                  successMessage: "KYC Submitted Successfully",
                  txtDesc:
                      "Your KYC details have been submitted successfully. Our team will review your application and get back to you shortly.",
                  screen: const LoginScreen(),
                )),
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog
      showErrorWithoutKeyboard(
          "Error", "An unexpected error occurred. Please try again later.");
      if (kDebugMode) {
        print("KYC submission error: $e");
      }
    }
  }

  // void bankForm(){
  //   if (formKey2.currentState!.validate()) {
  //       print("Bank Form Validating Testing PASSED !!");
  //   } else {
  //       print("Fail to validate Bank Form") ;
  //   }
  // }

  // void employmentForm(){
  //     if (formKey3.currentState!.validate()) {
  //       print("Employment Form Validating Testing PASSED !!");
  //   } else {
  //       print("Fail to validate Bank Form") ;
  //   }
  // }

  // ================================= FILE UPLOAD =================================

//   ======================= END OF FILE UPLOAD ==============================

  void toggled() {
    setState(() {
      isChecked = !isChecked;
    });
  }

  // when nida button clicked
  // nida button pressed
  bool resendLoading = false;

  // Add method to save form state
  Future<void> saveFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final formData = {
      'step': step,
      'title': title,
      'sourceOfIncome': sourceOfIncome,
      'gender': gender,
      'bankName': bankName,
      'incomeFreq': incomeFreq,
      'dseCDS': dseCDS,
      'region': region,
      'district': district,
      'ward': ward,
      // 'tinNumber': tinNumber,
      'pob': pob,
      'isChecked': isChecked,
      'hasDSEAccount': hasDSEAccount,
      'address': address.text,
      'other': other.text,
      'accNumber': accNumber.text,
      'accName': accName.text,
      'kinEmail': kinEmail.text,
      'kinPhoneNumber': _kinPhoneNumber.phoneNumber,
    };

    await prefs.setString('kyc_form_data', jsonEncode(formData));
  }

  // Add method to restore form state
  Future<void> restoreFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('kyc_form_data');

    if (savedData != null) {
      final Map<String, dynamic> formData = jsonDecode(savedData);

      setState(() {
        step = formData['step'] ?? 3;
        title = formData['title'] ?? "Verification";
        sourceOfIncome = formData['sourceOfIncome'];
        gender = formData['gender'];
        bankName = formData['bankName'];
        incomeFreq = formData['incomeFreq'];
        dseCDS = formData['dseCDS'];
        region = formData['region'];
        district = formData['district'];
        ward = formData['ward'];
        // tinNumber = formData['tinNumber'];
        pob = formData['pob'];
        isChecked = formData['isChecked'] ?? false;
        hasDSEAccount = formData['hasDSEAccount'] ?? 1;

        address.text = formData['address'] ?? '';
        other.text = formData['other'] ?? '';
        accNumber.text = formData['accNumber'] ?? '';
        accName.text = formData['accName'] ?? '';
        kinEmail.text = formData['kinEmail'] ?? '';

        if (formData['kinPhoneNumber'] != null) {
          _kinPhoneNumber = PhoneNumber(
            phoneNumber: formData['kinPhoneNumber'],
            isoCode: "TZ",
          );
        }
      });

      // Restore dependent dropdowns if needed
      if (region != null) {
        await fetchDistrictsData(region!);
      }
      if (district != null) {
        await fetchWardsData(district!);
      }
    }
  }

  // Clear form state when KYC is submitted successfully
  Future<void> clearFormState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kyc_form_data');
  }

  void _showCDSInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColor().blueBTN),
              const SizedBox(width: 10),
              const Text('DSE CDS Number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A CDS (Central Depository System) account number is required to trade on the Dar es Salaam Stock Exchange (DSE) platform.',
                  style: TextStyle(
                    color: AppColor().textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'To obtain a CDS account:',
                  style: TextStyle(
                    color: AppColor().textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Open a securities account with a licensed Dealing Member (stockbroking firm)',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                      Text(
                        '• Complete KYC requirements with your chosen broker',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                      Text(
                        '• Your broker will be your main point of contact for trading',
                        style:
                            TextStyle(color: AppColor().textColor, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: AppColor().blueBTN, fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double appHeight = MediaQuery.of(context).size.height;
    final double appWidth = MediaQuery.of(context).size.width;
    final metadataProvider = Provider.of<MetadataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (step > 3) {
              setState(() {
                step--;
                // Update title based on step
                switch (step) {
                  case 3:
                    title = "Verification";
                    break;
                  case 4:
                    title = "Additional Details";
                    break;
                  case 5:
                    title = "Additional Details";
                    break;
                  case 6:
                    title = "Additional Details";
                    break;
                }
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColor().textColor,
            size: 20,
          ),
        ),
        backgroundColor: AppColor().bgLight,
        title: Text(
          title,
          style: TextStyle(
            color: AppColor().textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping anywhere outside input fields
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior
            .translucent, // Ensures taps are caught even on transparent areas
        child: Stack(
          children: [
            // Background Container
            Container(
              height: appHeight,
              width: appWidth,
              decoration: BoxDecoration(
                gradient: AppColor().appGradient,
              ),
            ),

            // Content with Fixed Progress Indicator
            Column(
              children: [
                // Fixed Progress Indicator
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 20,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: (index + 3 <= step)
                              ? AppColor().blueBTN
                              : AppColor().grayText.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                        .onDrag, // Dismiss keyboard on drag
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildCurrentStep(
                          appHeight, appWidth, metadataProvider),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
      double appHeight, double appWidth, MetadataProvider metadataProvider) {
    const formPadding = EdgeInsets.only(bottom: 20);
    final sectionTitleStyle = TextStyle(
      color: AppColor().textColor,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    final sectionDivider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColor().grayText.withOpacity(0.2)),
    );

    switch (step) {
      case 3:
        return Form(
          key: formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Personal Information", style: sectionTitleStyle),
              const SizedBox(height: 20),
              Padding(
                padding: formPadding,
                child: CustomTextfield().idVerification(
                  "e.g: 19990412111230005690",
                  "NIDA*",
                  20,
                  SessionPref.getNIDA()?[7],
                  TextInputType.number,
                  true,
                  (val) => nida = val,
                ),
              ),
              // ...continue with other fields...
              Padding(
                padding: formPadding,
                child: staticCustomField(
                  "Select Your Title",
                  "Title*",
                  TextInputType.name,
                  ["Mr", "Mrs", "Miss", "Ms"],
                  (val) => investorTitle = val,
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameWithValue(
                  "",
                  "Name*",
                  TextInputType.name,
                  true,
                  (val) {},
                  "${SessionPref.getNIDA()?[4]}  ${SessionPref.getNIDA()?[5]}",
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameWithValue(
                  "",
                  "Phone number*",
                  TextInputType.name,
                  true,
                  (val) {},
                  SessionPref.getUserProfile()?[4],
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameWithValue(
                  "",
                  "Date Of Birth*",
                  TextInputType.name,
                  true,
                  (val) {},
                  SessionPref.getNIDA()?[3],
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameWithValue(
                  "",
                  "Place Of Birth*",
                  TextInputType.name,
                  SessionPref.getNIDA()?[8] != null &&
                          SessionPref.getNIDA()?[8] != ""
                      ? true
                      : false,
                  (val) => pob = val,
                  SessionPref.getNIDA()?[8],
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameWithValue(
                  "",
                  "Gender*",
                  TextInputType.name,
                  true,
                  (val) {},
                  SessionPref.getNIDA()?[13],
                ),
              ),
              Padding(
                padding: formPadding,
                child: customDropdownField(
                  "Select Your Region",
                  "Region*",
                  TextInputType.name,
                  regions,
                  (val) {
                    setState(() {
                      region = val.id;
                      // Clear dependent fields when region changes
                      district = null;
                      ward = null;
                    });
                    fetchDistrictsData(val.id);
                  },
                ),
              ),
              if (districts.isNotEmpty)
                Padding(
                  padding: formPadding,
                  child: customDropdownField(
                    "Select Your District",
                    "District*",
                    TextInputType.name,
                    districts,
                    (val) {
                      setState(() {
                        district = val.id;
                        ward = null;
                      });
                      fetchWardsData(val.id);
                    },
                  ),
                ),
              if (wards.isNotEmpty)
                Padding(
                  padding: formPadding,
                  child: customDropdownField(
                    "Select Your Ward",
                    "Ward*",
                    TextInputType.name,
                    wards,
                    (val) => ward = val.id,
                  ),
                ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameC(
                  "e.g: 429 Mahando Street, Masaki, DSM",
                  "Current Residential Address*",
                  TextInputType.name,
                  address,
                  (val) {},
                ),
              ),
              SizedBox(height: appHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (val) => toggled(),
                  ),
                  SizedBox(
                    width: appWidth * 0.7,
                    child: Text(
                      "I provide consest for conducting eKYC using NIDA. I understand that this process is necessary for identification verification and access to services, I agree to the collection and use of my personal data",
                      style: TextStyle(
                        color: AppColor().grayText,
                      ),
                    ),
                  ),
                ],
              ),
              largeBTN(
                appWidth,
                "Continue",
                AppColor().blueBTN,
                isChecked
                    ? () =>
                        validateForm("NIDA", formKey1, 4, "Additional Details")
                    : null,
              ),
            ],
          ),
        );

      case 4:
        // Modify to show bank details only
        return Form(
          key: formKey3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bank Account Details", style: sectionTitleStyle),
              const SizedBox(height: 20),
              Padding(
                padding: formPadding,
                child: customDropdownField(
                  "Select Your Bank",
                  "Bank Name*",
                  TextInputType.name,
                  metadataProvider.metadatabank,
                  (val) => setState(() => bankName = val.id),
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameC(
                  "Enter Account Number",
                  "Bank Account Number*",
                  TextInputType.number,
                  accNumber,
                  (val) {},
                ),
              ),
              Padding(
                padding: formPadding,
                child: CustomTextfield().nameC(
                  "Enter Account Name",
                  "Bank Account Name*",
                  TextInputType.name,
                  accName,
                  (val) {},
                ),
              ),
              // Income related fields
              Padding(
                padding: formPadding,
                child: customDropdownField(
                  "Select Your Source Of Income",
                  "Source Of Income*",
                  TextInputType.name,
                  metadataProvider.metadataincome,
                  (val) => sourceOfIncome = val.id,
                ),
              ),
              Padding(
                padding: formPadding,
                child: customDropdownField(
                  "Select Your Income Range",
                  "Annual Income Range*",
                  TextInputType.name,
                  metadataProvider.metadataincomefreq,
                  (val) => incomeFreq = val.id,
                ),
              ),
              sectionDivider,
              largeBTN(
                appWidth,
                "Continue",
                AppColor().blueBTN,
                isChecked
                    ? () =>
                        validateForm("BANK", formKey3, 5, "Additional Details")
                    : null,
              ),
            ],
          ),
        );

      case 5:
        // Modified to show document upload section (previously case 6)
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Form(
            key: formKey5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Please update your DSE CDS number to be able to make investments through the iTrust App",
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  const SizedBox(height: 20),
                  Text("Do you have a DSE Account?", style: sectionTitleStyle),
                  const SizedBox(height: 20),
                  RadioListTile(
                    value: 1,
                    groupValue: hasDSEAccount,
                    onChanged: (val) => setState(() => hasDSEAccount = val!),
                    title: Text(
                      "Yes",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                  ),
                  RadioListTile(
                    value: 0,
                    groupValue: hasDSEAccount,
                    onChanged: (val) => setState(() => hasDSEAccount = val!),
                    title: Text(
                      "No",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                  ),
                  if (hasDSEAccount == 1)
                    Padding(
                      padding: formPadding,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextfield().idVerification(
                              "Enter Your DSE CDS Number",
                              "",
                              6,
                              "",
                              TextInputType.number,
                              false,
                              (val) => dseCDS = val,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: AppColor().blueBTN,
                              size: 24,
                            ),
                            onPressed: _showCDSInfoDialog,
                            tooltip: 'What is a DSE CDS Number?',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (isRotate)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColor().blueBTN,
                      ),
                    ),
                  sectionDivider,
                  largeBTN(
                    appWidth,
                    "Confirm",
                    AppColor().blueBTN,
                    () => submitForm(appwidth: appWidth, mp: metadataProvider),
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// Add these extension methods for consistent styling
extension StyleExtensions on Widget {
  Widget withPadding([EdgeInsets padding = const EdgeInsets.only(bottom: 20)]) {
    return Padding(padding: padding, child: this);
  }

  Widget withAnimation() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: this,
    );
  }
}
