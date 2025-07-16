import 'package:flutter_dotenv/flutter_dotenv.dart';

class Keys {
  String get env => dotenv.env['ENV'] ?? 'Project Level';

  String get devClientID =>
      dotenv.env['DEV_CLIENT_ID'] ?? "9e111257-168f-4d92-93ae-18cefa488ec7";

  String get devClientSecret =>
      dotenv.env['DEV_CLIENT_SECRET'] ??
      "dSUWptidkTjMq5RCJFXL5113EJ5h01tOyGNm6gnR";

  String get prdClientID =>
      dotenv.env['PRD_CLIENT_ID'] ?? "9e37e036-b2c8-4ec9-b46d-c189b26a81f6";

  String get prdClientSecret =>
      dotenv.env['PRD_CLIENT_SECRET'] ??
      "IApmsn9vXXTEo9FHpy5Mf2cuV9qvjLZ0AtT8LCj7";

  String get uatClientID =>
      dotenv.env['UAT_CLIENT_ID'] ?? "9cdfa060-1249-44e8-89d1-f6016e1793f6";

  String get uatClientSecret =>
      dotenv.env['UAT_CLIENT_SECRET'] ??
      "QDWQPPfUUZ2l1pX1kiC5fsinRPkmhUrBzgcrbup7";

  String get clientId {
    switch (env) {
      case 'prod':
        return prdClientID;
      case 'uat':
        return uatClientID;
      case 'dev':
      default:
        return devClientID;
    }
  }

  String get clientSecret {
    switch (env) {
      case 'prod':
        return prdClientSecret;
      case 'uat':
        return uatClientSecret;
      case 'dev':
      default:
        return devClientSecret;
    }
  }

  String get ENV {
    switch (env) {
      case 'prod':
        return "mobile-api-prod";
      case 'uat':
        return "mobile-api-uat";
      case 'dev':
      default:
        return "mobile-api-dev";
    }
  }
}
