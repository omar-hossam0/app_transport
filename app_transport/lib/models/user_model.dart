/// User data model for Flutter app
class UserModel {
  final String uid; // Firebase unique ID
  final String email; // User email
  final String name; // Full name
  final String phoneNumber; // Phone number (optional)
  final bool isAdmin; // Admin role flag
  final DateTime createdAt; // Account creation timestamp
  final DateTime lastLogin; // Last login timestamp

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber = '',
    this.isAdmin = false,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Convert UserModel to JSON Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  /// Create UserModel from JSON Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isAdmin: map['isAdmin'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
