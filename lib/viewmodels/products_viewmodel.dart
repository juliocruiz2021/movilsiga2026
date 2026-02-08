import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../models/api_config.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class ProductsViewModel extends ChangeNotifier {
  SettingsViewModel? _settings;
  AuthViewModel? _auth;

  final List<Product> _products = [];
  final List<ProductCategory> _categories = [];
  int? _selectedCategoryId;
  int? _selectedBrandId;
  bool? _onlyActive = true;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _lastProductsResponse;
  String? _lastUploadError;
  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 20;
  bool _initialized = false;
  final Map<int, int> _cart = {};
  ProductViewMode _viewMode = ProductViewMode.grid;

  List<Product> get products => List.unmodifiable(_products);
  List<ProductCategory> get categories => List.unmodifiable(_categories);
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  bool? get onlyActive => _onlyActive;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get lastUploadError => _lastUploadError;
  bool get hasMore => _currentPage < _lastPage;
  ProductViewMode get viewMode => _viewMode;
  String? get lastProductsResponse => _lastProductsResponse;

  Map<int, int> get cartItems => Map.unmodifiable(_cart);

  double get subtotal {
    double total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere((p) => p.id == entry.key);
      total += product.precio * entry.value;
    }
    return total;
  }

  int get cartCount => _cart.values.fold(0, (a, b) => a + b);

  void updateDependencies(SettingsViewModel settings, AuthViewModel auth) {
    _settings = settings;
    _auth = auth;
    if (!_initialized) {
      _initialized = true;
      loadInitial();
    }
  }

  void updateCategory(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    loadInitial();
  }

  void updateBrand(int? brandId) {
    if (_selectedBrandId == brandId) return;
    _selectedBrandId = brandId;
    loadInitial();
  }

  void updateActive(bool? value) {
    if (_onlyActive == value) return;
    _onlyActive = value;
    loadInitial();
  }

  void updateSearch(String value) {
    final normalized = value.trim().toLowerCase();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    loadInitial();
  }

  void updateViewMode(ProductViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final raw = url.trim();
    final baseOrigin = _baseOrigin();

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (baseOrigin == null) return raw;
      final uri = Uri.tryParse(raw);
      if (uri == null) return raw;
      final host = uri.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1') {
        return '$baseOrigin${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
      }
      return raw;
    }

    if (baseOrigin == null) return raw;
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$baseOrigin$path';
  }

  Future<void> loadInitial() async {
    _currentPage = 1;
    _lastPage = 1;
    _products.clear();
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCategories();
      await _loadProducts(page: 1);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      await _loadProducts(page: _currentPage + 1);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void addToCart(Product product) {
    _cart.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (!_cart.containsKey(product.id)) return;
    final current = _cart[product.id] ?? 0;
    if (current <= 1) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = current - 1;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void replaceProduct(Product updated) {
    final index = _products.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _products[index] = updated;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null || auth.token.isEmpty) return;

    final uri = config.buildUri('/${config.companyCode}/categorias').replace(
      queryParameters: {'per_page': '100'},
    );
    final response = await http.get(uri, headers: _authHeaders(auth));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = _decodeJson(response.body);
      final raw = data['categories'];
      if (raw is List) {
        _categories
          ..clear()
          ..addAll(
            raw
                .whereType<Map>()
                .map((item) => ProductCategory.fromJson(
                      item.map((k, v) => MapEntry(k.toString(), v)),
                    )),
          );
      }
    }
  }

  Future<void> _loadProducts({required int page}) async {
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null || auth.token.isEmpty) {
      _errorMessage = 'No hay sesion activa.';
      return;
    }

    final params = <String, String>{
      'page': page.toString(),
      'per_page': _perPage.toString(),
      'tipo': '1',
    };
    if (_searchQuery.isNotEmpty) {
      params['q'] = _searchQuery;
    }
    if (_selectedCategoryId != null) {
      params['product_category_id'] = _selectedCategoryId.toString();
    }
    if (_selectedBrandId != null) {
      params['brand_id'] = _selectedBrandId.toString();
    }
    if (_onlyActive != null) {
      params['activo'] = _onlyActive! ? '1' : '0';
    }

    final uri = config
        .buildUri('/${config.companyCode}/productos')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: _authHeaders(auth));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _lastProductsResponse = response.body;
      final data = _decodeJson(response.body);
      final raw = data['products'];
      if (raw is List) {
        final items = raw
            .whereType<Map>()
            .map((item) => Product.fromJson(
                  item.map((k, v) => MapEntry(k.toString(), v)),
                ))
            .toList();
        if (page == 1) {
          _products
            ..clear()
            ..addAll(items);
        } else {
          _products.addAll(items);
        }
      }
      final pagination = data['pagination'];
      if (pagination is Map) {
        _currentPage =
            (pagination['current_page'] as num?)?.toInt() ?? _currentPage;
        _lastPage = (pagination['last_page'] as num?)?.toInt() ?? _lastPage;
      }
    } else {
      _errorMessage = 'No se pudo cargar productos.';
    }
  }

  ApiConfig? _currentConfig() {
    final config = _settings?.apiConfig;
    if (config == null || !config.isComplete || !config.isValidUrl) {
      _errorMessage = 'Configura la API antes de cargar productos.';
      return null;
    }
    return config;
  }

  Map<String, String> _authHeaders(AuthViewModel auth) {
    return {
      'Accept': 'application/json',
      'Authorization': auth.authorizationHeader,
    };
  }

  Future<Product?> uploadProductPhoto({
    required Product product,
    required String filePath,
  }) async {
    _lastUploadError = null;
    final config = _currentConfig();
    final auth = _auth;
    if (config == null || auth == null || auth.token.isEmpty) {
      _lastUploadError = 'No hay sesion activa.';
      return null;
    }

    final uri = config.buildUri(
      '/${config.companyCode}/productos/${product.id}/foto',
    );
    try {
      final uploadPath = await _normalizeImageForUpload(filePath);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeaders(auth));
      request.files.add(
        await http.MultipartFile.fromPath('foto', uploadPath),
      );
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _decodeJson(body);
        final raw = data['product'];
        if (raw is Map) {
          return Product.fromJson(
            raw.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      }
      final data = _decodeJson(body);
      _lastUploadError =
          data['message']?.toString() ?? 'No se pudo subir la imagen.';
    } catch (_) {
      _lastUploadError = 'No se pudo subir la imagen.';
    }
    return null;
  }

  Future<String> _normalizeImageForUpload(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return filePath;
      final baked = img.bakeOrientation(decoded);
      final jpg = img.encodeJpg(baked, quality: 90);
      final dir = await getTemporaryDirectory();
      final target = File(
        '${dir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await target.writeAsBytes(jpg, flush: true);
      return target.path;
    } catch (_) {
      return filePath;
    }
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return const {};
  }

  String? _baseOrigin() {
    final config = _settings?.apiConfig;
    if (config == null || config.baseUrl.isEmpty) return null;
    final uri = Uri.tryParse(config.baseUrl);
    if (uri == null) return null;
    final scheme = uri.scheme.isEmpty ? 'http' : uri.scheme;
    final host = uri.host.isNotEmpty ? uri.host : uri.path;
    if (host.isEmpty) return null;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://$host$port';
  }
}

enum ProductViewMode { grid, list }
