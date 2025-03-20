import 'package:flutter/material.dart';

import '../models/team_member_model.dart';

class TeamProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<TeamMemberModel> _teamMembers = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TeamMemberModel> get teamMembers => _teamMembers;
  List<TeamMemberModel> get activeTeamMembers =>
      _teamMembers.where((member) => member.isActive).toList();
  List<TeamMemberModel> get collectors =>
      _teamMembers.where((member) => member.role == 'collector').toList();
  List<TeamMemberModel> get teamLeaders =>
      _teamMembers.where((member) => member.role == 'team_leader').toList();

  // Initialize with dummy data
  Future<void> initializeDummyData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _teamMembers = [
      TeamMemberModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'team_leader',
        phoneNumber: '+1234567890',
        isActive: true,
        performance: {
          'completedRoutes': 45,
          'totalCollections': 520,
          'anomalies': 12,
          'rating': 4.8,
        },
      ),
      TeamMemberModel(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: 'collector',
        phoneNumber: '+1234567891',
        isActive: true,
        assignedRouteIds: ['1', '2'],
        performance: {
          'completedCollections': 182,
          'anomalies': 5,
          'rating': 4.6,
        },
      ),
      // Add more dummy team members
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTeamMember(TeamMemberModel updatedMember) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _teamMembers.indexWhere((member) => member.id == updatedMember.id);
    if (index != -1) {
      _teamMembers[index] = updatedMember;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleMemberStatus(String memberId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _teamMembers.indexWhere((member) => member.id == memberId);
    if (index != -1) {
      final member = _teamMembers[index];
      _teamMembers[index] = TeamMemberModel(
        id: member.id,
        name: member.name,
        email: member.email,
        role: member.role,
        phoneNumber: member.phoneNumber,
        profileImage: member.profileImage,
        isActive: !member.isActive,
        assignedRouteIds: member.assignedRouteIds,
        performance: member.performance,
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}