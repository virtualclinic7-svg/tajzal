import 'package:flutter/material.dart';
import '../../config/text_styles.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/appointment.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import '../appointments/appointment_details_screen.dart';
import '../video_call/video_call_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  final _authService = AuthService();
  final _apiService = ApiService();

  bool _loading = true;
  String? _error;
  PaginatedAppointments? _pending;
  PaginatedAppointments? _confirmed;
  PaginatedAppointments? _completed;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _authService.getToken() ?? '';
      final results = await Future.wait([
        _apiService.getDoctorAppointments(
          status: 'PENDING_CONFIRM',
          token: token,
        ),
        _apiService.getDoctorAppointments(status: 'CONFIRMED', token: token),
        _apiService.getDoctorAppointments(status: 'COMPLETED', token: token),
      ]);
      setState(() {
        _pending = results[0];
        _confirmed = results[1];
        _completed = results[2];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'في الانتظار'),
              Tab(text: 'المؤكدة'),
              Tab(text: 'المكتملة'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: AppTextStyles.bodyLarge))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_pending?.appointments ?? []),
                      _buildList(_confirmed?.appointments ?? []),
                      _buildList(_completed?.appointments ?? []),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Appointment> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('لا توجد بيانات', style: AppTextStyles.bodyLarge),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final a = items[index];
          return Card(
            elevation: 0,
            child: ListTile(
              onTap: () => _showAppointmentDetails(a),
              title: Text(
                '${a.service?.name ?? 'خدمة'} • ${a.type}',
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: Text(
                '${a.startAt} • ${a.status}${a.status == 'CONFIRMED' && (a.paymentStatus ?? '') != 'COMPLETED' ? ' • الدفع قيد الانتظار' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: _buildActionsFor(a),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: items.length,
      ),
    );
  }

  Widget? _buildActionsFor(Appointment a) {
    final canStartVideoCall = _canStartVideoCall(a);

    if (a.status == 'PENDING_CONFIRM') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _confirmAppointment(a),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _rejectAppointment(a),
          ),
          if (canStartVideoCall)
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.blue),
              tooltip: 'بدء مكالمة الفيديو',
              onPressed: () => _startVideoCall(a),
            ),
        ],
      );
    }

    // زر بدء مكالمة الفيديو عندما يكون متاحًا (يشمل وضع الاختبار)
    if (canStartVideoCall) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.blue),
            tooltip: 'بدء مكالمة الفيديو',
            onPressed: () => _startVideoCall(a),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppointmentDetails(a),
          ),
        ],
      );
    }

    // زر تفاصيل الموعد للمواعيد الأخرى
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () => _showAppointmentDetails(a),
    );
  }

  bool _canStartVideoCall(Appointment appointment) {
    // Check if appointment type is VIDEO
    if (appointment.type != 'VIDEO') {
      return false;
    }

    // يجب أن يكون الموعد مؤكداً من لوحة التحكم
    if (appointment.status != 'CONFIRMED') {
      return false;
    }

    // التحقق من حالة الدفع - الطبيب يجب ألا يبدأ الموعد إلا إذا دفع المريض
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

  void _startVideoCall(Appointment appointment) async {
    if (!_canStartVideoCall(appointment)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن بدء مكالمة الفيديو الآن'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
              doctorName: user.role == 'DOCTOR'
                  ? user.name
                  : appointment.doctor?.name,
              patientName: user.role == 'PATIENT' ? user.name : null,
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

  void _showAppointmentDetails(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentDetailsScreen(appointment: appointment),
      ),
    ).then((_) {
      // تحديث القائمة بعد العودة
      _loadAll();
    });
  }

  Future<void> _confirmAppointment(Appointment a) async {
    try {
      final token = await _authService.getToken() ?? '';
      await _apiService.confirmAppointment(appointmentId: a.id, token: token);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تأكيد الموعد')));
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل التأكيد: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _rejectAppointment(Appointment a) async {
    final reason = await _promptReason();
    if (reason == null || reason.trim().isEmpty) return;
    try {
      final token = await _authService.getToken() ?? '';
      await _apiService.rejectAppointment(
        appointmentId: a.id,
        reason: reason.trim(),
        token: token,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم رفض الموعد')));
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل الرفض: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<String?> _promptReason() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final localeProvider = LocaleProvider.of(context);
        final textDirection = localeProvider != null
            ? LocaleService.getTextDirection(localeProvider.locale)
            : TextDirection.rtl;
        return Directionality(
          textDirection: textDirection,
          child: AlertDialog(
            title: Text(l10n.drRejectReason),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: l10n.drEnterReason),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.drCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: Text(l10n.drSave),
              ),
            ],
          ),
        );
      },
    );
  }
}
