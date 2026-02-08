import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../models/appointment.dart';
import '../../models/department.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import '../departments/departments_screen.dart';
import '../appointments/appointments_screen.dart';
import '../departments/department_details_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _apiService = ApiService();
  final _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  late final Future _userFuture = _authService.getCurrentUser();
  late Future<PaginatedAppointments> _appointmentsFuture;
  late Future<List<Department>> _departmentsFuture;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    _appointmentsFuture = _getUpcomingAppointments();
    _departmentsFuture = _apiService.getPublicDepartments();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  Future<PaginatedAppointments> _getUpcomingAppointments() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return PaginatedAppointments(
          appointments: [],
          total: 0,
          page: 1,
          limit: 10,
          totalPages: 0,
        );
      }
      return await _apiService.getPatientAppointments(
        status: null, // Fetch all to filter locally for upcoming
        token: token,
        limit: 20,
      );
    } catch (e) {
      return PaginatedAppointments(
        appointments: [],
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
    await _loadUnreadCount();
  }

  String _formatWorkingHours(Department department) {
    if (department.workingHours == null ||
        department.workingHours!['startTime'] == null ||
        department.workingHours!['endTime'] == null) {
      return '08:00 ص - 05:00 م'; // Default fallback
    }

    String formatTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        if (parts.length < 2) return timeStr;

        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = parts[1].padLeft(2, '0');

        if (hour == 0) {
          return '12:$minute ص';
        } else if (hour < 12) {
          return '$hour:$minute ص';
        } else if (hour == 12) {
          return '12:$minute م';
        } else {
          return '${hour - 12}:$minute م';
        }
      } catch (e) {
        return timeStr;
      }
    }

    final startTime = formatTime(department.workingHours!['startTime']!);
    final endTime = formatTime(department.workingHours!['endTime']!);
    return '$startTime - $endTime';
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
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(l10n.homeMyAppointments, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsScreen(),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildAppointmentCard(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(l10n.homeMedicalDepartments, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepartmentsScreen(),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildDepartmentsScroll(),
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (Header and Search Bar and SectionHeader and AppointmentCard are fine)
  // Skipping them in replacement to avoid huge block, searching for unique anchor if possible.
  // Actually, I can't easily skip blocks with replace_file_content if I want to rewrite multiple disparate parts.
  // But wait, the previous tool showed lines 380-440 which covers buildCategoriesList.
  // I need to add state variables at the top. I'll do this in multiple edits or one big edit if I include surrounding context.

  // Let's first add the state and methods using MultiReplace or smart targeting.
  // Using replace_file_content on the class body start seems best for state.

  // I will first replace the _HomeScreenState class start to add variable and updated methods.

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? l10n.homeGuest;
        final avatar = user?.avatar;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeGreeting,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                    // Reload unread count after returning from notifications screen
                    _loadUnreadCount();
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.notification,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? const Icon(Iconsax.user, color: AppColors.primary)
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DepartmentsScreen(initialSearchQuery: value.trim()),
              ),
            );
          }
        },
        decoration: InputDecoration(
          hintText: l10n.homeSearchHint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal,
            color: AppColors.textDisabled,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            l10n.homeSeeAll,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard() {
    return FutureBuilder<PaginatedAppointments>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final appointments = snapshot.data?.appointments ?? [];
        final upcoming = appointments.where((apt) {
          final now = DateTime.now();
          return (apt.status == 'CONFIRMED' ||
                  apt.status == 'PENDING' ||
                  apt.status == 'PENDING_CONFIRM') &&
              apt.endAt.isAfter(now);
        }).toList();

        upcoming.sort((a, b) => a.startAt.compareTo(b.startAt));

        if (upcoming.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradientSecondary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Iconsax.calendar_tick,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.homeNoUpcomingAppointments,
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepartmentsScreen(),
                        ),
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.apptBookAppointment,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Use the Stack Widget for multiple appointments
        return _AppointmentStack(appointments: upcoming);
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
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

  Widget _buildDepartmentsScroll() {
    return FutureBuilder<List<Department>>(
      future: _departmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final departments = snapshot.data!;

        return SizedBox(
          height: 280, // Height to accommodate the card
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: departments.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280, // Fixed width for horizontal card
                child: _buildDepartmentHomeCard(departments[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentHomeCard(Department department) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DepartmentDetailsScreen(department: department),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Section
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      color: AppColors.background,
                      image: department.logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(department.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: department.logoUrl == null
                        ? Center(
                            child: Icon(
                              Iconsax.health,
                              size: 48,
                              color: AppColors.textDisabled,
                            ),
                          )
                        : null,
                  ),
                  // Heart/Favorite Icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.heart,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Time Row
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatWorkingHours(department),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location Row
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            department.description ?? 'الموقع غير متوفر',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}

class _AppointmentStack extends StatefulWidget {
  final List<Appointment> appointments;

  const _AppointmentStack({required this.appointments});

  @override
  State<_AppointmentStack> createState() => _AppointmentStackState();
}

class _AppointmentStackState extends State<_AppointmentStack> {
  int _currentIndex = 0;
  double _dragOffset = 0.0;
  final double _dragThreshold = 100.0;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.appointments.length) {
      if (widget.appointments.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
      }
      return const SizedBox(height: 180);
    }

    final int count = widget.appointments.length;
    final List<Widget> stackChildren = [];

    // Bottom Card (Index + 2)
    if (count > 2) {
      final index = (_currentIndex + 2) % count;
      stackChildren.add(_buildBackgroundCard(widget.appointments[index], 2));
    }

    // Middle Card (Index + 1)
    if (count > 1) {
      final index = (_currentIndex + 1) % count;
      stackChildren.add(_buildBackgroundCard(widget.appointments[index], 1));
    }

    // Top Card (Index + 0) - Interactive
    if (count > 0) {
      final index = (_currentIndex) % count;
      // The interactive card MUST have Positioned as the top-level widget in the Stack children list.
      stackChildren.add(
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dx;
              });
            },
            onHorizontalDragEnd: (details) {
              if (_dragOffset.abs() > _dragThreshold) {
                // Swipe away
                setState(() {
                  _currentIndex =
                      (_currentIndex + 1) % widget.appointments.length;
                  _dragOffset = 0;
                });
              } else {
                // Spring back
                setState(() {
                  _dragOffset = 0;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: Transform.rotate(
                angle: _dragOffset / 1000,
                child: _AppointmentCardContent(apt: widget.appointments[index]),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: stackChildren,
      ),
    );
  }

  Widget _buildBackgroundCard(Appointment apt, int stackIndex) {
    final double scale = 1.0 - (stackIndex * 0.05);
    final double yOffset = stackIndex * 15.0;
    final double opacity = stackIndex == 0 ? 1.0 : (1.0 - (stackIndex * 0.2));

    return Positioned(
      top: yOffset,
      left: 0,
      right: 0,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: _AppointmentCardContent(apt: apt),
        ),
      ),
    );
  }
}

class _AppointmentCardContent extends StatelessWidget {
  final Appointment apt;

  const _AppointmentCardContent({required this.apt});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientSecondary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.user, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.doctor?.name ?? 'طبيب',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apt.service?.name ?? 'استشارة طبية',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.arrow_circle_left,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.calendar_1, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${apt.startAt.day} ${_getMonthName(apt.startAt.month)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Iconsax.clock, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${apt.startAt.hour}:${apt.startAt.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CountdownTimer(targetDate: apt.startAt),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
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
}

class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;

  const _CountdownTimer({required this.targetDate});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
        final now = DateTime.now();
        final difference = widget.targetDate.difference(now);

        if (difference.isNegative) {
          return const SizedBox.shrink();
        }

        final days = difference.inDays;
        final hours = difference.inHours % 24;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'متبقي:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              _buildTimeUnit(
                days.toString(),
                'ي',
              ), // abbreviated labels for space
              _buildSeparator(),
              _buildTimeUnit(hours.toString(), 'س'),
              _buildSeparator(),
              _buildTimeUnit(minutes.toString(), 'د'),
              _buildSeparator(),
              _buildTimeUnit(seconds.toString(), 'ث'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
