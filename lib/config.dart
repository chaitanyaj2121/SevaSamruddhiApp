class APIConfig {
  static const String baseUrl = 'https://backend-smartserveapp.onrender.com';
  // Change to 'https://backend-smartserveapp.onrender.com' if testing locally.
  static const String customersUrl = baseUrl + "/customers";
  static const String addCustomerUrl = baseUrl + "/addCustomer";
  static const String loginUrl = baseUrl + "/login";
  static const String dashboardUrl = baseUrl + "/dashboard";
  static const String deleteCustUrl = baseUrl + "/delete-customer";
  static const String renewCustUrl = baseUrl + "/renew-customer";
  static const String notificationsUrl = baseUrl + "/notifications";
  // http://192.168.166.11:8080"
  static const String signupBusinessUrl = baseUrl + "/signup/business";
}

// config.dart
class Config {
  // Your backend server URL
  static const String apiUrl = 'https://your-backend-server.com';

  // Your Razorpay key_id (public key)
  static const String razorpayKey = 'rzp_test_yourKeyId';
}
