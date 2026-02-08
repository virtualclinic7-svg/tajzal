import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import '../appointments/appointments_screen.dart';
import '../payments/payment_history_screen.dart';
import 'profile_edit_screen.dart';
import 'support/tickets_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _apiService = ApiService();
  late Future<User?> _userFuture;
  bool _isRefreshing = false;

  // Statistics
  int _appointmentsCount = 0;
  int _completedAppointmentsCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getCurrentUser();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _isLoadingStats = false;
        });
        return;
      }

      final results = await Future.wait([
        _apiService.getPatientAppointments(token: token, limit: 1),
        _apiService.getPatientAppointments(
          token: token,
          status: 'COMPLETED',
          limit: 1,
        ),
      ]);

      setState(() {
        _appointmentsCount = results[0].total;
        _completedAppointmentsCount = results[1].total;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('⚠️ Error loading statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
      // Don't show error to user, just use 0 values
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final user = await _authService.refreshCurrentUser();
      await _loadStatistics();
      setState(() {
        _userFuture = Future.value(user);
        _isRefreshing = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profDataUpdated),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String errorMessage = l10n.commonError;
        if (e.toString().contains('انتهت صلاحية')) {
          errorMessage = l10n.profSessionExpired;
          // Navigate to login if session expired
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        } else if (e.toString().contains('غير مصرح')) {
          errorMessage = l10n.profUnauthorized;
        } else if (e.toString().contains('لا يمكن الاتصال')) {
          errorMessage = l10n.profConnectionError;
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: AppColors.primary,
          child: FutureBuilder<User?>(
            future: _userFuture,
            builder: (context, snapshot) {
              final l10n = AppLocalizations.of(context)!;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isRefreshing) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.commonLoading,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                final error = snapshot.error;
                String errorMessage = l10n.commonError;
                bool shouldNavigateToLogin = false;

                if (error.toString().contains('انتهت صلاحية') ||
                    error.toString().contains('401') ||
                    error.toString().contains('غير مصرح')) {
                  errorMessage = l10n.profSessionExpired;
                  shouldNavigateToLogin = true;
                } else if (error.toString().contains('لا يمكن الاتصال')) {
                  errorMessage = l10n.profConnectionError;
                } else {
                  errorMessage = error.toString().replaceAll('Exception: ', '');
                }

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error.withOpacity(0.15),
                                AppColors.error.withOpacity(0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Iconsax.info_circle,
                            size: 64,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          errorMessage,
                          style: AppTextStyles.headline3.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: shouldNavigateToLogin
                              ? () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                }
                              : () {
                                  setState(() {
                                    _userFuture = _authService.getCurrentUser();
                                  });
                                },
                          icon: Icon(
                            shouldNavigateToLogin
                                ? Iconsax.login
                                : Iconsax.refresh,
                            size: 20,
                          ),
                          label: Text(
                            shouldNavigateToLogin
                                ? AppLocalizations.of(context)!.authLogin
                                : AppLocalizations.of(context)!.commonRetry,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.data == null) {
                final l10n = AppLocalizations.of(context)!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.profNoUserData,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        icon: const Icon(Icons.login),
                        label: Text(AppLocalizations.of(context)!.authLogin),
                      ),
                    ],
                  ),
                );
              }

              final user = snapshot.data!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.profProfile,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: _isRefreshing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Iconsax.refresh,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                            onPressed: _isRefreshing ? null : _refreshProfile,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildProfileHeader(user),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildStatistics(),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMenuSection(context),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Avatar with gradient border
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.white,
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                        child: const Icon(
                          Iconsax.user,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.edit_2,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          user.name,
          style: AppTextStyles.headline2.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.sms,
              size: 16,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              user.email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.success.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.role == 'PATIENT' ? l10n.profPatient : user.role,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingStats) {
      return Row(
        children: [
          Expanded(child: _buildStatCard(l10n.profAppointments, '...', Icons.event)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(l10n.profSessions, '...', Icons.video_call)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.profAppointments,
            _appointmentsCount.toString(),
            Icons.event,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            l10n.profSessions,
            _completedAppointmentsCount.toString(),
            Icons.video_call,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
    Color iconColor;
    bool isClickable = false;

    if (title == l10n.profAppointments) {
      iconColor = AppColors.primary;
      isClickable = true;
    } else if (title == 'السجلات') {
      iconColor = AppColors.info;
      isClickable = true;
    } else if (title == l10n.profSessions) {
      iconColor = AppColors.success;
    } else {
      iconColor = AppColors.primary;
    }

    Widget cardContent = Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.1), width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          final l10n = AppLocalizations.of(context)!;
          if (title == l10n.profAppointments) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppointmentsScreen(),
              ),
            );
          }
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildMenuSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final menuGroups = [
      {
        'title': l10n.profPersonalSettings,
        'items': [
          {
            'icon': Iconsax.profile_circle,
            'title': l10n.profEditProfile,
            'color': AppColors.primary,
            'onTap': () async {
              final user = await _userFuture;
              if (user != null && context.mounted) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(user: user),
                  ),
                );
                if (result == true) {
                  _refreshProfile();
                }
              }
            },
          },
          {
            'icon': Iconsax.wallet,
            'title': l10n.profPayments,
            'color': AppColors.success,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
          },
        ],
      },
      {
        'title': l10n.profGeneralSettings,
        'items': [
          {
            'icon': Iconsax.translate,
            'title': l10n.profLanguage,
            'color': AppColors.accent,
            'onTap': () => _showLanguageDialog(context),
          },
          {
            'icon': Iconsax.message_question,
            'title': l10n.profHelpSupport,
            'color': AppColors.warning,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TicketsListScreen(),
                ),
              );
            },
          },
        ],
      },
      {
        'title': l10n.profAccount,
        'items': [
          {
            'icon': Iconsax.logout,
            'title': l10n.authLogout,
            'color': AppColors.error,
            'onTap': () => _showLogoutDialog(context),
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: menuGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
              child: Text(
                group['title'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.textDisabled.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: (group['items'] as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final items = group['items'] as List;
                  final isLast = index == items.length - 1;

                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: item['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: item['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item['title'] as String,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Iconsax.arrow_left_2,
                                  color: AppColors.textDisabled,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 64,
                          endIndent: 16,
                          color: AppColors.textDisabled.withOpacity(0.05),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);
    if (localeProvider == null) return;

    final currentLocale = localeProvider.locale;
    final textDirection = LocaleService.getTextDirection(currentLocale);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: textDirection,
          child: AlertDialog(
            title: Text(l10n.profLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.profArabic),
                  trailing: currentLocale.languageCode == 'ar'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await localeProvider.onChangeLocale(
                      const Locale('ar', 'SA'),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    // Force rebuild to update UI
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.profEnglish),
                  trailing: currentLocale.languageCode == 'en'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await localeProvider.onChangeLocale(
                      const Locale('en', 'US'),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    // Force rebuild to update UI
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Iconsax.logout, color: AppColors.error),
              const SizedBox(width: 12),
              Text(
                l10n.authLogout,
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.profLogoutConfirm,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.commonNo,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _authService.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(l10n.commonYes),
            ),
          ],
        );
      },
    );
  }
}
