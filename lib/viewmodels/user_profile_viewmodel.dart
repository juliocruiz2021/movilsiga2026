import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/api_config.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class UserProfileViewModel extends ChangeNotifier {
  UserProfileViewModel({
    required SettingsViewModel settings,
    required AuthViewModel auth,
  }) : _settings = settings,
       _auth = auth;

  final SettingsViewModel _settings;
  final AuthViewModel _auth;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  final List<UserProfileOption> _sucursales = [];
  final List<UserProfileOption> _puntosVenta = [];
  final List<UserProfileOption> _bodegas = [];
  final List<UserProfileOption> _vendedores = [];
  final List<UserProfileOption> _centrosCosto = [];

  int? _selectedSucursalId;
  int? _selectedPuntoVentaId;
  int? _selectedBodegaId;
  int? _selectedVendedorId;
  int? _selectedCentroCostoId;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<UserProfileOption> get sucursales => List.unmodifiable(_sucursales);
  List<UserProfileOption> get puntosVenta => List.unmodifiable(_puntosVenta);
  List<UserProfileOption> get bodegas => List.unmodifiable(_bodegas);
  List<UserProfileOption> get vendedores => List.unmodifiable(_vendedores);
  List<UserProfileOption> get centrosCosto => List.unmodifiable(_centrosCosto);

  int? get selectedSucursalId => _selectedSucursalId;
  int? get selectedPuntoVentaId => _selectedPuntoVentaId;
  int? get selectedBodegaId => _selectedBodegaId;
  int? get selectedVendedorId => _selectedVendedorId;
  int? get selectedCentroCostoId => _selectedCentroCostoId;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final config = _currentConfig();
      final auth = await _readyAuth();
      if (config == null || auth == null) {
        _errorMessage = 'Configura la API e inicia sesión para editar perfil.';
        return;
      }

      await _loadRemoteProfile(config, auth);

      await Future.wait([
        _loadSucursales(config, auth),
        _loadVendedores(config, auth),
        _loadCentrosCosto(config, auth),
      ]);

      _selectedSucursalId = _coerceSelection(
        current: _selectedSucursalId,
        options: _sucursales,
        preferred: _auth.defaultSucursalId,
      );
      _selectedVendedorId = _coerceSelection(
        current: _selectedVendedorId,
        options: _vendedores,
        preferred: _auth.defaultVendedorId,
      );
      _selectedCentroCostoId = _coerceSelection(
        current: _selectedCentroCostoId,
        options: _centrosCosto,
        preferred: _auth.defaultCentroCostoId,
      );

      await _loadPuntosVenta(config, auth);
      await _loadBodegas(config, auth);
    } catch (_) {
      _errorMessage = 'No se pudo cargar el perfil del usuario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSucursal(int? id) async {
    if (id == null || id == _selectedSucursalId) return;
    _selectedSucursalId = id;
    _selectedPuntoVentaId = null;
    _selectedBodegaId = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) return;

    await _loadPuntosVenta(config, auth);
    await _loadBodegas(config, auth);
    notifyListeners();
  }

  void setPuntoVenta(int? id) {
    if (id == null || id == _selectedPuntoVentaId) return;
    _selectedPuntoVentaId = id;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setBodega(int? id) {
    if (id == null || id == _selectedBodegaId) return;
    _selectedBodegaId = id;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setVendedor(int? id) {
    if (id == null || id == _selectedVendedorId) return;
    _selectedVendedorId = id;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setCentroCosto(int? id) {
    if (id == null || id == _selectedCentroCostoId) return;
    _selectedCentroCostoId = id;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> saveProfileDefaults() async {
    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) {
      _errorMessage = 'Configura la API e inicia sesión para guardar perfil.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    final validationError = _validateSelections();
    if (validationError != null) {
      _errorMessage = validationError;
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final uri = config.buildUri('/${config.companyCode}/perfil');
      final payload = <String, dynamic>{
        'perfil': {
          'sucursal_id': _selectedSucursalId,
          'punto_venta_id': _selectedPuntoVentaId,
          'centro_costo_id': _selectedCentroCostoId,
          'bodega_id': _selectedBodegaId,
          'vendedor_id': _selectedVendedorId,
        },
      };

      final response = await http.patch(
        uri,
        headers: _authHeaders(auth),
        body: jsonEncode(payload),
      );

      if (!_isSuccess(response.statusCode)) {
        _errorMessage = _extractErrorMessage(response.body);
        _successMessage = null;
        return false;
      }

      final data = _decodeJson(response.body);
      final user = _asMap(data['user']);
      final perfil = _asMap(user?['perfil']) ?? payload['perfil'];
      final userId = user?['id']?.toString();
      final userName = user?['name']?.toString();
      final userEmail = user?['email']?.toString();

      await _auth.saveUserPerfilDefaults(perfil);
      await _auth.saveUserSession(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );

      _successMessage = 'Perfil operativo actualizado.';
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'No se pudo guardar el perfil.';
      _successMessage = null;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemoteProfile(ApiConfig config, AuthViewModel auth) async {
    final uri = config.buildUri('/${config.companyCode}/perfil');
    final response = await http.get(uri, headers: _authHeaders(auth));
    if (!_isSuccess(response.statusCode)) {
      _selectedSucursalId = _auth.defaultSucursalId;
      _selectedPuntoVentaId = _auth.defaultPuntoVentaId;
      _selectedCentroCostoId = _auth.defaultCentroCostoId;
      _selectedBodegaId = _auth.defaultBodegaId;
      _selectedVendedorId = _auth.defaultVendedorId;
      return;
    }

    final data = _decodeJson(response.body);
    final user = _asMap(data['user']);
    final perfil = _asMap(user?['perfil']);

    _selectedSucursalId =
        _toInt(perfil?['sucursal_id']) ?? _auth.defaultSucursalId;
    _selectedPuntoVentaId =
        _toInt(perfil?['punto_venta_id']) ?? _auth.defaultPuntoVentaId;
    _selectedCentroCostoId =
        _toInt(perfil?['centro_costo_id']) ?? _auth.defaultCentroCostoId;
    _selectedBodegaId = _toInt(perfil?['bodega_id']) ?? _auth.defaultBodegaId;
    _selectedVendedorId =
        _toInt(perfil?['vendedor_id']) ?? _auth.defaultVendedorId;
  }

  Future<void> _loadSucursales(ApiConfig config, AuthViewModel auth) async {
    final items = await _fetchAllPages(
      config: config,
      auth: auth,
      path: '/sucursales',
      keys: const ['sucursales'],
      params: const {'activo': '1'},
    );

    _sucursales
      ..clear()
      ..addAll(items.map(UserProfileOption.fromJson));
  }

  Future<void> _loadPuntosVenta(ApiConfig config, AuthViewModel auth) async {
    if (_selectedSucursalId == null) {
      _puntosVenta.clear();
      _selectedPuntoVentaId = null;
      return;
    }

    final items = await _fetchAllPages(
      config: config,
      auth: auth,
      path: '/puntos-venta',
      keys: const ['puntos_venta'],
      params: {'activo': '1', 'sucursal_id': _selectedSucursalId.toString()},
    );

    _puntosVenta
      ..clear()
      ..addAll(items.map(UserProfileOption.fromJson));

    _selectedPuntoVentaId = _coerceSelection(
      current: _selectedPuntoVentaId,
      options: _puntosVenta,
      preferred: _auth.defaultPuntoVentaId,
    );
  }

  Future<void> _loadBodegas(ApiConfig config, AuthViewModel auth) async {
    if (_selectedSucursalId == null) {
      _bodegas.clear();
      _selectedBodegaId = null;
      return;
    }

    final items = await _fetchAllPages(
      config: config,
      auth: auth,
      path: '/bodegas',
      keys: const ['bodegas'],
      params: {'activo': '1', 'sucursal_id': _selectedSucursalId.toString()},
    );

    _bodegas
      ..clear()
      ..addAll(items.map(UserProfileOption.fromJson));

    _selectedBodegaId = _coerceSelection(
      current: _selectedBodegaId,
      options: _bodegas,
      preferred: _auth.defaultBodegaId,
    );
  }

  Future<void> _loadVendedores(ApiConfig config, AuthViewModel auth) async {
    final items = await _fetchAllPages(
      config: config,
      auth: auth,
      path: '/vendedores',
      keys: const ['vendedores'],
      params: const {'activo': '1'},
    );

    _vendedores
      ..clear()
      ..addAll(items.map(UserProfileOption.fromJson));
  }

  Future<void> _loadCentrosCosto(ApiConfig config, AuthViewModel auth) async {
    final items = await _fetchAllPages(
      config: config,
      auth: auth,
      path: '/centros-costo',
      keys: const ['centros_costo'],
      params: const {'activo': '1'},
    );

    _centrosCosto
      ..clear()
      ..addAll(items.map(UserProfileOption.fromJson));
  }

  Future<List<Map<String, dynamic>>> _fetchAllPages({
    required ApiConfig config,
    required AuthViewModel auth,
    required String path,
    required List<String> keys,
    Map<String, String> params = const {},
  }) async {
    final results = <Map<String, dynamic>>[];
    var page = 1;
    var lastPage = 1;

    do {
      final query = <String, String>{
        ...params,
        'page': page.toString(),
        'per_page': '100',
      };
      final uri = config
          .buildUri('/${config.companyCode}$path')
          .replace(queryParameters: query);
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (!_isSuccess(response.statusCode)) {
        break;
      }

      final data = _decodeJson(response.body);
      results.addAll(_extractList(data, keys));

      final pagination = data['pagination'];
      if (pagination is Map) {
        lastPage = _toInt(pagination['last_page']) ?? lastPage;
      }
      page += 1;
    } while (page <= lastPage);

    return results;
  }

  String? _validateSelections() {
    if (_selectedSucursalId == null) {
      return 'Selecciona una sucursal.';
    }
    if (_selectedPuntoVentaId == null) {
      return 'Selecciona un punto de venta.';
    }
    if (_selectedCentroCostoId == null) {
      return 'Selecciona un centro de costo.';
    }
    if (_selectedBodegaId == null) {
      return 'Selecciona una bodega.';
    }
    if (_selectedVendedorId == null) {
      return 'Selecciona un vendedor.';
    }
    return null;
  }

  ApiConfig? _currentConfig() {
    final config = _settings.apiConfig;
    if (!config.isComplete || !config.isValidUrl) return null;
    return config;
  }

  Future<AuthViewModel?> _readyAuth() async {
    if (_auth.token.isEmpty) {
      await _auth.reloadFromStorage();
    }
    if (_auth.token.isEmpty) return null;
    return _auth;
  }

  int? _coerceSelection<T extends UserProfileOption>({
    required int? current,
    required List<T> options,
    int? preferred,
  }) {
    if (options.isEmpty) return null;
    if (current != null && options.any((item) => item.id == current)) {
      return current;
    }
    if (preferred != null && options.any((item) => item.id == preferred)) {
      return preferred;
    }
    return options.first.id;
  }

  bool _isSuccess(int code) => code >= 200 && code < 300;

  Map<String, String> _authHeaders(AuthViewModel auth) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': auth.authorizationHeader,
    };
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return const {};
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final raw = data[key];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    }
    return const [];
  }

  String _extractErrorMessage(String rawBody) {
    final data = _decodeJson(rawBody);
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'No se pudo procesar la solicitud.';
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class UserProfileOption {
  const UserProfileOption({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  final int id;
  final String codigo;
  final String nombre;

  String get label {
    final code = codigo.trim();
    if (code.isEmpty) return nombre;
    return '$code • $nombre';
  }

  factory UserProfileOption.fromJson(Map<String, dynamic> json) {
    return UserProfileOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
