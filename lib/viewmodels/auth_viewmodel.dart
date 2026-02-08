import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/role_permissions.dart';

class AuthViewModel extends ChangeNotifier {
  static const _authTokenKey = 'auth_token';
  static const _authTokenTypeKey = 'auth_token_type';
  static const _authRoleKey = 'auth_role';

  final FlutterSecureStorage _secureStorage;

  String _token = '';
  String _tokenType = 'Bearer';
  String _role = '';

  AuthViewModel({
    FlutterSecureStorage? secureStorage,
    bool loadOnInit = true,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    if (loadOnInit) {
      _load();
    }
  }

  String get token => _token;
  String get tokenType => _tokenType;
  String get role => _role;
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

  Future<void> clearToken() async {
    _token = '';
    _tokenType = 'Bearer';
    _role = '';
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _authTokenTypeKey);
    await _secureStorage.delete(key: _authRoleKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _token = await _secureStorage.read(key: _authTokenKey) ?? '';
    _tokenType = await _secureStorage.read(key: _authTokenTypeKey) ?? 'Bearer';
    _role = await _secureStorage.read(key: _authRoleKey) ?? '';
    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    await _load();
  }
}
