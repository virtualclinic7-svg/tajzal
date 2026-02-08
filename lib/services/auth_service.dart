import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'notification_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  Future<User?>? _cachedUserFuture;
  
  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔐 Attempting login for: ${request.email}');
      final response = await _apiService.login(request);
      print('✅ Login API call successful');
      
      await _saveAuthData(response);
      print('💾 Auth data saved to local storage');
      
      // إرسال device token إلى backend بعد تسجيل الدخول الناجح
      try {
        await _notificationService.sendTokenToBackend(
          response.user.id,
          response.accessToken,
        );
        print('✅ Device token sent to backend after login');
      } catch (e) {
        print('⚠️ Failed to send device token after login: $e');
        // لا نوقف عملية تسجيل الدخول إذا فشل إرسال الـ token
      }
      
      return response;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }
  
  // Register - returns User (register doesn't return access_token)
  // Supports avatar file upload
  Future<User> register(RegisterRequest request, {File? avatarFile}) async {
    try {
      print('📝 Registering user: ${request.email}');
      if (avatarFile != null) {
        print('📸 Avatar file provided: ${avatarFile.path}');
      }
      
      final response = await _apiService.register(request, avatarFile: avatarFile);
      // Register endpoint returns User object, not AuthResponse
      final user = User.fromJson(response);
      // Don't save auth data since register doesn't provide token
      // User needs to login after registration
      print('✅ Registration successful: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }
  
  // Save auth data to local storage
  Future<void> _saveAuthData(AuthResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.accessToken);
      await prefs.setString(_userKey, jsonEncode(response.user.toJson()));
      // تحديث الـ cache عند تسجيل الدخول
      _cachedUserFuture = Future.value(response.user);
      print('💾 Token saved: ${response.accessToken.substring(0, 20)}...');
      print('💾 User saved: ${response.user.name} (${response.user.email})');
    } catch (e) {
      print('❌ Error saving auth data: $e');
      throw Exception('فشل حفظ بيانات تسجيل الدخول');
    }
  }
  
  // Get current user - tries API first, falls back to local storage
  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    final token = await getToken();
    
    // If no token, return null
    if (token == null || token.isEmpty) {
      _cachedUserFuture = null;
      return null;
    }
    
    // If forceRefresh is true, clear cache and fetch from API
    if (forceRefresh) {
      _cachedUserFuture = null;
      try {
        final user = await _apiService.getCurrentUserProfile(token);
        await _saveUserData(user);
        _cachedUserFuture = Future.value(user);
        return user;
      } catch (e) {
        print('❌ Error fetching user from API: $e');
        // If API fails, try local storage as fallback
        return _getUserFromLocalStorage();
      }
    }
    
    // إذا كان هناك cached future، استخدمه لتجنب استدعاء API بشكل متكرر
    if (_cachedUserFuture != null) {
      try {
        return await _cachedUserFuture;
      } catch (e) {
        // إذا فشل الـ cached future، امسحه وحاول مرة أخرى
        _cachedUserFuture = null;
      }
    }
    
    // إنشاء future جديد واستدعاء API
    _cachedUserFuture = _fetchUserFromAPI(token);
    return await _cachedUserFuture;
  }
  
  // Helper method to fetch user from API
  Future<User?> _fetchUserFromAPI(String token) async {
    try {
      final user = await _apiService.getCurrentUserProfile(token);
      await _saveUserData(user);
      return user;
    } catch (e) {
      print('⚠️ API call failed, using local storage: $e');
      // Check if it's a 401 error (unauthorized)
      if (e.toString().contains('401') || 
          e.toString().contains('انتهت صلاحية') ||
          e.toString().contains('غير مصرح')) {
        // Clear local data on 401
        _cachedUserFuture = null;
        await logout();
        return null;
      }
      // For other errors (network, etc.), use local storage as fallback
      return _getUserFromLocalStorage();
    }
  }
  
  // Refresh current user from server only
  Future<User> refreshCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('غير مصرح - يرجى تسجيل الدخول');
    }
    
    final user = await _apiService.getCurrentUserProfile(token);
    await _saveUserData(user);
    return user;
  }
  
  // Get user from local storage (helper method)
  Future<User?> _getUserFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Save user data to local storage (helper method)
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      print('💾 User data saved to local storage: ${user.name} (${user.email})');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }
  
  // Get auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Logout
  Future<void> logout() async {
    // حذف device token من backend قبل تسجيل الخروج
    try {
      final token = await getToken();
      final user = await _getUserFromLocalStorage();
      if (token != null && user != null) {
        await _notificationService.deleteTokenFromBackend(user.id, token);
        print('✅ Device token deleted from backend on logout');
      }
    } catch (e) {
      print('⚠️ Failed to delete device token on logout: $e');
      // لا نوقف عملية تسجيل الخروج إذا فشل حذف الـ token
    }

    // مسح الـ cache
    _cachedUserFuture = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      print('🔐 Requesting password reset for: $email');
      await _apiService.forgotPassword(email);
      print('✅ Forgot password request successful');
    } catch (e) {
      print('❌ Forgot password failed: $e');
      rethrow;
    }
  }

  // Verify OTP and Reset Password
  Future<void> verifyOtpAndResetPassword(String email, String otpCode, String newPassword) async {
    try {
      print('🔐 Verifying OTP and resetting password for: $email');
      await _apiService.verifyOtpAndResetPassword(email, otpCode, newPassword);
      print('✅ Password reset successful');
    } catch (e) {
      print('❌ OTP verification and password reset failed: $e');
      rethrow;
    }
  }
}

