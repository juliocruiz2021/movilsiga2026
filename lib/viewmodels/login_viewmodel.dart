import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/api_config.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  static const _lastEmailKey = 'last_login_email';
  static const _lastPasswordKey = 'last_login_password';

  final FlutterSecureStorage _secureStorage;

  String _email = '';
  String _password = '';
  String? _errorMessage;
  String? _infoMessage;
  bool _loginSuccess = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  SettingsViewModel? _settings;
  AuthViewModel? _auth;
  String? _deviceName;
  bool _hasLoadedSavedLogin = false;

  LoginViewModel({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _loadSavedLogin();
  }

  String get email => _email;
  String get password => _password;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get hasLoadedSavedLogin => _hasLoadedSavedLogin;
  bool get loginSuccess => _loginSuccess;

  bool get canSubmit =>
      _email.isNotEmpty && _password.length >= 6 && !_isLoading;

  void updateEmail(String value) {
    _email = value.trim();
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateDependencies(SettingsViewModel settings, AuthViewModel auth) {
    _settings = settings;
    _auth = auth;
  }

  Future<void> login() async {
    if (!canSubmit) {
      _errorMessage = 'Completa un email valido y una clave de 6+ caracteres.';
      _infoMessage = null;
      notifyListeners();
      return;
    }

    final settings = _settings;
    var apiConfig = settings?.apiConfig;
    if (settings == null || apiConfig == null) {
      _errorMessage = 'Configura la ruta, el codigo y el token de empresa.';
      _infoMessage = null;
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final companyToken = await settings.readCompanyTokenSecure();
      apiConfig = settings.apiConfig;
      if (!apiConfig.isComplete) {
        _errorMessage = 'Configura la ruta, el codigo y el token de empresa.';
        _infoMessage = null;
        return;
      }

      if (!apiConfig.isValidUrl) {
        _errorMessage = 'La ruta de la API no es valida.';
        _infoMessage = null;
        return;
      }

      final deviceName = await _getDeviceName();
      final response = await _loginRequest(apiConfig, companyToken, deviceName);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _decodeJson(response.body);
        final message = data['message'] as String? ?? 'Login correcto.';
        final token = data['token'] as String?;
        final tokenType = data['token_type'] as String?;
        if (token != null && token.isNotEmpty) {
          await _auth?.saveToken(token: token, tokenType: tokenType);
        }
        _loginSuccess = true;
        notifyListeners();
        await _saveLastLogin();
        _errorMessage = null;
        _infoMessage = message;
      } else {
        final data = _decodeJson(response.body);
        final message = data['message'] as String? ?? 'Error al iniciar sesion.';
        _errorMessage = message;
        _infoMessage = null;
      }
    } catch (_) {
      _errorMessage = 'No se pudo conectar con la API.';
      _infoMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<http.Response> _loginRequest(
    ApiConfig config,
    String companyToken,
    String deviceName,
  ) {
    final uri = config.buildUri('/${config.companyCode}/login');
    // Sin logs en login (evitar datos sensibles).
    return http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $companyToken',
        'X-Device-Name': deviceName,
      },
      body: jsonEncode({
        'email': _email,
        'password': _password,
        'device_name': deviceName,
      }),
    );
  }

  Future<String> _getDeviceName() async {
    if (_deviceName != null && _deviceName!.isNotEmpty) {
      return _deviceName!;
    }

    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      final data = info.data;
      final name = _firstNonEmpty([
        data['name'],
        data['device'],
        data['model'],
        data['computerName'],
        data['hostName'],
        data['hostname'],
        data['brand'],
      ]);
      final system = _firstNonEmpty([
        data['systemName'],
        data['platform'],
        data['osRelease'],
        data['version'],
      ]);
      final deviceId = await _getDeviceIdentifier();
      final resolved = [system, name].where((v) => v.isNotEmpty).join('-');
      final suffix = deviceId.isNotEmpty ? '-$deviceId' : '';
      _deviceName =
          resolved.isNotEmpty ? '$resolved$suffix' : 'flutter$suffix';
    } catch (_) {
      final deviceId = await _getDeviceIdentifier();
      _deviceName = deviceId.isNotEmpty ? 'flutter-$deviceId' : 'flutter';
    }

    return _deviceName!;
  }

  Future<String> _getDeviceIdentifier() async {
    const key = 'device_installation_id';
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = const Uuid().v4();
    await prefs.setString(key, generated);
    return generated;
  }

  String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text != 'null') {
        return text;
      }
    }
    return '';
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return const {};
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void consumeLoginSuccess() {
    if (!_loginSuccess) return;
    _loginSuccess = false;
    notifyListeners();
  }

  Future<void> _loadSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _email = prefs.getString(_lastEmailKey) ?? '';
      _password = await _secureStorage.read(key: _lastPasswordKey) ?? '';
    } finally {
      _hasLoadedSavedLogin = true;
      notifyListeners();
    }
  }

  Future<void> _saveLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEmailKey, _email);
    await _secureStorage.write(key: _lastPasswordKey, value: _password);
  }
}
