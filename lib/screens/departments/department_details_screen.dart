import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../models/department.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../doctors/doctors_screen.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final Department department;

  const DepartmentDetailsScreen({super.key, required this.department});

  @override
  State<DepartmentDetailsScreen> createState() =>
      _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  final _apiService = ApiService();
  late Future<List<Service>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _apiService.getDepartmentServices(
      departmentId: widget.department.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: widget.department.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.department.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.background,
                  ),
                  child: widget.department.logoUrl == null
                      ? Center(
                          child: Icon(
                            Iconsax.health,
                            size: 80,
                            color: AppColors.textDisabled,
                          ),
                        )
                      : null,
                ),
                // Gradient for text visibility if needed, though card slides up
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom App Bar Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: _buildCircleButton(
              icon: Iconsax.heart,
              onTap: () {}, // Implement favorite Toggle
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: _buildCircleButton(
              icon: Iconsax
                  .arrow_right_1, // RTL arrow usually points left? Arabic: Right arrow implies back? No, RTL back is usually right arrow on left side or left arrow on right side?
              // Standard Android RTL back button points RIGHT.
              // Standard iOS RTL back button points RIGHT.
              // Wait, in Iconsax arrow_right points right.
              // In RTL, "Back" is usually on the Right side of the screen pointing Left? No, usually Left side pointing right.
              // Let's stick to standard behavior. `Navigator.pop`.
              onTap: () => Navigator.pop(context),
            ),
          ),

          // Main Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.department.name,
                    style: AppTextStyles.headline1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location / Description Placeholder
                  if (widget.department.description != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.location,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.department.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Phone placeholder - as requested "add data based on backend" - if active?
                  // We don't have phone in Department model. Skipping or using placeholder if insisted?
                  // User said "add data based on backend". I will stick to what I have.
                  const SizedBox(height: 16),
                  // Rating Placeholder - "4.9 (Star)"
                  Row(
                    children: [
                      Text(
                        '4.9',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Services Title
                  Text(
                    AppLocalizations.of(context)!.deptServices,
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Services List (Chips)
                  Expanded(
                    child: FutureBuilder<List<Service>>(
                      future: _servicesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          // If no services, maybe show doctors or just "No services available"
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.deptNoServices,
                              style: AppTextStyles.bodyMedium,
                            ),
                          );
                        }

                        // Display as wrapped chips
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: snapshot.data!.map((service) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  service.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Location Map Placeholder (Image) - User said "I don't want the Location"
                  // But the image showed it. User said "Also I don't want the Location".
                  // I will assume they mean the map/address SECTION. So I will SKIP it.
                  const SizedBox(height: 16),

                  // Bottom Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Doctors List for appointment?
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorsScreen(
                              departmentId: widget.department.id,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.docBook,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
