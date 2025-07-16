import 'package:flutter/material.dart';
import 'package:iwealth/screens/user/employment_information_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/models/sector.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController branchController =
      TextEditingController(text: 'Tanzania');

  String? selectedBankId;
  bool isButtonEnabled = false;
  bool isLoadingBanks = true;
  List<Metadata> banks = [];

  @override
  void initState() {
    super.initState();
    accountNumberController.addListener(_checkFormCompletion);
    accountNameController.addListener(_checkFormCompletion);
    branchController.addListener(_checkFormCompletion);
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    try {
      final metadataProvider =
          Provider.of<MetadataProvider>(context, listen: false);

      if (kDebugMode) {
        print("Loading banks from API...");
      }

      final result = await Waiter().getSectors("bank", metadataProvider);

      if (result == "1") {
        setState(() {
          banks = metadataProvider.metadatabank;
          isLoadingBanks = false;
        });

        if (kDebugMode) {
          print("Banks loaded successfully: ${banks.length} banks");
        }
      } else {
        setState(() {
          isLoadingBanks = false;
        });

        if (kDebugMode) {
          print("Failed to load banks");
        }
      }
    } catch (e) {
      setState(() {
        isLoadingBanks = false;
      });

      if (kDebugMode) {
        print("Error loading banks: $e");
      }
    }
  }

  void _checkFormCompletion() {
    setState(() {
      isButtonEnabled = accountNumberController.text.isNotEmpty &&
          accountNameController.text.isNotEmpty &&
          branchController.text.isNotEmpty &&
          selectedBankId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColor().white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "Additional Details",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Header with progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            txt: "Enter Bank Details",
                            size: 18,
                            weight: FontWeight.w600,
                            color: AppColor().black,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 120,
                            color: AppColor().blueBTN,
                          ),
                        ],
                      ),
                      AppText(
                        txt: "1/4",
                        size: 16,
                        color: AppColor().grayText,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Account Number
                  AppText(
                    txt: "Account Number",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor().gray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter your Account Number",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        formKey.currentState?.validate();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account number';
                        }
                        if (value.length > 25) {
                          return 'Please enter valid account number';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Name
                  AppText(
                    txt: "Account Name",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor().gray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: accountNameController,
                      decoration: InputDecoration(
                        hintText: "Enter your Account Name",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        formKey.currentState?.validate();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account name';
                        }
                        if (value.length > 191) {
                          return 'Please enter valid name';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  AppText(
                    txt: "Bank Name",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor().gray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isLoadingBanks
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColor().blueBTN,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppText(
                                    txt: "Loading banks...",
                                    color: AppColor().grayText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedBankId,
                            isExpanded: true, // Prevents overflow
                            decoration: InputDecoration(
                              hintText: banks.isEmpty
                                  ? "No banks available"
                                  : "Select A Bank",
                              hintStyle: TextStyle(color: AppColor().grayText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            menuMaxHeight:
                                300, // Custom height for dropdown list
                            items: banks.map((bank) {
                              return DropdownMenuItem(
                                value: bank.id,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    bank.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: banks.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedBankId = value;
                                      _checkFormCompletion();
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a bank';
                              }
                              return null;
                            },
                            dropdownColor: Colors.white,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor().grayText,
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // AppText(
                  //   txt: "Branch Name",
                  //   size: 14,
                  //   weight: FontWeight.w500,
                  //   color: AppColor().black,
                  // ),
                  // const SizedBox(height: 8),
                  Visibility(
                    visible: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor().gray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: branchController,
                        decoration: InputDecoration(
                          hintText: "Enter Branch Name (Dar es Salaam)",
                          hintStyle: TextStyle(color: AppColor().grayText),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter branch name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  // Find the selected bank name from the ID
                                  String selectedBankName = banks
                                      .firstWhere(
                                        (bank) => bank.id == selectedBankId,
                                        orElse: () => Metadata(
                                            id: selectedBankId!,
                                            name: "Unknown Bank"),
                                      )
                                      .name;

                                  // Collect bank details and pass to next screen
                                  Map<String, dynamic> bankDetails = {
                                    'accountNumber':
                                        accountNumberController.text,
                                    'accountName': accountNameController.text,
                                    'bankId': selectedBankId,
                                    'bankName': selectedBankName,
                                    'branchName': branchController.text,
                                  };

                                  if (kDebugMode) {
                                    print(
                                        "Bank details collected: $bankDetails");
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EmploymentInfoScreen(
                                        bankDetails: bankDetails,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled
                              ? AppColor().blueBTN
                              : AppColor().blueBTN.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: isButtonEnabled ? 3 : 0,
                        ),
                        child: AppText(
                          txt: "Continue",
                          color: AppColor().white,
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    accountNameController.dispose();
    branchController.dispose();
    super.dispose();
  }
}
