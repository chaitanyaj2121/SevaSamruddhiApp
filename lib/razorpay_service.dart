// razorpay_service.dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'subscription_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  final Function(Subscription) onSubscriptionSuccess;
  final Function(String) onError;

  RazorpayService({
    required this.onSubscriptionSuccess,
    required this.onError,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> startPayment({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required int durationMonths,
  }) async {
    // Calculate amount (₹100 per month)
    final int amount = durationMonths * 100;

    try {
      // First, create order on your server
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount * 100, // Razorpay expects amount in paise
          'currency': 'INR',
          'receipt': 'subscription_$uid',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create order');
      }

      final orderData = json.decode(response.body);
      final orderId = orderData['id'];

      var options = {
        'key': Config.razorpayKey,
        'amount': amount * 100, // Razorpay expects amount in paise
        'name': 'SmartServe',
        'order_id': orderId,
        'description': '$durationMonths Month(s) Subscription',
        'prefill': {'contact': phone, 'email': email, 'name': name},
        'theme': {
          'color': '#7B1FA2', // Purple color matching your theme
        },
      };

      _razorpay.open(options);
    } catch (e) {
      onError('Error starting payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify payment on server
      final verifyResponse = await http.post(
        Uri.parse('${Config.apiUrl}/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        }),
      );

      if (verifyResponse.statusCode == 200) {
        final data = json.decode(verifyResponse.body);

        if (data['verified']) {
          // Extract duration from description
          final description = data['description'] ?? '';
          final durationPattern = RegExp(r'(\d+) Month');
          final match = durationPattern.firstMatch(description);
          final durationMonths = match != null ? int.parse(match.group(1)!) : 1;

          // Create subscription model
          final startDate = DateTime.now();
          final endDate = DateTime(
            startDate.year,
            startDate.month + durationMonths,
            startDate.day,
          );

          final subscription = Subscription(
            startDate: startDate,
            endDate: endDate,
            durationMonths: durationMonths,
            amount: data['amount'] / 100, // Convert paise to rupees
            transactionId: response.paymentId!,
            status: 'active',
          );

          onSubscriptionSuccess(subscription);
        } else {
          onError('Payment verification failed');
        }
      } else {
        onError('Failed to verify payment');
      }
    } catch (e) {
      onError('Error processing payment: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onError('External wallet selected: ${response.walletName}');
  }
}
