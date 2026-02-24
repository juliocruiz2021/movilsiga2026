import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/order_editor_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'order_confirmation_view.dart';
import 'order_header_view.dart';

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
  final GlobalKey _summaryBarKey = GlobalKey();
  final Map<int, GlobalKey> _productRowKeys = {};

  final TextEditingController _productSearchController =
      TextEditingController();

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
    _productSearchDebounce?.cancel();
    _scrollController
      ..removeListener(_handleProductScroll)
      ..dispose();
    _productSearchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.orderId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Pedido (editar)' : 'Pedido'),
        actions: [
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
                    _buildClientSelector(context),
                    const SizedBox(height: 12),
                    _buildProductsCard(context),
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

  Widget _buildClientSelector(BuildContext context) {
    final palette = context.palette;
    final selected = _vm.selectedClient;
    final label = selected == null
        ? 'Seleccionar cliente'
        : (selected.nombre.trim().isEmpty ? selected.label : selected.nombre);

    return InkWell(
      onTap: _openClientPicker,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_add_alt_1, color: palette.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente',
                    style: TextStyle(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textStrong,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_vm.noPidio)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.dangerContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'No pidió',
                  style: TextStyle(
                    color: palette.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            if (selected != null &&
                selected.telefonoPrincipal.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  selected.telefonoPrincipal,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Icon(Icons.expand_more, color: palette.textMuted),
          ],
        ),
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
                  'Este pedido esta marcado como No pidio desde encabezado. Si quieres agregar productos, desactiva No pidio en encabezado.',
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
    final rowKey = _productRowKeys.putIfAbsent(product.id, () => GlobalKey());

    return InkWell(
      onTap: () => _addProduct(product),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        key: rowKey,
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
            Container(
              width: 66,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: quantity > 0
                    ? palette.primary.withValues(alpha: 0.12)
                    : palette.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Pedido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: quantity > 0
                          ? palette.primary
                          : palette.textStrong,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _addProduct(product),
              icon: Icon(Icons.add_circle_outline, color: palette.primary),
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
            onTap: _vm.isSaving ? null : _openHeaderAndContinue,
            child: Container(
              key: _summaryBarKey,
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
                                'Total del pedido',
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

  Future<void> _openClientPicker() async {
    final searchController = TextEditingController();
    Timer? debounce;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.82;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.people_outline),
                        SizedBox(width: 8),
                        Text(
                          'Seleccionar cliente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: (value) {
                        debounce?.cancel();
                        debounce = Timer(
                          const Duration(milliseconds: 280),
                          () => _vm.searchClients(value),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Filtrar por codigo, nombre o telefono',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  _vm.searchClients('');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _vm,
                      builder: (context, _) {
                        if (_vm.isLoadingClients) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_vm.clientResults.isEmpty) {
                          if (searchController.text.trim().isEmpty) {
                            return const Center(
                              child: Text('Escribe para buscar clientes.'),
                            );
                          }
                          return const Center(
                            child: Text('No se encontraron clientes.'),
                          );
                        }

                        return ListView.separated(
                          itemCount: _vm.clientResults.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final client = _vm.clientResults[index];
                            final selected =
                                _vm.selectedClient?.id == client.id;
                            return ListTile(
                              title: Text(client.label),
                              subtitle: Text(
                                client.telefonoPrincipal.trim().isEmpty
                                    ? (client.nombreComercial ?? '')
                                    : client.telefonoPrincipal,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: selected
                                  ? const Icon(Icons.check_circle_outline)
                                  : null,
                              onTap: () {
                                _vm.selectClient(client);
                                Navigator.of(sheetContext).pop();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    debounce?.cancel();
    searchController.dispose();
    await _vm.searchClients('');
  }

  Future<void> _openHeaderAndContinue() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_vm.selectedClient == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente para continuar.')),
      );
      return;
    }

    if (!_vm.noPidio && _vm.lineas.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Agrega productos al pedido.')),
      );
      return;
    }

    final continueFlow = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => OrderHeaderView(vm: _vm)));
    if (!mounted || continueFlow != true) return;

    await _openConfirmationAndSave();
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

  void _addProduct(Product product) {
    _vm.addProduct(product);
    unawaited(_animateProductToSummary(product.id));
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

  Future<void> _animateProductToSummary(int productId) async {
    final sourceContext = _productRowKeys[productId]?.currentContext;
    final targetContext = _summaryBarKey.currentContext;
    if (sourceContext == null || targetContext == null || !mounted) return;

    final sourceBox = sourceContext.findRenderObject() as RenderBox?;
    final targetBox = targetContext.findRenderObject() as RenderBox?;
    if (sourceBox == null || targetBox == null) return;

    final overlay = Overlay.of(context);
    final start = sourceBox.localToGlobal(sourceBox.size.center(Offset.zero));
    final end = targetBox.localToGlobal(targetBox.size.center(Offset.zero));

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 420),
    );
    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    final move = Tween<Offset>(begin: start, end: end).animate(curved);
    final scale = Tween<double>(begin: 1, end: 0.25).animate(curved);
    final fade = Tween<double>(begin: 0.95, end: 0.2).animate(curved);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, child) {
            final pos = move.value;
            return Positioned(
              left: pos.dx - 14,
              top: pos.dy - 14,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: scale.value,
                  child: Opacity(
                    opacity: fade.value,
                    child: _FlyingDot(color: context.palette.primary),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();
  }

  void _handleProductScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      _vm.loadProducts();
    }
  }

  void _syncControllers() {
    if (_productSearchController.text != _vm.productSearch) {
      _productSearchController.text = _vm.productSearch;
      _productSearchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _productSearchController.text.length),
      );
    }
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

class _FlyingDot extends StatelessWidget {
  const _FlyingDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 18),
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
