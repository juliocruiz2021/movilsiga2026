import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/connectivity_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import 'clients_view.dart';
import 'login_view.dart';
import 'products_view.dart';
import 'settings_view.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/main_navigation_drawer.dart';
import 'widgets/offline_cloud_icon.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.initialIndex = MainMenuIndex.home});

  final int initialIndex;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final titles = <String>[
      'Bienvenida',
      'Clientes',
      'Proveedores',
      'Pedidos',
      'Productos',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[widget.initialIndex]),
        actions: const [OfflineCloudIcon()],
      ),
      drawer: MainNavigationDrawer(
        selectedIndex: widget.initialIndex,
        onDestinationSelected: _onDestinationSelected,
        onOpenSettings: _openSettings,
        onLogout: _logout,
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSection(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    switch (widget.initialIndex) {
      case 0:
        return const _WelcomeSection();
      case 1:
        return const ClientsView();
      case 2:
        return const _ModulePlaceholder(
          title: 'Proveedores',
          description:
              'Aqui se mostrara el control de proveedores (socios proveedor) con CRUD y sincronizacion offline.',
        );
      case 3:
        return const _ModulePlaceholder(
          title: 'Pedidos',
          description:
              'Aqui se construira el levantamiento de pedidos en ruta usando tipo_registro=PED.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onDestinationSelected(int index) {
    if (index == widget.initialIndex) return;
    if (index == MainMenuIndex.products) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProductsView(
            homeBuilder: (targetIndex) => HomeView(initialIndex: targetIndex),
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeView(initialIndex: index)),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsView()));
  }

  Future<void> _logout() async {
    final productsVm = context.read<ProductsViewModel>();
    productsVm.resetFilters(reload: false);
    productsVm.resetSession();
    await context.read<AuthViewModel>().clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final isOffline = context.select<ConnectivityViewModel, bool>(
      (vm) => vm.isOffline,
    );
    final name = auth.userName.trim().isNotEmpty
        ? auth.userName.trim()
        : (auth.userEmail.trim().isNotEmpty
              ? auth.userEmail.trim()
              : 'Usuario');
    final role = auth.role.trim().isNotEmpty ? auth.role.trim() : 'sin rol';
    final loginAt = auth.loginAt;

    return ListView(
      children: [
        Text(
          'Bienvenido, $name',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Rol', value: role),
                _InfoRow(label: 'Email', value: auth.userEmail),
                _InfoRow(
                  label: 'Sesion activa',
                  value: auth.hasToken ? 'Si' : 'No',
                ),
                _InfoRow(
                  label: 'Conectividad',
                  value: isOffline ? 'Offline' : 'Online',
                ),
                _InfoRow(
                  label: 'Inicio de sesion',
                  value: loginAt == null
                      ? 'No disponible'
                      : loginAt.toLocal().toString().split('.').first,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _ModulePlaceholder(
          title: 'Siguiente paso',
          description:
              'Esta pantalla se reemplazara por dashboard con indicadores de clientes, pedidos, ventas y rutas.',
        ),
      ],
    );
  }
}

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(safeValue)),
        ],
      ),
    );
  }
}
