import 'package:flutter/foundation.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/providers/payment.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/auth/toggle.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/utility/automatic_logout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/providers/theme_provider.dart';
import 'package:iwealth/constants/app_theme.dart';
import 'package:iwealth/screens/choice.dart';

GlobalKey<NavigatorState>? _globalNavKey;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  // HttpOverrides.global = MyHttpOverrides  // dont check ssl
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SessionPref.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final navKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState>? _globalNavKey;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _globalNavKey = navKey;
    return AutomaticLogout(
      timeDuration: const Duration(minutes: 5),
      onTimout: () {
        if (kDebugMode) {
          print("Timeout !!");
        }
        navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => MarketProvider()),
          ChangeNotifierProvider(create: (context) => MetadataProvider()),
          ChangeNotifierProvider(create: (context) => PaymentProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode:
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const LandingPage(),
            );
          },
        ),
      ),
    );
  }
}

GlobalKey<NavigatorState>? get globalNavigatorKey => _globalNavKey;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final challenge = SessionPref.getChallenge();
    final onboard = SessionPref.getOnboardData();
    final session = SessionPref.getSession();

    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Toggle()),
      );
    } else if (challenge != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Toggle()),
      );
    } else if (onboard == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => const Choice(
                  toggled: null, // Pass null or leave it out, see below
                )),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Toggle()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().bgLight,
      body: Container(
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: Center(
          child: SvgPicture.asset("assets/images/itrust_logo_with_name.svg"),
        ),
      ),
    );
  }
}
