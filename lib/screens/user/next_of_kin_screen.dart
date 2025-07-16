import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/models/sector.dart';
import 'package:iwealth/screens/user/tin_dse_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class NextOfKinScreen extends StatefulWidget {
  final Map<String, dynamic>? bankDetails;
  final Map<String, dynamic>? employmentDetails;
  final String title;

  const NextOfKinScreen({
    super.key,
    this.bankDetails,
    this.employmentDetails,
    required this.title
  });

  @override
  State<NextOfKinScreen> createState() => _NextOfKinScreenState();
}

class _NextOfKinScreenState extends State<NextOfKinScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedRelationship;
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'TZ', dialCode: '+255');
  bool isButtonEnabled = false;
  String? relationshipId;
  List<Metadata> relationships = [];
  bool isRelationships = true;

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_checkFormCompletion);
    phoneController.addListener(_checkFormCompletion);
    _loadRelationships();
  }

  Future<void> _loadRelationships() async {
    try {
      final metadataProvider =
          Provider.of<MetadataProvider>(context, listen: false);

      if (kDebugMode) {
        print("Loading relationships from API...");
      }
      print("==========${metadataProvider.metadatarelation}===========");

      if (metadataProvider.metadatarelation != null) {
        setState(() {
          relationships = metadataProvider.metadatarelation!;
          isRelationships = false;
        });

        if (kDebugMode) {
          print(
              "relationships loaded successfully: ${relationships.length} relationships");
        }
      } else {
        setState(() {
          isRelationships = false;
        });

        if (kDebugMode) {
          print("Failed to load relationships");
        }
      }
    } catch (e) {
      setState(() {
        isRelationships = false;
      });

      if (kDebugMode) {
        print("Error loading relationships: $e");
      }
    }
  }

  void _checkFormCompletion() {
    setState(() {
      isButtonEnabled = fullNameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          selectedRelationship != null;
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TINDSEScreen(
                    bankDetails: widget.bankDetails,
                    employmentDetails: widget.employmentDetails,
                    nextOfKinDetails: null,
                    title: widget.title, // Skip next of kin
                  ),
                ),
              );
            },
            child: AppText(
              txt: 'Skip',
              size: 18,
              color: AppColor().blueBTN,
            ),
          ),
        ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            txt: "Enter Next of Kin Information",
                            size: 18,
                            weight: FontWeight.w600,
                            color: AppColor().black,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 200,
                            color: AppColor().blueBTN,
                          ),
                        ],
                      ),
                      AppText(
                        txt: "3/4",
                        size: 16,
                        color: AppColor().grayText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppText(
                    txt: "Next of Kin's Full Name",
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
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: "Enter Full Name",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter next of kin full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppText(
                    txt: "Relationship",
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
                    child: isRelationships
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
                                    txt: "Loading relationships...",
                                    color: AppColor().grayText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedRelationship,
                            isExpanded: true, // Prevents overflow
                            decoration: InputDecoration(
                              hintText: relationships.isEmpty
                                  ? "No relationship available"
                                  : "Select A Relationship",
                              hintStyle: TextStyle(color: AppColor().grayText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            menuMaxHeight:
                                300, // Custom height for dropdown list
                            items: relationships.map((bank) {
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
                            onChanged: relationships.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedRelationship = value;
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
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColor().gray,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: DropdownButtonFormField<String>(
                  //     value: selectedRelationship,
                  //     decoration: InputDecoration(
                  //       hintText: "Select a Relationship",
                  //       hintStyle: TextStyle(color: AppColor().grayText),
                  //       border: InputBorder.none,
                  //       contentPadding: const EdgeInsets.all(16),
                  //     ),
                  //     items: relationships.map((relationship) {
                  //       return DropdownMenuItem(
                  //           value: relationship,
                  //           child: Text(relationship.toUpperCase()));
                  //     }).toList(),
                  //     onChanged: (value) {
                  //       setState(() {
                  //         selectedRelationship = value;
                  //         _checkFormCompletion();
                  //       });
                  //     },
                  //     validator: (value) {
                  //       if (value == null) {
                  //         return 'Please select relationship';
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  AppText(
                    txt: "Next of Kin's Mobile Number",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColor().gray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          txt: "+255",
                          size: 14,
                          color: AppColor().textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor().gray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Enter Mobile Number",
                              hintStyle: TextStyle(color: AppColor().grayText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            onChanged: (value) {
                              formKey.currentState?.validate();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length < 9) {
                                return 'Please enter valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppText(
                    txt: "Next of Kin's Email ID  (Optional)",
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
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter Email ID",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter valid email';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Map<String, dynamic>? nextOfKinDetails;

                          if (fullNameController.text.isNotEmpty ||
                              phoneController.text.isNotEmpty) {
                            nextOfKinDetails = {
                              'fullName': fullNameController.text,
                              'relationship': selectedRelationship
                                      .toString()
                                      .toLowerCase() ??
                                  '',
                              'phoneNumber': '+255${phoneController.text}',
                              'email': emailController.text,
                            };
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TINDSEScreen(
                                bankDetails: widget.bankDetails,
                                employmentDetails: widget.employmentDetails,
                                nextOfKinDetails: nextOfKinDetails, title: widget.title,
                              ),
                            ),
                          );
                        },
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
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
