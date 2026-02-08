import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_config.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../data/app_db.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class ProductsViewModel extends ChangeNotifier {
  SettingsViewModel? _settings;
  AuthViewModel? _auth;
  AppDb? _db;

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
  String? _lastSyncError;
  bool _isSyncing = false;
  bool _isDownloadingPhotos = false;
  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 20;
  bool _initialized = false;
  final Map<int, int> _cart = {};
  ProductViewMode _viewMode = ProductViewMode.grid;
  static const _lastSyncKey = 'last_sync_catalog';

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
  String? get lastSyncError => _lastSyncError;
  bool get isSyncing => _isSyncing;
  bool get isDownloadingPhotos => _isDownloadingPhotos;

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

  void updateDependencies(
    SettingsViewModel settings,
    AuthViewModel auth,
    AppDb db,
  ) {
    _settings = settings;
    _auth = auth;
    _db = db;
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
      final hasConnection = await _hasConnection();
      if (!hasConnection) {
        await _loadCategoriesLocal();
        await _loadProductsLocal(page: 1);
      } else {
        await _loadCategories();
        await _loadProducts(page: 1);
      }
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
      final hasConnection = await _hasConnection();
      if (!hasConnection) {
        await _loadProductsLocal(page: _currentPage + 1);
      } else {
        await _loadProducts(page: _currentPage + 1);
      }
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

  Future<bool> _hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncCatalog({bool incremental = true}) async {
    if (_isSyncing) return;
    _lastSyncError = null;
    _isSyncing = true;
    notifyListeners();

    try {
      final config = _currentConfig();
      final auth = _auth;
      final db = _db;
      if (config == null || auth == null || auth.token.isEmpty || db == null) {
        _lastSyncError = 'No hay sesion activa.';
        return;
      }

      final lastSync = await _readLastSync();
      final useIncremental = incremental && lastSync != null;

      await _syncCategories(config, auth, db, useIncremental ? lastSync : null);
      await _syncBrands(config, auth, db, useIncremental ? lastSync : null);
      await _syncSucursales(config, auth, db, useIncremental ? lastSync : null);
      await _syncBodegas(config, auth, db, useIncremental ? lastSync : null);
      await _syncExistencias(config, auth, db, useIncremental ? lastSync : null);
      await _syncProducts(config, auth, db, useIncremental ? lastSync : null);

      await _saveLastSync(DateTime.now());
    } catch (_) {
      _lastSyncError = 'No se pudo sincronizar el catalogo.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> downloadAllPhotos() async {
    if (_isDownloadingPhotos) return;
    _isDownloadingPhotos = true;
    notifyListeners();

    try {
      final db = _db;
      final cache = DefaultCacheManager();
      final items = db == null
          ? _products
          : (await db.select(db.products).get())
              .map((row) => Product(
                    id: row.id,
                    codigo: row.codigo,
                  nombre: row.nombre,
                  precio: row.precio,
                  stock: row.stock,
                    colorHex: Product.colorFromId(row.id),
                    categoryId: row.categoryId,
                    categoryNombre: row.categoryNombre,
                    brandId: row.brandId,
                    brandNombre: row.brandNombre,
                    fotoUrl: row.fotoUrl,
                    fotoUrlWeb: row.fotoUrlWeb,
                    fotoThumbUrl: row.fotoThumbUrl,
                    descripcion: row.descripcion,
                    stockBySucursal: const [],
                  ))
              .toList();

      final urls = <String>{};
      for (final product in items) {
        final thumb = resolveImageUrl(product.fotoThumbUrl);
        final web = resolveImageUrl(product.fotoUrlWeb ?? product.fotoUrl);
        if (thumb.isNotEmpty) urls.add(thumb);
        if (web.isNotEmpty) urls.add(web);
      }

      for (final url in urls) {
        await cache.downloadFile(url);
      }
    } catch (_) {
      _lastSyncError = 'No se pudieron descargar las fotos.';
    } finally {
      _isDownloadingPhotos = false;
      notifyListeners();
    }
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

  Future<void> _loadCategoriesLocal() async {
    final db = _db;
    if (db == null) return;
    final rows = await db.fetchCategories();
    _categories
      ..clear()
      ..addAll(rows.map((row) => ProductCategory(id: row.id, nombre: row.nombre)));
  }

  Future<void> _loadProductsLocal({required int page}) async {
    final db = _db;
    if (db == null) {
      _errorMessage = 'No hay base local.';
      return;
    }

    final result = await db.fetchProductsPage(
      page: page,
      perPage: _perPage,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      categoryId: _selectedCategoryId,
      brandId: _selectedBrandId,
      tipo: 1,
      onlyActive: _onlyActive,
    );

    final rows = result.map((item) => item.row).toList();
    final total = result.isNotEmpty ? result.first.total : 0;
    final lastPage = (total / _perPage).ceil().clamp(1, 9999);

    final items = <Product>[];
    for (final row in rows) {
      final stocks = await db.fetchProductStocks(row.id);
      items.add(Product(
        id: row.id,
        codigo: row.codigo,
        nombre: row.nombre,
        precio: row.precio,
        stock: row.stock,
        colorHex: Product.colorFromId(row.id),
        categoryId: row.categoryId,
        categoryNombre: row.categoryNombre,
        brandId: row.brandId,
        brandNombre: row.brandNombre,
        fotoUrl: row.fotoUrl,
        fotoUrlWeb: row.fotoUrlWeb,
        fotoThumbUrl: row.fotoThumbUrl,
        descripcion: row.descripcion,
        stockBySucursal: stocks
            .map((s) => SucursalStock(
                  id: s.sucursalId,
                  codigo: s.sucursalCodigo ?? '',
                  nombre: s.sucursalNombre ?? '',
                  stockTotal: s.stockTotal,
                ))
            .toList(),
      ));
    }

    if (page == 1) {
      _products
        ..clear()
        ..addAll(items);
    } else {
      _products.addAll(items);
    }
    _currentPage = page;
    _lastPage = lastPage;
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

  Future<void> _syncCategories(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/categorias',
      listKey: 'categories',
      since: since,
    );
    final rows = items.map(_categoryCompanion).toList();
    await db.upsertCategories(rows);
  }

  Future<void> _syncBrands(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/marcas',
      listKey: 'brands',
      since: since,
    );
    final rows = items.map(_brandCompanion).toList();
    await db.upsertBrands(rows);
  }

  Future<void> _syncSucursales(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/sucursales',
      listKey: 'sucursales',
      since: since,
    );
    final rows = items.map(_sucursalCompanion).toList();
    await db.upsertSucursales(rows);
  }

  Future<void> _syncBodegas(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/bodegas',
      listKey: 'bodegas',
      since: since,
    );
    final rows = items.map(_bodegaCompanion).toList();
    await db.upsertBodegas(rows);
  }

  Future<void> _syncExistencias(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/existencias',
      listKey: 'existencias',
      since: since,
    );
    final rows = items.map(_existenciaCompanion).toList();
    await db.upsertExistencias(rows);
  }

  Future<void> _syncProducts(
    ApiConfig config,
    AuthViewModel auth,
    AppDb db,
    DateTime? since,
  ) async {
    final items = await _fetchPaged(
      config: config,
      auth: auth,
      path: '/${config.companyCode}/productos',
      listKey: 'products',
      since: since,
      extraParams: const {'tipo': '1'},
    );
    final rows = items.map(_productCompanion).toList();
    await db.upsertProducts(rows);

    for (final item in items) {
      final productId = _toInt(item['id']);
      if (productId == null) continue;
      final stocksRaw = item['existencias_sucursales'];
      final stocks = <ProductSucursalStocksCompanion>[];
      if (stocksRaw is List) {
        for (final entry in stocksRaw) {
          if (entry is Map) {
            final sucursal = entry['sucursal'];
            final sucursalMap = sucursal is Map
                ? sucursal.map((k, v) => MapEntry(k.toString(), v))
                : const <String, dynamic>{};
            final stockTotal = _toDouble(entry['stock_total']);
            final sucursalId = _toInt(sucursalMap['id']) ?? 0;
            stocks.add(ProductSucursalStocksCompanion(
              productId: Value(productId),
              sucursalId: Value(sucursalId),
              sucursalCodigo: Value(sucursalMap['codigo']?.toString()),
              sucursalNombre: Value(sucursalMap['nombre']?.toString()),
              stockTotal: Value(stockTotal),
            ));
          }
        }
      }
      await db.replaceProductSucursalStocks(productId, stocks);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPaged({
    required ApiConfig config,
    required AuthViewModel auth,
    required String path,
    required String listKey,
    DateTime? since,
    Map<String, String> extraParams = const {},
  }) async {
    final results = <Map<String, dynamic>>[];
    var page = 1;
    var lastPage = 1;

    do {
      final params = <String, String>{
        'page': page.toString(),
        'per_page': '100',
        ...extraParams,
      };
      if (since != null) {
        params['updated_since'] = since.toIso8601String();
        params['include_deleted'] = '1';
      }

      final uri = config.buildUri(path).replace(queryParameters: params);
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error sync $path');
      }
      final data = _decodeJson(response.body);
      final raw = data[listKey];
      if (raw is List) {
        results.addAll(
          raw.whereType<Map>().map(
                (item) => item.map((k, v) => MapEntry(k.toString(), v)),
              ),
        );
      }
      final pagination = data['pagination'];
      if (pagination is Map) {
        lastPage =
            (pagination['last_page'] as num?)?.toInt() ?? lastPage;
      }
      page += 1;
    } while (page <= lastPage);

    return results;
  }

  ProductCategoriesCompanion _categoryCompanion(Map<String, dynamic> json) {
    return ProductCategoriesCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      codigo: Value(json['codigo']?.toString() ?? ''),
      nombre: Value(json['nombre']?.toString() ?? ''),
      descripcion: Value(json['descripcion']?.toString()),
      activo: Value(_toBool(json['activo']) ?? true),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  BrandsCompanion _brandCompanion(Map<String, dynamic> json) {
    return BrandsCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      codigo: Value(json['codigo']?.toString() ?? ''),
      nombre: Value(json['nombre']?.toString() ?? ''),
      descripcion: Value(json['descripcion']?.toString()),
      activo: Value(_toBool(json['activo']) ?? true),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  SucursalesCompanion _sucursalCompanion(Map<String, dynamic> json) {
    return SucursalesCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      codigo: Value(json['codigo']?.toString() ?? ''),
      nombre: Value(json['nombre']?.toString() ?? ''),
      activo: Value(_toBool(json['activo']) ?? true),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  BodegasCompanion _bodegaCompanion(Map<String, dynamic> json) {
    return BodegasCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      sucursalId: Value(_toInt(json['sucursal_id'])),
      codigo: Value(json['codigo']?.toString() ?? ''),
      nombre: Value(json['nombre']?.toString() ?? ''),
      activo: Value(_toBool(json['activo']) ?? true),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  ExistenciasCompanion _existenciaCompanion(Map<String, dynamic> json) {
    return ExistenciasCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      bodegaId: Value(_toInt(json['bodega_id'])),
      productId: Value(_toInt(json['product_id'])),
      stock: Value(_toDouble(json['stock'])),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  ProductsCompanion _productCompanion(Map<String, dynamic> json) {
    final category = json['category'];
    final brand = json['brand'];
    final categoryMap = category is Map
        ? category.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    final brandMap = brand is Map
        ? brand.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    return ProductsCompanion(
      id: Value(_toInt(json['id']) ?? 0),
      codigo: Value(json['codigo']?.toString() ?? ''),
      nombre: Value(json['nombre']?.toString() ?? ''),
      tipo: Value(_toInt(json['tipo'])),
      precio: Value(_toDouble(json['precio'])),
      stock: Value(_toDouble(json['stock'])),
      activo: Value(_toBool(json['activo']) ?? true),
      descripcion: Value(json['descripcion']?.toString()),
      fotoUrl: Value(json['foto_url']?.toString()),
      fotoUrlWeb: Value(json['foto_url_web']?.toString()),
      fotoThumbUrl: Value(json['foto_thumb_url']?.toString()),
      categoryId: Value(_toInt(categoryMap['id'])),
      categoryNombre: Value(categoryMap['nombre']?.toString()),
      brandId: Value(_toInt(brandMap['id'])),
      brandNombre: Value(brandMap['nombre']?.toString()),
      updatedAt: Value(_parseDate(json['updated_at'])),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == '1' || normalized == 'true') return true;
      if (normalized == '0' || normalized == 'false') return false;
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  Future<DateTime?> _readLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _saveLastSync(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, value.toIso8601String());
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
          final updated = Product.fromJson(
            raw.map((k, v) => MapEntry(k.toString(), v)),
          );
          return updated.mergeFallback(product);
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
