import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissingFingerManagementScreen extends StatefulWidget {
  const MissingFingerManagementScreen({super.key});

  @override
  State<MissingFingerManagementScreen> createState() =>
      _MissingFingerManagementScreenState();
}

class _MissingFingerManagementScreenState
    extends State<MissingFingerManagementScreen>
    with SingleTickerProviderStateMixin {
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

  late TabController _tabController;
  bool isLoading = true;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final leftMissing = prefs.getStringList('missing_fingers_left') ?? [];
      final rightMissing = prefs.getStringList('missing_fingers_right') ?? [];

      setState(() {
        missingFingers['left'] = leftMissing;
        missingFingers['right'] = rightMissing;
        isLoading = false;
        hasChanges = false;
      });

      if (kDebugMode) {
        print(
            'Loaded missing fingers - Left: $leftMissing, Right: $rightMissing');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading missing finger settings: $e');
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'missing_fingers_left', missingFingers['left']!);
      await prefs.setStringList(
          'missing_fingers_right', missingFingers['right']!);

      setState(() => hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Settings saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      if (kDebugMode) {
        print(
            'Saved missing fingers - Left: ${missingFingers['left']}, Right: ${missingFingers['right']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving missing finger settings: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Failed to save settings'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _toggleFinger(String hand, String fingerKey) {
    setState(() {
      if (missingFingers[hand]!.contains(fingerKey)) {
        missingFingers[hand]!.remove(fingerKey);
      } else {
        missingFingers[hand]!.add(fingerKey);
      }
      hasChanges = true;
    });
  }

  void _resetHand(String hand) {
    setState(() {
      missingFingers[hand]!.clear();
      hasChanges = true;
    });
  }

  void _resetAll() {
    setState(() {
      missingFingers['left']!.clear();
      missingFingers['right']!.clear();
      hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: AppText(
          txt: "Unsaved Changes",
          size: 18,
          weight: FontWeight.w600,
          color: AppColor().black,
        ),
        content: AppText(
          txt:
              "You have unsaved changes. Do you want to save them before leaving?",
          size: 14,
          color: AppColor().grayText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AppText(
              txt: "Discard",
              size: 14,
              color: AppColor().orangeApp,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppText(
              txt: "Cancel",
              size: 14,
              color: AppColor().grayText,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveSettings();
              if (mounted) Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor().blueBTN,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: AppText(
              txt: "Save",
              size: 14,
              color: AppColor().white,
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColor().white,
        appBar: AppBar(
          elevation: 3,
          backgroundColor: AppColor().white,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back_ios, color: AppColor().black, size: 20),
          ),
          title: AppText(
            txt: "Missing Finger Configuration",
            color: AppColor().black,
            weight: FontWeight.w600,
            size: 18,
          ),
          centerTitle: true,
          actions: [
            if (hasChanges)
              TextButton(
                onPressed: _saveSettings,
                child: AppText(
                  txt: "Save",
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColor().blueBTN,
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColor().blueBTN,
            unselectedLabelColor: AppColor().grayText,
            indicatorColor: AppColor().blueBTN,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.back_hand, size: 20),
                    const SizedBox(width: 8),
                    AppText(txt: "Left Hand", size: 14),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.front_hand, size: 20),
                    const SizedBox(width: 8),
                    AppText(txt: "Right Hand", size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColor().blueBTN),
                    const SizedBox(height: 16),
                    AppText(
                      txt: "Loading settings...",
                      size: 14,
                      color: AppColor().grayText,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Instructions Card
                  Container(
                    margin: const EdgeInsets.all(20),
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
                              txt: "How to Configure",
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColor().blueBTN,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          txt:
                              "Mark any fingers that are missing, injured, or cannot be scanned. During biometric verification, only the available fingers will be used for identification.",
                          size: 12,
                          color: AppColor().textColor,
                        ),
                      ],
                    ),
                  ),

                  // Tab View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHandTab('left', 'Left Hand', Icons.back_hand),
                        _buildHandTab('right', 'Right Hand', Icons.front_hand),
                      ],
                    ),
                  ),

                  // Bottom Summary and Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor().white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHandTab(String hand, String title, IconData icon) {
    List<String> missing = missingFingers[hand]!;
    int availableCount = 4 - missing.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hand Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor().gray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColor().blueBTN, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        txt: title,
                        size: 18,
                        weight: FontWeight.w600,
                        color: AppColor().black,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        txt: "$availableCount of 4 fingers available",
                        size: 14,
                        color: availableCount > 0
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                if (missing.isNotEmpty)
                  TextButton(
                    onPressed: () => _resetHand(hand),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: AppText(
                      txt: "Reset",
                      size: 12,
                      color: AppColor().orangeApp,
                      weight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Finger List
          ...fingerNames.entries.map((entry) {
            String fingerKey = entry.key;
            String fingerName = entry.value;
            bool isMissing = missing.contains(fingerKey);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggleFinger(hand, fingerKey),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMissing
                          ? Colors.red.withOpacity(0.05)
                          : Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMissing
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Status Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isMissing
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isMissing ? Icons.cancel : Icons.check_circle,
                            color: isMissing
                                ? Colors.red.shade600
                                : Colors.green.shade600,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Finger Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                txt: fingerName,
                                size: 16,
                                weight: FontWeight.w500,
                                color: AppColor().black,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                txt: isMissing
                                    ? "Will not be scanned"
                                    : "Available for scanning",
                                size: 12,
                                color: isMissing
                                    ? Colors.red.shade600
                                    : Colors.green.shade600,
                              ),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isMissing
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppText(
                            txt: isMissing ? "Missing" : "Available",
                            size: 12,
                            weight: FontWeight.w600,
                            color: isMissing
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Hand-specific warnings
          if (availableCount == 0)
            _buildWarningCard(
              "No fingers available for $title",
              "All fingers on this hand are marked as missing. Biometric verification will not be possible with this hand.",
              Colors.red,
            )
          else if (availableCount < 2)
            _buildWarningCard(
              "Limited fingers available",
              "Only $availableCount finger(s) available on this hand. Consider using the other hand if possible for better verification accuracy.",
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: AppColor().orangeApp,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  txt: title,
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColor().black,
                ),
                const SizedBox(height: 4),
                AppText(
                  txt: message,
                  size: 12,
                  color: AppColor().grayText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    int totalMissing =
        missingFingers['left']!.length + missingFingers['right']!.length;
    int totalAvailable = 8 - totalMissing;
    int leftAvailable = 4 - missingFingers['left']!.length;
    int rightAvailable = 4 - missingFingers['right']!.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().gray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                txt: "Configuration Summary",
                size: 14,
                weight: FontWeight.w600,
                color: AppColor().black,
              ),
              if (hasChanges)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor().blueBTN.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    txt: "Unsaved",
                    size: 10,
                    color: AppColor().blueBTN,
                    weight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  "Total Available",
                  "$totalAvailable/8 fingers",
                  totalAvailable > 0 ? Colors.green : Colors.red,
                  Icons.fingerprint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  "Left Hand",
                  "$leftAvailable/4 fingers",
                  leftAvailable > 0 ? Colors.green : Colors.red,
                  Icons.back_hand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  "Right Hand",
                  "$rightAvailable/4 fingers",
                  rightAvailable > 0 ? Colors.green : Colors.red,
                  Icons.front_hand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColor().grayText, size: 20),
          const SizedBox(height: 8),
          AppText(
            txt: title,
            size: 10,
            color: AppColor().grayText,
          ),
          const SizedBox(height: 2),
          AppText(
            txt: value,
            size: 12,
            weight: FontWeight.w600,
            color: AppColor().black,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (missingFingers['left']!.isNotEmpty ||
                    missingFingers['right']!.isNotEmpty)
                ? _resetAll
                : null,
            icon: Icon(
              Icons.refresh,
              size: 18,
              color: AppColor().orangeApp,
            ),
            label: AppText(
              txt: "Reset All",
              size: 14,
              color: AppColor().orangeApp,
              weight: FontWeight.w500,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColor().orangeApp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: hasChanges ? _saveSettings : null,
            icon: Icon(
              Icons.save,
              size: 18,
              color: AppColor().white,
            ),
            label: AppText(
              txt: "Save Configuration",
              size: 14,
              color: AppColor().white,
              weight: FontWeight.w600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChanges
                  ? AppColor().blueBTN
                  : AppColor().blueBTN.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: hasChanges ? 3 : 0,
            ),
          ),
        ),
      ],
    );
  }
}
