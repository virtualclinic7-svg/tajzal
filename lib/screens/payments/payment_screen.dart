import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment.dart';
import '../../models/payment.dart';
import '../../l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final String appointmentId;
  final Appointment? appointment;
  final bool isNewBooking; // لتحديد إذا كان هذا حجز جديد يحتاج دفع

  const PaymentScreen({
    super.key,
    required this.appointmentId,
    this.appointment,
    this.isNewBooking = true, // افتراضياً يعتبر حجز جديد
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isProcessing = false;
  Payment? _payment;
  Appointment? _appointment;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب بيانات الموعد إذا لم تكن موجودة
      if (_appointment == null) {
        final token = await _authService.getToken();
        if (token != null) {
          // يمكن إضافة method لجلب الموعد هنا إذا لزم
        }
      }

      // محاولة جلب حالة الدفع
      // للحجوزات الجديدة قد لا يكون هناك payment بعد، وهذا طبيعي
      try {
        final payment = await _paymentService.verifyPaymentStatus(
          widget.appointmentId,
        );

        if (mounted) {
          setState(() {
            _payment = payment;
          });
        }
      } catch (paymentError) {
        // تجاهل الخطأ إذا كان هذا حجز جديد - سيتم إنشاء payment عند الضغط على زر الدفع
        print('⚠️ Payment status check: $paymentError');
        if (!widget.isNewBooking) {
          // فقط نرمي الخطأ إذا لم يكن حجز جديد
          rethrow;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // معالجة الدفع (سيتم تهيئة SDK تلقائياً إذا لزم الأمر)
      final result = await _paymentService.processPayment(
        appointmentId: widget.appointmentId,
        context: context,
      );

      if (mounted) {
        // التحقق من حالة الدفع بعد إتمام العملية
        await Future.delayed(const Duration(seconds: 2));
        await _loadPaymentInfo();

        // If Paylink returned error/timeout, give backend a short window to settle
        // (payment status can be updated asynchronously).
        if (result == PaymentResult.error &&
            (_payment == null || _payment!.status != PaymentStatus.completed)) {
          final deadline = DateTime.now().add(const Duration(seconds: 45));
          while (mounted && DateTime.now().isBefore(deadline)) {
            await Future.delayed(const Duration(seconds: 3));
            await _loadPaymentInfo();
            if (_payment != null &&
                _payment!.status == PaymentStatus.completed) {
              break;
            }
          }
        }

        setState(() {
          _isProcessing = false;
        });

        // عرض رسالة النجاح أو الخطأ
        final isCompleted =
            _payment != null && _payment!.status == PaymentStatus.completed;
        final l10n = AppLocalizations.of(context);
        
        if (result == PaymentResult.success || isCompleted) {
          setState(() {
            _successMessage = l10n?.paymentSuccess ?? 'تم الدفع بنجاح! تم تأكيد حجزك';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.paymentSuccess ?? 'تم الدفع بنجاح! تم تأكيد حجزك ✓'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // العودة للشاشة السابقة بعد ثانيتين
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else if (result == PaymentResult.cancel) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.paymentCancelled ?? 'تم إلغاء عملية الدفع'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _errorMessage = l10n?.paymentError ?? 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // حتى لو حدث خطأ، نتحقق من حالة الدفع من Backend
        // لأن الدفع قد يكون نجح بالفعل (خاصة مع خطأ "Payment Error" من SDK)
        print('⚠️ Exception in payment process: $e');
        print('Checking payment status from backend...');

        try {
          await Future.delayed(const Duration(seconds: 2));
          await _loadPaymentInfo();

          // إذا كان الدفع مكتمل، نعتبر العملية نجحت
          if (_payment != null && _payment!.status == PaymentStatus.completed) {
            final l10n = AppLocalizations.of(context);
            setState(() {
              _isProcessing = false;
              _successMessage = l10n?.paymentSuccess ?? 'تم الدفع بنجاح! تم تأكيد حجزك';
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.paymentSuccess ?? 'تم الدفع بنجاح! تم تأكيد حجزك ✓'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // العودة للشاشة السابقة بعد ثانيتين
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });
            return;
          }
        } catch (verifyError) {
          print('❌ Error verifying payment status: $verifyError');
        }

        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${_errorMessage ?? "فشلت عملية الدفع"}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n?.paymentTitle ?? 'الدفع',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رسالة توضيحية للحجز الجديد
                    if (widget.isNewBooking && _payment?.status != PaymentStatus.completed)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.warning.withOpacity(0.15),
                              AppColors.warning.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.info_circle,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n?.paymentRequired ?? 'الدفع مطلوب لتأكيد الحجز',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.paymentCompleteToConfirm ?? 'أكمل الدفع لتأكيد حجزك',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.paymentReservationExpiry ?? 'ملاحظة: سينتهي الحجز إذا لم يتم الدفع خلال 15 دقيقة',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Success Message
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withOpacity(0.15),
                              AppColors.success.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.tick_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error.withOpacity(0.15),
                              AppColors.error.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.info_circle,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Appointment Info Card (إذا كان هناك معلومات موعد)
                    if (_appointment != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: AppColors.gradientPrimary,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Iconsax.calendar_1,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n?.apptAppointmentDetails ?? 'تفاصيل الحجز',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Doctor Name
                              if (_appointment!.doctor != null)
                                _buildDetailRow(
                                  l10n?.apptDoctor ?? 'الطبيب',
                                  'د. ${_appointment!.doctor!.name}',
                                  Iconsax.user,
                                  AppColors.primary,
                                ),
                              if (_appointment!.doctor != null)
                                const SizedBox(height: 12),
                              
                              // Service Name
                              if (_appointment!.service != null)
                                _buildDetailRow(
                                  l10n?.apptDetailsService ?? 'الخدمة',
                                  _appointment!.service!.name,
                                  Iconsax.health,
                                  AppColors.secondary,
                                ),
                              if (_appointment!.service != null)
                                const SizedBox(height: 12),
                              
                              // Date & Time
                              _buildDetailRow(
                                l10n?.apptDetailsDateTime ?? 'التاريخ والوقت',
                                '${_appointment!.startAt.day}/${_appointment!.startAt.month}/${_appointment!.startAt.year} - ${_appointment!.startAt.hour}:${_appointment!.startAt.minute.toString().padLeft(2, '0')}',
                                Iconsax.clock,
                                AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Payment Details Card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.gradientPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Iconsax.wallet,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n?.paymentDetails ?? 'تفاصيل الدفع',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Amount
                            _buildDetailRow(
                              l10n?.paymentAmount ?? 'المبلغ',
                              '${_payment?.amount ?? _appointment?.price ?? 0} ${_payment?.currency ?? 'SAR'}',
                              Iconsax.dollar_circle,
                              AppColors.primary,
                            ),
                            const SizedBox(height: 16),

                            // Payment Status
                            if (_payment != null)
                              _buildDetailRow(
                                l10n?.paymentStatus ?? 'حالة الدفع',
                                _payment!.status.arabicLabel,
                                _payment!.status == PaymentStatus.completed
                                    ? Iconsax.tick_circle
                                    : Iconsax.clock,
                                _payment!.status == PaymentStatus.completed
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Button
                    if (_payment == null ||
                        _payment!.status != PaymentStatus.completed)
                      Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: _isProcessing
                              ? null
                              : const LinearGradient(
                                  colors: AppColors.gradientPrimary,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: _isProcessing
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : null,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: _isProcessing
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _processPayment,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Iconsax.wallet, size: 26),
                          label: Text(
                            _isProcessing 
                                ? (l10n?.paymentProcessing ?? 'جاري المعالجة...') 
                                : (l10n?.paymentPayNow ?? 'الدفع الآن'),
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 19,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white.withOpacity(
                              0.7,
                            ),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
