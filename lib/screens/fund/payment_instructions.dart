import 'package:flutter/material.dart';

class PaymentInstructionsScreen extends StatefulWidget {
  final String paymentMethod;

  const PaymentInstructionsScreen({super.key, required this.paymentMethod});

  @override
  State<PaymentInstructionsScreen> createState() =>
      _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState extends State<PaymentInstructionsScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late List<Map<String, String>> _steps;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _steps = [
      {
        'title': 'Step 1: Open Airtel App',
        'description':
            'Unlock your phone and locate the Airtel app on your home screen. Tap on the Airtel app to open it.',
      },
      {
        'title': 'Step 2: Log In to Airtel',
        'description':
            'Enter your Airtel number and password, or use fingerprint or FAce ID if enabled for quicker access.',
      },
      {
        'title': 'Step 3: Navigate to the Wallet Section',
        'description':
            'Once logged in, go to the "Wallet" or "Pay" section from the main menu.This is where you can top up your wallet.',
      },
      {
        'title': 'Step 4: Choose the Recharge Amount',
        'description':
            'Select the recharge amount you wish to add to your Itrust wallet. You can choose from available denominations or enter a custom amount.',
      },
      {
        'title': 'Step 5: Confirm Payment Method',
        'description':
            'Choose your preferred payment method, such as Airtel Money , bank trasnfer, or UPI.',
      },
      {
        'title': 'Step 6: Complete the Payment',
        'description':
            'Enter your payment details, such as PIN or OTP, to confirm the transaction.',
      },
      {
        'title': 'Step 7: Success',
        'description':
            'Once your transaction is successful, you will see a confirmation message. Your Itrust wallet will now be rcharged.',
      },
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _animationController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _currentStep++;
        });
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _currentStep--;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge Itrust Wallet'),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color:  Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(child: _buildStepIndicator()),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Colors.amber.shade200
                            : const Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _steps[index]['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Visibility(
                              key: ValueKey<int>(index),
                              visible: index == _currentStep,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_steps[index]['description']!
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      _steps[index]['description']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w100,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index == _currentStep)
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: _buildNavigationButtons(),
                ),
              if (index < _steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 16,
                    width: 1.5,
                    color: index < _currentStep
                        ? const Color(0xFFF9D5A4)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: _previousStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: _currentStep < _steps.length - 1
              ? const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                )
              : const Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
        ),
      ],
    );
  }
}
