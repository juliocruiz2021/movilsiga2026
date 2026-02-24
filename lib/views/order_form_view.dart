import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/order_editor_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'order_confirmation_view.dart';

class OrderFormView extends StatefulWidget {
  const OrderFormView({
    super.key,
    required this.settings,
    required this.auth,
    this.orderId,
  });

  final SettingsViewModel settings;
  final AuthViewModel auth;
  final int? orderId;

  @override
  State<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<OrderFormView> {
  late final OrderEditorViewModel _vm;
  late final ScrollController _scrollController;

  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  final TextEditingController _numeroManualController = TextEditingController();

  Timer? _clientSearchDebounce;
  Timer? _productSearchDebounce;

  bool _summaryPulse = false;
  int? _recentProductId;

  @override
  void initState() {
    super.initState();
    _vm = OrderEditorViewModel()
      ..updateDependencies(widget.settings, widget.auth)
      ..initialize(orderId: widget.orderId);
    _scrollController = ScrollController()..addListener(_handleProductScroll);
  }

  @override
  void dispose() {
    _clientSearchDebounce?.cancel();
    _productSearchDebounce?.cancel();
    _scrollController
      ..removeListener(_handleProductScroll)
      ..dispose();
    _clientSearchController.dispose();
    _productSearchController.dispose();
    _gpsController.dispose();
    _notaController.dispose();
    _numeroManualController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.orderId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar pedido' : 'Nuevo pedido'),
        actions: [
          IconButton(
            onPressed: _vm.isResolvingGps ? null : _captureGps,
            tooltip: 'Capturar GPS',
            icon: _vm.isResolvingGps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined),
          ),
          IconButton(
            onPressed: _vm.isLoadingInitial ? null : _vm.refreshAll,
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          _syncControllers();

          if (_vm.isLoadingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_vm.errorMessage != null && _vm.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_vm.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _vm.refreshAll,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  children: [
                    _buildClientCard(context),
                    const SizedBox(height: 12),
                    _buildHeaderCard(context),
                    const SizedBox(height: 12),
                    _buildProductsCard(context),
                    if (_vm.lineas.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildCurrentLinesCard(context),
                    ],
                    if (_vm.saveErrorMessage != null) ...[
                      const SizedBox(height: 12),
                      _buildSaveError(context, _vm.saveErrorMessage!),
                    ],
                  ],
                ),
              ),
              _buildSummaryBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context) {
    final palette = context.palette;
    final selected = _vm.selectedClient;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Cliente', icon: Icons.person_outline),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _clientSearchController,
                  onChanged: (value) {
                    _clientSearchDebounce?.cancel();
                    _clientSearchDebounce = Timer(
                      const Duration(milliseconds: 320),
                      () => _vm.searchClients(value),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por codigo, nombre o telefono',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _vm.isLoadingClients
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_clientSearchController.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _clientSearchController.clear();
                                    _vm.searchClients('');
                                  },
                                  icon: const Icon(Icons.close),
                                )),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: selected == null
                    ? null
                    : () {
                        _vm.clearSelectedClient();
                        _clientSearchController.clear();
                      },
                icon: const Icon(Icons.person_remove_outlined),
                tooltip: 'Quitar cliente',
              ),
            ],
          ),
          if (_vm.clientResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: palette.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _vm.clientResults.length,
                itemBuilder: (context, index) {
                  final client = _vm.clientResults[index];
                  return ListTile(
                    dense: true,
                    title: Text(client.label),
                    subtitle: Text(
                      client.telefonoPrincipal.trim().isEmpty
                          ? (client.nombreComercial ?? '')
                          : client.telefonoPrincipal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _vm.selectClient(client);
                      _clientSearchController.text = client.label;
                    },
                  );
                },
              ),
            ),
          ],
          if (selected != null) ...[
            const SizedBox(height: 8),
            _InfoText(
              text:
                  'Seleccionado: ${selected.label}${selected.telefonoPrincipal.trim().isEmpty ? '' : ' • ${selected.telefonoPrincipal}'}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Encabezado', icon: Icons.receipt_long_outlined),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text('Fecha: ${_formatDate(_vm.fecha)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Sucursal',
            value: _safeSelected(_vm.selectedSucursalId, _vm.sucursales),
            items: _vm.sucursales,
            onChanged: (value) {
              if (value == null) return;
              _vm.setSucursal(value);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Punto de venta',
            value: _safeSelected(_vm.selectedPuntoVentaId, _vm.puntosVenta),
            items: _vm.puntosVenta,
            onChanged: (value) {
              if (value == null) return;
              _vm.setPuntoVenta(value);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Bodega',
            value: _safeSelected(_vm.selectedBodegaId, _vm.bodegas),
            items: _vm.bodegas,
            onChanged: _vm.noPidio
                ? null
                : (value) {
                    if (value == null) return;
                    _vm.setBodega(value);
                  },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Vendedor',
            value: _safeSelected(_vm.selectedVendedorId, _vm.vendedores),
            items: _vm.vendedores,
            onChanged: (value) {
              if (value == null) return;
              _vm.setVendedor(value);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Centro de costo',
            value: _safeSelected(_vm.selectedCentroCostoId, _vm.centrosCosto),
            items: _vm.centrosCosto,
            onChanged: (value) {
              if (value == null) return;
              _vm.setCentroCosto(value);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Tipo documento',
            value: _safeSelected(
              _vm.selectedTipoDocumentoId,
              _vm.tiposDocumento,
            ),
            items: _vm.tiposDocumento,
            onChanged: (value) {
              if (value == null) return;
              _vm.setTipoDocumento(value);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdown<int>(
            label: 'Serie',
            value: _safeSelected(_vm.selectedSerieId, _vm.series),
            items: _vm.series,
            onChanged: (value) {
              if (value == null) return;
              _vm.setSerie(value);
            },
          ),
          if (!_vm.serieAutomatica) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _numeroManualController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numero manual',
                border: OutlineInputBorder(),
              ),
              onChanged: _vm.setNumeroManual,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _gpsController,
                  decoration: const InputDecoration(
                    labelText: 'GPS ubicacion',
                    hintText: 'lat,lng',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _vm.setGpsUbicacion,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _vm.isResolvingGps ? null : _captureGps,
                tooltip: 'Tomar GPS',
                icon: _vm.isResolvingGps
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'No va pedir',
                  style: TextStyle(
                    color: palette.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: _vm.noPidio,
                onChanged: (value) async {
                  _vm.setNoPidio(value);
                  if (value && _vm.gpsUbicacion.trim().isEmpty) {
                    await _captureGps();
                  }
                },
              ),
            ],
          ),
          if (_vm.noPidio) ...[
            _buildDropdown<int>(
              label: 'Motivo no pidio',
              value: _safeSelected(
                _vm.selectedMotivoNoPedidoId,
                _vm.motivosNoPedido,
              ),
              items: _vm.motivosNoPedido,
              onChanged: (value) {
                if (value == null) return;
                _vm.setMotivoNoPedido(value);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _vm.isLoadingReasons ? null : _openCreateReasonDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar motivo nuevo'),
            ),
            const SizedBox(height: 4),
            _InfoText(
              text: 'En no pidio, se guarda un pedido vacio con GPS y motivo.',
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: _notaController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Nota / observaciones',
              border: OutlineInputBorder(),
            ),
            onChanged: _vm.setObservaciones,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Productos', icon: Icons.inventory_2_outlined),
          const SizedBox(height: 10),
          if (_vm.noPidio)
            const _InfoText(
              text:
                  'Producto deshabilitado porque el pedido se marcó como no pidió.',
            )
          else ...[
            TextField(
              controller: _productSearchController,
              onChanged: (value) {
                _productSearchDebounce?.cancel();
                _productSearchDebounce = Timer(
                  const Duration(milliseconds: 320),
                  () => _vm.updateProductSearch(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Buscar producto',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _productSearchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _productSearchController.clear();
                          _vm.updateProductSearch('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            if (_vm.isLoadingProducts && _vm.products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_vm.products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No hay productos para mostrar.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _vm.products.length + (_vm.isLoadingMoreProducts ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= _vm.products.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final product = _vm.products[index];
                  return _buildProductRow(context, product);
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentLinesCard(BuildContext context) {
    final palette = context.palette;
    final lines = _vm.lineas.values.toList()
      ..sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Detalle actual', icon: Icons.list_alt_outlined),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final line = lines[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${line.cantidad.toStringAsFixed(0)} x \$${line.precioUnitario.toStringAsFixed(2)}',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${line.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: palette.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveError(BuildContext context, String message) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.dangerContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: palette.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: palette.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _vm.clearSaveError,
            icon: Icon(Icons.close, color: palette.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, Product product) {
    final palette = context.palette;
    final quantity = _vm.quantityByProduct(product.id);
    final highlighted = _recentProductId == product.id;

    return InkWell(
      onTap: () => _addProduct(product),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted ? palette.infoContainer : palette.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.codigo} • Stock ${product.stock.toStringAsFixed(0)} • \$${product.precio.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: quantity <= 0
                  ? null
                  : () => _vm.removeProduct(product.id),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 34,
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _addProduct(product),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: AnimatedScale(
          scale: _summaryPulse ? 1.03 : 1,
          duration: const Duration(milliseconds: 180),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _vm.isSaving ? null : _openConfirmationAndSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: _vm.isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Guardando...',
                          style: TextStyle(
                            color: palette.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _vm.noPidio
                                    ? 'Registrar no pidió'
                                    : 'Confirmar pedido',
                                style: TextStyle(
                                  color: palette.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_vm.lineasCount} lineas • ${_vm.cantidadTotal.toStringAsFixed(0)} unidades',
                                style: TextStyle(
                                  color: palette.onPrimary.withValues(
                                    alpha: 0.86,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${_vm.totalPedido.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: palette.onPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openConfirmationAndSave() async {
    final motivo = _vm.motivosNoPedido.firstWhere(
      (item) => item.id == _vm.selectedMotivoNoPedidoId,
      orElse: () => const OrderReasonOption(id: 0, codigo: '', nombre: ''),
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final note = await navigator.push<String>(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationView(
          clienteLabel: _vm.selectedClient?.label ?? '-',
          fecha: _vm.fecha,
          noPidio: _vm.noPidio,
          motivoNoPedido: motivo.nombre.trim().isEmpty ? null : motivo.nombre,
          total: _vm.totalPedido,
          cantidad: _vm.cantidadTotal,
          lineasCount: _vm.lineasCount,
          gps: _vm.gpsUbicacion,
          initialNote: _vm.observaciones,
        ),
      ),
    );

    if (!mounted || note == null) return;

    _vm.setObservaciones(note);
    final ok = await _vm.saveOrder();
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pedido guardado correctamente.')),
      );
      navigator.pop(true);
      return;
    }

    final message = _vm.saveErrorMessage ?? 'No se pudo guardar el pedido.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _vm.fecha,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    _vm.setFecha(picked);
  }

  Future<void> _openCreateReasonDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nuevo motivo de no pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del motivo',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Codigo (opcional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (!mounted || result != true) {
      nameController.dispose();
      codeController.dispose();
      return;
    }

    final created = await _vm.createMotivoNoPedido(
      nombre: nameController.text,
      codigo: codeController.text,
    );

    nameController.dispose();
    codeController.dispose();

    if (!mounted) return;

    if (created != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Motivo "${created.nombre}" creado.')),
      );
      return;
    }

    final message = _vm.saveErrorMessage ?? 'No se pudo crear el motivo.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _captureGps() async {
    final ok = await _vm.captureGpsFromDevice();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el GPS del dispositivo.'),
        ),
      );
    }
  }

  void _addProduct(Product product) {
    _vm.addProduct(product);
    setState(() {
      _recentProductId = product.id;
      _summaryPulse = true;
    });

    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() {
        if (_recentProductId == product.id) {
          _recentProductId = null;
        }
      });
    });

    Future.delayed(const Duration(milliseconds: 210), () {
      if (!mounted) return;
      setState(() => _summaryPulse = false);
    });
  }

  void _handleProductScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      _vm.loadProducts();
    }
  }

  void _syncControllers() {
    final gps = _vm.gpsUbicacion;
    if (_gpsController.text != gps) {
      _gpsController.text = gps;
      _gpsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _gpsController.text.length),
      );
    }

    final note = _vm.observaciones;
    if (_notaController.text != note) {
      _notaController.text = note;
      _notaController.selection = TextSelection.fromPosition(
        TextPosition(offset: _notaController.text.length),
      );
    }

    final manual = _vm.numeroManual?.toString() ?? '';
    if (_numeroManualController.text != manual) {
      _numeroManualController.text = manual;
      _numeroManualController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numeroManualController.text.length),
      );
    }

    if (_productSearchController.text != _vm.productSearch) {
      _productSearchController.text = _vm.productSearch;
      _productSearchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _productSearchController.text.length),
      );
    }
  }

  int? _safeSelected<T extends OrderLookupOption>(
    int? selected,
    List<T> items,
  ) {
    if (selected == null) return null;
    return items.any((item) => item.id == selected) ? selected : null;
  }

  Widget _buildDropdown<T extends int>({
    required String label,
    required int? value,
    required List<OrderLookupOption> items,
    required ValueChanged<int?>? onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Icon(icon, size: 20, color: palette.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: palette.textStrong,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      text,
      style: TextStyle(
        color: palette.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

BoxDecoration _cardDecoration(AppPalette palette) {
  return BoxDecoration(
    color: palette.surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: palette.shadow.withValues(alpha: 0.05),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}
