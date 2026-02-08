import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/text_styles.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/appointment.dart';
import '../appointments/appointment_details_screen.dart';
import '../video_call/video_call_screen.dart';

class DoctorAppointmentsScreenNew extends StatefulWidget {
  const DoctorAppointmentsScreenNew({super.key});

  @override
  State<DoctorAppointmentsScreenNew> createState() =>
      _DoctorAppointmentsScreenNewState();
}

class _DoctorAppointmentsScreenNewState
    extends State<DoctorAppointmentsScreenNew>
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'المواعيد',
                        style: AppTextStyles.headline2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.filter,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: AppTextStyles.bodyMedium,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('انتظار'),
                              if ((_pending?.total ?? 0) > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_pending?.total ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Tab(text: 'المؤكدة'),
                      const Tab(text: 'المكتملة'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(_error!, style: AppTextStyles.bodyLarge),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAll,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(
                            _pending?.appointments ?? [],
                            isPending: true,
                          ),
                          _buildList(_confirmed?.appointments ?? []),
                          _buildList(
                            _completed?.appointments ?? [],
                            isCompleted: true,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<Appointment> items, {
    bool isPending = false,
    bool isCompleted = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending
                  ? Iconsax.timer_pause
                  : (isCompleted ? Iconsax.tick_circle : Iconsax.calendar_1),
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواعيد',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'ستظهر هنا المواعيد في الانتظار'
                  : (isCompleted
                        ? 'ستظهر هنا المواعيد المكتملة'
                        : 'ستظهر هنا المواعيد المؤكدة'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
        itemBuilder: (context, index) {
          final a = items[index];
          return _buildAppointmentCard(a, isPending: isPending);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment a, {bool isPending = false}) {
    final timeStr =
        '${a.startAt.hour.toString().padLeft(2, '0')}:${a.startAt.minute.toString().padLeft(2, '0')}';
    final dateStr = '${a.startAt.day}/${a.startAt.month}/${a.startAt.year}';
    final canStartVideoCall = _canStartVideoCall(a);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAppointmentDetails(a),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Date Badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: a.type == 'VIDEO'
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${a.startAt.day}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: a.type == 'VIDEO'
                                  ? const Color(0xFF6366F1)
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            _getMonthName(a.startAt.month),
                            style: AppTextStyles.caption.copyWith(
                              color: a.type == 'VIDEO'
                                  ? const Color(0xFF6366F1)
                                  : AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.patient?.name ?? 'مريض',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                a.type == 'VIDEO'
                                    ? Iconsax.video
                                    : Iconsax.hospital,
                                size: 14,
                                color: AppColors.textDisabled,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.service?.name ?? 'خدمة',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 14,
                                color: AppColors.textDisabled,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$timeStr - $dateStr',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(a.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(a.status),
                        style: AppTextStyles.caption.copyWith(
                          color: _getStatusColor(a.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Action Buttons
                if (isPending || canStartVideoCall) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (isPending) ...[
                        Expanded(
                          child: _buildActionButton(
                            label: 'قبول',
                            icon: Iconsax.tick_circle,
                            color: AppColors.success,
                            onTap: () => _confirmAppointment(a),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'رفض',
                            icon: Iconsax.close_circle,
                            color: AppColors.error,
                            onTap: () => _rejectAppointment(a),
                          ),
                        ),
                      ],
                      if (canStartVideoCall) ...[
                        if (isPending) const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'بدء المكالمة',
                            icon: Iconsax.video,
                            color: const Color(0xFF6366F1),
                            onTap: () => _startVideoCall(a),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
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
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.success;
      case 'PENDING_CONFIRM':
      case 'PENDING':
        return AppColors.warning;
      case 'CANCELLED':
      case 'REJECTED':
        return AppColors.error;
      case 'COMPLETED':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'مؤكد';
      case 'PENDING_CONFIRM':
      case 'PENDING':
        return 'في الانتظار';
      case 'CANCELLED':
        return 'ملغي';
      case 'REJECTED':
        return 'مرفوض';
      case 'COMPLETED':
        return 'مكتمل';
      default:
        return status;
    }
  }

  bool _canStartVideoCall(Appointment appointment) {
    if (appointment.type != 'VIDEO') return false;
    if (appointment.status != 'CONFIRMED') return false;

    if (appointment.requiresPayment == true) {
      if (appointment.paymentStatus != 'PAID' &&
          appointment.paymentStatus != 'COMPLETED') {
        return false;
      }
    }

    final now = DateTime.now();
    final appointmentStart = appointment.startAt;
    final appointmentEnd = appointment.endAt;
    final minutesUntilStart = appointmentStart.difference(now).inMinutes;
    final isAfterEnd = now.isAfter(appointmentEnd);

    return (minutesUntilStart <= 10 && !isAfterEnd);
  }

  void _startVideoCall(Appointment appointment) async {
    if (!_canStartVideoCall(appointment)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يمكن بدء مكالمة الفيديو الآن'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final role = user.role == 'DOCTOR' ? 'doctor' : 'patient';

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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    ).then((_) => _loadAll());
  }

  Future<void> _confirmAppointment(Appointment a) async {
    try {
      final token = await _authService.getToken() ?? '';
      await _apiService.confirmAppointment(appointmentId: a.id, token: token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تأكيد الموعد بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل التأكيد: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم رفض الموعد'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل الرفض: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('سبب الرفض', style: AppTextStyles.headline3),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'أدخل سبب الرفض',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }
}
