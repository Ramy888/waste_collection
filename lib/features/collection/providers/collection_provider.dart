import 'package:flutter/material.dart';

import '../models/collection_point_model.dart';
import '../models/route_model.dart';

class CollectionProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  RouteModel? _currentRoute;
  List<RouteModel> _routes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  RouteModel? get currentRoute => _currentRoute;
  List<RouteModel> get routes => _routes;

  // Initialize with dummy data
  Future<void> initializeDummyData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final dummyCollectionPoints = [
      CollectionPointModel(
        id: '1',
        address: '123 Main St, City',
        latitude: 40.7128,
        longitude: -74.0060,
        status: 'pending',
      ),
      CollectionPointModel(
        id: '2',
        address: '456 Park Ave, City',
        latitude: 40.7589,
        longitude: -73.9851,
        status: 'completed',
        completedAt: DateTime.now(),
      ),
      // Add more dummy collection points as needed
    ];

    _routes = [
      RouteModel(
        id: '1',
        name: 'Morning Route',
        date: '2025-03-17',
        assignedTeamId: 'team1',
        collectionPoints: dummyCollectionPoints,
        status: 'in_progress',
        startTime: DateTime.now(),
        statistics: {
          'totalPoints': 10,
          'completedPoints': 5,
          'skippedPoints': 1,
          'anomalies': 2,
        },
      ),
      // Add more dummy routes as needed
    ];

    _currentRoute = _routes.first;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCollectionPoint(
      String routeId,
      CollectionPointModel updatedPoint,
      ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final routeIndex = _routes.indexWhere((route) => route.id == routeId);
    if (routeIndex != -1) {
      final pointIndex = _routes[routeIndex]
          .collectionPoints
          .indexWhere((point) => point.id == updatedPoint.id);
      if (pointIndex != -1) {
        final updatedPoints = List<CollectionPointModel>.from(
          _routes[routeIndex].collectionPoints,
        );
        updatedPoints[pointIndex] = updatedPoint;

        _routes[routeIndex] = RouteModel(
          id: _routes[routeIndex].id,
          name: _routes[routeIndex].name,
          date: _routes[routeIndex].date,
          assignedTeamId: _routes[routeIndex].assignedTeamId,
          collectionPoints: updatedPoints,
          status: _routes[routeIndex].status,
          startTime: _routes[routeIndex].startTime,
          endTime: _routes[routeIndex].endTime,
          statistics: _routes[routeIndex].statistics,
        );

        if (_currentRoute?.id == routeId) {
          _currentRoute = _routes[routeIndex];
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}