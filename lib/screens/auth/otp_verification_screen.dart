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

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtpAndResetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    // Validate fields
    final otpError = Validators.validateOtp(_otpController.text);
    final passwordError = Validators.validatePassword(_passwordController.text);
    final confirmPasswordError = Validators.validateConfirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (otpError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      setState(() {
        _errorMessage = otpError ?? passwordError ?? confirmPasswordError;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verifyOtpAndResetPassword(
        widget.email,
        _otpController.text.trim(),
        _passwordController.text,
      );

      // Show success message and navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authPasswordChangedSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to login screen after showing success message
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (Route<dynamic> route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('❌ OTP verification error in UI: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPassword(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authOtpResent),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Resend OTP error in UI: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
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
                            l10n.authOtpVerification,
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingXS),
                          Text(
                            l10n.authOtpSubtitle,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppDimensions.spacingSM),
                          Text(
                            widget.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
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
                                    Icons.verified_user_outlined,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spacingMD),
                                Expanded(
                                  child: Text(
                                    l10n.authOtpVerification,
                                    style: AppTextStyles.headline2.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppDimensions.spacingXXL),

                            // OTP Field
                            Builder(
                              builder: (context) {
                                String? otpError;
                                if (_otpController.text.isNotEmpty) {
                                  otpError = Validators.validateOtp(
                                    _otpController.text,
                                  );
                                }
                                return AppInputField(
                                  label: l10n.authOtpCode,
                                  hint: l10n.authOtpCodeHint,
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.pin_outlined,
                                  maxLength: 6,
                                  errorText:
                                      otpError ??
                                      (_errorMessage?.contains('OTP') == true
                                          ? _errorMessage
                                          : null),
                                  onChanged: (_) {
                                    setState(() {
                                      if (_errorMessage != null) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  textInputAction: TextInputAction.next,
                                );
                              },
                            ),

                            SizedBox(height: AppDimensions.spacingLG),

                            // New Password Field
                            Builder(
                              builder: (context) {
                                String? passwordError;
                                if (_passwordController.text.isNotEmpty) {
                                  passwordError = Validators.validatePassword(
                                    _passwordController.text,
                                  );
                                }
                                return AppInputField(
                                  label: l10n.authNewPassword,
                                  hint: l10n.authNewPasswordHint,
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  icon: Icons.lock_outlined,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  errorText:
                                      passwordError ??
                                      (_errorMessage?.contains('password') ==
                                              true
                                          ? _errorMessage
                                          : null),
                                  onChanged: (_) {
                                    setState(() {
                                      if (_errorMessage != null) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  textInputAction: TextInputAction.next,
                                );
                              },
                            ),

                            SizedBox(height: AppDimensions.spacingLG),

                            // Confirm Password Field
                            Builder(
                              builder: (context) {
                                String? confirmPasswordError;
                                if (_confirmPasswordController
                                    .text
                                    .isNotEmpty) {
                                  confirmPasswordError =
                                      Validators.validateConfirmPassword(
                                        _passwordController.text,
                                        _confirmPasswordController.text,
                                      );
                                }
                                return AppInputField(
                                  label: l10n.authConfirmPassword,
                                  hint: l10n.authConfirmPasswordHint,
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  icon: Icons.lock_reset_outlined,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  errorText: confirmPasswordError,
                                  onChanged: (_) {
                                    setState(() {
                                      if (_errorMessage != null) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: _handleVerifyOtpAndResetPassword,
                                );
                              },
                            ),

                            SizedBox(height: AppDimensions.spacingSM),

                            // Error Message
                            if (_errorMessage != null &&
                                !_errorMessage!.contains('OTP') &&
                                !_errorMessage!.contains('password'))
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

                            SizedBox(height: AppDimensions.spacingXL),

                            // Verify and Reset Button
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
                                      : _handleVerifyOtpAndResetPassword,
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
                                                Icons.check_circle_rounded,
                                                color: AppColors.textInverse,
                                                size: 22,
                                              ),
                                              SizedBox(
                                                width: AppDimensions.spacingSM,
                                              ),
                                              Text(
                                                l10n.authChangePassword,
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

                            SizedBox(height: AppDimensions.spacingLG),

                            // Resend OTP Link
                            TextButton(
                              onPressed: _isLoading ? null : _resendOtp,
                              child: Text(
                                l10n.authResendCode,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),

                            SizedBox(height: AppDimensions.spacingLG),

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
                                    l10n.authRememberPassword,
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
