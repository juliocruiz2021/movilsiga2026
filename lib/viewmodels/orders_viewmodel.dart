import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/pagination.dart';
import '../models/api_config.dart';
import '../models/order_summary.dart';
import '../utils/debug_tools.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

enum OrderDateFilterMode { exactDay, range }

class OrdersViewModel extends ChangeNotifier {
  SettingsViewModel? _settings;
  AuthViewModel? _auth;

  final List<OrderSummary> _orders = [];
  String _searchQuery = '';
  DateTime _fromDate = _dateOnly(DateTime.now());
  DateTime _toDate = _dateOnly(DateTime.now());
  OrderDateFilterMode _dateFilterMode = OrderDateFilterMode.exactDay;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _initialized = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  List<OrderSummary> get orders => List.unmodifiable(_orders);
  String get searchQuery => _searchQuery;
  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  OrderDateFilterMode get dateFilterMode => _dateFilterMode;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _lastPage;

  void updateDependencies(SettingsViewModel settings, AuthViewModel auth) {
    _settings = settings;
    _auth = auth;
    debugTrace(
      'ORDERS_VM',
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

  void updateDateFilterMode(OrderDateFilterMode mode) {
    if (_dateFilterMode == mode) return;
    _dateFilterMode = mode;
    if (_dateFilterMode == OrderDateFilterMode.exactDay) {
      _toDate = _fromDate;
    }
    loadInitial();
  }

  void updateExactDate(DateTime value) {
    final normalized = _dateOnly(value);
    final changed =
        !_isSameDate(_fromDate, normalized) ||
        !_isSameDate(_toDate, normalized);
    if (!changed) return;
    _fromDate = normalized;
    _toDate = normalized;
    loadInitial();
  }

  void updateFromDate(DateTime value) {
    final normalized = _dateOnly(value);
    if (_isSameDate(_fromDate, normalized) &&
        (_dateFilterMode == OrderDateFilterMode.range ||
            _isSameDate(_toDate, normalized))) {
      return;
    }

    _fromDate = normalized;
    if (_dateFilterMode == OrderDateFilterMode.exactDay ||
        _fromDate.isAfter(_toDate)) {
      _toDate = _fromDate;
    }
    loadInitial();
  }

  void updateToDate(DateTime value) {
    final normalized = _dateOnly(value);
    if (_dateFilterMode == OrderDateFilterMode.exactDay) {
      updateExactDate(normalized);
      return;
    }
    if (_isSameDate(_toDate, normalized) && !_fromDate.isAfter(normalized)) {
      return;
    }

    _toDate = normalized;
    if (_fromDate.isAfter(_toDate)) {
      _fromDate = _toDate;
    }
    loadInitial();
  }

  void setToday() {
    updateExactDate(DateTime.now());
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadInitial() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _lastPage = 1;
    notifyListeners();

    try {
      await _loadPage(page: 1, replaceItems: true);
    } catch (e, st) {
      debugTrace('ORDERS_VM', 'loadInitial fatal exception: $e\n$st');
      _errorMessage = 'Error inesperado al cargar pedidos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      await _loadPage(page: _currentPage + 1, replaceItems: false);
    } catch (e, st) {
      debugTrace('ORDERS_VM', 'loadMore fatal exception: $e\n$st');
      _errorMessage = 'Error inesperado al cargar mas pedidos.';
    } finally {
      _isLoadingMore = false;
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
      _errorMessage = 'Configura la API antes de cargar pedidos.';
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
      if (_orders.isEmpty) {
        _errorMessage = 'Sin internet para cargar pedidos.';
      }
      return;
    }

    final params = <String, String>{
      'page': page.toString(),
      'per_page': kPageSize.toString(),
      'tipo_registro': 'PED',
      'fecha_desde': _formatDate(_fromDate),
      'fecha_hasta': _formatDate(_toDate),
    };
    if (_searchQuery.isNotEmpty) {
      params['q'] = _searchQuery;
    }

    final uri = config
        .buildUri('/${config.companyCode}/ventas')
        .replace(queryParameters: params);
    debugTrace(
      'ORDERS_VM',
      'GET $uri headers=${redactHeaders(_authHeaders(auth))}',
    );

    try {
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace(
          'ORDERS_VM',
          'loadPage failed status=${response.statusCode} body=${debugBodyPreview(response.body)}',
        );
        _errorMessage = _extractErrorMessage(response.body);
        return;
      }

      _setOffline(false);
      _errorMessage = null;
      final data = _decodeJson(response.body);
      final raw = _extractOrdersList(data);
      final fetched = raw
          .map(OrderSummary.fromJson)
          .where(_matchesDateFilter)
          .where(_matchesSearchFilter)
          .toList();

      if (replaceItems) {
        _orders
          ..clear()
          ..addAll(fetched);
      } else {
        _orders.addAll(fetched);
      }

      final pagination = data['pagination'];
      if (pagination is Map) {
        _currentPage = _toInt(pagination['current_page']) ?? page;
        _lastPage = _toInt(pagination['last_page']) ?? _currentPage;
      } else {
        _currentPage = page;
        _lastPage = fetched.length < kPageSize ? page : page + 1;
      }
      debugTrace(
        'ORDERS_VM',
        'loadPage ok page=$_currentPage lastPage=$_lastPage fetched=${fetched.length} totalLoaded=${_orders.length}',
      );
    } catch (e, st) {
      debugTrace('ORDERS_VM', 'loadPage exception: $e\n$st');
      _setOffline(true);
      if (_orders.isEmpty) {
        _errorMessage = 'No se pudo cargar pedidos.';
      }
    }
  }

  bool _matchesDateFilter(OrderSummary order) {
    final date = order.fecha;
    if (date == null) return true;
    final orderDate = _dateOnly(date);
    if (orderDate.isBefore(_fromDate)) return false;
    if (orderDate.isAfter(_toDate)) return false;
    return true;
  }

  bool _matchesSearchFilter(OrderSummary order) {
    if (_searchQuery.isEmpty) return true;

    final term = _searchQuery.toLowerCase();
    final candidates = <String>[
      order.id.toString(),
      order.socioCodigo,
      order.socioNombre,
      order.socioNombreComercial ?? '',
      order.socioTelefono ?? '',
      order.socioCelular ?? '',
      order.documentNumber,
      order.estado,
      order.noPidio ? 'no pidio' : 'si pidio',
      order.motivoNoPedidoNombre ?? '',
      order.total.toStringAsFixed(2),
    ];
    return candidates.any((value) => value.toLowerCase().contains(term));
  }

  ApiConfig? _currentConfig() {
    final config = _settings?.apiConfig;
    if (config == null || !config.isComplete || !config.isValidUrl) return null;
    return config;
  }

  Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      return hasConnection;
    } catch (_) {
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
    _setOffline(offline);
  }

  Map<String, String> _authHeaders(AuthViewModel auth) {
    return withDebugHeader({
      'Accept': 'application/json',
      'Authorization': auth.authorizationHeader,
      'Content-Type': 'application/json',
    });
  }

  List<Map<String, dynamic>> _extractOrdersList(Map<String, dynamic> data) {
    final raw = data['ventas'] ?? data['pedidos'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
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
    return 'No se pudo cargar pedidos.';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
