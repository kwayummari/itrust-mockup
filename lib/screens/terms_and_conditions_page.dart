import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/auth/registration.dart';
import 'package:iwealth/widgets/register_now_btn.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreed = false;
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: rootBundle.loadString(
                    "assets/markdowns/terms_and_conditions.md",
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Markdown(
                        controller: _scrollController,
                        data: snapshot.data!,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    activeColor: AppColor().blueBTN,
                    value: _agreed,
                    onChanged: _hasScrolledToBottom
                        ? (val) {
                            setState(() {
                              _agreed = val ?? false;
                            });
                          }
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      _hasScrolledToBottom
                          ? "I have read and agree to the Terms and Conditions."
                          : "Scroll to the bottom to agree.",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              largeBTN(
                double.infinity,
                "Accept and Continue",
                AppColor().blueBTN,
                _agreed
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Registration()),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
