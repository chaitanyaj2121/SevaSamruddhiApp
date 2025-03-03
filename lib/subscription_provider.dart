// subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'subscription_model.dart';

class SubscriptionProvider with ChangeNotifier {
  Subscription? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  Subscription? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSubscription => _currentSubscription?.isActive ?? false;

  // Initialize - load subscription data from server or local storage
  Future<void> initialize(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // First try to get from server
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/subscriptions/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['subscription'] != null) {
          _currentSubscription = Subscription.fromJson(data['subscription']);
        }
      } else {
        // If server fails, try to get from local storage
        final prefs = await SharedPreferences.getInstance();
        final subscriptionJson = prefs.getString('subscription_$uid');
        if (subscriptionJson != null) {
          _currentSubscription = Subscription.fromJson(
            json.decode(subscriptionJson),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update subscription after successful payment
  Future<void> updateSubscription(String uid, Subscription subscription) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update on server
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/subscriptions/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'subscription': subscription.toJson()}),
      );

      if (response.statusCode == 200) {
        _currentSubscription = subscription;

        // Also save locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'subscription_$uid',
          json.encode(subscription.toJson()),
        );

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to update subscription');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if feature is available based on subscription
  bool canAccessFeature(String featureName) {
    if (featureName == 'Profile' || featureName == 'About & Help') {
      // These features are always accessible
      return true;
    }

    // Other features require active subscription
    return hasActiveSubscription;
  }
}
