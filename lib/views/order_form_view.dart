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

class _OrderFormViewState extends State<OrderFormView>
    with TickerProviderStateMixin {
  static const List<int> _qtyMultiplierOptions = [1, 2, 3, 5, 10];

  late final OrderEditorViewModel _vm;
  late final ScrollController _scrollController;
  final GlobalKey _summaryBarKey = GlobalKey();
  final Map<int, GlobalKey> _productRowKeys = {};

  final TextEditingController _productSearchController =
      TextEditingController();

  Timer? _productSearchDebounce;

  bool _isGrid = true;
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
    return Scaffold(
      appBar: _buildAppBar(context),
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
              _buildControlsBar(context),
              _buildCategoryTabs(context),
              Expanded(
                child: _isGrid
                    ? _buildProductsGrid(context)
                    : _buildProductsList(context),
              ),
              if (_vm.saveErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: _buildSaveError(context, _vm.saveErrorMessage!),
                ),
              _buildSummaryBar(context),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final palette = context.palette;
    final client = _vm.selectedClient;
    final clientText = client == null
        ? 'Cliente'
        : (client.nombre.trim().isEmpty ? client.label : client.nombre.trim());

    return AppBar(
      title: const Text('Pedido'),
      actions: [
        InkWell(
          onTap: _openClientPicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: palette.textMuted.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Text(
                  client == null ? '+ Cliente' : _clipText(clientText, 8),
                  style: TextStyle(
                    color: palette.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  client == null
                      ? Icons.person_add_alt_1
                      : Icons.person_outline,
                  size: 16,
                  color: palette.textStrong,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsBar(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.surfaceSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _productSearchController,
              onChanged: (value) {
                _productSearchDebounce?.cancel();
                _productSearchDebounce = Timer(
                  const Duration(milliseconds: 300),
                  () => _vm.updateProductSearch(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Buscar',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: palette.surfaceSoft,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _isGrid = true),
            icon: Icon(
              Icons.grid_view,
              color: _isGrid ? palette.primary : palette.textMuted,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isGrid = false),
            icon: Icon(
              Icons.view_list,
              color: !_isGrid ? palette.primary : palette.textMuted,
            ),
          ),
          PopupMenuButton<int>(
            tooltip: 'Multiplicador',
            onSelected: _vm.setTapMultiplier,
            itemBuilder: (context) => _qtyMultiplierOptions
                .map(
                  (value) => PopupMenuItem<int>(
                    value: value,
                    child: Text(
                      '${value}X',
                      style: TextStyle(
                        fontWeight: value == _vm.tapMultiplier
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: palette.textMuted.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${_vm.tapMultiplier}X',
                style: TextStyle(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    final palette = context.palette;
    final allTabs = <_CategoryTabData>[
      const _CategoryTabData(id: null, label: 'TODOS'),
      ..._vm.productCategories.map(
        (c) => _CategoryTabData(id: c.id, label: c.nombre.toUpperCase()),
      ),
    ];

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.surfaceSoft)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final tab = allTabs[index];
          final selected = tab.id == _vm.selectedProductCategoryId;
          return InkWell(
            onTap: () => _vm.setProductCategory(tab.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? palette.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  color: selected ? palette.primary : palette.textMuted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    if (_vm.isLoadingProducts && _vm.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vm.products.isEmpty) {
      return const Center(child: Text('No hay productos para mostrar.'));
    }

    final itemCount = _vm.products.length + (_vm.isLoadingMoreProducts ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.72,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= _vm.products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final product = _vm.products[index];
        return _buildProductGridTile(context, product);
      },
    );
  }

  Widget _buildProductsList(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    if (_vm.isLoadingProducts && _vm.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vm.products.isEmpty) {
      return const Center(child: Text('No hay productos para mostrar.'));
    }

    final itemCount = _vm.products.length + (_vm.isLoadingMoreProducts ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= _vm.products.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = _vm.products[index];
        final quantity = _vm.quantityByProduct(product.id);
        final rowKey = _productRowKeys.putIfAbsent(
          product.id,
          () => GlobalKey(),
        );

        return ListTile(
          key: rowKey,
          onTap: () => _addProduct(product),
          leading: SizedBox(
            width: 44,
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildProductImage(product),
            ),
          ),
          title: Text(
            product.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            product.codigo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textMuted,
            ),
          ),
          trailing: SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${product.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: palette.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (quantity > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$quantity',
                      style: TextStyle(
                        color: palette.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGridTile(BuildContext context, Product product) {
    final palette = context.palette;
    final quantity = _vm.quantityByProduct(product.id);
    final highlighted = _recentProductId == product.id;
    final rowKey = _productRowKeys.putIfAbsent(product.id, () => GlobalKey());

    return InkWell(
      key: rowKey,
      onTap: () => _addProduct(product),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(6),
          border: highlighted
              ? Border.all(
                  color: palette.primary.withValues(alpha: 0.7),
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildProductImage(product),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF3F4B61),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${product.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (quantity > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      color: palette.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    final palette = context.palette;
    final imageUrl = _vm.resolveImageUrl(
      product.fotoThumbUrl ?? product.fotoUrlWeb ?? product.fotoUrl,
    );

    if (imageUrl.isEmpty) {
      return Container(
        color: palette.surfaceSoft,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: palette.textMuted,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) {
        return Container(
          color: palette.surfaceSoft,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: palette.textMuted,
          ),
        );
      },
    );
  }

  Widget _buildSaveError(BuildContext context, String message) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.dangerContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: palette.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: palette.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    final palette = context.palette;
    final hasItems = _vm.lineasCount > 0 || _vm.noPidio;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        child: AnimatedScale(
          scale: _summaryPulse ? 1.03 : 1,
          duration: const Duration(milliseconds: 170),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: hasItems && !_vm.isSaving ? _openHeaderAndContinue : null,
            child: Container(
              key: _summaryBarKey,
              height: 48,
              decoration: BoxDecoration(
                color: hasItems ? palette.primary : palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.primary),
              ),
              child: _vm.isSaving
                  ? Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasItems
                                ? '${_vm.cantidadTotal.toStringAsFixed(0)} ítems = \$${_vm.totalPedido.toStringAsFixed(2)}'
                                : 'Ningún ítem',
                            style: TextStyle(
                              color: hasItems
                                  ? palette.onPrimary
                                  : palette.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 30 / 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (hasItems)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.chevron_right,
                              color: palette.onPrimary,
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
    final selected = await Navigator.of(context).push<OrderClientOption>(
      MaterialPageRoute(builder: (_) => _OrderClientPickerView(vm: _vm)),
    );
    if (!mounted || selected == null) return;
    _vm.selectClient(selected);
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
    final usedMultiplier = _vm.tapMultiplier;
    _vm.addProduct(product, quantity: usedMultiplier);
    if (usedMultiplier != 1) {
      _vm.setTapMultiplier(1);
    }
    unawaited(_animateProductToSummary(product.id));
    setState(() {
      _recentProductId = product.id;
      _summaryPulse = true;
    });

    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        if (_recentProductId == product.id) {
          _recentProductId = null;
        }
      });
    });

    Future.delayed(const Duration(milliseconds: 180), () {
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
      vsync: this,
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
        _scrollController.position.maxScrollExtent - 260) {
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

class _OrderClientPickerView extends StatefulWidget {
  const _OrderClientPickerView({required this.vm});

  final OrderEditorViewModel vm;

  @override
  State<_OrderClientPickerView> createState() => _OrderClientPickerViewState();
}

class _OrderClientPickerViewState extends State<_OrderClientPickerView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  OrderEditorViewModel get _vm => widget.vm;

  @override
  void initState() {
    super.initState();
    unawaited(_vm.searchClients(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar cliente')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 280),
                  () => _vm.searchClients(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Busque por nombre, email o teléfono',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _vm.searchClients('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _vm,
              builder: (context, _) {
                if (_vm.isLoadingClients) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_vm.clientResults.isEmpty) {
                  return const Center(
                    child: Text('No hay clientes para mostrar.'),
                  );
                }

                return ListView.separated(
                  itemCount: _vm.clientResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final client = _vm.clientResults[index];
                    final selected = _vm.selectedClient?.id == client.id;
                    return ListTile(
                      title: Text(
                        client.nombre.trim().isEmpty
                            ? client.label
                            : client.nombre.trim(),
                      ),
                      subtitle: client.telefonoPrincipal.trim().isEmpty
                          ? null
                          : Text(client.telefonoPrincipal),
                      trailing: selected
                          ? const Icon(Icons.chevron_right)
                          : null,
                      onTap: () => Navigator.of(context).pop(client),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

class _CategoryTabData {
  const _CategoryTabData({required this.id, required this.label});

  final int? id;
  final String label;
}

String _clipText(String text, int maxLen) {
  final clean = text.trim();
  if (clean.length <= maxLen) return clean;
  return '${clean.substring(0, maxLen)}...';
}
