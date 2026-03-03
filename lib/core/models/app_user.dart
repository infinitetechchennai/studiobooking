import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id; // Firebase Auth UID
  final String name;
  final String email;
  final String role; // 'client' | 'creator'
  final int? suspendedUntil;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.suspendedUntil,
  });

  bool get isSuspended {
    if (suspendedUntil == null) return false;
    return suspendedUntil! > DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'suspendedUntil': suspendedUntil,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: (json['role'] ?? 'client').toString().toLowerCase(),
      suspendedUntil: json['suspendedUntil'] as int?,
    );
  }
}
