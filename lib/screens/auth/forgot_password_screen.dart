import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/dimensions.dart';
import '../../widgets/common/app_input_field.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    // Validate fields
    final emailError = Validators.validateEmail(_emailController.text);

    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.forgotPassword(_emailController.text.trim());

      setState(() {
        _successMessage = 'تم إرسال رمز التحقق إلى بريدك الإلكتروني';
        _isLoading = false;
      });

      // Navigate to OTP verification screen after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationScreen(email: _emailController.text.trim()),
            ),
          );
        }
      });
    } catch (e) {
      print('❌ Forgot password error in UI: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);
    final textDirection = localeProvider != null
        ? LocaleService.getTextDirection(localeProvider.locale)
        : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundLight,
                AppColors.background,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppDimensions.spacingXL),

                    // Logo Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingLG,
                      ),
                      child: Column(
                        children: [
                          // Logo Image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(AppDimensions.spacingMD),
                            child: Image.asset(
                              'assets/imgs/logotajal.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingLG),

                          // Title
                          Text(
                            l10n.authForgotPassword,
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingXS),
                          Text(
                            l10n.authEnterEmailReset,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.spacingXXL),

                    // Form Card
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingLG,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppDimensions.radiusXXL),
                          topLeft: Radius.circular(AppDimensions.radiusXXL),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title with Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    AppDimensions.spacingSM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMD,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spacingMD),
                                Expanded(
                                  child: Text(
                                    l10n.authResetPassword,
                                    style: AppTextStyles.headline2.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppDimensions.spacingXXL),

                            // Email Field
                            Builder(
                              builder: (context) {
                                String? emailError;
                                if (_emailController.text.isNotEmpty) {
                                  emailError = Validators.validateEmail(
                                    _emailController.text,
                                  );
                                }
                                return AppInputField(
                                  label: l10n.authEmail,
                                  hint: l10n.authEmailHint,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  icon: Icons.email_outlined,
                                  errorText:
                                      emailError ??
                                      (_errorMessage?.contains('email') == true
                                          ? _errorMessage
                                          : null),
                                  onChanged: (_) {
                                    setState(() {
                                      if (_errorMessage != null) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: _handleForgotPassword,
                                );
                              },
                            ),

                            SizedBox(height: AppDimensions.spacingSM),

                            // Error Message
                            if (_errorMessage != null &&
                                !_errorMessage!.contains('email'))
                              Container(
                                padding: EdgeInsets.all(
                                  AppDimensions.spacingMD,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD,
                                  ),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    SizedBox(width: AppDimensions.spacingSM),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Success Message
                            if (_successMessage != null)
                              Container(
                                padding: EdgeInsets.all(
                                  AppDimensions.spacingMD,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD,
                                  ),
                                  border: Border.all(
                                    color: AppColors.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                    SizedBox(width: AppDimensions.spacingSM),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: AppDimensions.spacingXL),

                            // Send OTP Button
                            Container(
                              height: AppDimensions.buttonHeight + 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.gradientPrimary,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : _handleForgotPassword,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD,
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.textInverse,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.send_rounded,
                                                color: AppColors.textInverse,
                                                size: 22,
                                              ),
                                              SizedBox(
                                                width: AppDimensions.spacingSM,
                                              ),
                                              Text(
                                                l10n.authSendOtp,
                                                style: AppTextStyles.button
                                                    .copyWith(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppDimensions.spacingXL),

                            // Back to Login Link
                            Container(
                              padding: EdgeInsets.all(AppDimensions.spacingMD),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'تذكرت كلمة السر؟',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      ' ${l10n.authLogin}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppDimensions.spacingMD),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
