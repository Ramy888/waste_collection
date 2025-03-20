
import 'collection_point_model.dart';

class RouteModel {
  final String id;
  final String name;
  final String date;
  final String assignedTeamId;
  final List<CollectionPointModel> collectionPoints;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> statistics;

  RouteModel({
    required this.id,
    required this.name,
    required this.date,
    required this.assignedTeamId,
    required this.collectionPoints,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.statistics,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      assignedTeamId: json['assignedTeamId'] as String,
      collectionPoints: (json['collectionPoints'] as List)
          .map((point) => CollectionPointModel.fromJson(point))
          .toList(),
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      statistics: json['statistics'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'assignedTeamId': assignedTeamId,
      'collectionPoints': collectionPoints.map((point) => point.toJson()).toList(),
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'statistics': statistics,
    };
  }

  double get completionPercentage {
    if (collectionPoints.isEmpty) return 0;
    final completed = collectionPoints
        .where((point) => point.status == 'completed')
        .length;
    return (completed / collectionPoints.length) * 100;
  }
}