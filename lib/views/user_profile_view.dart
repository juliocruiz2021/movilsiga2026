import 'package:flutter/material.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/user_profile_viewmodel.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({
    super.key,
    required this.settings,
    required this.auth,
  });

  final SettingsViewModel settings;
  final AuthViewModel auth;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late final UserProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = UserProfileViewModel(settings: widget.settings, auth: widget.auth)
      ..initialize();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil operativo')),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_vm.errorMessage != null &&
              _vm.sucursales.isEmpty &&
              _vm.vendedores.isEmpty &&
              _vm.centrosCosto.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_vm.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _vm.initialize,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  children: [
                    _buildDropdown(
                      label: 'Sucursal',
                      value: _safeSelected(
                        _vm.selectedSucursalId,
                        _vm.sucursales,
                      ),
                      items: _vm.sucursales,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setSucursal(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Punto de venta',
                      value: _safeSelected(
                        _vm.selectedPuntoVentaId,
                        _vm.puntosVenta,
                      ),
                      items: _vm.puntosVenta,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setPuntoVenta(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Centro de costo',
                      value: _safeSelected(
                        _vm.selectedCentroCostoId,
                        _vm.centrosCosto,
                      ),
                      items: _vm.centrosCosto,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setCentroCosto(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Bodega',
                      value: _safeSelected(_vm.selectedBodegaId, _vm.bodegas),
                      items: _vm.bodegas,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setBodega(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Vendedor',
                      value: _safeSelected(
                        _vm.selectedVendedorId,
                        _vm.vendedores,
                      ),
                      items: _vm.vendedores,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setVendedor(value);
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _vm.isSaving ? null : _save,
                      icon: _vm.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _vm.isSaving ? 'Guardando...' : 'Guardar perfil',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DropdownButtonFormField<int> _buildDropdown({
    required String label,
    required int? value,
    required List<UserProfileOption> items,
    required ValueChanged<int?> onChanged,
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

  int? _safeSelected(int? selected, List<UserProfileOption> items) {
    if (selected == null) return null;
    return items.any((item) => item.id == selected) ? selected : null;
  }

  Future<void> _save() async {
    final ok = await _vm.saveProfileDefaults();
    if (!mounted) return;

    final message = ok
        ? (_vm.successMessage ?? 'Perfil guardado correctamente.')
        : (_vm.errorMessage ?? 'No se pudo guardar el perfil.');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (ok) {
      Navigator.of(context).pop(true);
    }
  }
}
