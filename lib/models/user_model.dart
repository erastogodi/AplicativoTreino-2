class UserModel {
  final String id;
  final double weight;
  final double height;
  final int age;
  final String activityLevel;
  final String email;
  final String gender; // Adicionado atributo de gênero

  UserModel({
    required this.id,
    required this.weight,
    required this.height,
    required this.age,
    required this.activityLevel,
    required this.email,
    required this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      age: json['age'] as int? ?? 0,
      activityLevel: json['activityLevel'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? 'Masculino', // Default como Masculino
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'age': age,
      'activityLevel': activityLevel,
      'email': email,
      'gender': gender,
    };
  }

  UserModel copyWith({
    String? id,
    double? weight,
    double? height,
    int? age,
    String? activityLevel,
    String? email,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      email: email ?? this.email,
      gender: gender ?? this.gender,
    );
  }
}
