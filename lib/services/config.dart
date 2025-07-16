import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  String get environment => dotenv.env['ENV'] ?? 'dev';

  Map<String, String> get clientCredentials {
    switch (environment) {
      case 'prod':
        return {
          'clientId': dotenv.env['PRD_CLIENT_ID'] ?? '',
          'clientSecret': dotenv.env['PRD_CLIENT_SECRET'] ?? '',
        };
      case 'uat':
        return {
          'clientId': dotenv.env['UAT_CLIENT_ID'] ?? '',
          'clientSecret': dotenv.env['UAT_CLIENT_SECRET'] ?? '',
        };
      case 'dev':
      default:
        return {
          'clientId': dotenv.env['DEV_CLIENT_ID'] ?? '',
          'clientSecret': dotenv.env['DEV_CLIENT_SECRET'] ?? '',
        };
    }
  }

  String get apiBasePath {
    switch (environment) {
      case 'prod':
        return 'mobile-api-prod';
      case 'uat':
        return 'mobile-api-uat';
      case 'dev':
      default:
        return 'mobile-api-dev';
    }
  }

  String get brokerMainDoor {
    return environment == 'prod'
        ? 'investor.itrust.co.tz'
        : 'investoruat.itrust.co.tz:8888';
  }

  String get developmentIP => '192.168.1.36:40414';

  bool get isProduction => environment == 'prod';

  bool get isDevelopment => environment == 'dev';

  bool get isUAT => environment == 'uat';
}