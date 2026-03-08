import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart' as crypto;

class AuthUser {
  final String id;
  final String email;
  final String name;
  final String bio;
  final String phone;
  final String gender;
  final String? dob; // ISO date string (YYYY-MM-DD)
  final String avatarPath;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.bio = '',
    this.phone = '',
    this.gender = '',
    this.dob,
    this.avatarPath = '',
  });

  AuthUser copyWith({
    String? name,
    String? bio,
    String? phone,
    String? gender,
    String? dob,
    String? avatarPath,
  }) {
    return AuthUser(
      id: id,
      email: email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'bio': bio,
    'phone': phone,
    'gender': gender,
    'dob': dob,
    'avatar': avatarPath,
  };

  static AuthUser fromJson(Map<String, dynamic> j) => AuthUser(
    id: j['id'] ?? '',
    email: j['email'] ?? '',
    name: j['name'] ?? '',
    bio: j['bio'] ?? '',
    phone: j['phone'] ?? '',
    gender: j['gender'] ?? '',
    dob: j['dob'],
    avatarPath: j['avatar'] ?? '',
  );
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<AuthUser?> currentUser = ValueNotifier<AuthUser?>(null);

  final Map<String, String> _passwords = {}; // email -> password (mock)
  final Map<String, AuthUser> _users = {}; // email -> user
  final Map<String, bool> _following = {}; // follow state per profile

  String _hash(String input) =>
      crypto.sha256.convert(utf8.encode(input)).toString();

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final rawUsers = sp.getString('auth_users');
    if (rawUsers != null) {
      try {
        final map = json.decode(rawUsers) as Map<String, dynamic>;
        _users.clear();
        map.forEach((k, v) {
          _users[k] = AuthUser.fromJson(Map<String, dynamic>.from(v));
        });
      } catch (_) {}
    }
    final rawPw = sp.getString('auth_passwords');
    if (rawPw != null) {
      try {
        final map = json.decode(rawPw) as Map<String, dynamic>;
        _passwords.clear();
        map.forEach((k, v) => _passwords[k] = v.toString());
      } catch (_) {}
    }
    final rawFollow = sp.getString('auth_follow');
    if (rawFollow != null) {
      try {
        final map = json.decode(rawFollow) as Map<String, dynamic>;
        _following.clear();
        map.forEach((k, v) => _following[k] = v == true);
      } catch (_) {}
    }
    final cur = sp.getString('auth_current');
    if (cur != null && _users.containsKey(cur)) {
      currentUser.value = _users[cur];
    }
  }

  Future<void> _saveAll() async {
    final sp = await SharedPreferences.getInstance();
    final usersMap = _users.map((k, v) => MapEntry(k, v.toJson()));
    await sp.setString('auth_users', json.encode(usersMap));
    await sp.setString('auth_passwords', json.encode(_passwords));
    await sp.setString('auth_follow', json.encode(_following));
    await sp.setString('auth_current', currentUser.value?.email ?? '');
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String gender,
    String? dob,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_users.containsKey(email)) return false;
    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
    );
    _users[email] = user;
    _passwords[email] = _hash(password);
    currentUser.value = user;
    await _saveAll();
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final pw = _passwords[email];
    if (pw == null) return false;
    if (pw != _hash(password)) return false;
    currentUser.value = _users[email];
    await _saveAll();
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    currentUser.value = null;
    await _saveAll();
  }

  Future<bool> updateProfile({
    required String email,
    String? name,
    String? bio,
    String? phone,
    String? gender,
    String? dob,
    String? avatarPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _users[email];
    if (user == null) return false;
    final updated = user.copyWith(
      name: name,
      bio: bio,
      phone: phone,
      gender: gender,
      dob: dob,
      avatarPath: avatarPath,
    );
    _users[email] = updated;
    if (currentUser.value?.email == email) currentUser.value = updated;
    await _saveAll();
    return true;
  }

  bool isFollowing(String email) => _following[email] == true;

  Future<void> toggleFollow(String email) async {
    _following[email] = !(_following[email] == true);
    await _saveAll();
  }
}
