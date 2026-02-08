import '../config/api_config.dart';

class Department {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final String? logoUrl;
  final String? icon;
  final Map<String, String>? workingHours;

  Department({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.logoUrl,
    this.icon,
    this.workingHours,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    // تحويل logoUrl النسبي إلى URL كامل
    String? logoUrl = json['logoUrl'];
    if (logoUrl != null && logoUrl.isNotEmpty) {
      logoUrl = ApiConfig.buildFullUrl(logoUrl);
    }
    
    // تحويل icon أيضاً إذا كان مسار نسبي
    String? icon = json['icon'];
    if (icon != null && icon.isNotEmpty && (icon.startsWith('/static') || icon.startsWith('/'))) {
      icon = ApiConfig.buildFullUrl(icon);
    }
    
    // Parse workingHours if exists
    Map<String, String>? workingHours;
    if (json['workingHours'] != null) {
      final wh = json['workingHours'] as Map<String, dynamic>;
      workingHours = {
        'startTime': wh['startTime']?.toString() ?? '',
        'endTime': wh['endTime']?.toString() ?? '',
      };
    }
    
    return Department(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? false,
      logoUrl: logoUrl,
      icon: icon,
      workingHours: workingHours,
    );
  }
}

