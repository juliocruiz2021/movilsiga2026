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
  static const _authDefaultSucursalIdKey = 'auth_default_sucursal_id';
  static const _authDefaultPuntoVentaIdKey = 'auth_default_punto_venta_id';
  static const _authDefaultCentroCostoIdKey = 'auth_default_centro_costo_id';
  static const _authDefaultBodegaIdKey = 'auth_default_bodega_id';
  static const _authDefaultVendedorIdKey = 'auth_default_vendedor_id';

  final FlutterSecureStorage _secureStorage;

  String _token = '';
  String _tokenType = 'Bearer';
  String _role = '';
  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  String _loginAtIso = '';
  int? _defaultSucursalId;
  int? _defaultPuntoVentaId;
  int? _defaultCentroCostoId;
  int? _defaultBodegaId;
  int? _defaultVendedorId;

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
  int? get defaultSucursalId => _defaultSucursalId;
  int? get defaultPuntoVentaId => _defaultPuntoVentaId;
  int? get defaultCentroCostoId => _defaultCentroCostoId;
  int? get defaultBodegaId => _defaultBodegaId;
  int? get defaultVendedorId => _defaultVendedorId;
  DateTime? get loginAt =>
      _loginAtIso.isEmpty ? null : DateTime.tryParse(_loginAtIso);
  bool get hasToken => _token.isNotEmpty;
  bool get isAdmin => _role.toLowerCase() == 'admin';

  String get authorizationHeader => '$_tokenType $_token'.trim();
  bool hasPermission(String permission) {
    if (_role.isEmpty) return false;
    final normalizedRole = _role.toLowerCase();
    if (normalizedRole == 'admin') return true;
    return RolePermissions.hasPermission(normalizedRole, permission);
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
    _role = role.trim().toLowerCase();
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

  Future<void> saveUserPerfilDefaults(Map<String, dynamic>? perfil) async {
    _defaultSucursalId = _toInt(perfil?['sucursal_id']);
    _defaultPuntoVentaId = _toInt(perfil?['punto_venta_id']);
    _defaultCentroCostoId = _toInt(perfil?['centro_costo_id']);
    _defaultBodegaId = _toInt(perfil?['bodega_id']);
    _defaultVendedorId = _toInt(perfil?['vendedor_id']);

    await _writeOptionalInt(_authDefaultSucursalIdKey, _defaultSucursalId);
    await _writeOptionalInt(_authDefaultPuntoVentaIdKey, _defaultPuntoVentaId);
    await _writeOptionalInt(
      _authDefaultCentroCostoIdKey,
      _defaultCentroCostoId,
    );
    await _writeOptionalInt(_authDefaultBodegaIdKey, _defaultBodegaId);
    await _writeOptionalInt(_authDefaultVendedorIdKey, _defaultVendedorId);
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
    _defaultSucursalId = null;
    _defaultPuntoVentaId = null;
    _defaultCentroCostoId = null;
    _defaultBodegaId = null;
    _defaultVendedorId = null;
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _authTokenTypeKey);
    await _secureStorage.delete(key: _authRoleKey);
    await _secureStorage.delete(key: _authUserIdKey);
    await _secureStorage.delete(key: _authUserNameKey);
    await _secureStorage.delete(key: _authUserEmailKey);
    await _secureStorage.delete(key: _authLoginAtKey);
    await _secureStorage.delete(key: _authDefaultSucursalIdKey);
    await _secureStorage.delete(key: _authDefaultPuntoVentaIdKey);
    await _secureStorage.delete(key: _authDefaultCentroCostoIdKey);
    await _secureStorage.delete(key: _authDefaultBodegaIdKey);
    await _secureStorage.delete(key: _authDefaultVendedorIdKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _token = await _secureStorage.read(key: _authTokenKey) ?? '';
    _tokenType = await _secureStorage.read(key: _authTokenTypeKey) ?? 'Bearer';
    _role = (await _secureStorage.read(key: _authRoleKey) ?? '')
        .trim()
        .toLowerCase();
    _userId = await _secureStorage.read(key: _authUserIdKey) ?? '';
    _userName = await _secureStorage.read(key: _authUserNameKey) ?? '';
    _userEmail = await _secureStorage.read(key: _authUserEmailKey) ?? '';
    _loginAtIso = await _secureStorage.read(key: _authLoginAtKey) ?? '';
    _defaultSucursalId = _toInt(
      await _secureStorage.read(key: _authDefaultSucursalIdKey),
    );
    _defaultPuntoVentaId = _toInt(
      await _secureStorage.read(key: _authDefaultPuntoVentaIdKey),
    );
    _defaultCentroCostoId = _toInt(
      await _secureStorage.read(key: _authDefaultCentroCostoIdKey),
    );
    _defaultBodegaId = _toInt(
      await _secureStorage.read(key: _authDefaultBodegaIdKey),
    );
    _defaultVendedorId = _toInt(
      await _secureStorage.read(key: _authDefaultVendedorIdKey),
    );
    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    await _load();
  }

  Future<void> _writeOptionalInt(String key, int? value) async {
    if (value == null) {
      await _secureStorage.delete(key: key);
      return;
    }
    await _secureStorage.write(key: key, value: value.toString());
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }
}
