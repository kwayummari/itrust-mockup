import 'package:iwealth/services/keys.dart';

class API {
  // Fixed endpoints
  String get fundList => "/api/UnitTrust/UnitTrustFunds";
  String get brokerLinkMainDoor => Keys().env == 'prod'
      ? "investor.itrust.co.tz"
      : "investoruat.itrust.co.tz:8888";
  String get ip => "192.168.1.36:40414";
  String get countriesList => "/${Keys().ENV}/countries";
  String get createInvestor =>
      "/${Keys().ENV}/customers/onboard/account/register";
  String get requestOTPEndpoint =>
      "/${Keys().ENV}/customers/onboard/account/request-otp";
  String get resendOTPEndpoint =>
      "/${Keys().ENV}/customers/onboard/account/resend-otp";
  String get verifyOTPEndpoint =>
      "/${Keys().ENV}/customers/onboard/account/validate-otp";
  String get authenticate =>
      "/${Keys().ENV}/customers/onboard/account/create-token";
  String get resetPINEndpoint =>
      "/${Keys().ENV}/customers/onboard/account/reset-pin";
  String get sectors => "/${Keys().ENV}/sectors";
  String get banks => "/${Keys().ENV}/banks";
  String get metadata => "/${Keys().ENV}/onboarding-meta";

  // KYC
  String get kyc1 =>
      "/${Keys().ENV}/customers/profile/individual/update_personal_information";
  String get kyc2 =>
      "/${Keys().ENV}/customers/profile/individual/update_contact_information";
  String get kyc3 =>
      "/${Keys().ENV}/customers/profile/individual/update_employment_information";
  String get fileEndpoint =>
      "/${Keys().ENV}/customers/profile/individual/update_files_information";
  String get kyc => "/${Keys().ENV}/customers/onboarding/process";
  String get kyc5 =>
      "/${Keys().ENV}/customers/profile/update_next_of_kin_information";
  String get nidaBio => "/${Keys().ENV}/nida/inquiry-bio";
  String get nidaBioQuestion => "/${Keys().ENV}/nida/bio/verify";
  String get nidaAnswerQuestion => "/${Keys().ENV}/nida/inquiry";
  String get nidaQuestions => "/${Keys().ENV}/nida/inquiry";

  // OTP
  String get sendOTP => "/${Keys().ENV}/nida/get-otp-nbc";
  String get verifyOTP => "/${Keys().ENV}/nida/verify-otp-nbc";
  String get metadataNBC => "/${Keys().ENV}/nida/options-nbc";
  String get sendQuotationEndpoint => "/${Keys().ENV}/transfers/inquiry";
  String get verifyInformation => "/${Keys().ENV}/transfers/verify";
  String get transfer => "/${Keys().ENV}/transfers/confirm";

  // Metadata Endpoint
  String get regionEp => "/${Keys().ENV}/regions";
  String get districtEp => "/${Keys().ENV}/districts";
  String get wardEp => "/${Keys().ENV}/wards";

  String get brokerageList => "/${Keys().ENV}/v2/innova/list";
  String get brokeragePurchase => "/${Keys().ENV}/v2/innova/purchase";
  String get brokerageFundBuyOrder => "/${Keys().ENV}/v2/innova/purchases";
  String get uploadProofEp => "/${Keys().ENV}/v2/innova/proof-of-payment";

  String get stockList => "/${Keys().ENV}/stock-prices";
  String get marketStatus => "/${Keys().ENV}/market-status";
  String get dseINDEX => "/${Keys().ENV}/dse-index";
  String get userProfile => "/${Keys().ENV}/profiles";
  String get movers => "/${Keys().ENV}/performance/movers";
  String get gainer => "/${Keys().ENV}/performance/gainers";
  String get loosers => "/${Keys().ENV}/performance/losers";
  String get buyOrder => "/${Keys().ENV}/trading/equities/buy";
  String get sellOrder => "/${Keys().ENV}/trading/equities/sell";
  String get orderList => "/${Keys().ENV}/trading/equities/orders";
  String get portfolioEndpoint => "/${Keys().ENV}/holdings/portfolio-stock";
  String get eachStockPortfolioEndpoint => "/${Keys().ENV}/holdings/equities";
  String get statementEndpoint =>
      "/${Keys().ENV}/holdings/order-contract-notes";
  String get downloadContract =>
      "/${Keys().ENV}/holdings/download-contract-note";
  String get statement => "/${Keys().ENV}/holdings/statement";
  String get stockMobilePayment =>
      "/${Keys().ENV}/trading/equities/push-payment";
  String get bondMobilePayment => "/${Keys().ENV}/trading/bonds/push-payment";
  String get fees => "/${Keys().ENV}/trading/equities/calculate-buy";
  String get stockProofPayment =>
      "/${Keys().ENV}/trading/equities/proof-of-payment";

  // Fund
  String get fundlist => "/${Keys().ENV}/v2/innova/list";
  String get purchasesFund => "/${Keys().ENV}/v2/innova/purchase";
  String get fundPortfolio =>
      "/${Keys().ENV}/innova/investor-unit-trust-holding";
  String get fundBuyOrder => "/${Keys().ENV}/innova/investor-buy-order";
  String get redemptionOrder => "/${Keys().ENV}/innova/investor-sell-orders";
  String get redemptionEndpoint => "/${Keys().ENV}/v2/innova/sale";
  // String get fundMobilePayment => "/${Keys().ENV}/v2/innova/push-payment";
  String get fundMobilePayment => "/${Keys().ENV}/v2/innova/push-payment";
  String get azamPay => "/${Keys().ENV}/v2/innova/push-payment";

  // Fund wallet
  String get fundWallet => "/${Keys().ENV}/wallet/push";

  String get refreshToken => "/${Keys().ENV}/tokens/refresh";

  // Bonds
  String get bondList => "/${Keys().ENV}/bonds-secondary";
  String get bondBuy => "/${Keys().ENV}/trading/bonds/buy";
  String get bondSell => "/${Keys().ENV}/trading/bonds/sell";
  String get calculateBuy => "/${Keys().ENV}/trading/bonds/calculate-buy";
  String get bondOrders => "/${Keys().ENV}/trading/bonds/orders";
  String get bondProofPayment =>
      "/${Keys().ENV}/trading/bonds/proof-of-payment";
  String get bondPortfolio => "/${Keys().ENV}/holdings/portfolio-bond";
}
