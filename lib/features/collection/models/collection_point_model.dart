class CollectionPointModel {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String status; // 'pending', 'completed', 'skipped'
  final DateTime? completedAt;
  final String? notes;
  final List<String>? photos;
  final Map<String, dynamic>? anomalies;

  CollectionPointModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.completedAt,
    this.notes,
    this.photos,
    this.anomalies,
  });

  factory CollectionPointModel.fromJson(Map<String, dynamic> json) {
    return CollectionPointModel(
      id: json['id'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      status: json['status'] as String,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList(),
      anomalies: json['anomalies'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'photos': photos,
      'anomalies': anomalies,
    };
  }
}