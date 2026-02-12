import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/role_permissions.dart';

class AuthViewModel extends ChangeNotifier {
  static const _authTokenKey = 'auth_token';
  static const _authTokenTypeKey = 'auth_token_type';
  static const _authRoleKey = 'auth_role';
  static const _authUserIdKey = 'auth_user_id';
  static const _authUserNameKey = 'auth_user_name';
  static const _authUserEmailKey = 'auth_user_email';
  static const _authLoginAtKey = 'auth_login_at';

  final FlutterSecureStorage _secureStorage;

  String _token = '';
  String _tokenType = 'Bearer';
  String _role = '';
  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  String _loginAtIso = '';

  AuthViewModel({FlutterSecureStorage? secureStorage, bool loadOnInit = true})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    if (loadOnInit) {
      _load();
    }
  }

  String get token => _token;
  String get tokenType => _tokenType;
  String get role => _role;
  String get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  DateTime? get loginAt =>
      _loginAtIso.isEmpty ? null : DateTime.tryParse(_loginAtIso);
  bool get hasToken => _token.isNotEmpty;
  bool get isAdmin => _role == 'admin';

  String get authorizationHeader => '$_tokenType $_token'.trim();
  bool hasPermission(String permission) {
    if (_role.isEmpty) return false;
    if (_role == 'admin') return true;
    return RolePermissions.hasPermission(_role, permission);
  }

  Future<void> saveToken({required String token, String? tokenType}) async {
    _token = token;
    if (tokenType != null && tokenType.trim().isNotEmpty) {
      _tokenType = tokenType.trim();
    }
    await _secureStorage.write(key: _authTokenKey, value: _token);
    await _secureStorage.write(key: _authTokenTypeKey, value: _tokenType);
    notifyListeners();
  }

  Future<void> saveRole(String role) async {
    _role = role.trim();
    await _secureStorage.write(key: _authRoleKey, value: _role);
    notifyListeners();
  }

  Future<void> saveUserSession({
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? loginAt,
  }) async {
    if (userId != null) {
      _userId = userId.trim();
      await _secureStorage.write(key: _authUserIdKey, value: _userId);
    }
    if (userName != null) {
      _userName = userName.trim();
      await _secureStorage.write(key: _authUserNameKey, value: _userName);
    }
    if (userEmail != null) {
      _userEmail = userEmail.trim();
      await _secureStorage.write(key: _authUserEmailKey, value: _userEmail);
    }
    if (loginAt != null) {
      _loginAtIso = loginAt.toIso8601String();
      await _secureStorage.write(key: _authLoginAtKey, value: _loginAtIso);
    }
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = '';
    _tokenType = 'Bearer';
    _role = '';
    _userId = '';
    _userName = '';
    _userEmail = '';
    _loginAtIso = '';
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _authTokenTypeKey);
    await _secureStorage.delete(key: _authRoleKey);
    await _secureStorage.delete(key: _authUserIdKey);
    await _secureStorage.delete(key: _authUserNameKey);
    await _secureStorage.delete(key: _authUserEmailKey);
    await _secureStorage.delete(key: _authLoginAtKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _token = await _secureStorage.read(key: _authTokenKey) ?? '';
    _tokenType = await _secureStorage.read(key: _authTokenTypeKey) ?? 'Bearer';
    _role = await _secureStorage.read(key: _authRoleKey) ?? '';
    _userId = await _secureStorage.read(key: _authUserIdKey) ?? '';
    _userName = await _secureStorage.read(key: _authUserNameKey) ?? '';
    _userEmail = await _secureStorage.read(key: _authUserEmailKey) ?? '';
    _loginAtIso = await _secureStorage.read(key: _authLoginAtKey) ?? '';
    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    await _load();
  }
}
