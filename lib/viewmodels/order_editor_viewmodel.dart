import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../constants/pagination.dart';
import '../models/api_config.dart';
import '../models/product.dart';
import '../utils/debug_tools.dart';
import 'auth_viewmodel.dart';
import 'settings_viewmodel.dart';

class OrderEditorViewModel extends ChangeNotifier {
  SettingsViewModel? _settings;
  AuthViewModel? _auth;

  int? _orderId;
  bool _isLoadingInitial = false;
  bool _isLoadingProducts = false;
  bool _isLoadingMoreProducts = false;
  bool _isLoadingClients = false;
  bool _isLoadingReasons = false;
  bool _isSaving = false;
  bool _isResolvingGps = false;

  String? _errorMessage;
  String? _saveErrorMessage;

  DateTime _fecha = _dateOnly(DateTime.now());
  bool _noPidio = false;
  String _gpsUbicacion = '';
  String _observaciones = '';

  OrderClientOption? _selectedClient;
  final List<OrderClientOption> _clientResults = [];

  final List<OrderLookupOption> _sucursales = [];
  final List<OrderLookupOption> _puntosVenta = [];
  final List<OrderLookupOption> _bodegas = [];
  final List<OrderLookupOption> _vendedores = [];
  final List<OrderLookupOption> _centrosCosto = [];
  final List<OrderDocumentTypeOption> _tiposDocumento = [];
  final List<OrderSeriesOption> _series = [];
  final List<OrderReasonOption> _motivosNoPedido = [];
  final List<OrderLookupOption> _productCategories = [];

  int? _selectedSucursalId;
  int? _selectedPuntoVentaId;
  int? _selectedBodegaId;
  int? _selectedVendedorId;
  int? _selectedCentroCostoId;
  int? _selectedTipoDocumentoId;
  int? _selectedSerieId;
  int? _selectedMotivoNoPedidoId;
  int? _selectedProductCategoryId;

  bool _serieAutomatica = true;
  int? _numeroManual;

  final List<Product> _products = [];
  String _productSearch = '';
  int _productsCurrentPage = 1;
  int _productsLastPage = 1;

  final Map<int, OrderLineDraft> _lineas = {};
  int _summaryPulse = 0;
  int _tapMultiplier = 1;

  int? get orderId => _orderId;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingMoreProducts => _isLoadingMoreProducts;
  bool get isLoadingClients => _isLoadingClients;
  bool get isLoadingReasons => _isLoadingReasons;
  bool get isSaving => _isSaving;
  bool get isResolvingGps => _isResolvingGps;
  String? get errorMessage => _errorMessage;
  String? get saveErrorMessage => _saveErrorMessage;

  DateTime get fecha => _fecha;
  bool get noPidio => _noPidio;
  String get gpsUbicacion => _gpsUbicacion;
  String get observaciones => _observaciones;

  OrderClientOption? get selectedClient => _selectedClient;
  List<OrderClientOption> get clientResults =>
      List.unmodifiable(_clientResults);

  List<OrderLookupOption> get sucursales => List.unmodifiable(_sucursales);
  List<OrderLookupOption> get puntosVenta => List.unmodifiable(_puntosVenta);
  List<OrderLookupOption> get bodegas => List.unmodifiable(_bodegas);
  List<OrderLookupOption> get vendedores => List.unmodifiable(_vendedores);
  List<OrderLookupOption> get centrosCosto => List.unmodifiable(_centrosCosto);
  List<OrderDocumentTypeOption> get tiposDocumento =>
      List.unmodifiable(_tiposDocumento);
  List<OrderSeriesOption> get series => List.unmodifiable(_series);
  List<OrderReasonOption> get motivosNoPedido =>
      List.unmodifiable(_motivosNoPedido);
  List<OrderLookupOption> get productCategories =>
      List.unmodifiable(_productCategories);

  int? get selectedSucursalId => _selectedSucursalId;
  int? get selectedPuntoVentaId => _selectedPuntoVentaId;
  int? get selectedBodegaId => _selectedBodegaId;
  int? get selectedVendedorId => _selectedVendedorId;
  int? get selectedCentroCostoId => _selectedCentroCostoId;
  int? get selectedTipoDocumentoId => _selectedTipoDocumentoId;
  int? get selectedSerieId => _selectedSerieId;
  int? get selectedMotivoNoPedidoId => _selectedMotivoNoPedidoId;
  int? get selectedProductCategoryId => _selectedProductCategoryId;

  bool get serieAutomatica => _serieAutomatica;
  int? get numeroManual => _numeroManual;

  List<Product> get products => List.unmodifiable(_products);
  String get productSearch => _productSearch;
  bool get hasMoreProducts => _productsCurrentPage < _productsLastPage;

  Map<int, OrderLineDraft> get lineas => Map.unmodifiable(_lineas);
  int get lineasCount => _lineas.length;
  double get cantidadTotal =>
      _lineas.values.fold(0, (sum, line) => sum + line.cantidad);
  double get totalPedido =>
      _lineas.values.fold(0, (sum, line) => sum + line.subtotal);
  int get summaryPulse => _summaryPulse;
  int get tapMultiplier => _tapMultiplier;

  void updateDependencies(SettingsViewModel settings, AuthViewModel auth) {
    _settings = settings;
    _auth = auth;
  }

  Future<void> initialize({int? orderId}) async {
    _orderId = orderId;
    _isLoadingInitial = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (orderId != null) {
        await _loadOrder(orderId);
      }

      await Future.wait([
        _loadSucursales(),
        _loadVendedores(),
        _loadCentrosCosto(),
        _loadTiposDocumento(),
        _loadMotivosNoPedido(),
        _loadProductCategories(),
      ]);

      _ensureBaseSelections();
      await _loadPuntosVenta();
      await _loadBodegas();
      await _loadSeries();

      if (_products.isEmpty) {
        await loadProducts(reset: true);
      }
    } catch (e, st) {
      debugTrace('ORDER_EDITOR_VM', 'initialize exception: $e\n$st');
      _errorMessage = 'No se pudo cargar el formulario de pedido.';
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await initialize(orderId: _orderId);
  }

  void clearSaveError() {
    if (_saveErrorMessage == null) return;
    _saveErrorMessage = null;
    notifyListeners();
  }

  void setFecha(DateTime value) {
    final normalized = _dateOnly(value);
    if (_isSameDate(_fecha, normalized)) return;
    _fecha = normalized;
    notifyListeners();
    unawaited(_loadSeries());
  }

  void setObservaciones(String value) {
    final normalized = value.trim();
    if (_observaciones == normalized) return;
    _observaciones = normalized;
    notifyListeners();
  }

  void setGpsUbicacion(String value) {
    final normalized = value.trim();
    if (_gpsUbicacion == normalized) return;
    _gpsUbicacion = normalized;
    notifyListeners();
  }

  void setNoPidio(bool value) {
    if (_noPidio == value) return;
    _noPidio = value;
    if (value) {
      _lineas.clear();
    }
    notifyListeners();
  }

  void selectClient(OrderClientOption option) {
    _selectedClient = option;
    _clientResults.clear();
    notifyListeners();
  }

  void clearSelectedClient() {
    if (_selectedClient == null) return;
    _selectedClient = null;
    notifyListeners();
  }

  Future<void> searchClients(String query) async {
    final term = query.trim();
    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) {
      _clientResults.clear();
      _isLoadingClients = false;
      notifyListeners();
      return;
    }

    _isLoadingClients = true;
    notifyListeners();

    try {
      final params = <String, String>{'activo': '1', 'per_page': '20'};
      if (term.isNotEmpty) {
        params['q'] = term;
      }
      final uri = config
          .buildUri('/${config.companyCode}/clientes')
          .replace(queryParameters: params);
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (!_isSuccess(response.statusCode)) {
        _clientResults.clear();
        return;
      }

      final data = _decodeJson(response.body);
      final items = _extractList(data, const ['clientes', 'socios']);
      _clientResults
        ..clear()
        ..addAll(items.map(OrderClientOption.fromJson));
    } catch (_) {
      _clientResults.clear();
    } finally {
      _isLoadingClients = false;
      notifyListeners();
    }
  }

  Future<void> setSucursal(int? id) async {
    if (id == null || _selectedSucursalId == id) return;
    _selectedSucursalId = id;
    _selectedPuntoVentaId = null;
    _selectedBodegaId = null;
    notifyListeners();

    await _loadPuntosVenta();
    await _loadBodegas();
    await _loadSeries();
  }

  Future<void> setPuntoVenta(int? id) async {
    if (id == null || _selectedPuntoVentaId == id) return;
    _selectedPuntoVentaId = id;
    notifyListeners();
    await _loadSeries();
  }

  void setBodega(int? id) {
    if (_selectedBodegaId == id) return;
    _selectedBodegaId = id;
    notifyListeners();
  }

  void setVendedor(int? id) {
    if (_selectedVendedorId == id) return;
    _selectedVendedorId = id;
    notifyListeners();
  }

  void setCentroCosto(int? id) {
    if (_selectedCentroCostoId == id) return;
    _selectedCentroCostoId = id;
    notifyListeners();
  }

  Future<void> setTipoDocumento(int? id) async {
    if (id == null || _selectedTipoDocumentoId == id) return;
    _selectedTipoDocumentoId = id;
    _selectedSerieId = null;
    _serieAutomatica = true;
    _numeroManual = null;
    notifyListeners();
    await _loadSeries();
  }

  void setSerie(int? id) {
    if (id == null || _selectedSerieId == id) return;
    _selectedSerieId = id;
    final serie = _series.firstWhere(
      (item) => item.id == id,
      orElse: () => const OrderSeriesOption(
        id: 0,
        codigo: '',
        nombre: '',
        automatica: true,
      ),
    );
    _serieAutomatica = serie.automatica;
    if (_serieAutomatica) {
      _numeroManual = null;
    }
    notifyListeners();
  }

  void setNumeroManual(String value) {
    final parsed = int.tryParse(value.trim());
    if (_numeroManual == parsed) return;
    _numeroManual = parsed;
    notifyListeners();
  }

  void setMotivoNoPedido(int? id) {
    if (_selectedMotivoNoPedidoId == id) return;
    _selectedMotivoNoPedidoId = id;
    notifyListeners();
  }

  void setProductCategory(int? id) {
    if (_selectedProductCategoryId == id) return;
    _selectedProductCategoryId = id;
    loadProducts(reset: true);
  }

  void updateProductSearch(String value) {
    final normalized = value.trim();
    if (_productSearch == normalized) return;
    _productSearch = normalized;
    loadProducts(reset: true);
  }

  void setTapMultiplier(int value) {
    final normalized = value < 1 ? 1 : value;
    if (_tapMultiplier == normalized) return;
    _tapMultiplier = normalized;
    notifyListeners();
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (_isLoadingProducts || _isLoadingMoreProducts) return;

    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) return;

    if (reset) {
      _isLoadingProducts = true;
      _productsCurrentPage = 1;
      _productsLastPage = 1;
      notifyListeners();
    } else {
      if (!hasMoreProducts) return;
      _isLoadingMoreProducts = true;
      notifyListeners();
    }

    try {
      final nextPage = reset ? 1 : _productsCurrentPage + 1;
      final params = <String, String>{
        'page': nextPage.toString(),
        'per_page': kPageSize.toString(),
        'activo': '1',
      };
      if (_productSearch.isNotEmpty) {
        params['q'] = _productSearch;
      }
      if (_selectedProductCategoryId != null) {
        params['product_category_id'] = _selectedProductCategoryId.toString();
      }

      final uri = config
          .buildUri('/${config.companyCode}/productos')
          .replace(queryParameters: params);
      final response = await http.get(uri, headers: _authHeaders(auth));
      if (!_isSuccess(response.statusCode)) {
        if (reset) {
          _products.clear();
          _errorMessage = _extractErrorMessage(response.body);
        }
        return;
      }

      final data = _decodeJson(response.body);
      final items = _extractList(data, const ['products', 'productos']);
      final fetched = items.map(Product.fromJson).toList();

      if (reset) {
        _products
          ..clear()
          ..addAll(fetched);
      } else {
        _products.addAll(fetched);
      }

      final pagination = data['pagination'];
      if (pagination is Map) {
        _productsCurrentPage = _toInt(pagination['current_page']) ?? nextPage;
        _productsLastPage =
            _toInt(pagination['last_page']) ?? _productsCurrentPage;
      } else {
        _productsCurrentPage = nextPage;
        _productsLastPage = fetched.length < kPageSize
            ? nextPage
            : nextPage + 1;
      }
    } catch (_) {
      if (reset) {
        _products.clear();
      }
    } finally {
      _isLoadingProducts = false;
      _isLoadingMoreProducts = false;
      notifyListeners();
    }
  }

  void addProduct(Product product, {int quantity = 1}) {
    if (_noPidio) return;

    final current = _lineas[product.id];
    final increment = quantity < 1 ? 1 : quantity.toDouble();
    final nextQty = (current?.cantidad ?? 0) + increment;
    _lineas[product.id] = OrderLineDraft(
      productId: product.id,
      codigo: product.codigo,
      nombre: product.nombre,
      precioUnitario: product.precio,
      cantidad: nextQty,
    );
    _summaryPulse += 1;
    notifyListeners();
  }

  void removeProduct(int productId) {
    final current = _lineas[productId];
    if (current == null) return;

    final nextQty = current.cantidad - 1;
    if (nextQty <= 0) {
      _lineas.remove(productId);
    } else {
      _lineas[productId] = current.copyWith(cantidad: nextQty);
    }
    notifyListeners();
  }

  void setProductQuantity(int productId, double quantity) {
    final current = _lineas[productId];
    if (current == null) return;

    if (quantity <= 0) {
      _lineas.remove(productId);
    } else {
      _lineas[productId] = current.copyWith(cantidad: quantity);
    }
    notifyListeners();
  }

  int quantityByProduct(int productId) {
    final qty = _lineas[productId]?.cantidad ?? 0;
    return qty.toInt();
  }

  Future<OrderReasonOption?> createMotivoNoPedido({
    required String nombre,
    String? codigo,
  }) async {
    final cleanedName = nombre.trim();
    final cleanedCode = codigo?.trim();
    if (cleanedName.isEmpty) return null;

    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) return null;

    _isLoadingReasons = true;
    notifyListeners();

    try {
      final uri = config.buildUri('/${config.companyCode}/motivos-no-pedido');
      final payload = <String, dynamic>{
        'nombre': cleanedName,
        if (cleanedCode != null && cleanedCode.isNotEmpty)
          'codigo': cleanedCode,
        'activo': true,
      };

      final response = await http.post(
        uri,
        headers: _authHeaders(auth),
        body: jsonEncode(payload),
      );

      if (!_isSuccess(response.statusCode)) {
        _saveErrorMessage = _extractErrorMessage(response.body);
        return null;
      }

      final data = _decodeJson(response.body);
      final raw = _asMap(data['motivo_no_pedido']);
      if (raw == null) {
        await _loadMotivosNoPedido();
        return null;
      }

      final created = OrderReasonOption.fromJson(raw);
      _motivosNoPedido.insert(0, created);
      _selectedMotivoNoPedidoId = created.id;
      _saveErrorMessage = null;
      notifyListeners();
      return created;
    } catch (_) {
      _saveErrorMessage = 'No se pudo crear el motivo.';
      notifyListeners();
      return null;
    } finally {
      _isLoadingReasons = false;
      notifyListeners();
    }
  }

  Future<bool> captureGpsFromDevice() async {
    _isResolvingGps = true;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _gpsUbicacion =
          '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isResolvingGps = false;
      notifyListeners();
    }
  }

  Future<bool> saveOrder() async {
    _saveErrorMessage = null;

    if (_noPidio && _gpsUbicacion.trim().isEmpty) {
      await captureGpsFromDevice();
    }

    final validationMessage = _validateBeforeSave();
    if (validationMessage != null) {
      _saveErrorMessage = validationMessage;
      notifyListeners();
      return false;
    }

    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) {
      _saveErrorMessage = 'Configura la API y la sesión antes de guardar.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final payload = _buildSavePayload();
      final path = _orderId == null
          ? '/${config.companyCode}/ventas'
          : '/${config.companyCode}/ventas/${_orderId!}';
      final uri = config.buildUri(path);

      final response = _orderId == null
          ? await http.post(
              uri,
              headers: _authHeaders(auth),
              body: jsonEncode(payload),
            )
          : await http.put(
              uri,
              headers: _authHeaders(auth),
              body: jsonEncode(payload),
            );

      if (!_isSuccess(response.statusCode)) {
        _saveErrorMessage = _extractErrorMessage(response.body);
        notifyListeners();
        return false;
      }

      _saveErrorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _saveErrorMessage = 'No se pudo guardar el pedido.';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String? _validateBeforeSave() {
    if (_selectedClient == null) {
      return 'Selecciona un cliente.';
    }
    if (_selectedSucursalId == null) {
      return 'Selecciona una sucursal.';
    }
    if (_selectedPuntoVentaId == null) {
      return 'Selecciona un punto de venta.';
    }
    if (_selectedVendedorId == null) {
      return 'Selecciona un vendedor.';
    }
    if (_selectedCentroCostoId == null) {
      return 'Selecciona un centro de costo.';
    }
    if (_selectedTipoDocumentoId == null) {
      return 'Selecciona un tipo de documento.';
    }
    if (_selectedSerieId == null) {
      return 'Selecciona una serie.';
    }
    if (!_serieAutomatica && (_numeroManual == null || _numeroManual! <= 0)) {
      return 'Ingresa un número manual válido para la serie.';
    }

    if (_noPidio) {
      if (_selectedMotivoNoPedidoId == null) {
        return 'Selecciona un motivo de no pedido.';
      }
      if (_gpsUbicacion.trim().isEmpty) {
        return 'Se requiere GPS para registrar no pidió.';
      }
      return null;
    }

    if (_selectedBodegaId == null) {
      return 'Selecciona una bodega.';
    }
    if (_lineas.isEmpty) {
      return 'Agrega al menos un producto al pedido.';
    }

    return null;
  }

  Map<String, dynamic> _buildSavePayload() {
    final payload = <String, dynamic>{
      'document_type_id': _selectedTipoDocumentoId,
      'socio_id': _selectedClient?.id,
      'sucursal_id': _selectedSucursalId,
      'punto_venta_id': _selectedPuntoVentaId,
      'vendedor_id': _selectedVendedorId,
      'centro_costo_id': _selectedCentroCostoId,
      'fecha': _formatDate(_fecha),
      'tipo_registro': 'PED',
      'tipo_operacion': 'pedido',
      'no_pidio': _noPidio,
      'serie_id': _selectedSerieId,
      if (!_serieAutomatica && _numeroManual != null) 'numero': _numeroManual,
      if (_selectedMotivoNoPedidoId != null)
        'motivo_no_pedido_id': _selectedMotivoNoPedidoId,
      if (_gpsUbicacion.trim().isNotEmpty)
        'gps_ubicacion': _gpsUbicacion.trim(),
      if (_observaciones.trim().isNotEmpty)
        'observaciones': _observaciones.trim(),
    };

    if (!_noPidio) {
      final detalles = _lineas.values
          .map(
            (linea) => <String, dynamic>{
              'product_id': linea.productId,
              'bodega_id': _selectedBodegaId,
              'cantidad': linea.cantidad,
              'precio_unitario': linea.precioUnitario,
              'descuento': 0,
            },
          )
          .toList();
      payload['detalles'] = detalles;
    }

    return payload;
  }

  Future<void> _loadOrder(int orderId) async {
    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) return;

    final uri = config.buildUri('/${config.companyCode}/ventas/$orderId');
    final response = await http.get(uri, headers: _authHeaders(auth));
    if (!_isSuccess(response.statusCode)) {
      _errorMessage = _extractErrorMessage(response.body);
      return;
    }

    final data = _decodeJson(response.body);
    final venta = _asMap(data['venta']);
    if (venta == null) return;

    _fecha = _toDate(venta['fecha']) ?? _dateOnly(DateTime.now());
    _noPidio = _toBool(venta['no_pidio']) ?? false;
    _gpsUbicacion = _toText(venta['gps_ubicacion']) ?? '';
    _observaciones = _toText(venta['observaciones']) ?? '';

    _selectedSucursalId = _toInt(venta['sucursal_id']);
    _selectedPuntoVentaId = _toInt(venta['punto_venta_id']);
    _selectedVendedorId = _toInt(venta['vendedor_id']);
    _selectedCentroCostoId = _toInt(venta['centro_costo_id']);
    _selectedTipoDocumentoId = _toInt(venta['document_type_id']);
    _selectedSerieId = _toInt(venta['serie_id']);
    _numeroManual = _toInt(venta['numero']);

    final motivo = _asMap(venta['motivo_no_pedido']);
    _selectedMotivoNoPedidoId =
        _toInt(venta['motivo_no_pedido_id']) ?? _toInt(motivo?['id']);

    final socio = _asMap(venta['socio']);
    if (socio != null) {
      _selectedClient = OrderClientOption.fromJson(socio);
    }

    final detallesRaw = venta['detalles'];
    _lineas.clear();
    if (detallesRaw is List) {
      for (final item in detallesRaw) {
        if (item is! Map) continue;
        final map = item.map((k, v) => MapEntry(k.toString(), v));
        final aplicaTotales = _toBool(map['aplica_totales']) ?? true;
        if (!aplicaTotales) continue;

        final product = _asMap(map['product']);
        final productId =
            _toInt(map['product_id']) ?? _toInt(product?['id']) ?? 0;
        if (productId <= 0) continue;

        final existing = _lineas[productId];
        final cantidad = _toDouble(map['cantidad']);
        final precio = _toDouble(map['precio_unitario']);

        final currentQty = existing?.cantidad ?? 0;
        _lineas[productId] = OrderLineDraft(
          productId: productId,
          codigo: _toText(product?['codigo']) ?? '',
          nombre: _toText(product?['nombre']) ?? 'Producto $productId',
          precioUnitario: precio,
          cantidad: currentQty + cantidad,
        );
      }
    }

    if (_lineas.isNotEmpty) {
      final first = _lineas.values.first;
      final detail = (detallesRaw is List)
          ? detallesRaw
                .whereType<Map>()
                .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
                .firstWhere(
                  (e) => _toInt(e['product_id']) == first.productId,
                  orElse: () => const <String, dynamic>{},
                )
          : const <String, dynamic>{};
      final bodegaId = _toInt(detail['bodega_id']);
      if (bodegaId != null && bodegaId > 0) {
        _selectedBodegaId = bodegaId;
      }
    }
  }

  Future<void> _loadSucursales() async {
    final items = await _fetchAllPages(
      path: '/sucursales',
      keys: const ['sucursales'],
      params: const {'activo': '1'},
    );

    _sucursales
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_selectedSucursalId == null && _sucursales.isNotEmpty) {
      _selectedSucursalId = _sucursales.first.id;
    }
  }

  Future<void> _loadPuntosVenta() async {
    if (_selectedSucursalId == null) {
      _puntosVenta.clear();
      _selectedPuntoVentaId = null;
      notifyListeners();
      return;
    }

    final items = await _fetchAllPages(
      path: '/puntos-venta',
      keys: const ['puntos_venta'],
      params: {'activo': '1', 'sucursal_id': _selectedSucursalId.toString()},
    );

    _puntosVenta
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_puntosVenta.any((item) => item.id == _selectedPuntoVentaId)) {
      return;
    }
    _selectedPuntoVentaId = _puntosVenta.isEmpty ? null : _puntosVenta.first.id;
    notifyListeners();
  }

  Future<void> _loadBodegas() async {
    if (_selectedSucursalId == null) {
      _bodegas.clear();
      _selectedBodegaId = null;
      notifyListeners();
      return;
    }

    final items = await _fetchAllPages(
      path: '/bodegas',
      keys: const ['bodegas'],
      params: {'activo': '1', 'sucursal_id': _selectedSucursalId.toString()},
    );

    _bodegas
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_bodegas.any((item) => item.id == _selectedBodegaId)) {
      return;
    }
    _selectedBodegaId = _bodegas.isEmpty ? null : _bodegas.first.id;
    notifyListeners();
  }

  Future<void> _loadVendedores() async {
    final items = await _fetchAllPages(
      path: '/vendedores',
      keys: const ['vendedores'],
      params: const {'activo': '1'},
    );

    _vendedores
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_selectedVendedorId == null && _vendedores.isNotEmpty) {
      _selectedVendedorId = _vendedores.first.id;
    }
  }

  Future<void> _loadCentrosCosto() async {
    final items = await _fetchAllPages(
      path: '/centros-costo',
      keys: const ['centros_costo'],
      params: const {'activo': '1'},
    );

    _centrosCosto
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_selectedCentroCostoId == null && _centrosCosto.isNotEmpty) {
      _selectedCentroCostoId = _centrosCosto.first.id;
    }
  }

  Future<void> _loadTiposDocumento() async {
    final items = await _fetchAllPages(
      path: '/tipos-documento',
      keys: const ['document_types'],
      params: const {'module': 'ventas'},
    );

    _tiposDocumento
      ..clear()
      ..addAll(items.map(OrderDocumentTypeOption.fromJson));

    if (_selectedTipoDocumentoId == null && _tiposDocumento.isNotEmpty) {
      _selectedTipoDocumentoId = _tiposDocumento.first.id;
    }
  }

  Future<void> _loadSeries() async {
    if (_selectedTipoDocumentoId == null ||
        _selectedSucursalId == null ||
        _selectedPuntoVentaId == null) {
      _series.clear();
      _selectedSerieId = null;
      _serieAutomatica = true;
      _numeroManual = null;
      notifyListeners();
      return;
    }

    final selectedType = _selectedTipoDocumentoId.toString();
    final selectedSucursal = _selectedSucursalId.toString();
    final selectedPuntoVenta = _selectedPuntoVentaId.toString();
    final selectedYear = _fecha.year.toString();

    var items = await _fetchAllPages(
      path: '/series',
      keys: const ['series'],
      params: {
        'document_type_id': selectedType,
        'sucursal_id': selectedSucursal,
        'punto_venta_id': selectedPuntoVenta,
        'anio': selectedYear,
      },
    );

    if (items.isEmpty) {
      items = await _fetchAllPages(
        path: '/series',
        keys: const ['series'],
        params: {
          'document_type_id': selectedType,
          'sucursal_id': selectedSucursal,
          'punto_venta_id': selectedPuntoVenta,
        },
      );
    }

    if (items.isEmpty) {
      items = await _fetchAllPages(
        path: '/series',
        keys: const ['series'],
        params: {
          'document_type_id': selectedType,
          'anio': selectedYear,
        },
      );
    }

    if (items.isEmpty) {
      items = await _fetchAllPages(
        path: '/series',
        keys: const ['series'],
        params: {'document_type_id': selectedType},
      );
    }

    _series
      ..clear()
      ..addAll(
        items
            .map(OrderSeriesOption.fromJson)
            .where(_seriesMatchesHeaderSelection),
      );

    if (!_series.any((item) => item.id == _selectedSerieId)) {
      _selectedSerieId = _series.isEmpty ? null : _series.first.id;
    }

    final selected = _series.firstWhere(
      (item) => item.id == _selectedSerieId,
      orElse: () => const OrderSeriesOption(
        id: 0,
        codigo: '',
        nombre: '',
        automatica: true,
      ),
    );
    _serieAutomatica = selected.automatica;
    if (_serieAutomatica) {
      _numeroManual = null;
    }
    notifyListeners();
  }

  bool _seriesMatchesHeaderSelection(OrderSeriesOption item) {
    final sucursalMatch =
        item.sucursalId == null || item.sucursalId == _selectedSucursalId;
    final puntoVentaMatch = item.puntoVentaId == null ||
        item.puntoVentaId == _selectedPuntoVentaId;

    // Pedidos/ventas no deben usar series amarradas a una bodega.
    final validForVentas = item.bodegaId == null;

    return sucursalMatch && puntoVentaMatch && validForVentas;
  }

  Future<void> _loadMotivosNoPedido() async {
    _isLoadingReasons = true;
    notifyListeners();

    try {
      final items = await _fetchAllPages(
        path: '/motivos-no-pedido',
        keys: const ['motivos_no_pedido'],
        params: const {'activo': '1'},
      );

      _motivosNoPedido
        ..clear()
        ..addAll(items.map(OrderReasonOption.fromJson));

      if (_selectedMotivoNoPedidoId == null && _motivosNoPedido.isNotEmpty) {
        _selectedMotivoNoPedidoId = _motivosNoPedido.first.id;
      }
    } finally {
      _isLoadingReasons = false;
      notifyListeners();
    }
  }

  Future<void> _loadProductCategories() async {
    final items = await _fetchAllPages(
      path: '/categorias',
      keys: const ['categories'],
    );

    _productCategories
      ..clear()
      ..addAll(items.map(OrderLookupOption.fromJson));

    if (_selectedProductCategoryId != null &&
        !_productCategories.any(
          (item) => item.id == _selectedProductCategoryId,
        )) {
      _selectedProductCategoryId = null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllPages({
    required String path,
    required List<String> keys,
    Map<String, String> params = const {},
  }) async {
    final config = _currentConfig();
    final auth = await _readyAuth();
    if (config == null || auth == null) return const [];

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

  void _ensureBaseSelections() {
    _selectedSucursalId ??= _sucursales.isEmpty ? null : _sucursales.first.id;
    _selectedVendedorId ??= _vendedores.isEmpty ? null : _vendedores.first.id;
    _selectedCentroCostoId ??= _centrosCosto.isEmpty
        ? null
        : _centrosCosto.first.id;
    _selectedTipoDocumentoId ??= _tiposDocumento.isEmpty
        ? null
        : _tiposDocumento.first.id;
  }

  ApiConfig? _currentConfig() {
    final config = _settings?.apiConfig;
    if (config == null || !config.isComplete || !config.isValidUrl) return null;
    return config;
  }

  Future<AuthViewModel?> _readyAuth() async {
    final auth = _auth;
    if (auth == null) return null;
    if (auth.token.isEmpty) {
      await auth.reloadFromStorage();
    }
    if (auth.token.isEmpty) return null;
    return auth;
  }

  Map<String, String> _authHeaders(AuthViewModel auth) {
    return withDebugHeader({
      'Accept': 'application/json',
      'Authorization': auth.authorizationHeader,
      'Content-Type': 'application/json',
    });
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

  bool _isSuccess(int code) => code >= 200 && code < 300;

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return const {};
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

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  String _extractErrorMessage(String rawBody) {
    final data = _decodeJson(rawBody);
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'No se pudo procesar la solicitud.';
  }

  String? _toText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
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

  DateTime? _toDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String? _baseOrigin() {
    final config = _currentConfig();
    if (config == null) return null;
    final uri = Uri.tryParse(config.baseUrl.trim());
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) return null;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }
}

class OrderLookupOption {
  const OrderLookupOption({
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

  factory OrderLookupOption.fromJson(Map<String, dynamic> json) {
    return OrderLookupOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class OrderDocumentTypeOption extends OrderLookupOption {
  const OrderDocumentTypeOption({
    required super.id,
    required super.codigo,
    required super.nombre,
    required this.module,
  });

  final String module;

  factory OrderDocumentTypeOption.fromJson(Map<String, dynamic> json) {
    return OrderDocumentTypeOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
    );
  }
}

class OrderSeriesOption extends OrderLookupOption {
  const OrderSeriesOption({
    required super.id,
    required super.codigo,
    required super.nombre,
    required this.automatica,
    this.anio,
    this.sucursalId,
    this.puntoVentaId,
    this.bodegaId,
  });

  final bool automatica;
  final int? anio;
  final int? sucursalId;
  final int? puntoVentaId;
  final int? bodegaId;

  @override
  String get label {
    final mode = automatica ? 'Auto' : 'Manual';
    final code = codigo.trim();
    final anioLabel = anio == null ? '' : ' $anio';
    if (code.isEmpty) return '$nombre$anioLabel ($mode)';
    return '$code • $nombre$anioLabel ($mode)';
  }

  factory OrderSeriesOption.fromJson(Map<String, dynamic> json) {
    final serie = json['serie']?.toString() ?? '';
    final nombre = serie.isEmpty ? 'Serie' : 'Serie $serie';
    return OrderSeriesOption(
      id: _toInt(json['id']) ?? 0,
      codigo: serie,
      nombre: nombre,
      automatica: _toBool(json['automatica']) ?? true,
      anio: _toInt(json['anio']),
      sucursalId: _toInt(json['sucursal_id']),
      puntoVentaId: _toInt(json['punto_venta_id']),
      bodegaId: _toInt(json['bodega_id']),
    );
  }
}

class OrderReasonOption extends OrderLookupOption {
  const OrderReasonOption({
    required super.id,
    required super.codigo,
    required super.nombre,
  });

  factory OrderReasonOption.fromJson(Map<String, dynamic> json) {
    return OrderReasonOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class OrderClientOption {
  const OrderClientOption({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.nombreComercial,
    this.telefono,
    this.celular,
    this.gpsUbicacion,
  });

  final int id;
  final String codigo;
  final String nombre;
  final String? nombreComercial;
  final String? telefono;
  final String? celular;
  final String? gpsUbicacion;

  String get label {
    final code = codigo.trim();
    if (code.isEmpty) return nombre;
    return '$code • $nombre';
  }

  String get telefonoPrincipal {
    final cel = celular?.trim() ?? '';
    if (cel.isNotEmpty) return cel;
    final tel = telefono?.trim() ?? '';
    if (tel.isNotEmpty) return tel;
    return '';
  }

  factory OrderClientOption.fromJson(Map<String, dynamic> json) {
    return OrderClientOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      nombreComercial: _toText(json['nombre_comercial']),
      telefono: _toText(json['telefono']),
      celular: _toText(json['celular']),
      gpsUbicacion: _toText(json['gps_ubicacion']),
    );
  }
}

class OrderLineDraft {
  const OrderLineDraft({
    required this.productId,
    required this.codigo,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });

  final int productId;
  final String codigo;
  final String nombre;
  final double precioUnitario;
  final double cantidad;

  double get subtotal => cantidad * precioUnitario;

  OrderLineDraft copyWith({
    int? productId,
    String? codigo,
    String? nombre,
    double? precioUnitario,
    double? cantidad,
  }) {
    return OrderLineDraft(
      productId: productId ?? this.productId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

String? _toText(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
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
