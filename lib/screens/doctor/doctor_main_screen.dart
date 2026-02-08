import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'doctor_home_screen_new.dart';
import 'doctor_appointments_screen_new.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_services_screen.dart';
import '../../widgets/navigation/doctor_bottom_nav_bar.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
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
      if (token == null) return;

      final pendingRes = await _apiService.getDoctorAppointments(
        status: 'PENDING_CONFIRM',
        page: 1,
        limit: 100,
        token: token,
      );

      if (mounted) {
        setState(() {
          _badges['المواعيد'] = pendingRes.total;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const DoctorHomeScreenNew(),
            DoctorAppointmentsScreenNew(key: ValueKey(_appointmentsReloadKey)),
            const DoctorScheduleScreen(),
            const DoctorServicesScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: DoctorBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) {
                _appointmentsReloadKey++;
                _loadAppointmentsCount();
              } else if (index == 0) {
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
