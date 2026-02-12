import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/client.dart';
import '../theme/app_theme.dart';
import '../utils/debug_tools.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/clients_viewmodel.dart';
import 'client_form_view.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugTrace('CLIENTS_UI', 'ClientsView init');
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 180) {
          debugTrace('CLIENTS_UI', 'Scroll near end -> loadMore');
          context.read<ClientsViewModel>().loadMore();
        }
      });
  }

  @override
  void dispose() {
    debugTrace('CLIENTS_UI', 'ClientsView dispose');
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final canViewClients = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.view') ||
          auth.hasPermission('clientes.view'),
    );
    final canCreateClients = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.create') ||
          auth.hasPermission('clientes.create'),
    );
    final canUpdateClients = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.update') ||
          auth.hasPermission('clientes.update'),
    );
    final canDeleteClients = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.delete') ||
          auth.hasPermission('clientes.delete'),
    );

    if (!canViewClients) {
      return Center(
        child: Text(
          'No tienes permiso para ver clientes.',
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        ),
      );
    }

    return Consumer<ClientsViewModel>(
      builder: (context, vm, _) {
        if (_searchController.text != vm.searchQuery) {
          _searchController.text = vm.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }

        return Column(
          children: [
            _ClientsToolbar(
              searchController: _searchController,
              canCreateClients: canCreateClients,
              onSearch: vm.updateSearch,
              onCreate: () => _openCreateClient(context),
              onRefresh: vm.refresh,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildBody(
                context,
                vm,
                canUpdateClients: canUpdateClients,
                canDeleteClients: canDeleteClients,
              ),
            ),
            const SizedBox(height: 8),
            _ListCounter(count: vm.clients.length),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ClientsViewModel vm, {
    required bool canUpdateClients,
    required bool canDeleteClients,
  }) {
    if (vm.isLoading && vm.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.clients.isEmpty) {
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

    if (vm.clients.isEmpty) {
      return const Center(child: Text('No hay clientes para mostrar.'));
    }

    final itemCount = vm.clients.length + (vm.isLoadingMore ? 1 : 0);
    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 4),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= vm.clients.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final client = vm.clients[index];
          return _ClientListRow(
            client: client,
            canDelete: canDeleteClients,
            onOpenDetail: canUpdateClients
                ? () => _openEditClient(context, client)
                : () => _openClientReadOnly(context, client),
            onDelete: canDeleteClients
                ? () => _confirmDeleteClient(context, client)
                : null,
            onCall: () => _callClient(client),
            onWhatsApp: () => _openWhatsApp(client),
            onOpenMap: () => _openRouteInMap(client),
          );
        },
      ),
    );
  }

  Future<void> _openCreateClient(BuildContext context) async {
    debugTrace('CLIENTS_UI', 'Open create client form');
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ClientFormView()));

    if (!context.mounted || created != true) return;
    await context.read<ClientsViewModel>().refresh();
  }

  Future<void> _openEditClient(BuildContext context, Client client) async {
    debugTrace('CLIENTS_UI', 'Open edit client id=${client.id}');
    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClientFormView(client: client)),
    );

    if (!context.mounted || edited != true) return;
    await context.read<ClientsViewModel>().refresh();
  }

  Future<void> _openClientReadOnly(BuildContext context, Client client) async {
    debugTrace('CLIENTS_UI', 'Open read-only client id=${client.id}');
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ClientFormView(client: client)),
    );
  }

  Future<void> _callClient(Client client) async {
    final phone = _dialPhone(client);
    if (phone == null) return;

    final uri = Uri(scheme: 'tel', path: phone);
    debugTrace('CLIENTS_UI', 'Dialing client id=${client.id} phone=$phone');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp(Client client) async {
    final phone = _whatsAppPhone(client);
    if (phone == null) return;

    final appUri = Uri.parse('whatsapp://send?phone=$phone');
    if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    final webUri = Uri.parse('https://wa.me/$phone');
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openRouteInMap(Client client) async {
    final gps = client.gpsUbicacion?.trim();
    if (gps == null || gps.isEmpty) return;

    final query = Uri.encodeComponent(gps);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    debugTrace('CLIENTS_UI', 'Open map for client id=${client.id} gps=$gps');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDeleteClient(BuildContext context, Client client) async {
    final accept = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cliente'),
          content: Text('Se eliminara el cliente "${client.nombre}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || accept != true) return;

    debugTrace('CLIENTS_UI', 'Deleting client id=${client.id}');
    final vm = context.read<ClientsViewModel>();
    final ok = await vm.deleteClient(client.id);
    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente "${client.nombre}" eliminado.')),
      );
      return;
    }

    final message = vm.saveErrorMessage ?? 'No se pudo eliminar el cliente.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _dialPhone(Client client) {
    final phone = _bestPhoneRaw(client);
    if (phone == null) return null;

    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.isEmpty ? null : cleaned;
  }

  String? _whatsAppPhone(Client client) {
    final phone = _bestPhoneRaw(client);
    if (phone == null) return null;

    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length == 8) {
      digits = '503$digits';
    }
    return digits;
  }

  String? _bestPhoneRaw(Client client) {
    final celular = client.celular?.trim();
    if (celular != null && celular.isNotEmpty) return celular;
    final telefono = client.telefono?.trim();
    if (telefono != null && telefono.isNotEmpty) return telefono;
    return null;
  }
}

class _ClientsToolbar extends StatefulWidget {
  const _ClientsToolbar({
    required this.searchController,
    required this.canCreateClients,
    required this.onSearch,
    required this.onCreate,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final bool canCreateClients;
  final ValueChanged<String> onSearch;
  final VoidCallback onCreate;
  final Future<void> Function() onRefresh;

  @override
  State<_ClientsToolbar> createState() => _ClientsToolbarState();
}

class _ClientsToolbarState extends State<_ClientsToolbar> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.searchController,
            onChanged: (value) {
              setState(() {});
              widget.onSearch(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar cliente',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        widget.searchController.clear();
                        setState(() {});
                        widget.onSearch('');
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
          onPressed: widget.onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
        ),
        if (widget.canCreateClients)
          IconButton(
            onPressed: widget.onCreate,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nuevo cliente',
          ),
      ],
    );
  }
}

class _ClientListRow extends StatelessWidget {
  const _ClientListRow({
    required this.client,
    required this.onOpenDetail,
    required this.onCall,
    required this.onWhatsApp,
    required this.onOpenMap,
    required this.canDelete,
    this.onDelete,
  });

  final Client client;
  final VoidCallback onOpenDetail;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onOpenMap;
  final bool canDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final subtitle = (client.nombreComercial ?? '').trim().isNotEmpty
        ? client.nombreComercial!.trim()
        : client.codigo;
    final phone = _phoneLabel(client);
    final hasPhone = phone != '-';
    final hasGps = (client.gpsUbicacion ?? '').trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onOpenDetail,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hasPhone
                              ? palette.textStrong
                              : palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _IconAction(
                      icon: Icons.phone_outlined,
                      color: palette.primary,
                      onTap: hasPhone ? onCall : null,
                      tooltip: 'Llamar',
                    ),
                    _IconAction(
                      icon: Icons.chat_outlined,
                      color: const Color(0xFF22C55E),
                      onTap: hasPhone ? onWhatsApp : null,
                      tooltip: 'WhatsApp',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _ActionLink(
                  icon: Icons.route_outlined,
                  label: client.routeLabel,
                  onTap: hasGps ? onOpenMap : null,
                ),
              ],
            ),
          ),
          if (canDelete)
            PopupMenuButton<_ClientMenuAction>(
              tooltip: 'Opciones',
              onSelected: (action) {
                switch (action) {
                  case _ClientMenuAction.open:
                    onOpenDetail();
                    break;
                  case _ClientMenuAction.delete:
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ClientMenuAction.open,
                  child: Text('Abrir ficha'),
                ),
                PopupMenuItem(
                  value: _ClientMenuAction.delete,
                  child: Text('Eliminar'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _phoneLabel(Client client) {
    final celular = client.celular?.trim();
    if (celular != null && celular.isNotEmpty) return celular;
    final telefono = client.telefono?.trim();
    if (telefono != null && telefono.isNotEmpty) return telefono;
    return '-';
  }
}

enum _ClientMenuAction { open, delete }

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      splashRadius: 18,
      tooltip: tooltip,
      icon: Icon(
        icon,
        color: onTap == null ? color.withValues(alpha: 0.35) : color,
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final enabled = onTap != null;
    final color = enabled ? palette.primary : palette.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCounter extends StatelessWidget {
  const _ListCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count items mostrados',
        style: theme.textTheme.bodySmall?.copyWith(
          color: palette.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
