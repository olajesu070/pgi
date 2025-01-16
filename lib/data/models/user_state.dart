import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_user_api.dart';

class UserState with ChangeNotifier {
  Map<String, dynamic>? _userDetails;
  String? _errorMessage;
   final XenForoUserApi userApiService = XenForoUserApi();

  Map<String, dynamic>? get userDetails => _userDetails;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserDetails() async {
    try {
      // Replace with your API call
      final data = await userApiService.getCurrentUserInfo();

      if (data.isEmpty) {
        _userDetails = null;
        _errorMessage = 'No user information found.';
      } else {
        _userDetails = data;
        _errorMessage = null;
      }
      notifyListeners(); // Notify listeners about state changes
    } catch (e) {
      _userDetails = null;
      _errorMessage = 'Failed to fetch user information. Please try again later.';
      debugPrint('Error fetching user details: $e');
      notifyListeners();
    }
  }
}
