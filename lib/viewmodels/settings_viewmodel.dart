import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_config.dart';

enum AppThemePreference {
  system,
  light,
  dark,
  sky;

  String get storageValue => name;

  static AppThemePreference fromStorage(String? value) {
    return AppThemePreference.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => AppThemePreference.sky,
    );
  }
}

class SettingsViewModel extends ChangeNotifier {
  static const _companyTokenKey = 'company_token';
  static const _apiBaseUrlKey = 'api_base_url';
  static const _companyCodeKey = 'company_code';
  static const _themePreferenceKey = 'theme_preference';

  final FlutterSecureStorage _secureStorage;

  String _companyToken = '';
  String _apiBaseUrl = '';
  String _companyCode = '';
  AppThemePreference _themePreference = AppThemePreference.sky;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  SettingsViewModel({
    FlutterSecureStorage? secureStorage,
    bool loadOnInit = true,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    if (loadOnInit) {
      _load();
    } else {
      _isLoading = false;
    }
  }

  String get companyToken => _companyToken;
  String get apiBaseUrl => _apiBaseUrl;
  String get companyCode => _companyCode;
  AppThemePreference get themePreference => _themePreference;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get message => _message;
  ApiConfig get apiConfig => ApiConfig(
    baseUrl: _apiBaseUrl,
    companyCode: _companyCode,
    companyToken: _companyToken,
  );

  bool get isConfigValid => apiConfig.isComplete && apiConfig.isValidUrl;

  void updateCompanyToken(String value) {
    _companyToken = value;
    _message = null;
    notifyListeners();
  }

  void updateApiBaseUrl(String value) {
    _apiBaseUrl = value.trim();
    _message = null;
    notifyListeners();
  }

  void updateCompanyCode(String value) {
    _companyCode = value.trim().toLowerCase();
    _message = null;
    notifyListeners();
  }

  Future<void> updateThemePreference(AppThemePreference value) async {
    if (_themePreference == value) return;
    _themePreference = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, value.storageValue);
  }

  Future<void> save() async {
    if (_apiBaseUrl.isEmpty) {
      _message = 'La ruta de la API es obligatoria.';
      notifyListeners();
      return;
    }

    if (!apiConfig.isValidUrl) {
      _message = 'La ruta de la API no es valida.';
      notifyListeners();
      return;
    }

    if (_companyCode.isEmpty) {
      _message = 'El codigo de empresa es obligatorio.';
      notifyListeners();
      return;
    }

    if (_companyToken.isEmpty) {
      _message = 'El token de empresa es obligatorio.';
      notifyListeners();
      return;
    }

    _setSaving(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiBaseUrlKey, _apiBaseUrl);
    await prefs.setString(_companyCodeKey, _companyCode);
    await _secureStorage.write(key: _companyTokenKey, value: _companyToken);
    _message = 'Configuracion guardada.';
    _setSaving(false);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiBaseUrl = prefs.getString(_apiBaseUrlKey) ?? '';
    _companyCode = prefs.getString(_companyCodeKey) ?? '';
    _themePreference = AppThemePreference.fromStorage(
      prefs.getString(_themePreferenceKey),
    );
    _companyToken = await _secureStorage.read(key: _companyTokenKey) ?? '';
    _isLoading = false;
    notifyListeners();
  }

  Future<String> readCompanyTokenSecure() async {
    final token = await _secureStorage.read(key: _companyTokenKey) ?? '';
    if (token.isNotEmpty) {
      _companyToken = token;
    }
    return _companyToken;
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
