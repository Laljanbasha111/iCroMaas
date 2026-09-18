class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final double farmSize;
  final List<String> crops;
  final String profileImageUrl;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.location = '',
    this.farmSize = 0.0,
    this.crops = const [],
    this.profileImageUrl = '',
    this.language = 'en',
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'farmSize': farmSize,
      'crops': crops,
      'profileImageUrl': profileImageUrl,
      'language': language,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      farmSize: (map['farmSize'] ?? 0).toDouble(),
      crops: List<String>.from(map['crops'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
      language: map['language'] ?? 'en',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    double? farmSize,
    List<String>? crops,
    String? profileImageUrl,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      farmSize: farmSize ?? this.farmSize,
      crops: crops ?? this.crops,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}