import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/nidamodel.dart';
import 'package:iwealth/screens/user/confirm_details_screen.dart';
import 'package:iwealth/screens/user/kyc.dart';
import 'package:iwealth/screens/user/nida_kyc.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/app_button.dart';
import 'package:iwealth/widgets/app_rich_text.dart';
import 'package:iwealth/widgets/app_text.dart';

class IDOpts extends StatefulWidget {
  const IDOpts({super.key});

  @override
  State<IDOpts> createState() => _IDOptsState();
}

class _IDOptsState extends State<IDOpts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().blueBTN,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          txt: "Complete Your Profile",
          color: AppColor().black,
          weight: FontWeight.bold,
          size: 16,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      txt:
                          "Please complete your profile by uploading and verifying one of the documents below.",
                      color: AppColor().grayText,
                      size: 15,
                    ),
                    Center(
                        child: SvgPicture.asset(
                      'assets/images/profile-password-unlock-gh6KArKaiS.svg',
                    )),
                    const SizedBox(height: 16),
                    AppText(
                      txt: "Choose a Document to verify your ID",
                      color: AppColor().black,
                      weight: FontWeight.w600,
                      size: 16,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      txt:
                          "NIDA Number (National Identification Authority) also known as Tanzanian National ID Number.",
                      color: AppColor().grayText,
                      size: 15,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColor().gray,
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 60,
                      child: AppButton(
                        onPress: () {
                          final data = SessionPref.getNIDA();

                          if (data != null) {
                            final nida = NIDA(
                              birthCountry: data[0],
                              birthDistrict: data[1],
                              birthRegion: data[2],
                              dob: data[3],
                              fname: data[4],
                              lname: data[5],
                              mname: data[6],
                              nin: data[7],
                              pob: data[8],
                              resDistrict: data[9],
                              resRegion: data[10],
                              resVillage: data[11],
                              resWard: data[12],
                              sex: data[13],
                              photo: data[14]
                            );

                            final nin = data[7];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmDetailsScreen(
                                    nin: nin, userData: nida),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NIDAUserKYC(),
                              ),
                            );
                          }
                        },
                        label: Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: AppColor().black,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            AppRichText(
                              parts: [
                                TextPart("NIDA", AppColor().black, 13),
                                TextPart("(National Identification Authority)",
                                    AppColor().black, 12),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColor().black,
                              size: 20,
                            ),
                          ],
                        ),
                        elevation: 0,
                        borderRadius: 16,
                        textColor: AppColor().black,
                        bcolor: AppColor().transparent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      txt: "Passport Number and Document",
                      color: AppColor().grayText,
                      size: 15,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor().gray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 60,
                      child: AppButton(
                        onPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 8,
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.white,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColor().gray,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.schedule,
                                        size: 32,
                                        color: AppColor().blueBTN,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AppText(
                                      txt: 'Coming Soon',
                                      size: 20,
                                      color: Colors.grey.shade800,
                                      weight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 8),
                                    AppText(
                                      txt:
                                          'This feature is currently under development.\nStay tuned for updates!',
                                      size: 14,
                                      color: Colors.grey.shade600,
                                      align: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor().blueBTN,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: AppText(
                                          txt: 'Got it',
                                          size: 16,
                                          color: Colors.white,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        label: Row(
                          children: [
                            Icon(
                              Icons.password,
                              color: AppColor().black,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            AppText(
                              txt: "Passport Number",
                              color: AppColor().black,
                              size: 15,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColor().black,
                              size: 20,
                            ),
                          ],
                        ),
                        elevation: 0,
                        borderRadius: 16,
                        textColor: AppColor().black,
                        bcolor: AppColor().transparent,
                      ),
                    ),
                    const Spacer(flex: 2),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarWidget())),
                      child: Center(
                        child: AppText(
                            txt: "Skip KYC Verification",
                            color: AppColor().blueText,
                            size: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
