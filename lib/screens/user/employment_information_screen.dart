import 'package:flutter/material.dart';
import 'package:iwealth/screens/user/next_of_kin_screen.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/models/sector.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class EmploymentInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? bankDetails;

  const EmploymentInfoScreen({
    super.key,
    this.bankDetails,
  });

  @override
  State<EmploymentInfoScreen> createState() => _EmploymentInfoScreenState();
}

class _EmploymentInfoScreenState extends State<EmploymentInfoScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController employerNameController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();

  String employmentStatus = "Employed";
  String? selectedIncomeSourceId;
  String? selectedIncomeRange;
  String? selectedTitleId;
  bool isButtonEnabled = false;
  bool isLoadingIncomeSources = true;
  bool isLoadingTitles = true;
  List<Metadata> incomeSources = [];
  List<Metadata> titles = [];
  bool showEmployedForm = true;
  bool showSelfEmployedForm = false;
  bool showIncomeOnlyForm = false;

  // Monthly income ranges
  final List<Map<String, String>> incomeRanges = [
    {'value': '0-1m', 'label': '0 - 1,000,000 TZS'},
    {'value': '1m-5m', 'label': '1,000,000 - 5,000,000 TZS'},
    {'value': '5m-100m', 'label': '5,000,000 - 100,000,000 TZS'},
    {'value': 'above-100m', 'label': 'Above 100,000,000 TZS'},
  ];

  @override
  void initState() {
    super.initState();
    employerNameController.addListener(_checkFormCompletion);
    occupationController.addListener(_checkFormCompletion);
    sectorController.addListener(_checkFormCompletion);

    // Use postFrameCallback to ensure it works on hot reload
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncomeSources();
      _loadTitles();
    });
  }

  Future<void> _loadIncomeSources() async {
    final metadataProvider =
        Provider.of<MetadataProvider>(context, listen: false);

    // Check if data already exists
    if (metadataProvider.metadataincome != null &&
        metadataProvider.metadataincome!.isNotEmpty) {
      setState(() {
        incomeSources = metadataProvider.metadataincome!;
        isLoadingIncomeSources = false;
      });
      if (kDebugMode) {
        print("Income sources already loaded: ${incomeSources.length} sources");
      }
      _checkFormCompletion();
      return;
    }

    // Otherwise load from API
    try {
      if (kDebugMode) {
        print("Loading income sources from API...");
      }

      final result =
          await Waiter().getSourceOfIncome("source", metadataProvider);

      if (kDebugMode) {
        print("Income sources API result: '$result'");
      }

      if (result == "1") {
        setState(() {
          final incomeList = metadataProvider.metadataincome;
          incomeSources = incomeList ?? [];
          isLoadingIncomeSources = false;
        });

        if (kDebugMode) {
          print(
              "Income sources loaded successfully: ${incomeSources.length} sources");
        }
      } else {
        setState(() {
          isLoadingIncomeSources = false;
        });

        if (kDebugMode) {
          print("Failed to load income sources. API returned: '$result'");
        }
      }
      _checkFormCompletion();
    } catch (e) {
      setState(() {
        isLoadingIncomeSources = false;
      });

      if (kDebugMode) {
        print("Error loading income sources: $e");
      }
      _checkFormCompletion();
    }
  }

  Future<void> _loadTitles() async {
    final metadataProvider =
        Provider.of<MetadataProvider>(context, listen: false);

    // Check if data already exists in the provider (from cache or previous calls)
    if (metadataProvider.titles.isNotEmpty) {
      setState(() {
        titles = metadataProvider.titles;
        isLoadingTitles = false;
      });
      if (kDebugMode) {
        print("Titles already loaded from provider: ${titles.length} titles");
      }
      _checkFormCompletion();
      return;
    }

    // If no cached data, try API call but handle rate limiting
    try {
      if (kDebugMode) {
        print("Loading titles from API...");
      }

      final result = await Waiter().getTitles(metadataProvider);

      if (kDebugMode) {
        print("Titles API result: '$result'");
      }

      if (result == "1") {
        setState(() {
          titles = metadataProvider.titles;
          isLoadingTitles = false;
        });

        if (kDebugMode) {
          print("Titles loaded successfully: ${titles.length} titles");
          if (titles.isNotEmpty) {
            print("First title: ${titles.first.name}");
          }
        }
      } else {
        // API failed - check if titles were loaded by previous calls (PullMetadata)
        if (metadataProvider.titles.isNotEmpty) {
          if (kDebugMode) {
            print(
                "API failed but titles exist in provider from previous calls, using them");
          }
          setState(() {
            titles = metadataProvider.titles;
            isLoadingTitles = false;
          });
        } else {
          setState(() {
            isLoadingTitles = false;
          });
          if (kDebugMode) {
            print("Failed to load titles. API returned: '$result'");
          }
        }
      }
      _checkFormCompletion();
    } catch (e) {
      setState(() {
        isLoadingTitles = false;
      });

      if (kDebugMode) {
        print("Error loading titles: $e");
      }
      _checkFormCompletion();
    }
  }

  void _checkFormCompletion() {
    setState(() {
      bool baseRequirement = selectedIncomeSourceId != null &&
          selectedIncomeRange != null &&
          selectedTitleId != null;

      if (showEmployedForm) {
        // For employed: title, employer name, occupation, income source and income range required
        isButtonEnabled = employerNameController.text.isNotEmpty &&
            occupationController.text.isNotEmpty &&
            baseRequirement;
      } else if (showSelfEmployedForm) {
        // For self-employed: title, sector text, income source and income range required
        isButtonEnabled = sectorController.text.isNotEmpty && baseRequirement;
      } else if (showIncomeOnlyForm) {
        // For unemployed/retired: title, income source and income range required
        isButtonEnabled = baseRequirement;
      } else {
        isButtonEnabled = baseRequirement;
      }
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
                            txt: "Enter Employment Information",
                            size: 18,
                            weight: FontWeight.w600,
                            color: AppColor().black,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 180,
                            color: AppColor().blueBTN,
                          ),
                        ],
                      ),
                      AppText(
                        txt: "2/4",
                        size: 16,
                        color: AppColor().grayText,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Title field (shown for all employment statuses)
                  AppText(
                    txt: "Title",
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
                    child: isLoadingTitles
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
                                    txt: "Loading titles...",
                                    color: AppColor().grayText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedTitleId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: titles.isEmpty
                                  ? "No titles available"
                                  : "Select your Title",
                              hintStyle: TextStyle(color: AppColor().grayText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            menuMaxHeight: 250,
                            items: titles.map((title) {
                              return DropdownMenuItem(
                                value: title.id,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    title.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: titles.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedTitleId = value;
                                      _checkFormCompletion();
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your title';
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

                  AppText(
                    txt: "Employment Status",
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColor().black,
                  ),
                  const SizedBox(height: 16),

                  Column(
                    children: [
                      _buildRadioOption("Employed"),
                      _buildRadioOption("Self Employed"),
                      _buildRadioOption("Unemployed"),
                      _buildRadioOption("Retired"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Conditional form fields based on employment status
                  if (showEmployedForm) ...[
                    // Employed form: Employer name, occupation, income source
                    AppText(
                      txt: "Employer's Name",
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
                        controller: employerNameController,
                        decoration: InputDecoration(
                          hintText: "Enter your Employer's Name",
                          hintStyle: TextStyle(color: AppColor().grayText),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (showEmployedForm &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter employer name';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    AppText(
                      txt: "Present Occupation",
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
                        controller: occupationController,
                        decoration: InputDecoration(
                          hintText: "Enter your Present Occupation",
                          hintStyle: TextStyle(color: AppColor().grayText),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (showEmployedForm &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter occupation';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  if (showSelfEmployedForm) ...[
                    // Self-employed form: Sector text input
                    AppText(
                      txt: "Business Sector",
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
                        controller: sectorController,
                        decoration: InputDecoration(
                          hintText:
                              "Enter your Business Sector (Technology, Agriculture ...)",
                          hintStyle: TextStyle(color: AppColor().grayText),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (showSelfEmployedForm &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter your business sector';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  if (showIncomeOnlyForm) ...[
                    // Info message for unemployed/retired
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColor().blueBTN.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColor().blueBTN.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColor().blueBTN,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              txt:
                                  "Please specify your current source of income (savings, pension...)",
                              size: 14,
                              color: AppColor().textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Monthly Income Range (shown for all employment statuses)
                  AppText(
                    txt: "Monthly Income Range",
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
                    child: DropdownButtonFormField<String>(
                      value: selectedIncomeRange,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: "Select Monthly Income Range",
                        hintStyle: TextStyle(color: AppColor().grayText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      menuMaxHeight: 300,
                      items: incomeRanges.map((income) {
                        return DropdownMenuItem(
                          value: income['value'],
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              income['label']!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIncomeRange = value;
                          _checkFormCompletion();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your monthly income range';
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

                  // Source of Income (shown for all employment statuses)
                  AppText(
                    txt: "Source Of Income",
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
                    child: isLoadingIncomeSources
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
                                    txt: "Loading income sources...",
                                    color: AppColor().grayText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedIncomeSourceId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: incomeSources.isEmpty
                                  ? "No income sources available"
                                  : "Select your Source Of Income",
                              hintStyle: TextStyle(color: AppColor().grayText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            menuMaxHeight: 250,
                            items: incomeSources.map((source) {
                              return DropdownMenuItem(
                                value: source.id,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    source.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: incomeSources.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedIncomeSourceId = value;
                                      _checkFormCompletion();
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select income source';
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

                  const SizedBox(height: 40),

                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () {
                                // Validate forms based on employment status
                                if ((showEmployedForm ||
                                        showSelfEmployedForm ||
                                        showIncomeOnlyForm) &&
                                    !formKey.currentState!.validate()) {
                                  return; // Don't proceed if form is invalid
                                }

                                // Find the selected income source name from the ID
                                String selectedIncomeSourceName = "";
                                if (selectedIncomeSourceId != null) {
                                  selectedIncomeSourceName = incomeSources
                                      .firstWhere(
                                        (source) =>
                                            source.id == selectedIncomeSourceId,
                                        orElse: () => Metadata(
                                            id: selectedIncomeSourceId!,
                                            name: "Unknown Source"),
                                      )
                                      .name;
                                }

                                // Find the selected title name from the ID
                                String selectedTitleName = "";
                                if (selectedTitleId != null) {
                                  selectedTitleName = titles
                                      .firstWhere(
                                        (title) => title.id == selectedTitleId,
                                        orElse: () => Metadata(
                                            id: selectedTitleId!,
                                            name: "Unknown Title"),
                                      )
                                      .name;
                                }

                                // Find the selected income range label
                                String selectedIncomeLabel =
                                    incomeRanges.firstWhere(
                                  (income) =>
                                      income['value'] == selectedIncomeRange,
                                  orElse: () => {
                                    'value': selectedIncomeRange!,
                                    'label': 'Unknown Range'
                                  },
                                )['label']!;

                                // Find the selected sector name from the ID
                                String selectedSectorName = "";
                                if (showSelfEmployedForm) {
                                  selectedSectorName = sectorController.text;
                                }

                                // Collect employment details and pass to next screen
                                Map<String, dynamic> employmentDetails = {
                                  'titleId': selectedTitleId ?? "",
                                  'title': selectedTitleName,
                                  'employmentStatus': employmentStatus,
                                  'employerName': showEmployedForm
                                      ? employerNameController.text
                                      : "",
                                  'occupation': showEmployedForm
                                      ? occupationController.text
                                      : "",
                                  'sectorName': showSelfEmployedForm
                                      ? selectedSectorName
                                      : "",
                                  'sourceOfIncomeId':
                                      selectedIncomeSourceId ?? "",
                                  'sourceOfIncome': selectedIncomeSourceName,
                                  'monthlyIncomeRange': selectedIncomeRange,
                                  'monthlyIncomeLabel': selectedIncomeLabel,
                                };

                                if (kDebugMode) {
                                  print(
                                      "Employment details collected: $employmentDetails");
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NextOfKinScreen(
                                        bankDetails: widget.bankDetails,
                                        employmentDetails: employmentDetails,
                                        title: selectedTitleName),
                                  ),
                                );
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

  Widget _buildRadioOption(String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: employmentStatus,
            activeColor: AppColor().blueBTN,
            onChanged: (String? newValue) {
              setState(() {
                employmentStatus = newValue!;

                // Set form visibility based on employment status
                showEmployedForm = newValue == 'Employed';
                showSelfEmployedForm = newValue == 'Self Employed';
                showIncomeOnlyForm =
                    newValue == 'Unemployed' || newValue == 'Retired';

                // Clear all fields when changing employment status
                employerNameController.clear();
                occupationController.clear();
                sectorController.clear();
                selectedIncomeSourceId = null;
                selectedIncomeRange = null;
                selectedTitleId = null;

                _checkFormCompletion();
              });
            },
          ),
          AppText(
            txt: value,
            size: 14,
            color: AppColor().black,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    employerNameController.dispose();
    occupationController.dispose();
    sectorController.dispose();
    super.dispose();
  }
}
