import 'dart:convert';
import 'dart:io';
import 'package:iwealth/screens/user/verification_ongoing_screen.dart';
import 'package:iwealth/widgets/app_button.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/screens/user/identy_finger.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricVerificationScreen extends StatefulWidget {
  final String nin;
  final String? selectedHand;

  const BiometricVerificationScreen({
    super.key,
    required this.nin,
    this.selectedHand,
  });

  @override
  State<BiometricVerificationScreen> createState() =>
      _BiometricVerificationScreenState();
}

class _BiometricVerificationScreenState
    extends State<BiometricVerificationScreen> with TickerProviderStateMixin {
  String? selectedHand;
  bool isCapturing = false;
  bool hasConfiguredMissingFingers = false;
  Map<String, List<String>> missingFingers = {
    'left': [],
    'right': [],
  };

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    selectedHand = widget.selectedHand;
    _initializeAnimations();
    _loadMissingFingerConfiguration();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadMissingFingerConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final leftMissing = prefs.getStringList('missing_fingers_left') ?? [];
      final rightMissing = prefs.getStringList('missing_fingers_right') ?? [];

      setState(() {
        missingFingers['left'] = leftMissing;
        missingFingers['right'] = rightMissing;
        hasConfiguredMissingFingers =
            leftMissing.isNotEmpty || rightMissing.isNotEmpty;
      });

      _startBiometricCapture();

      if (kDebugMode) {
        print(
            'Loaded missing fingers - Left: $leftMissing, Right: $rightMissing');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading missing finger configuration: $e');
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColor().white,
        leading: IconButton(
          onPressed: isCapturing ? null : () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
        ),
        title: AppText(
          txt: "Biometric Verification",
          color: AppColor().black,
          weight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header Section
              _buildHeaderSection(),

              const SizedBox(height: 10),

              // Missing Finger Status Card
              if (hasConfiguredMissingFingers) _buildMissingFingerStatusCard(),

              const SizedBox(height: 20),

              // Hand Selection Options
              _buildHandSelectionCards(),

              const SizedBox(height: 30),

              // Instructions Card
              _buildInstructionsCard(),

              const SizedBox(height: 40),

              _buildStartCaptureButton(),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildStartCaptureButton() {
    if (!isCapturing) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: null, // Disabled during loading
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor().blueBTN.withOpacity(0.7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColor().white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                txt: "Processing Fingerprints...",
                color: AppColor().white,
                size: 16,
                weight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor().blueBTN.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: AppColor().blueBTN,
                  size: 40,
                ),
              ),
            );
          },
        ),
        AppText(
          txt: "Choose Hand for Verification",
          size: 24,
          weight: FontWeight.w600,
          color: AppColor().black,
          align: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMissingFingerStatusCard() {
    int totalMissing =
        missingFingers['left']!.length + missingFingers['right']!.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().blueBTN.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor().blueBTN.withOpacity(0.2)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  txt: "Missing Finger Configuration",
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColor().blueBTN,
                ),
                const SizedBox(height: 4),
                AppText(
                  txt: totalMissing > 0
                      ? "$totalMissing finger(s) configured as missing"
                      : "No missing fingers configured",
                  size: 12,
                  color: AppColor().grayText,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            // onPressed: _showMissingFingerSettings(value),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: AppText(
              txt: "Edit",
              size: 12,
              color: AppColor().blueBTN,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandSelectionCards() {
    return Column(
      children: [
        _buildHandOption(
          "Left Hand",
          "left",
          Icons.back_hand,
          selectedHand == "left",
        ),
        const SizedBox(height: 16),
        _buildHandOption(
          "Right Hand",
          "right",
          Icons.front_hand,
          selectedHand == "right",
        ),
      ],
    );
  }

  Widget _buildHandOption(
      String title, String value, IconData icon, bool isSelected) {
    int availableFingers = 4 - missingFingers[value]!.length;
    bool canCapture = true;

    return GestureDetector(
      onTap: canCapture && !isCapturing
          ? () {
              setState(() {
                selectedHand = value;
              });
              _showMissingFingerSettings(value);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor().blueBTN.withOpacity(0.1)
              : AppColor().gray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor().blueBTN : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColor().blueBTN : AppColor().white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColor().white : AppColor().grayText,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        txt: title,
                        size: 16,
                        weight: FontWeight.w600,
                        color:
                            isSelected ? AppColor().blueBTN : AppColor().black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (missingFingers[value]!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText(
                      txt: "Available: $availableFingers finger(s)",
                      size: 11,
                      color: availableFingers > 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      weight: FontWeight.w500,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected && canCapture)
              Icon(
                Icons.check_circle,
                color: AppColor().blueBTN,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor().blueBTN.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor().blueBTN.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: AppColor().blueBTN, size: 20),
              const SizedBox(width: 8),
              AppText(
                txt: "Capture Instructions:",
                size: 14,
                weight: FontWeight.w600,
                color: AppColor().blueBTN,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            txt: "• Camera will open automatically for fingerprint capture\n"
                "• Position your selected hand in front of the camera\n"
                "• Keep your hand steady during the scan\n"
                "• Ensure good lighting for better results\n"
                "• Only available fingers will be scanned\n"
                "• Follow any on-screen guidance during capture",
            size: 12,
            color: AppColor().textColor,
          ),
        ],
      ),
    );
  }

  void _showMissingFingerSettings(String value) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MissingFingerSettingsBottomSheet(
        onSettingsChanged: () {
          _loadMissingFingerConfiguration();
        },
        onContinueToCapture: () {
          _startBiometricCapture();
        },
        value: value,
      ),
    );
  }

  Future<void> _startBiometricCapture() async {
    if (selectedHand == null || isCapturing) return;

    setState(() {
      isCapturing = true;
    });

    try {
      final up = Provider.of<UserProvider>(context, listen: false);

      // Check camera permission
      if (Platform.isAndroid) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            if (mounted) {
              AppSnackbar(
                isError: true,
                response:
                    "Camera permission is required for fingerprint capture. Please enable it in settings.",
              ).show(context);
            }
            setState(() {
              isCapturing = false;
            });
            return;
          }
        }
      }

      // Start the capture process
      final result = await _captureFingerprint();

      if (result == null || result.isEmpty) {
        setState(() {
          isCapturing = false;
        });
        if (mounted) {
          AppSnackbar(
            isError: true,
            response: "No fingerprint data received. Please try again.",
          ).show(context);
        }
        return;
      }

      // Process the captured fingerprints (this will handle its own loading states)
      await _processFingerprints(result, up);
    } catch (e) {
      setState(() {
        isCapturing = false;
      });
      if (kDebugMode) {
        print('Error during biometric capture: $e');
      }
      if (mounted) {
        AppSnackbar(
          isError: true,
          response:
              "An error occurred during fingerprint capture. Please try again.",
        ).show(context);
      }
    }
  }

  Future<Map<String, String>?> _captureFingerprint() async {
    try {
      dynamic rawResult;
      if (Platform.isAndroid) {
        const platform = MethodChannel("identy_finger");
        final captureData = {
          'hand': selectedHand,
          'missingFingers': missingFingers[selectedHand] ?? []
        };
        rawResult = await platform.invokeMethod('capture', captureData);

        if (rawResult is Map) {
          return Map<String, String>.from(rawResult.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ));
        }
      } else if (Platform.isIOS) {
        rawResult = await IdentyFinger.capture(selectedHand!);
      }

      if (rawResult == null) return null;

      if (kDebugMode) {
        print("Raw capture result: $rawResult");
      }

      if (rawResult is String) {
        try {
          final decoded = jsonDecode(rawResult);
          if (decoded is Map) {
            return Map<String, String>.from(decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ));
          }
        } catch (e) {
          if (kDebugMode) {
            print("Failed to parse result: $e");
          }
          return {"R1": rawResult.toString()};
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Capture error: $e");
      }
      return null;
    }
  }

  Future<void> _processFingerprints(
      Map<String, String> result, UserProvider up) async {
    bool success = false;
    dynamic verificationData;
    String lastErrorMessage = "";

    for (final entry in result.entries) {
      final fingerCode = entry.key;
      final fingerImage = entry.value.toString();

      if (fingerCode.isEmpty || fingerImage.isEmpty) {
        continue;
      }

      try {
        final verificationResult = await Waiter().nidaBioVerification(
            widget.nin, fingerCode, fingerImage, up, context, true);

        if (verificationResult.status == 'success') {
          success = true;
          verificationData = verificationResult.data;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationOngoingScreen(
                nin: widget.nin,
                verificationData: verificationData,
              ),
            ),
          );
          return;
        } else {
          lastErrorMessage =
              verificationResult.message ?? "Verification failed";
        }
      } catch (e) {
        lastErrorMessage = "Verification failed for finger $fingerCode: $e";
        // Continue to next finger
      }
    }

    setState(() {
      isCapturing = false;
    });

    if (lastErrorMessage.isNotEmpty) {
      AppSnackbar(
        isError: true,
        response: "Unable to verify any fingerprints. Please try again.",
      ).show(context);
    } else {
      AppSnackbar(
        isError: true,
        response: "Unable to verify any fingerprints. Please try again.",
      ).show(context);
    }
  }
}

class MissingFingerSettingsBottomSheet extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  final VoidCallback? onContinueToCapture;
  final String value;

  const MissingFingerSettingsBottomSheet(
      {super.key,
      required this.onSettingsChanged,
      this.onContinueToCapture,
      required this.value});

  @override
  State<MissingFingerSettingsBottomSheet> createState() =>
      _MissingFingerSettingsBottomSheetState();
}

class _MissingFingerSettingsBottomSheetState
    extends State<MissingFingerSettingsBottomSheet> {
  Map<String, List<String>> missingFingers = {
    'left': [],
    'right': [],
  };

  final Map<String, String> fingerNames = {
    'index': 'Index Finger',
    'middle': 'Middle Finger',
    'ring': 'Ring Finger',
    'little': 'Little Finger',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        missingFingers['left'] =
            prefs.getStringList('missing_fingers_left') ?? [];
        missingFingers['right'] =
            prefs.getStringList('missing_fingers_right') ?? [];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading missing finger settings: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('=== FLUTTER DEBUG: Saving missing finger config ===');
      print('Saving left missing: ${missingFingers['left']}');
      print('Saving right missing: ${missingFingers['right']}');
      await prefs.setStringList(
          'missing_fingers_left', missingFingers['left']!);
      await prefs.setStringList(
          'missing_fingers_right', missingFingers['right']!);

      final savedLeft = prefs.getStringList('missing_fingers_left') ?? [];
      final savedRight = prefs.getStringList('missing_fingers_right') ?? [];
      print('Verified saved left: $savedLeft');
      print('Verified saved right: $savedRight');
      print('=== END FLUTTER DEBUG ===');

      widget.onSettingsChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Missing finger settings saved'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving missing finger settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      txt: "Missing Finger Configuration",
                      size: 18,
                      weight: FontWeight.w600,
                      color: AppColor().black,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor().blueBTN.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColor().blueBTN.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColor().blueBTN, size: 20),
                                const SizedBox(width: 8),
                                AppText(
                                  txt: "Instructions",
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: AppColor().blueBTN,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AppText(
                              txt:
                                  "Select any fingers that are missing, injured, or cannot be scanned. "
                                  "Only the available fingers will be used for verification.",
                              size: 12,
                              color: AppColor().textColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (widget.value == 'left')
                        _buildHandSection('left', 'Left Hand', Icons.back_hand),

                      const SizedBox(height: 24),

                      if (widget.value == 'right')
                        _buildHandSection(
                            'right', 'Right Hand', Icons.front_hand),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearAllSettings,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: AppColor().orangeApp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: AppText(
                                txt: "Clear All",
                                color: AppColor().orangeApp,
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _saveSettings();
                                Navigator.pop(context);
                                // Trigger the capture process
                                widget.onContinueToCapture?.call();
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: AppColor().blueBTN),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: AppText(
                                txt: "Start Capture",
                                color: AppColor().blueBTN,
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     _saveSettings();
                          //     Navigator.pop(context);
                          //     // Trigger the capture process
                          //     widget.onContinueToCapture?.call();
                          //   },
                          //   child: const Text(
                          //     "Start Capture",
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.w600,
                          //       letterSpacing: 1,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandSection(String hand, String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColor().blueBTN, size: 24),
            const SizedBox(width: 8),
            AppText(
              txt: title,
              size: 16,
              weight: FontWeight.w600,
              color: AppColor().black,
            ),
            const Spacer(),
            AppText(
              txt: "${4 - missingFingers[hand]!.length}/4 available",
              size: 12,
              color: AppColor().grayText,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...fingerNames.entries.map((entry) {
          String fingerKey = entry.key;
          String fingerName = entry.value;
          bool isMissing = missingFingers[hand]!.contains(fingerKey);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    if (isMissing) {
                      missingFingers[hand]!.remove(fingerKey);
                    } else {
                      missingFingers[hand]!.add(fingerKey);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMissing
                        ? Colors.red.withOpacity(0.05)
                        : Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMissing
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMissing
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        color: isMissing
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          txt: fingerName,
                          size: 14,
                          color: AppColor().black,
                        ),
                      ),
                      AppText(
                        txt: isMissing ? "Missing" : "Available",
                        size: 12,
                        color: isMissing
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    int totalMissing =
        missingFingers['left']!.length + missingFingers['right']!.length;
    int totalAvailable = 8 - totalMissing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().gray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            txt: "Summary",
            size: 14,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                txt: "Total fingers available:",
                size: 12,
                color: AppColor().grayText,
              ),
              AppText(
                txt: "$totalAvailable/8",
                size: 12,
                weight: FontWeight.w600,
                color: totalAvailable > 0
                    ? Colors.green.shade600
                    : Colors.red.shade600,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                txt: "Left hand available:",
                size: 12,
                color: AppColor().grayText,
              ),
              AppText(
                txt: "${4 - missingFingers['left']!.length}/4",
                size: 12,
                weight: FontWeight.w500,
                color: AppColor().black,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                txt: "Right hand available:",
                size: 12,
                color: AppColor().grayText,
              ),
              AppText(
                txt: "${4 - missingFingers['right']!.length}/4",
                size: 12,
                weight: FontWeight.w500,
                color: AppColor().black,
              ),
            ],
          ),
          if (totalAvailable == 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      txt: "No fingers available for verification",
                      size: 11,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearAllSettings() {
    setState(() {
      missingFingers['left']!.clear();
      missingFingers['right']!.clear();
    });
  }
}

extension StringCapitalization on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
