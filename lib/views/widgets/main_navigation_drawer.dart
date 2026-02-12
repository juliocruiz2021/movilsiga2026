import 'package:flutter/material.dart';

import '../../utils/debug_tools.dart';

class MainMenuIndex {
  const MainMenuIndex._();

  static const home = 0;
  static const clients = 1;
  static const suppliers = 2;
  static const orders = 3;
  static const products = 4;
}

class MainNavigationDrawer extends StatelessWidget {
  const MainNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        debugTrace('DRAWER', 'Destination selected index=$index');
        onDestinationSelected(index);
      },
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Menu principal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Clientes'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: Text('Proveedores'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: Text('Pedidos'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Productos'),
        ),
        const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuracion'),
            onTap: () {
              debugTrace('DRAWER', 'Settings tapped');
              onOpenSettings();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesion'),
            onTap: () {
              debugTrace('DRAWER', 'Logout tapped');
              onLogout();
            },
          ),
        ),
      ],
    );
  }
}
