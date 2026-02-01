class User {
  final String? id;
  final String googleId;
  final String email;
  final String? fullName;
  final String? mobileNumber;
  final String? profilePicture;
  final String? fcmToken;
  final String role; // 'user' or 'admin'
  final Map<String, dynamic>? deviceInfo;
  final String? ipAddress;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.googleId,
    required this.email,
    this.fullName,
    this.mobileNumber,
    this.profilePicture,
    this.fcmToken,
    this.role = 'user',
    this.deviceInfo,
    this.ipAddress,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      googleId: json['googleId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      profilePicture: json['profilePicture'],
      fcmToken: json['fcmToken'],
      role: json['role'] ?? 'user',
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'googleId': googleId,
      'email': email,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'profilePicture': profilePicture,
      'fcmToken': fcmToken,
      'role': role,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
