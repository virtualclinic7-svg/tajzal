import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/user.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import '../video_call/video_call_screen.dart';

import '../payments/payment_screen.dart';
import '../../services/payment_service.dart';
import '../../config/api_config.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  final _paymentService = PaymentService();
  bool _isLoading = false;
  Doctor? _doctor;
  Appointment? _currentAppointment;
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  bool _isOngoing = false;
  bool _isDoctor = false; // لتحديد إذا كان المستخدم طبيب
  User? _patient; // بيانات المريض

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
    _loadUserRole().then((_) {
      // بعد تحديد دور المستخدم، أعد تحميل الموعد للحصول على أحدث البيانات
      // أعد تحميل الموعد دائماً للحصول على أحدث البيانات (للمريض والطبيب)
      _reloadAppointment();
    });
    _ensureDoctorLoaded();
    _ensurePatientLoaded();
    _updateTime(updateState: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> _loadUserRole() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _isDoctor = user?.role == 'DOCTOR';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime({bool updateState = true}) {
    final now = DateTime.now();
    final startAt = appointment.startAt;
    final endAt = appointment.endAt;

    Duration remaining;
    bool ongoing;

    if (now.isBefore(startAt)) {
      remaining = startAt.difference(now);
      ongoing = false;
    } else if (now.isBefore(endAt)) {
      remaining = endAt.difference(now);
      ongoing = true;
    } else {
      remaining = Duration.zero;
      ongoing = false;
      _timer?.cancel();
    }

    if (updateState) {
      if (mounted) {
        setState(() {
          _timeRemaining = remaining;
          _isOngoing = ongoing;
        });
      }
    } else {
      _timeRemaining = remaining;
      _isOngoing = ongoing;
    }
  }

  // Getter للحصول على الموعد الحالي (المحدث أو الأصلي)
  Appointment get appointment => _currentAppointment ?? widget.appointment;

  Future<void> _ensureDoctorLoaded() async {
    // إذا لم تأتِ بيانات الطبيب ضمن الموعد، اجلبها من السيرفر
    if (appointment.doctor == null && appointment.doctorId.isNotEmpty) {
      try {
        final token = await _authService.getToken();
        if (token == null) return;
        final doctor = await _apiService.getDoctorById(
          doctorId: appointment.doctorId,
          token: token,
        );
        if (mounted) {
          setState(() {
            _doctor = doctor;
          });
        }
      } catch (_) {
        // تجاهل الخطأ ونبقي الاسم غير محدد إذا فشل
      }
    }
  }

  Future<void> _ensurePatientLoaded() async {
    // إذا كان المستخدم طبيباً ولم تأتِ بيانات المريض ضمن الموعد، حاول جلبها
    if (_isDoctor && appointment.patientId.isNotEmpty) {
      try {
        // محاولة جلب بيانات المريض من خلال المستخدم الحالي إذا كان هو المريض نفسه
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null && currentUser.id == appointment.patientId) {
          if (mounted) {
            setState(() {
              _patient = currentUser;
            });
          }
        }
      } catch (_) {
        // تجاهل الخطأ
      }
    }
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  String _getArabicWeekday(int weekday) {
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekdays[weekday - 1];
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? l10n.apptEvening : l10n.apptMorning;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day;
    final month = _getArabicMonth(dateTime.month);
    final year = dateTime.year;
    final weekday = _getArabicWeekday(dateTime.weekday);
    return '$weekday، $day $month $year';
  }

  String _getStatusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'PENDING_CONFIRM':
      case 'PENDING':
        return l10n.apptStatusPendingConfirm;
      case 'CONFIRMED':
        return l10n.apptStatusConfirmed;
      case 'CANCELLED':
        return l10n.apptStatusCancelled;
      case 'COMPLETED':
        return l10n.apptStatusCompleted;
      case 'NO_SHOW':
        return l10n.apptStatusNoShow;
      case 'REJECTED':
        return l10n.apptStatusRejected;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING_CONFIRM':
      case 'PENDING':
        return AppColors.warning;
      case 'CONFIRMED':
        return AppColors.info;
      case 'CANCELLED':
        return AppColors.error;
      case 'COMPLETED':
        return AppColors.success;
      case 'NO_SHOW':
        return AppColors.error;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTypeLabel(String type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'IN_PERSON':
        return l10n.apptTypeInPerson;
      case 'VIDEO':
        return l10n.apptTypeVideo;
      case 'CHAT':
        return l10n.apptTypeChat;
      default:
        return type;
    }
  }

  bool _canCancel() {
    final status = appointment.status;
    if (status != 'PENDING_CONFIRM' &&
        status != 'CONFIRMED' &&
        status != 'PENDING') {
      return false;
    }

    final now = DateTime.now();
    final hoursUntil = appointment.startAt.difference(now).inHours;
    return hoursUntil > 24;
  }

  bool _canStartVideoCall() {
    // Check if appointment type is VIDEO
    if (appointment.type != 'VIDEO') {
      return false;
    }

    // يجب أن يكون الموعد مؤكداً من لوحة التحكم
    if (appointment.status != 'CONFIRMED') {
      return false;
    }

    // التحقق من حالة الدفع إذا كان مطلوباً
    if (appointment.requiresPayment == true) {
      if (appointment.paymentStatus != 'PAID' &&
          appointment.paymentStatus != 'COMPLETED') {
        return false;
      }
    }

    final now = DateTime.now();
    final appointmentStart = appointment.startAt;
    final appointmentEnd = appointment.endAt;

    // التحقق من الوقت: الظهور قبل الموعد بـ 10 دقائق وحتى نهاية الموعد
    final minutesUntilStart = appointmentStart.difference(now).inMinutes;
    final isAfterEnd = now.isAfter(appointmentEnd);

    return (minutesUntilStart <= 10 && !isAfterEnd);
  }

  void _startVideoCall() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Determine role
      final role = user.role == 'DOCTOR' ? 'doctor' : 'patient';

      // Navigate to video call screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              appointmentId: appointment.id,
              role: role,
              doctorName: appointment.doctor?.name ?? _doctor?.name,
              patientName: user.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _reloadAppointment() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      setState(() => _isLoading = true);
      final updatedAppointment = await _apiService.getAppointmentById(
        appointmentId: appointment.id,
        token: token,
      );

      // طباعة بيانات الموعد للتحقق
      print('🔍 Reloaded Appointment Debug:');
      print('  - Patient: ${updatedAppointment.patient?.name}');
      print('  - Patient Avatar: ${updatedAppointment.patient?.avatar}');
      print('  - Patient ID: ${updatedAppointment.patient?.id}');
      print('  - Doctor: ${updatedAppointment.doctor?.name}');
      print('  - Doctor Avatar: ${updatedAppointment.doctor?.avatar}');
      print('  - Doctor ID: ${updatedAppointment.doctor?.id}');

      if (mounted) {
        setState(() {
          _currentAppointment = updatedAppointment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('⚠️ Error reloading appointment: $e');
      }
    }
  }

  void _navigateToPayment() async {
    try {
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              appointmentId: appointment.id,
              appointment: appointment,
            ),
          ),
        );

        // إذا تم الدفع بنجاح، إعادة تحميل بيانات الموعد
        if (result == true && mounted) {
          await _reloadAppointment();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث حالة الدفع'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _cancelAppointment() async {
    if (!_canCancel()) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apptCannotCancel),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إلغاء الموعد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب الإلغاء (اختياري)',
                  hintText: 'مثال: تغير في الخطط',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('رجوع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        setState(() => _isLoading = true);

        final token = await _authService.getToken();
        await _apiService.cancelAppointment(
          appointmentId: appointment.id,
          reason: reasonController.text.isNotEmpty
              ? reasonController.text
              : null,
          token: token,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الموعد بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطأ: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);
    final textDirection = localeProvider != null
        ? LocaleService.getTextDirection(localeProvider.locale)
        : TextDirection.rtl;

    final statusColor = _getStatusColor(appointment.status);
    final doctorName =
        appointment.doctor?.name ?? _doctor?.name ?? l10n.docDoctors;
    final serviceName = appointment.service?.name ?? l10n.deptServices;

    // تحديد الاسم والصورة بناءً على دور المستخدم
    final displayName = _isDoctor
        ? (appointment.patient?.name ?? 'مريض')
        : doctorName;
    final displaySubtitle = serviceName;

    // جلب صورة المريض أو الطبيب بناءً على دور المستخدم
    String? avatarPath;
    if (_isDoctor) {
      // إذا كان المستخدم طبيباً، اعرض صورة المريض
      // جرب أولاً من بيانات الموعد، ثم من البيانات المحملة
      avatarPath = appointment.patient?.avatar ?? _patient?.avatar;

      // طباعة للتحقق من البيانات
      print('🔍 Patient Avatar Debug:');
      print(
        '  - appointment.patient: ${appointment.patient != null ? "exists" : "null"}',
      );
      print('  - appointment.patient?.name: ${appointment.patient?.name}');
      print('  - appointment.patient?.avatar: ${appointment.patient?.avatar}');
      print('  - _patient?.avatar: ${_patient?.avatar}');
      print('  - Final avatarPath: $avatarPath');
    } else {
      // إذا كان المستخدم مريضاً، اعرض صورة الطبيب
      avatarPath = appointment.doctor?.avatar ?? _doctor?.avatar;

      // طباعة للتحقق من البيانات
      print('🔍 Doctor Avatar Debug (Patient View):');
      print(
        '  - appointment.doctor: ${appointment.doctor != null ? "exists" : "null"}',
      );
      print('  - appointment.doctor?.name: ${appointment.doctor?.name}');
      print('  - appointment.doctor?.avatar: ${appointment.doctor?.avatar}');
      print('  - _doctor?.avatar: ${_doctor?.avatar}');
      print('  - Final avatarPath: $avatarPath');
    }

    // بناء URL كامل للصورة
    final displayAvatarUrl = avatarPath != null && avatarPath.isNotEmpty
        ? (avatarPath.startsWith('http')
              ? avatarPath
              : ApiConfig.buildFullUrl(avatarPath))
        : null;

    // طباعة URL النهائي
    print('🔍 Final displayAvatarUrl: $displayAvatarUrl');
    print('🔍 Base URL: ${ApiConfig.baseUrl}');
    print('🔍 Base URL without /v1: ${ApiConfig.baseUrlWithoutV1}');

    final isPatientView = !_isDoctor;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Decorative Header Background
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isDoctor
                            ? AppColors.gradientSecondary
                            : AppColors.gradientPrimary,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),

                  // Main Content
                  SafeArea(
                    child: Column(
                      children: [
                        // Custom App Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  l10n.apptDetailsTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headline3.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Balance spacing
                            ],
                          ),
                        ),

                        // Scrollable Body
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                // Doctor/Patient Profile Card
                                _buildProfileCard(
                                  displayName,
                                  displaySubtitle,
                                  statusColor,
                                  isPatientView: isPatientView,
                                  avatarUrl: displayAvatarUrl,
                                ),

                                if (_timeRemaining.inSeconds > 0 &&
                                    [
                                      'PENDING',
                                      'PENDING_CONFIRM',
                                      'CONFIRMED',
                                    ].contains(appointment.status)) ...[
                                  const SizedBox(height: 20),
                                  _buildCountdownTimer(),
                                ],

                                const SizedBox(height: 24),

                                // Info Grid
                                _buildInfoGrid(),

                                // Sections
                                if (appointment.requiresPayment == true)
                                  _buildPaymentSection(),

                                if (appointment.notes?.isNotEmpty == true)
                                  _buildNotesSection(),

                                if (appointment.status == 'CANCELLED')
                                  _buildCancellationSection(),

                                const SizedBox(height: 30),

                                // Actions
                                _buildActionButtons(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileCard(
    String name,
    String subtitle,
    Color statusColor, {
    required bool isPatientView,
    String? avatarUrl,
  }) {
    // تحديد اللون والأيقونة بناءً على نوع العرض
    final gradientColors = isPatientView
        ? [AppColors.primary.withOpacity(0.8), AppColors.primary]
        : [AppColors.secondary.withOpacity(0.8), AppColors.secondary];
    final shadowColor = isPatientView
        ? AppColors.primary.withOpacity(0.3)
        : AppColors.secondary.withOpacity(0.3);
    final namePrefix = isPatientView ? 'د. ' : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // في حالة الخطأ، اعرض الأيقونة كبديل
                            return Center(
                              child: isPatientView
                                  ? Icon(
                                      Iconsax.user_octagon,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : Icon(
                                      Iconsax.profile_2user,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            );
                          },
                        ),
                      )
                    : Center(
                        // إذا لم تكن هناك صورة، اعرض الأيقونة
                        child: isPatientView
                            ? Icon(
                                Iconsax.user_octagon,
                                color: Colors.white,
                                size: 32,
                              )
                            : Icon(
                                Iconsax.profile_2user,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
              ),
              const SizedBox(width: 16),
              // Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!isPatientView)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'المريض',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isPatientView)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الطبيب',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$namePrefix$name',
                      style: AppTextStyles.headline3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.apptDetailsStatus,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusLabel(appointment.status, context),
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildInfoItem(
          Iconsax.calendar_1,
          'التاريخ',
          _formatDate(appointment.startAt),
          AppColors.primary,
        ),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return _buildInfoItem(
              Iconsax.clock,
              l10n.apptDetailsDateTime,
              '${_formatTime(appointment.startAt, context)} - ${_formatTime(appointment.endAt, context)}',
              AppColors.accent,
            );
          },
        ),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return _buildInfoItem(
              appointment.type == 'VIDEO'
                  ? Iconsax.video
                  : appointment.type == 'CHAT'
                  ? Iconsax.message
                  : Iconsax.location,
              l10n.apptDetailsType,
              _getTypeLabel(appointment.type, context),
              AppColors.secondary,
            );
          },
        ),
        if (appointment.price != null)
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return _buildInfoItem(
                Iconsax.money,
                l10n.apptDetailsPrice,
                '${appointment.price} ${l10n.apptDetailsPrice}',
                AppColors.success,
              );
            },
          )
        else
          _buildInfoItem(
            Iconsax.hashtag,
            'رقم الموعد',
            '#${appointment.id.substring(0, 6)}',
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const Spacer(),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final isPaid =
        appointment.paymentStatus == 'PAID' ||
        appointment.paymentStatus == 'COMPLETED';
    final isFailed = appointment.paymentStatus == 'FAILED';
    final statusColor = isPaid
        ? AppColors.success
        : isFailed
        ? AppColors.error
        : AppColors.warning;
    final statusText = isPaid
        ? 'تم الدفع بنجاح'
        : isFailed
        ? 'فشل الدفع'
        : 'قيد الانتظار';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.wallet, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الدفع',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (!isPaid)
                ElevatedButton(
                  onPressed: _isLoading ? null : _navigateToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('دفع الآن'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.document_text,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ملاحظات',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.notes!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationSection() {
    if (appointment.cancellationReason == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.info_circle, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'تم إلغاء الموعد',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            appointment.cancellationReason!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          if (appointment.cancelledAt != null) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                return Text(
                  '${_formatDate(appointment.cancelledAt!)} - ${_formatTime(appointment.cancelledAt!, context)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_canStartVideoCall())
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _startVideoCall,
              icon: const Icon(Iconsax.video, size: 24),
              label: const Text('بدء مكالمة الفيديو'),
              style: _primaryButtonStyle(AppColors.success),
            ),
          ),
        if (_canCancel()) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _cancelAppointment,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('إلغاء الموعد'),
            ),
          ),
        ],
      ],
    );
  }

  ButtonStyle _primaryButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: color.withOpacity(0.4),
    );
  }

  Widget _buildCountdownTimer() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    final color = _isOngoing ? AppColors.success : AppColors.primary;
    final label = _isOngoing ? 'الموعد جاري، ينتهي خلال' : 'يبدأ الموعد خلال';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (days > 0) ...[
                  _buildTimeUnit(days, 'يوم', color),
                  _buildTimeSeparator(),
                ],
                _buildTimeUnit(hours, 'ساعة', color),
                _buildTimeSeparator(),
                _buildTimeUnit(minutes, 'دقيقة', color),
                if (days == 0) ...[
                  _buildTimeSeparator(),
                  _buildTimeUnit(seconds, 'ثانية', color),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Monospace for stability
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 40,
      alignment: Alignment.topCenter,
      child: const Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
