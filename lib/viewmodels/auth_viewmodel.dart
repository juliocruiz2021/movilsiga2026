import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthViewModel extends ChangeNotifier {
  static const _authTokenKey = 'auth_token';
  static const _authTokenTypeKey = 'auth_token_type';

  final FlutterSecureStorage _secureStorage;

  String _token = '';
  String _tokenType = 'Bearer';

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
  bool get hasToken => _token.isNotEmpty;

  String get authorizationHeader => '$_tokenType $_token'.trim();

  Future<void> saveToken({required String token, String? tokenType}) async {
    _token = token;
    if (tokenType != null && tokenType.trim().isNotEmpty) {
      _tokenType = tokenType.trim();
    }
    await _secureStorage.write(key: _authTokenKey, value: _token);
    await _secureStorage.write(key: _authTokenTypeKey, value: _tokenType);
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = '';
    _tokenType = 'Bearer';
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _authTokenTypeKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _token = await _secureStorage.read(key: _authTokenKey) ?? '';
    _tokenType = await _secureStorage.read(key: _authTokenTypeKey) ?? 'Bearer';
    notifyListeners();
  }
}
