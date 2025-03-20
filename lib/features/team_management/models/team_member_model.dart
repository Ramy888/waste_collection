class TeamMemberModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'collector' or 'team_leader'
  final String? phoneNumber;
  final String? profileImage;
  final bool isActive;
  final List<String>? assignedRouteIds;
  final Map<String, dynamic>? performance;

  TeamMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImage,
    this.isActive = true,
    this.assignedRouteIds,
    this.performance,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      assignedRouteIds: (json['assignedRouteIds'] as List?)?.map((e) => e as String).toList(),
      performance: json['performance'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isActive': isActive,
      'assignedRouteIds': assignedRouteIds,
      'performance': performance,
    };
  }
}