import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../theme/app_theme.dart';
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
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 180) {
          context.read<ClientsViewModel>().loadMore();
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Clientes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textStrong,
                    ),
                  ),
                ),
                if (canCreateClients)
                  ElevatedButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () => _openCreateClient(context),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Nuevo'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: vm.updateSearch,
              decoration: InputDecoration(
                hintText: 'Buscar cliente por codigo, nombre, NIT o correo',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          vm.updateSearch('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(context, vm)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ClientsViewModel vm) {
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
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= vm.clients.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _ClientCard(client: vm.clients[index]);
        },
      ),
    );
  }

  Future<void> _openCreateClient(BuildContext context) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ClientFormView()));

    if (!context.mounted || created != true) return;
    await context.read<ClientsViewModel>().refresh();
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  client.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.textStrong,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                client.codigo,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'NIT', value: client.nit ?? '-'),
          _InfoLine(
            label: 'Contacto',
            value: client.primaryContact.isEmpty ? '-' : client.primaryContact,
          ),
          _InfoLine(label: 'Direccion', value: client.direccion ?? '-'),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(color: palette.textMuted),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
