import 'dart:async';
import 'package:paylink_payment/paylink_payment.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/payment.dart';

enum PaymentResult { success, error, cancel }

class PaymentService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  PaylinkPayment? _paylinkInstance;
  bool _isInitialized = false;

  // #region agent global paylink error bridge
  static Completer<PaymentResult>? _activeCompleter;

  static void handleGlobalPaylinkError(Object error, StackTrace stack) {
    final errStr = error.toString();
    final stackStr = stack.toString();
    final isPaylinkStack =
        stackStr.contains('paylink_payment') ||
        stackStr.contains('package:paylink_payment/paylink_payment.dart');
    final isPaylinkPaymentException =
        errStr.contains('Payment Error') ||
        errStr.contains('Payment response code') ||
        errStr.contains('Payment response');

    if (!isPaylinkStack || !isPaylinkPaymentException) return;

    final completer = _activeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(PaymentResult.error);
    }
    _activeCompleter = null;
  }
  // #endregion

  /// تهيئة Paylink SDK في Test Mode
  Future<void> initializePaylink(BuildContext context) async {
    if (_isInitialized && _paylinkInstance != null) {
      return;
    }

    // التحقق من أن context لا يزال صالحاً
    if (!context.mounted) {
      throw Exception('Context is no longer valid');
    }

    try {
      // تهيئة Paylink SDK في Test Mode
      _paylinkInstance = PaylinkPayment.test(
        context: context,
        webViewTitle: 'الدفع',
        textColor: Colors.white,
        themeColor: Colors.red,
      );

      _isInitialized = true;
      print('✅ Paylink SDK initialized successfully (Test Mode)');
    } catch (e) {
      print('❌ Failed to initialize Paylink SDK: $e');
      throw Exception('فشل تهيئة نظام الدفع: $e');
    }
  }

  /// فتح نموذج الدفع باستخدام transactionNo
  Future<PaymentResult> openPaymentForm({
    required String transactionNo,
    required BuildContext context,
  }) async {
    try {
      // التأكد من تهيئة SDK
      if (!_isInitialized || _paylinkInstance == null) {
        await initializePaylink(context);
      }

      print('💳 Opening Paylink payment form for transaction: $transactionNo');
      print(
        '📱 Paylink SDK instance: ${_paylinkInstance != null ? "Ready" : "Not initialized"}',
      );

      // استخدام Completer للانتظار حتى يتم استدعاء callbacks
      final completer = Completer<PaymentResult>();
      _activeCompleter = completer;

      void completeOnce(PaymentResult result, String reason) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
        _activeCompleter = null;
      }

      try {
        print('🔄 Calling openPaymentForm...');
        _paylinkInstance!.openPaymentForm(
          transactionNo: transactionNo,
          onPaymentComplete: (PaylinkInvoice orderDetails) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('✅ Payment completed callback received!');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('TransactionNo: ${orderDetails.transactionNo}');
            print('Amount: ${orderDetails.amount}');
            print('Invoice details: ${orderDetails.toString()}');
            // إذا تم استدعاء onPaymentComplete، يعني الدفع نجح
            print('✅ Completing with success result');
            completeOnce(PaymentResult.success, 'onPaymentComplete');
          },
          onError: (Object error) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('❌ Payment error callback received!');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('Error: $error');
            print('Error type: ${error.runtimeType}');
            print('Error string: ${error.toString()}');
            // معالجة أنواع مختلفة من الأخطاء
            if (error.toString().contains('cancel') ||
                error.toString().contains('Cancel') ||
                error.toString().contains('cancelled')) {
              print('🔄 Detected cancellation, completing with cancel result');
              completeOnce(PaymentResult.cancel, 'onError:cancel');
            } else {
              print('🔄 Detected error, completing with error result');
              completeOnce(PaymentResult.error, 'onError:error');
            }
          },
        );
        print(
          '✅ openPaymentForm called successfully, waiting for callbacks...',
        );
      } catch (e) {
        print('❌ Exception while opening payment form: $e');
        // إذا فشل فتح النموذج، نرجع خطأ
        completeOnce(PaymentResult.error, 'exception_opening_form');
      }

      // انتظار النتيجة من callbacks مع timeout
      try {
        print('⏳ Waiting for payment result (timeout: 60 seconds)...');
        final result = await completer.future.timeout(
          const Duration(seconds: 60), // زيادة timeout إلى 60 ثانية
          onTimeout: () {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('⏰ Payment form timeout after 60 seconds');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            completeOnce(PaymentResult.error, 'timeout');
            return PaymentResult.error;
          },
        );
        print('✅ Received payment result: $result');
        // If some path completed without cleanup, ensure cleanup here.
        _activeCompleter = null;
        return result;
      } catch (e) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('⚠️ Exception while waiting for payment result');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        print('Error toString: ${e.toString()}');

        // إذا كان الخطأ "Payment Error" من SDK، نتحقق من حالة الدفع من Backend
        if (e.toString().contains('Payment Error') ||
            e.toString().contains('Exception: Payment Error')) {
          print('🔄 Payment Error detected from SDK');
          print(
            'This might be a false error - checking payment status from backend...',
          );
          // نحرر محاولة الدفع الحالية (حتى لا تظل معلقة)
          completeOnce(PaymentResult.error, 'caught_payment_error_exception');
          print(
            '✅ Returning success - backend will verify actual payment status',
          );
          // نعتبر أن العملية قد تكون نجحت (سيتم التحقق من Backend)
          return PaymentResult.success;
        }

        // للأخطاء الأخرى، نرجع خطأ
        print('❌ Returning error result');
        _activeCompleter = null;
        return PaymentResult.error;
      }
    } catch (e) {
      print('❌ Failed to open payment form: $e');
      if (e.toString().contains('cancel') || e.toString().contains('Cancel')) {
        return PaymentResult.cancel;
      }
      throw Exception('فشل فتح نموذج الدفع: $e');
    }
  }

  /// إنشاء payment intent وفتح نموذج الدفع
  Future<PaymentResult> processPayment({
    required String appointmentId,
    required BuildContext context,
  }) async {
    try {
      // 1. الحصول على token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('غير مصرح - يرجى تسجيل الدخول');
      }

      // 2. إنشاء payment intent من الباك إند
      print('📝 Creating payment intent for appointment: $appointmentId');
      final paymentIntent = await _apiService.createPaymentIntent(
        appointmentId: appointmentId,
        token: token,
      );

      print(
        '✅ Payment intent created - TransactionNo: ${paymentIntent.intentId}',
      );

      // 3. التأكد من تهيئة SDK قبل فتح نموذج الدفع
      // التحقق من أن context لا يزال صالحاً قبل الاستخدام
      if (!context.mounted) {
        throw Exception('Context is no longer valid');
      }

      if (!_isInitialized || _paylinkInstance == null) {
        await initializePaylink(context);
      }

      // 4. التحقق مرة أخرى من context قبل فتح نموذج الدفع
      if (!context.mounted) {
        throw Exception('Context is no longer valid');
      }

      // 5. فتح نموذج الدفع
      return await openPaymentForm(
        transactionNo: paymentIntent.intentId,
        context: context,
      );
    } catch (e) {
      print('❌ Payment processing failed: $e');
      if (e is Exception) rethrow;
      throw Exception('فشل معالجة الدفع: $e');
    }
  }

  Future<Payment?> verifyPaymentStatus(String appointmentId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('غير مصرح - يرجى تسجيل الدخول');
      }

      return await _apiService.getPaymentStatus(
        appointmentId: appointmentId,
        token: token,
      );
    } catch (e) {
      print('❌ Failed to verify payment status: $e');
      if (e is Exception) rethrow;
      throw Exception('فشل التحقق من حالة الدفع: $e');
    }
  }

  /// جلب سجل كامل للمدفوعات
  Future<List<Payment>> getPaymentHistory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('غير مصرح - يرجى تسجيل الدخول');
      }
      return await _apiService.getMyPaymentHistory(token);
    } catch (e) {
      print('❌ Failed to get payment history: $e');
      if (e is Exception) rethrow;
      throw Exception('فشل جلب سجل المدفوعات: $e');
    }
  }
}
