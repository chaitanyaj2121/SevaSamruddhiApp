class APIConfig {
  static const String baseUrl = 'https://backend-smart-serve-app.vercel.app';
  static const String customersUrl = baseUrl + "/customers";
  static const String addCustomerUrl = baseUrl + "/addCustomer";
  static const String loginUrl = baseUrl + "/login";
  static const String dashboardUrl = baseUrl + "/dashboard";
  static const String dashboardHomeStatsUrl = baseUrl + "/dashboard/home-stats";
  static const String deleteCustUrl = baseUrl + "/delete-customer";
  static const String renewCustUrl = baseUrl + "/renew-customer";
  static const String notificationsUrl = baseUrl + "/notifications";
  static const String signupBusinessUrl = baseUrl + "/signup/business";
}

// config.dart
class Config {
  // Your backend server URL
  static const String apiUrl = 'https://backend-smart-serve-app.vercel.app';

  // Your Razorpay key_id (public key)
  static const String razorpayKey = 'rzp_test_yourKeyId';
}
