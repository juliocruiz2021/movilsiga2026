import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/client_branch.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/client_branches_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'client_branch_form_view.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/offline_cloud_icon.dart';

class ClientBranchesView extends StatelessWidget {
  const ClientBranchesView({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientBranchesViewModel>(
      create: (_) => ClientBranchesViewModel(
        settings: context.read<SettingsViewModel>(),
        auth: context.read<AuthViewModel>(),
        client: client,
      ),
      child: _ClientBranchesScreen(client: client),
    );
  }
}

class _ClientBranchesScreen extends StatefulWidget {
  const _ClientBranchesScreen({required this.client});

  final Client client;

  @override
  State<_ClientBranchesScreen> createState() => _ClientBranchesScreenState();
}

class _ClientBranchesScreenState extends State<_ClientBranchesScreen> {
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 180) {
          context.read<ClientBranchesViewModel>().loadMore();
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
    final canCreate = context.select<AuthViewModel, bool>(
      (auth) => auth.hasPermission('socios.create'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Sucursales · ${widget.client.nombre}'),
        actions: [
          const OfflineCloudIcon(),
          if (canCreate)
            IconButton(
              onPressed: () => _openBranchForm(context),
              icon: const Icon(Icons.add_business_outlined),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<ClientBranchesViewModel>(
              builder: (context, vm, _) {
                if (_searchController.text != vm.searchQuery) {
                  _searchController.text = vm.searchQuery;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.client.nombre,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: palette.textStrong,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Codigo: ${widget.client.codigo} · NIT: ${widget.client.nit ?? '-'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: vm.updateSearch,
                      decoration: InputDecoration(
                        hintText:
                            'Buscar sucursal por codigo, nombre o contacto',
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
                    Expanded(child: _buildBody(vm)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ClientBranchesViewModel vm) {
    if (vm.isLoading && vm.branches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.branches.isEmpty) {
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

    if (vm.branches.isEmpty) {
      return const Center(child: Text('No hay sucursales registradas.'));
    }

    final itemCount = vm.branches.length + (vm.isLoadingMore ? 1 : 0);
    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= vm.branches.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _BranchCard(
            branch: vm.branches[index],
            onEdit: () => _openBranchForm(context, branch: vm.branches[index]),
            onDelete: () => _confirmDelete(context, vm.branches[index]),
          );
        },
      ),
    );
  }

  Future<void> _openBranchForm(
    BuildContext context, {
    ClientBranch? branch,
  }) async {
    final vm = context.read<ClientBranchesViewModel>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ClientBranchFormView(client: widget.client, branch: branch),
        ),
      ),
    );
    if (!context.mounted || saved != true) return;
    await vm.refresh();
  }

  Future<void> _confirmDelete(BuildContext context, ClientBranch branch) async {
    final canDelete = context.read<AuthViewModel>().hasPermission(
      'socios.delete',
    );
    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permiso para eliminar.')),
      );
      return;
    }

    final accept = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar sucursal'),
          content: Text('Se eliminara la sucursal "${branch.nombre}".'),
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
    final vm = context.read<ClientBranchesViewModel>();
    final ok = await vm.deleteBranch(branch.id);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sucursal "${branch.nombre}" eliminada.')),
      );
      return;
    }
    final message = vm.saveErrorMessage ?? 'No se pudo eliminar la sucursal.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  });

  final ClientBranch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final canUpdate = context.select<AuthViewModel, bool>(
      (auth) => auth.hasPermission('socios.update'),
    );
    final canDelete = context.select<AuthViewModel, bool>(
      (auth) => auth.hasPermission('socios.delete'),
    );

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
            children: [
              Expanded(
                child: Text(
                  branch.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.textStrong,
                  ),
                ),
              ),
              if (canUpdate)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                ),
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: palette.danger),
                  tooltip: 'Eliminar',
                ),
            ],
          ),
          _InfoLine(label: 'Codigo', value: branch.codigo ?? '-'),
          _InfoLine(label: 'Ruta', value: branch.rutaNombre ?? '-'),
          _InfoLine(
            label: 'Contacto',
            value: branch.primaryContact.isEmpty ? '-' : branch.primaryContact,
          ),
          _InfoLine(label: 'Direccion', value: branch.direccion ?? '-'),
          _InfoLine(label: 'GPS', value: branch.gpsUbicacion ?? '-'),
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
