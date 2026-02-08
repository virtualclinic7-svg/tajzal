import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../departments/departments_screen.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _appointmentsReloadKey = 0;
  final _authService = AuthService();
  final _apiService = ApiService();
  final Map<String, int> _badges = {};

  @override
  void initState() {
    super.initState();
    _loadAppointmentsCount();
  }

  Future<void> _loadAppointmentsCount() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return;
      }

      final appointments = await _apiService.getPatientAppointments(
        status: null,
        token: token,
        limit: 100,
      );

      final now = DateTime.now();
      final upcomingCount = appointments.appointments.where((apt) {
        final isUpcoming = apt.startAt.isAfter(now);
        final isActiveStatus =
            apt.status == 'CONFIRMED' ||
            apt.status == 'PENDING' ||
            apt.status == 'PENDING_CONFIRM';
        return isUpcoming && isActiveStatus;
      }).length;

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          setState(() {
            _badges[l10n.navAppointments] = upcomingCount;
          });
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);
    final textDirection = localeProvider != null
        ? LocaleService.getTextDirection(localeProvider.locale)
        : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const DepartmentsScreen(),
            AppointmentsScreen(key: ValueKey(_appointmentsReloadKey)),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                _appointmentsReloadKey++;
                // تحديث عدد المواعيد عند فتح صفحة المواعيد
                _loadAppointmentsCount();
              } else if (index == 0) {
                // تحديث عدد المواعيد عند العودة للشاشة الرئيسية
                _loadAppointmentsCount();
              }
            });
          },
          badges: _badges,
        ),
      ),
    );
  }
}
