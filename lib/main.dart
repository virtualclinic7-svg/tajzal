import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:ui';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/api_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/doctor/doctor_main_screen.dart';
import 'screens/medical_records/medical_records_screen.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/locale_service.dart';
import 'l10n/app_localizations.dart';
import 'widgets/common/error_boundary.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  // معالجة أخطاء Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // تسجيل الخطأ في production
    print('❌ Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };

  // معالجة الأخطاء غير المعالجة
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // If Paylink throws an internal "Payment Error", handle it to avoid crashing
    // and signal the current payment attempt.
    final errorStr = error.toString();
    final stackStr = stack.toString();
    final isPaylinkStack =
        stackStr.contains('paylink_payment') ||
        stackStr.contains('package:paylink_payment/paylink_payment.dart');
    final isPaylinkPaymentException =
        errorStr.contains('Payment Error') ||
        errorStr.contains('Payment response code') ||
        errorStr.contains('Payment response');

    if (isPaylinkStack && isPaylinkPaymentException) {
      PaymentService.handleGlobalPaylinkError(error, stack);
      return true; // handled
    }

    // تسجيل الأخطاء غير المعالجة
    print('❌ Unhandled Error: $error');
    print('Stack: $stack');

    // في production، يمكن إرسال الخطأ إلى خدمة تسجيل الأخطاء
    // Crashlytics.recordError(error, stack);

    // Return false للسماح بمعالجة الخطأ الافتراضية
    return false;
  };

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          'Firebase initialization timeout',
          const Duration(seconds: 10),
        );
      },
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // Continue without Firebase - app can still function
    // Firebase is not critical for app startup
  }

  // Initialize Notification Service with error handling
  try {
    final notificationService = NotificationService();
    await notificationService.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          'NotificationService initialization timeout',
          const Duration(seconds: 10),
        );
      },
    );
    print('✅ NotificationService initialized successfully');
  } catch (e) {
    print('⚠️ NotificationService initialization failed: $e');
    // Continue without notifications - app can still function
    // Notifications are not critical for app startup
  }

  // Print API configuration for debugging
  ApiConfig.printConfig();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = LocaleService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.getLocale();
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  Future<void> _changeLocale(Locale locale) async {
    await LocaleService.setLocale(locale);
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: LocaleProvider(
        locale: _locale,
        onChangeLocale: _changeLocale,
        child: MaterialApp(
          key: ValueKey(_locale.toString()),
          title: 'تاج ازال',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SplashScreen(next: const AuthWrapper()),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const MainScreen(),
            '/doctor-dashboard': (context) => const DoctorMainScreen(),
            '/medical-records': (context) => const MedicalRecordsScreen(),
          },
        ),
      ),
    );
  }
}

class LocaleProvider extends InheritedWidget {
  final Locale locale;
  final Future<void> Function(Locale) onChangeLocale;

  const LocaleProvider({
    super.key,
    required this.locale,
    required this.onChangeLocale,
    required super.child,
  });

  static LocaleProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) {
    return locale != oldWidget.locale;
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  final _notificationService = NotificationService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final loggedIn = await _authService.isLoggedIn();

      // إذا كان المستخدم مسجل دخول، حاول جلب بيانات المستخدم
      if (loggedIn) {
        try {
          // احفظ الـ Future في state variable لتجنب استدعاء API بشكل متكرر
          // استخدم timeout لتجنب الانتظار الطويل
          _userFuture = _authService.getCurrentUser().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⚠️ getCurrentUser timeout, using local storage');
              // في حالة timeout، استخدم البيانات المحلية
              // نستخدم Future.value(null) كـ fallback
              return Future<User?>.value(null);
            },
          ).catchError((error) {
            print('⚠️ Error in getCurrentUser: $error');
            // في حالة الخطأ، حاول استخدام البيانات المحلية
            return _authService.getCurrentUser(forceRefresh: false)
                .catchError((e) {
              print('⚠️ Error loading from local storage: $e');
              return null;
            });
          });

          final user = await _userFuture;

          // تحقق من أن الـ widget ما زال موجوداً قبل المتابعة
          if (!mounted) return;

          // محاولة إرسال device token إلى backend (غير حرج)
          try {
            final token = await _authService.getToken();
            if (user != null && token != null) {
              await _notificationService.sendTokenToBackend(user.id, token)
                  .timeout(const Duration(seconds: 5));
              print('✅ Device token sent to backend on app start');
            }
          } catch (e) {
            print('⚠️ Failed to send device token on app start: $e');
            // لا نوقف عملية فتح التطبيق إذا فشل إرسال الـ token
          }
        } catch (e) {
          print('⚠️ Error loading user data: $e');
          // في حالة فشل جلب البيانات، استخدم البيانات المحلية
          // التطبيق يمكنه العمل بدون الاتصال بالـ API
        }
      }

      // تحقق من أن الـ widget ما زال موجوداً قبل استدعاء setState
      if (!mounted) return;

      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error checking auth status: $e');
      // في حالة حدوث خطأ، افتح شاشة تسجيل الدخول
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // تنظيف أي عمليات غير مكتملة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn) {
      return const LoginScreen();
    }

    // When logged in, determine role and route accordingly
    // استخدم الـ Future المحفوظ في state لتجنب استدعاء API بشكل متكرر
    _userFuture ??= _authService.getCurrentUser().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⚠️ getCurrentUser timeout in FutureBuilder');
        // في حالة timeout، حاول استخدام البيانات المحلية
        return _authService.getCurrentUser(forceRefresh: false);
      },
    );

    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // حالة الخطأ
        if (snapshot.hasError) {
          print('⚠️ Error loading user: ${snapshot.error}');
          // في حالة الخطأ، حاول استخدام البيانات المحلية
          return FutureBuilder<User?>(
            future: _authService.getCurrentUser(forceRefresh: false),
            builder: (context, localSnapshot) {
              if (localSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final user = localSnapshot.data;
              if (user?.role == 'DOCTOR') {
                return const DoctorMainScreen();
              }
              // حتى لو لم نجد بيانات محلية، افتح الشاشة الرئيسية
              return const MainScreen();
            },
          );
        }

        // حالة النجاح
        final user = snapshot.data;
        if (user?.role == 'DOCTOR') {
          return const DoctorMainScreen();
        }
        // حتى لو كان user null، افتح الشاشة الرئيسية
        return const MainScreen();
      },
    );
  }
}
