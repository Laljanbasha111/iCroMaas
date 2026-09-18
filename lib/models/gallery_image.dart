class GalleryImage {
  final String id;
  final String path;
  final String cropType;
  final double healthScore;
  final String disease;
  final String date;

  GalleryImage({
    required this.id,
    required this.path,
    required this.cropType,
    required this.healthScore,
    required this.disease,
    required this.date,
  });

  factory GalleryImage.fromMap(Map<String, dynamic> map) {
    return GalleryImage(
      id: map['id'] ?? '',
      path: map['path'] ?? '',
      cropType: map['cropType'] ?? 'Unknown',
      healthScore: (map['healthScore'] ?? 0).toDouble(),
      disease: map['disease'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'cropType': cropType,
      'healthScore': healthScore,
      'disease': disease,
      'date': date,
    };
  }

  GalleryImage copyWith({
    String? id,
    String? path,
    String? cropType,
    double? healthScore,
    String? disease,
    String? date,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      path: path ?? this.path,
      cropType: cropType ?? this.cropType,
      healthScore: healthScore ?? this.healthScore,
      disease: disease ?? this.disease,
      date: date ?? this.date,
    );
  }
}