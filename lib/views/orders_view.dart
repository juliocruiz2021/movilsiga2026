import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_summary.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'order_form_view.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 180) {
          context.read<OrdersViewModel>().loadMore();
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final authRole = context.select<AuthViewModel, String>(
      (auth) => auth.role.trim(),
    );
    final hasSession = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasToken ||
          auth.userId.trim().isNotEmpty ||
          auth.userEmail.trim().isNotEmpty,
    );
    final isOffline = context.select<OrdersViewModel, bool>(
      (vm) => vm.isOffline,
    );
    final canViewOrders = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('ventas.view') ||
          auth.hasPermission('pedidos.view'),
    );
    final canCreateOrders = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('ventas.create') ||
          auth.hasPermission('pedidos.create'),
    );
    final canUpdateOrders = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('ventas.update') ||
          auth.hasPermission('pedidos.update'),
    );
    final allowOfflineViewFallback =
        isOffline && authRole.isEmpty && hasSession;
    final canRenderOrders = canViewOrders || allowOfflineViewFallback;

    if (!canRenderOrders) {
      return Center(
        child: Text(
          'No tienes permiso para ver pedidos.',
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        ),
      );
    }

    return Consumer<OrdersViewModel>(
      builder: (context, vm, _) {
        if (_searchController.text != vm.searchQuery) {
          _searchController.text = vm.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }

        return Column(
          children: [
            _OrdersToolbar(
              searchController: _searchController,
              dateFilterMode: vm.dateFilterMode,
              fromDate: vm.fromDate,
              toDate: vm.toDate,
              showCreateButton: canCreateOrders,
              onSearch: vm.updateSearch,
              onCreate: () => _openCreateOrder(context),
              onRefresh: vm.refresh,
              onModeChanged: vm.updateDateFilterMode,
              onPickExactDate: () => _pickExactDate(context, vm),
              onPickFromDate: () => _pickFromDate(context, vm),
              onPickToDate: () => _pickToDate(context, vm),
              onSetToday: vm.setToday,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildBody(context, vm, canUpdateOrders: canUpdateOrders),
            ),
            const SizedBox(height: 8),
            _OrdersCounter(count: vm.orders.length),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrdersViewModel vm, {
    required bool canUpdateOrders,
  }) {
    if (vm.isLoading && vm.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: vm.loadInitial,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (vm.orders.isEmpty) {
      return const Center(child: Text('No hay pedidos para mostrar.'));
    }

    final itemCount = vm.orders.length + (vm.isLoadingMore ? 1 : 0);
    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        padding: const EdgeInsets.only(bottom: 4),
        itemBuilder: (context, index) {
          if (index >= vm.orders.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final order = vm.orders[index];
          return _OrderListRow(
            order: order,
            onOpenDetail: canUpdateOrders
                ? () => _openEditOrder(context, order)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _pickExactDate(BuildContext context, OrdersViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.fromDate,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    vm.updateExactDate(picked);
  }

  Future<void> _pickFromDate(BuildContext context, OrdersViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.fromDate,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    vm.updateFromDate(picked);
  }

  Future<void> _pickToDate(BuildContext context, OrdersViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.toDate,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    vm.updateToDate(picked);
  }

  Future<void> _openCreateOrder(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OrderFormView(
          settings: context.read<SettingsViewModel>(),
          auth: context.read<AuthViewModel>(),
        ),
      ),
    );

    if (!context.mounted || created != true) return;
    await context.read<OrdersViewModel>().refresh();
  }

  Future<void> _openEditOrder(BuildContext context, OrderSummary order) async {
    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OrderFormView(
          settings: context.read<SettingsViewModel>(),
          auth: context.read<AuthViewModel>(),
          orderId: order.id,
        ),
      ),
    );

    if (!context.mounted || edited != true) return;
    await context.read<OrdersViewModel>().refresh();
  }
}

class _OrdersToolbar extends StatelessWidget {
  const _OrdersToolbar({
    required this.searchController,
    required this.dateFilterMode,
    required this.fromDate,
    required this.toDate,
    required this.showCreateButton,
    required this.onSearch,
    required this.onCreate,
    required this.onRefresh,
    required this.onModeChanged,
    required this.onPickExactDate,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onSetToday,
  });

  final TextEditingController searchController;
  final OrderDateFilterMode dateFilterMode;
  final DateTime fromDate;
  final DateTime toDate;
  final bool showCreateButton;
  final ValueChanged<String> onSearch;
  final VoidCallback onCreate;
  final Future<void> Function() onRefresh;
  final ValueChanged<OrderDateFilterMode> onModeChanged;
  final VoidCallback onPickExactDate;
  final VoidCallback onPickFromDate;
  final VoidCallback onPickToDate;
  final VoidCallback onSetToday;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isToday =
        _isSameDate(fromDate, DateTime.now()) &&
        _isSameDate(toDate, DateTime.now());
    final isExactMode = dateFilterMode == OrderDateFilterMode.exactDay;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Buscar pedido o cliente',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController.clear();
                            onSearch('');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: palette.surface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRefresh,
              tooltip: 'Refrescar',
              icon: const Icon(Icons.refresh),
            ),
            if (showCreateButton)
              IconButton(
                onPressed: onCreate,
                tooltip: 'Nuevo pedido',
                icon: const Icon(Icons.add_circle_outline),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Misma fecha'),
                selected: isExactMode,
                onSelected: (_) => onModeChanged(OrderDateFilterMode.exactDay),
                selectedColor: palette.primary,
                labelStyle: TextStyle(
                  color: isExactMode ? palette.onPrimary : palette.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Rango'),
                selected: !isExactMode,
                onSelected: (_) => onModeChanged(OrderDateFilterMode.range),
                selectedColor: palette.primary,
                labelStyle: TextStyle(
                  color: !isExactMode ? palette.onPrimary : palette.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isExactMode)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickExactDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text('Fecha: ${_formatDateForUi(fromDate)}'),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFromDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text('Desde: ${_formatDateForUi(fromDate)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickToDate,
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text('Hasta: ${_formatDateForUi(toDate)}'),
                ),
              ),
            ],
          ),
        if (!isToday) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Spacer(),
              TextButton(onPressed: onSetToday, child: const Text('Hoy')),
            ],
          ),
        ],
      ],
    );
  }
}

class _OrderListRow extends StatelessWidget {
  const _OrderListRow({required this.order, this.onOpenDetail});

  final OrderSummary order;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final title = order.socioNombre.trim().isNotEmpty
        ? order.socioNombre.trim()
        : 'Cliente sin nombre';
    final secondary = <String>[
      if (order.socioCodigo.trim().isNotEmpty) order.socioCodigo.trim(),
      if (order.bestPhone.trim().isNotEmpty) order.bestPhone.trim(),
    ];
    final orderDate = order.fecha == null
        ? '-'
        : _formatDateForUi(order.fecha!);

    final rowContent = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ((theme.textTheme.bodySmall?.fontSize ?? 12) - 1)
                        .clamp(8.0, 18.0)
                        .toDouble(),
                    fontWeight: FontWeight.w600,
                    color: palette.textStrong,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  secondary.isEmpty ? '-' : secondary.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pedido ${order.documentNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                if (order.noPidio) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.motivoNoPedidoNombre?.trim().isNotEmpty == true
                        ? 'No pidio: ${order.motivoNoPedidoNombre}'
                        : 'No pidio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                orderDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.estado.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (onOpenDetail != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: palette.textMuted),
          ],
        ],
      ),
    );

    if (onOpenDetail == null) return rowContent;
    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(14),
      child: rowContent,
    );
  }
}

class _OrdersCounter extends StatelessWidget {
  const _OrdersCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '$count pedidos mostrados',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: palette.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDateForUi(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}
