import 'config.dart';

class APIEndpoints {
  static final AppConfig _config = AppConfig();
  static String get _basePath => _config.apiBasePath;

  // Authentication & User Management
  static String get requestOTP =>
      '/$_basePath/customers/onboard/account/request-otp';
  static String get resendOTP =>
      '/$_basePath/customers/onboard/account/resend-otp';
  static String get verifyOTP =>
      '/$_basePath/customers/onboard/account/validate-otp';
  static String get authenticate =>
      '/$_basePath/customers/onboard/account/create-token';
  static String get createInvestor =>
      '/$_basePath/customers/onboard/account/register';
  static String get resetPIN =>
      '/$_basePath/customers/onboard/account/reset-pin';
  static String get refreshToken => '/$_basePath/tokens/refresh';
  static String get userProfile => '/$_basePath/profiles';

  // KYC Related
  static String get kyc => '/$_basePath/customers/onboarding/process';
  static String get kyc1 =>
      '/$_basePath/customers/profile/individual/update_personal_information';
  static String get kyc2 =>
      '/$_basePath/customers/profile/individual/update_contact_information';
  static String get kyc3 =>
      '/$_basePath/customers/profile/individual/update_employment_information';
  static String get fileEndpoint =>
      '/$_basePath/customers/profile/individual/update_files_information';
  static String get kyc5 =>
      '/$_basePath/customers/profile/update_next_of_kin_information';
  static String get kyc6 => '/$_basePath/onboarding/settings';

  // NIDA Verification
  static String get nidaBio => '/$_basePath/nida/inquiry-bio';
  static String get nidaBioQuestion => '/$_basePath/nida/bio/verify';
  static String get nidaAnswerQuestion => '/$_basePath/nida/inquiry';
  static String get nidaQuestions => '/$_basePath/nida/inquiry';

  // NBC OTP
  static String get sendOTP => '/$_basePath/nida/get-otp-nbc';
  static String get verifyNBCOTP => '/$_basePath/nida/verify-otp-nbc';
  static String get metadataNBC => '/$_basePath/nida/options-nbc';

  // Transfers
  static String get sendQuotationEndpoint => '/$_basePath/transfers/inquiry';
  static String get verifyInformation => '/$_basePath/transfers/verify';
  static String get transfer => '/$_basePath/transfers/confirm';

  // Metadata
  static String get countriesList => '/$_basePath/countries';
  static String get sectors => '/$_basePath/sectors';
  static String get banks => '/$_basePath/banks';
  static String get relations => '/$_basePath/kins';
  // static String get relations => '/$_basePath/customers/onboarding/settings';
  static String get metadata => '/$_basePath/onboarding-meta';
  static String get regionEp => '/$_basePath/regions';
  static String get districtEp => '/$_basePath/districts';
  static String get wardEp => '/$_basePath/wards';

  // Stocks & Trading
  static String get stockList => '/$_basePath/stock-prices';
  static String get marketStatus => '/$_basePath/market-status';
  static String get dseINDEX => '/$_basePath/dse-index';
  static String get movers => '/$_basePath/performance/movers';
  static String get gainer => '/$_basePath/performance/gainers';
  static String get loosers => '/$_basePath/performance/losers';
  static String get buyOrder => '/$_basePath/trading/equities/buy';
  static String get sellOrder => '/$_basePath/trading/equities/sell';
  static String get orderList => '/$_basePath/trading/equities/orders';
  static String get portfolioEndpoint => '/$_basePath/holdings/portfolio-stock';
  static String get eachStockPortfolioEndpoint =>
      '/$_basePath/holdings/equities';
  static String get statementEndpoint =>
      '/$_basePath/holdings/order-contract-notes';
  static String get downloadContract =>
      '/$_basePath/holdings/download-contract-note';
  static String get statement => '/$_basePath/holdings/statement';
  static String get stockMobilePayment =>
      '/$_basePath/trading/equities/push-payment';
  static String get stockProofPayment =>
      '/$_basePath/trading/equities/proof-of-payment';
  static String get fees => '/$_basePath/trading/equities/calculate-buy';

  // Unit Trust Funds
  static String get fundList => '/api/UnitTrust/UnitTrustFunds';
  static String get brokerageList => '/$_basePath/v2/innova/list';
  static String get brokeragePurchase => '/$_basePath/v2/innova/purchase';
  static String get brokerageFundBuyOrder => '/$_basePath/v2/innova/purchases';
  static String get uploadProofEp => '/$_basePath/v2/innova/proof-of-payment';
  static String get fundlist => '/$_basePath/v2/innova/list';
  static String get purchasesFund => '/$_basePath/v2/innova/purchase';
  static String get fundPortfolio =>
      '/$_basePath/innova/investor-unit-trust-holding';
  static String get fundBuyOrder => '/$_basePath/innova/investor-buy-order';
  static String get redemptionOrder =>
      '/$_basePath/innova/investor-sell-orders';
  static String get redemptionEndpoint => '/$_basePath/v2/innova/sale';
  static String get fundMobilePayment => '/$_basePath/v2/innova/push-payment';
  static String get azamPay => '/$_basePath/v2/innova/push-payment';

  // Fund Wallet
  static String get fundWallet => '/$_basePath/wallet/push';

  // Bonds
  static String get bondList => '/$_basePath/bonds-secondary';
  static String get eachBondPortfolioEndpoint => '/$_basePath/holdings/bonds';
  static String get bondBuy => '/$_basePath/trading/bonds/buy';
  static String get bondSell => '/$_basePath/trading/bonds/sell';
  static String get calculateBuy => '/$_basePath/trading/bonds/calculate-buy';
  static String get bondOrders => '/$_basePath/trading/bonds/orders';
  static String get bondMobilePayment =>
      '/$_basePath/trading/bonds/push-payment';
  static String get bondProofPayment =>
      '/$_basePath/trading/bonds/proof-of-payment';

  // Legacy compatibility - Keep original names for backward compatibility
  static String get countries => countriesList;
  static String get regions => regionEp;
  static String get districts => districtEp;
  static String get wards => wardEp;
  static String get requestOTPEndpoint => requestOTP;
  static String get resendOTPEndpoint => resendOTP;
  static String get verifyOTPEndpoint => verifyOTP;
  static String get resetPINEndpoint => resetPIN;
  static String get sendQuotation => sendQuotationEndpoint;
  static String get dseIndex => dseINDEX;
  static String get gainers => gainer;
  static String get losers => loosers;
  static String get portfolioStock => portfolioEndpoint;
  static String get eachStockPortfolio => eachStockPortfolioEndpoint;
  static String get orderContractNotes => statementEndpoint;
  static String get downloadContractNote => downloadContract;
  static String get calculateBuyFees => fees;
  static String get brokerageFundList => brokerageList;
  static String get fundPurchase => brokeragePurchase;
  static String get fundBuyOrders => brokerageFundBuyOrder;
  static String get fundProofUpload => uploadProofEp;
  static String get fundRedemption => redemptionEndpoint;
  static String get fundRedemptionOrder => redemptionOrder;
  static String get bondCalculateBuy => calculateBuy;

  static String get ip => '192.168.1.36:40414';

  static String get kycFileUpload =>
      '/$_basePath/customers/profile/individual/update_files_information';

  static String get getBondPortfolio => "/$_basePath/holdings/portfolio-bond";

  // portfolios
  static String get myPortfolio => '$_basePath/my-portfolio';
  static String get myFundPortfolio => '$_basePath/fund-portfolio';
}

/// Legacy API class for backward compatibility
class API {
  static final AppConfig _config = AppConfig();

  String get fundList => APIEndpoints.fundList;
  String get brokerLinkMainDoor => _config.brokerMainDoor;
  String get ip => APIEndpoints.ip;

  String get countriesList => APIEndpoints.countriesList;
  String get createInvestor => APIEndpoints.createInvestor;
  String get requestOTPEndpoint => APIEndpoints.requestOTPEndpoint;
  String get resendOTPEndpoint => APIEndpoints.resendOTPEndpoint;
  String get verifyOTPEndpoint => APIEndpoints.verifyOTPEndpoint;
  String get authenticate => APIEndpoints.authenticate;
  String get resetPINEndpoint => APIEndpoints.resetPINEndpoint;
  String get sectors => APIEndpoints.sectors;
  String get banks => APIEndpoints.banks;
  String get metadata => APIEndpoints.metadata;

  // KYC
  String get kyc1 => APIEndpoints.kyc1;
  String get kyc2 => APIEndpoints.kyc2;
  String get kyc3 => APIEndpoints.kyc3;
  String get fileEndpoint => APIEndpoints.fileEndpoint;
  String get kyc => APIEndpoints.kyc;
  String get kyc5 => APIEndpoints.kyc5;
  String get nidaBio => APIEndpoints.nidaBio;
  String get nidaBioQuestion => APIEndpoints.nidaBioQuestion;
  String get nidaAnswerQuestion => APIEndpoints.nidaAnswerQuestion;
  String get nidaQuestions => APIEndpoints.nidaQuestions;

  // OTP
  String get sendOTP => APIEndpoints.sendOTP;
  String get verifyOTP => APIEndpoints.verifyNBCOTP;
  String get metadataNBC => APIEndpoints.metadataNBC;
  String get sendQuotationEndpoint => APIEndpoints.sendQuotationEndpoint;
  String get verifyInformation => APIEndpoints.verifyInformation;
  String get transfer => APIEndpoints.transfer;

  // Metadata Endpoint
  String get regionEp => APIEndpoints.regionEp;
  String get districtEp => APIEndpoints.districtEp;
  String get wardEp => APIEndpoints.wardEp;

  String get brokerageList => APIEndpoints.brokerageList;
  String get brokeragePurchase => APIEndpoints.brokeragePurchase;
  String get brokerageFundBuyOrder => APIEndpoints.brokerageFundBuyOrder;
  String get uploadProofEp => APIEndpoints.uploadProofEp;

  String get stockList => APIEndpoints.stockList;
  String get marketStatus => APIEndpoints.marketStatus;
  String get dseINDEX => APIEndpoints.dseINDEX;
  String get userProfile => APIEndpoints.userProfile;
  String get movers => APIEndpoints.movers;
  String get gainer => APIEndpoints.gainer;
  String get loosers => APIEndpoints.loosers;
  String get buyOrder => APIEndpoints.buyOrder;
  String get sellOrder => APIEndpoints.sellOrder;
  String get orderList => APIEndpoints.orderList;
  String get portfolioEndpoint => APIEndpoints.portfolioEndpoint;
  String get eachStockPortfolioEndpoint =>
      APIEndpoints.eachStockPortfolioEndpoint;
  String get statementEndpoint => APIEndpoints.statementEndpoint;
  String get downloadContract => APIEndpoints.downloadContract;
  String get statement => APIEndpoints.statement;
  String get stockMobilePayment => APIEndpoints.stockMobilePayment;
  String get bondMobilePayment => APIEndpoints.bondMobilePayment;
  String get fees => APIEndpoints.fees;
  String get stockProofPayment => APIEndpoints.stockProofPayment;

  // Fund
  String get fundlist => APIEndpoints.fundlist;
  String get purchasesFund => APIEndpoints.purchasesFund;
  String get fundPortfolio => APIEndpoints.fundPortfolio;
  String get fundBuyOrder => APIEndpoints.fundBuyOrder;
  String get redemptionOrder => APIEndpoints.redemptionOrder;
  String get redemptionEndpoint => APIEndpoints.redemptionEndpoint;
  String get fundMobilePayment => APIEndpoints.fundMobilePayment;
  String get azamPay => APIEndpoints.azamPay;

  // Fund wallet
  String get fundWallet => APIEndpoints.fundWallet;

  String get refreshToken => APIEndpoints.refreshToken;

  // Bonds
  String get bondList => APIEndpoints.bondList;
  String get bondBuy => APIEndpoints.bondBuy;
  String get bondSell => APIEndpoints.bondSell;
  String get calculateBuy => APIEndpoints.calculateBuy;
  String get bondOrders => APIEndpoints.bondOrders;
  String get bondProofPayment => APIEndpoints.bondProofPayment;
  String get bondPortfolio => APIEndpoints.getBondPortfolio;

  // PORTFOLIOS
  String get myPortfolio => APIEndpoints.myPortfolio;
  String get myFundPortfolio => APIEndpoints.myFundPortfolio;
}
