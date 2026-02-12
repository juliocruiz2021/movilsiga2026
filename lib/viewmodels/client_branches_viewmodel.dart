import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/pagination.dart';
import '../models/api_config.dart';
import '../models/client.dart';
import '../models/client_branch.dart';
import '../utils/debug_tools.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class ClientBranchesViewModel extends ChangeNotifier {
  ClientBranchesViewModel({
    required SettingsViewModel settings,
    required AuthViewModel auth,
    required Client client,
  }) : _settings = settings,
       _auth = auth,
       _client = client {
    debugTrace(
      'BRANCHES_VM',
      'Init for client id=${client.id} ${client.nombre}',
    );
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _handleConnectivity,
    );
    loadInitial();
  }

  final SettingsViewModel _settings;
  final AuthViewModel _auth;
  final Client _client;
  final List<ClientBranch> _branches = [];

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
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

  Client get client => _client;
  List<ClientBranch> get branches => List.unmodifiable(_branches);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  String? get saveErrorMessage => _saveErrorMessage;
  bool get hasMore => _currentPage < _lastPage;

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
    debugTrace('BRANCHES_VM', 'updateSearch -> "$_searchQuery"');
    loadInitial();
  }

  Future<void> loadInitial() async {
    debugTrace('BRANCHES_VM', 'loadInitial start query="$_searchQuery"');
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _lastPage = 1;
    notifyListeners();
    try {
      await _loadPage(page: 1, replaceItems: true);
    } catch (e, st) {
      debugTrace('BRANCHES_VM', 'loadInitial fatal exception: $e\n$st');
      _errorMessage = 'Error inesperado al cargar sucursales.';
    } finally {
      _isLoading = false;
      debugTrace(
        'BRANCHES_VM',
        'loadInitial end count=${_branches.length} error=$_errorMessage',
      );
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    debugTrace('BRANCHES_VM', 'loadMore nextPage=${_currentPage + 1}');
    _isLoadingMore = true;
    notifyListeners();
    try {
      await _loadPage(page: _currentPage + 1, replaceItems: false);
    } catch (e, st) {
      debugTrace('BRANCHES_VM', 'loadMore fatal exception: $e\n$st');
      _errorMessage = 'Error inesperado al cargar mas sucursales.';
    } finally {
      _isLoadingMore = false;
      debugTrace(
        'BRANCHES_VM',
        'loadMore end count=${_branches.length} hasMore=$hasMore',
      );
      notifyListeners();
    }
  }

  Future<void> refresh() => loadInitial();

  Future<ClientBranch?> createBranch({
    required String nombre,
    String? codigo,
    String? direccion,
    String? gpsUbicacion,
    String? telefono,
    String? correo,
    int? rutaId,
  }) async {
    debugTrace('BRANCHES_VM', 'createBranch start nombre=$nombre');
    final config = _currentConfig();
    if (config == null) {
      _saveErrorMessage = 'Configura la API antes de crear sucursales.';
      notifyListeners();
      return null;
    }

    if (_auth.token.isEmpty) {
      await _auth.reloadFromStorage();
    }
    if (_auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return null;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para crear sucursales.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _saveErrorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'socio_id': _client.id,
      'nombre': nombre.trim(),
      'codigo': _nullableText(codigo),
      'direccion': _nullableText(direccion),
      'gps_ubicacion': _nullableText(gpsUbicacion),
      'telefono': _nullableText(telefono),
      'correo': _nullableText(correo),
      'ruta_id': rutaId,
      'activo': true,
    };

    final uri = config.buildUri('/${config.companyCode}/socios-sucursales');
    debugTrace(
      'BRANCHES_VM',
      'POST $uri headers=${redactHeaders(_authHeaders())} body=${debugBodyPreview(jsonEncode(payload))}',
    );
    try {
      final response = await http.post(
        uri,
        headers: _authHeaders(),
        body: jsonEncode(payload),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'BRANCHES_VM',
          'createBranch failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return null;
      }
      debugTrace(
        'BRANCHES_VM',
        'createBranch ok status=${response.statusCode}',
      );
      _setOffline(false);
      final data = _decodeJson(response.body);
      final raw = data['socio_sucursal'];
      if (raw is! Map) {
        _saveErrorMessage = 'No se pudo procesar la sucursal creada.';
        return null;
      }
      final created = ClientBranch.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      debugTrace('BRANCHES_VM', 'createBranch parsed id=${created.id}');
      _upsertInCurrentList(created);
      return created;
    } catch (_) {
      debugTrace('BRANCHES_VM', 'createBranch exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo crear la sucursal.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ClientBranch?> updateBranch({
    required int branchId,
    required String nombre,
    String? codigo,
    String? direccion,
    String? gpsUbicacion,
    String? telefono,
    String? correo,
    int? rutaId,
  }) async {
    debugTrace('BRANCHES_VM', 'updateBranch start id=$branchId nombre=$nombre');
    final config = _currentConfig();
    if (config == null) {
      _saveErrorMessage = 'Configura la API antes de editar sucursales.';
      notifyListeners();
      return null;
    }

    if (_auth.token.isEmpty) {
      await _auth.reloadFromStorage();
    }
    if (_auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return null;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para editar sucursales.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _saveErrorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'socio_id': _client.id,
      'nombre': nombre.trim(),
      'codigo': _nullableText(codigo),
      'direccion': _nullableText(direccion),
      'gps_ubicacion': _nullableText(gpsUbicacion),
      'telefono': _nullableText(telefono),
      'correo': _nullableText(correo),
      'ruta_id': rutaId,
    };

    final uri = config.buildUri(
      '/${config.companyCode}/socios-sucursales/$branchId',
    );
    debugTrace(
      'BRANCHES_VM',
      'PUT $uri headers=${redactHeaders(_authHeaders())} body=${debugBodyPreview(jsonEncode(payload))}',
    );
    try {
      final response = await http.put(
        uri,
        headers: _authHeaders(),
        body: jsonEncode(payload),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'BRANCHES_VM',
          'updateBranch failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return null;
      }
      debugTrace(
        'BRANCHES_VM',
        'updateBranch ok status=${response.statusCode}',
      );
      _setOffline(false);
      final data = _decodeJson(response.body);
      final raw = data['socio_sucursal'];
      if (raw is! Map) {
        _saveErrorMessage = 'No se pudo procesar la sucursal actualizada.';
        return null;
      }
      final updated = ClientBranch.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      debugTrace('BRANCHES_VM', 'updateBranch parsed id=${updated.id}');
      _upsertInCurrentList(updated);
      return updated;
    } catch (_) {
      debugTrace('BRANCHES_VM', 'updateBranch exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo editar la sucursal.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBranch(int branchId) async {
    debugTrace('BRANCHES_VM', 'deleteBranch start id=$branchId');
    final config = _currentConfig();
    if (config == null) {
      _saveErrorMessage = 'Configura la API antes de eliminar sucursales.';
      notifyListeners();
      return false;
    }

    if (_auth.token.isEmpty) {
      await _auth.reloadFromStorage();
    }
    if (_auth.token.isEmpty) {
      _saveErrorMessage = 'No hay sesion activa.';
      notifyListeners();
      return false;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      _saveErrorMessage = 'Sin internet para eliminar sucursales.';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    _saveErrorMessage = null;
    notifyListeners();
    final uri = config.buildUri(
      '/${config.companyCode}/socios-sucursales/$branchId',
    );
    debugTrace(
      'BRANCHES_VM',
      'DELETE $uri headers=${redactHeaders(_authHeaders())}',
    );

    try {
      final response = await http.delete(uri, headers: _authHeaders());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'BRANCHES_VM',
          'deleteBranch failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _saveErrorMessage = _extractErrorMessage(response.body);
        return false;
      }
      debugTrace(
        'BRANCHES_VM',
        'deleteBranch ok status=${response.statusCode}',
      );
      _setOffline(false);
      _branches.removeWhere((item) => item.id == branchId);
      return true;
    } catch (_) {
      debugTrace('BRANCHES_VM', 'deleteBranch exception');
      _setOffline(true);
      _saveErrorMessage = 'No se pudo eliminar la sucursal.';
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
    if (config == null) {
      _errorMessage = 'Configura la API antes de cargar sucursales.';
      return;
    }

    if (_auth.token.isEmpty) {
      await _auth.reloadFromStorage();
    }
    if (_auth.token.isEmpty) {
      _errorMessage = 'No hay sesion activa.';
      return;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      _setOffline(true);
      if (_branches.isEmpty) {
        _errorMessage = 'Sin internet para cargar sucursales.';
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
        .buildUri('/${config.companyCode}/socios/${_client.id}/sucursales')
        .replace(queryParameters: params);
    debugTrace(
      'BRANCHES_VM',
      'GET $uri headers=${redactHeaders(_authHeaders())}',
    );

    try {
      final response = await http.get(uri, headers: _authHeaders());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'BRANCHES_VM',
          'loadPage failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _errorMessage = _extractErrorMessage(response.body);
        return;
      }
      debugTrace('BRANCHES_VM', 'loadPage ok status=${response.statusCode}');

      _setOffline(false);
      _errorMessage = null;
      final data = _decodeJson(response.body);
      final rawList = _extractList(data);
      final fetched = rawList.map(ClientBranch.fromJson).toList();
      debugTrace('BRANCHES_VM', 'loadPage parsed fetched=${fetched.length}');

      if (replaceItems) {
        _branches
          ..clear()
          ..addAll(fetched);
      } else {
        _branches.addAll(fetched);
      }

      final pagination = data['pagination'];
      if (pagination is Map) {
        _currentPage = _toInt(pagination['current_page']) ?? page;
        _lastPage = _toInt(pagination['last_page']) ?? _currentPage;
      } else {
        _currentPage = page;
        _lastPage = fetched.length < kPageSize ? page : page + 1;
      }
    } catch (e, st) {
      debugTrace('BRANCHES_VM', 'loadPage exception: $e\n$st');
      _setOffline(true);
      if (_branches.isEmpty) {
        _errorMessage = 'No se pudo cargar sucursales.';
      }
    }
  }

  ApiConfig? _currentConfig() {
    final config = _settings.apiConfig;
    if (!config.isComplete || !config.isValidUrl) return null;
    return config;
  }

  Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      debugTrace(
        'BRANCHES_VM',
        'Connectivity check -> $results / $hasConnection',
      );
      return hasConnection;
    } catch (e, st) {
      debugTrace('BRANCHES_VM', 'Connectivity check exception: $e\n$st');
      return false;
    }
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
      'BRANCHES_VM',
      'Connectivity stream -> $results / offline=$offline',
    );
    _setOffline(offline);
  }

  Map<String, String> _authHeaders() {
    return withDebugHeader({
      'Accept': 'application/json',
      'Authorization': _auth.authorizationHeader,
      'Content-Type': 'application/json',
    });
  }

  String? _nullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> data) {
    final candidates = [
      data['socio_sucursales'],
      data['sucursales'],
      data['items'],
    ];
    for (final entry in candidates) {
      if (entry is List) {
        return entry
            .whereType<Map>()
            .map((item) => item.map((k, v) => MapEntry('$k', v)))
            .toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry('$k', v));
      }
    } catch (_) {}
    return const {};
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _extractErrorMessage(String rawBody) {
    final data = _decodeJson(rawBody);
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'Operacion no completada.';
  }

  void _upsertInCurrentList(ClientBranch branch) {
    final index = _branches.indexWhere((item) => item.id == branch.id);
    if (index >= 0) {
      _branches[index] = branch;
      return;
    }
    if (!_matchesCurrentFilters(branch)) return;
    _branches.insert(0, branch);
  }

  bool _matchesCurrentFilters(ClientBranch branch) {
    if (!branch.activo) return false;
    if (_searchQuery.isEmpty) return true;
    final term = _searchQuery.toLowerCase();
    final fields = <String>[
      branch.codigo ?? '',
      branch.nombre,
      branch.direccion ?? '',
      branch.telefono ?? '',
      branch.correo ?? '',
    ];
    return fields.any((value) => value.toLowerCase().contains(term));
  }
}
