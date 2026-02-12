import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/pagination.dart';
import '../models/api_config.dart';
import '../models/client.dart';
import '../utils/debug_tools.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class ClientsViewModel extends ChangeNotifier {
  SettingsViewModel? _settings;
  AuthViewModel? _auth;

  final List<Client> _clients = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isOffline = false;
  String? _errorMessage;
  String? _saveErrorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _initialized = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  List<Client> get clients => List.unmodifiable(_clients);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  String? get saveErrorMessage => _saveErrorMessage;
  bool get hasMore => _currentPage < _lastPage;

  void updateDependencies(SettingsViewModel settings, AuthViewModel auth) {
    _settings = settings;
    _auth = auth;
    debugTrace(
      'CLIENTS_VM',
      'Dependencies ready. hasConfig=${settings.apiConfig.isComplete} hasToken=${auth.token.isNotEmpty}',
    );
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen(
      _handleConnectivity,
    );
    if (!_initialized) {
      _initialized = true;
      loadInitial();
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    super.dispose();
  }

  void updateSearch(String value) {
    final normalized = value.trim();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    loadInitial();
  }

  Future<void> loadInitial() async {
    debugTrace('CLIENTS_VM', 'loadInitial start. query="$_searchQuery"');
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _lastPage = 1;
    notifyListeners();
    try {
      await _loadPage(page: 1, replaceItems: true);
    } finally {
      _isLoading = false;
      debugTrace(
        'CLIENTS_VM',
        'loadInitial end. count=${_clients.length} error=$_errorMessage',
      );
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    debugTrace(
      'CLIENTS_VM',
      'loadMore start. nextPage=${_currentPage + 1} currentCount=${_clients.length}',
    );
    _isLoadingMore = true;
    notifyListeners();
    try {
      await _loadPage(page: _currentPage + 1, replaceItems: false);
    } finally {
      _isLoadingMore = false;
      debugTrace(
        'CLIENTS_VM',
        'loadMore end. page=$_currentPage count=${_clients.length} hasMore=$hasMore',
      );
      notifyListeners();
    }
  }

  Future<void> refresh() => loadInitial();

  Future<Client?> createClient({
    required String codigo,
    required String nombre,
    String? nombreComercial,
    String? nit,
    String? dui,
    String? pasaporte,
    String? telefono,
    String? celular,
    String? correo,
    String? direccion,
    String? gpsUbicacion,
    String? codigoGiro,
    int? giroId,
    int? municipioId,
    bool esProveedor = false,
  }) async {
    debugTrace(
      'CLIENTS_VM',
      'createClient start. codigo=$codigo nombre=$nombre esProveedor=$esProveedor',
    );
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null) {
      _saveErrorMessage = 'Configura la API antes de crear clientes.';
      notifyListeners();
      return null;
    }

    if (auth.token.isEmpty) {
      await auth.reloadFromStorage();
    }
    if (auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return null;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para crear clientes.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _saveErrorMessage = null;
    notifyListeners();

    final normalizedCode = codigo.trim().isEmpty
        ? _generateClientCode()
        : codigo.trim();
    final payload = <String, dynamic>{
      'codigo': normalizedCode,
      'nombre': nombre.trim(),
      'es_cliente': true,
      'es_proveedor': esProveedor,
      'activo': true,
      if (_hasValue(nombreComercial))
        'nombre_comercial': nombreComercial!.trim(),
      if (_hasValue(nit)) 'nit': nit!.trim(),
      if (_hasValue(dui)) 'dui': dui!.trim(),
      if (_hasValue(pasaporte)) 'pasaporte': pasaporte!.trim(),
      if (_hasValue(telefono)) 'telefono': telefono!.trim(),
      if (_hasValue(celular)) 'celular': celular!.trim(),
      if (_hasValue(correo)) 'correo': correo!.trim(),
      if (_hasValue(direccion)) 'direccion': direccion!.trim(),
      if (_hasValue(gpsUbicacion)) 'gps_ubicacion': gpsUbicacion!.trim(),
      if (_hasValue(codigoGiro)) 'codigo_giro': codigoGiro!.trim(),
      if (giroId case final id) 'giro_id': id,
      if (municipioId case final id) 'municipio_id': id,
    };

    final uri = config.buildUri('/${config.companyCode}/socios');
    debugTrace(
      'CLIENTS_VM',
      'POST $uri headers=${redactHeaders(_authHeaders(auth))} body=${debugBodyPreview(jsonEncode(payload))}',
    );

    try {
      final response = await http.post(
        uri,
        headers: _authHeaders(auth),
        body: jsonEncode(payload),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'CLIENTS_VM',
          'createClient failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return null;
      }
      debugTrace('CLIENTS_VM', 'createClient ok status=${response.statusCode}');

      _setOffline(false);
      final data = _decodeJson(response.body);
      final socioRaw = data['socio'];
      if (socioRaw is! Map) {
        _saveErrorMessage = 'No se pudo procesar el cliente creado.';
        return null;
      }

      final created = Client.fromJson(
        socioRaw.map((key, value) => MapEntry(key.toString(), value)),
      );
      debugTrace('CLIENTS_VM', 'createClient parsed id=${created.id}');
      _upsertInCurrentList(created);
      return created;
    } catch (_) {
      debugTrace('CLIENTS_VM', 'createClient exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo crear el cliente.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<Client?> updateClient({
    required int clientId,
    required String codigo,
    required String nombre,
    String? nombreComercial,
    String? nit,
    String? dui,
    String? pasaporte,
    String? telefono,
    String? celular,
    String? correo,
    String? direccion,
    String? gpsUbicacion,
    String? codigoGiro,
    int? giroId,
    int? municipioId,
    bool esProveedor = false,
  }) async {
    debugTrace(
      'CLIENTS_VM',
      'updateClient start id=$clientId codigo=$codigo nombre=$nombre',
    );
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null) {
      _saveErrorMessage = 'Configura la API antes de editar clientes.';
      notifyListeners();
      return null;
    }

    if (auth.token.isEmpty) {
      await auth.reloadFromStorage();
    }
    if (auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return null;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para editar clientes.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _saveErrorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'codigo': codigo.trim(),
      'nombre': nombre.trim(),
      'es_cliente': true,
      'es_proveedor': esProveedor,
      'nombre_comercial': _nullableText(nombreComercial),
      'nit': _nullableText(nit),
      'dui': _nullableText(dui),
      'pasaporte': _nullableText(pasaporte),
      'telefono': _nullableText(telefono),
      'celular': _nullableText(celular),
      'correo': _nullableText(correo),
      'direccion': _nullableText(direccion),
      'gps_ubicacion': _nullableText(gpsUbicacion),
      'codigo_giro': _nullableText(codigoGiro),
      'giro_id': giroId,
      'municipio_id': municipioId,
    };

    final uri = config.buildUri('/${config.companyCode}/socios/$clientId');
    debugTrace(
      'CLIENTS_VM',
      'PUT $uri headers=${redactHeaders(_authHeaders(auth))} body=${debugBodyPreview(jsonEncode(payload))}',
    );
    try {
      final response = await http.put(
        uri,
        headers: _authHeaders(auth),
        body: jsonEncode(payload),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'CLIENTS_VM',
          'updateClient failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return null;
      }
      debugTrace('CLIENTS_VM', 'updateClient ok status=${response.statusCode}');

      _setOffline(false);
      final data = _decodeJson(response.body);
      final socioRaw = data['socio'];
      if (socioRaw is! Map) {
        _saveErrorMessage = 'No se pudo procesar el cliente actualizado.';
        return null;
      }

      final updated = Client.fromJson(
        socioRaw.map((key, value) => MapEntry(key.toString(), value)),
      );
      debugTrace('CLIENTS_VM', 'updateClient parsed id=${updated.id}');
      _upsertInCurrentList(updated);
      return updated;
    } catch (_) {
      debugTrace('CLIENTS_VM', 'updateClient exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo editar el cliente.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClient(int clientId) async {
    debugTrace('CLIENTS_VM', 'deleteClient start id=$clientId');
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null) {
      _saveErrorMessage = 'Configura la API antes de eliminar clientes.';
      notifyListeners();
      return false;
    }

    if (auth.token.isEmpty) {
      await auth.reloadFromStorage();
    }
    if (auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return false;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para eliminar clientes.';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    _saveErrorMessage = null;
    notifyListeners();
    final uri = config.buildUri('/${config.companyCode}/socios/$clientId');
    debugTrace(
      'CLIENTS_VM',
      'DELETE $uri headers=${redactHeaders(_authHeaders(auth))}',
    );

    try {
      final response = await http.delete(uri, headers: _authHeaders(auth));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'CLIENTS_VM',
          'deleteClient failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return false;
      }
      debugTrace('CLIENTS_VM', 'deleteClient ok status=${response.statusCode}');
      _setOffline(false);
      _clients.removeWhere((item) => item.id == clientId);
      return true;
    } catch (_) {
      debugTrace('CLIENTS_VM', 'deleteClient exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo eliminar el cliente.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> _loadPage({
    required int page,
    required bool replaceItems,
  }) async {
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null) {
      _errorMessage = 'Configura la API antes de cargar clientes.';
      return;
    }

    if (auth.token.isEmpty) {
      await auth.reloadFromStorage();
    }
    if (auth.token.isEmpty) {
      _errorMessage = 'No hay sesion activa.';
      return;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      if (_clients.isEmpty) {
        _errorMessage = 'Sin internet para cargar clientes.';
      }
      return;
    }

    final params = <String, String>{
      'page': page.toString(),
      'per_page': kPageSize.toString(),
      'activo': '1',
    };
    if (_searchQuery.isNotEmpty) {
      params['q'] = _searchQuery;
    }

    final uri = config
        .buildUri('/${config.companyCode}/clientes')
        .replace(queryParameters: params);
    debugTrace(
      'CLIENTS_VM',
      'GET $uri headers=${redactHeaders(_authHeaders(auth))}',
    );

    try {
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'CLIENTS_VM',
          'loadPage failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _errorMessage = _extractErrorMessage(response.body);
        return;
      }
      debugTrace('CLIENTS_VM', 'loadPage ok status=${response.statusCode}');
      _setOffline(false);
      _errorMessage = null;
      final data = _decodeJson(response.body);
      final rawList = _extractList(data);
      final fetched = rawList.map(Client.fromJson).toList();
      debugTrace('CLIENTS_VM', 'loadPage parsed fetched=${fetched.length}');

      if (replaceItems) {
        _clients
          ..clear()
          ..addAll(fetched);
      } else {
        _clients.addAll(fetched);
      }

      final pagination = data['pagination'];
      if (pagination is Map) {
        _currentPage = _toInt(pagination['current_page']) ?? page;
        _lastPage = _toInt(pagination['last_page']) ?? _currentPage;
      } else {
        _currentPage = page;
        _lastPage = fetched.length < kPageSize ? page : page + 1;
      }
    } catch (_) {
      debugTrace('CLIENTS_VM', 'loadPage exception');
      _setOffline(true);
      if (_clients.isEmpty) {
        _errorMessage = 'No se pudo cargar clientes.';
      }
    }
  }

  ApiConfig? _currentConfig() {
    final config = _settings?.apiConfig;
    if (config == null || !config.isComplete || !config.isValidUrl) return null;
    return config;
  }

  Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    debugTrace('CLIENTS_VM', 'Connectivity check -> $results / $hasConnection');
    return hasConnection;
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);
    debugTrace(
      'CLIENTS_VM',
      'Connectivity stream -> $results / offline=$offline',
    );
    _setOffline(offline);
  }

  Map<String, String> _authHeaders(AuthViewModel auth) {
    return withDebugHeader({
      'Accept': 'application/json',
      'Authorization': auth.authorizationHeader,
      'Content-Type': 'application/json',
    });
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> data) {
    final candidates = [data['socios'], data['clientes'], data['clients']];
    for (final entry in candidates) {
      if (entry is List) {
        return entry
            .whereType<Map>()
            .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    }
    return const [];
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

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _generateClientCode() {
    final unix = DateTime.now().millisecondsSinceEpoch.toString();
    return 'CLI$unix';
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String? _nullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  String _extractErrorMessage(String rawBody) {
    final data = _decodeJson(rawBody);
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'No se pudo crear el cliente.';
  }

  void _upsertInCurrentList(Client client) {
    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index >= 0) {
      _clients[index] = client;
      return;
    }
    if (!_matchesCurrentFilters(client)) return;
    _clients.insert(0, client);
  }

  bool _matchesCurrentFilters(Client client) {
    if (!client.activo) return false;
    if (_searchQuery.isEmpty) return true;

    final term = _searchQuery.toLowerCase();
    final candidates = <String>[
      client.codigo,
      client.nombre,
      client.nit ?? '',
      client.correo ?? '',
      client.celular ?? '',
      client.telefono ?? '',
    ];
    return candidates.any((value) => value.toLowerCase().contains(term));
  }
}
