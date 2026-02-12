import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/client_branch.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/client_branches_viewmodel.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/offline_cloud_icon.dart';

class ClientBranchFormView extends StatefulWidget {
  const ClientBranchFormView({super.key, required this.client, this.branch});

  final Client client;
  final ClientBranch? branch;

  @override
  State<ClientBranchFormView> createState() => _ClientBranchFormViewState();
}

class _ClientBranchFormViewState extends State<ClientBranchFormView> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _rutaIdController = TextEditingController();
  final _gpsController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  bool get _isEdit => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    if (branch == null) return;
    _codigoController.text = branch.codigo ?? '';
    _nombreController.text = branch.nombre;
    _direccionController.text = branch.direccion ?? '';
    _rutaIdController.text = branch.rutaId?.toString() ?? '';
    _gpsController.text = branch.gpsUbicacion ?? '';
    _telefonoController.text = branch.telefono ?? '';
    _correoController.text = branch.correo ?? '';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _rutaIdController.dispose();
    _gpsController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final canWrite = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.create') ||
          auth.hasPermission('socios.update'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar sucursal' : 'Nueva sucursal'),
        actions: const [OfflineCloudIcon()],
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Consumer<ClientBranchesViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!canWrite)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.dangerContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No tienes permiso para guardar sucursales.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (!canWrite) const SizedBox(height: 12),
                    Text(
                      'Cliente: ${widget.client.nombre}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textStrong,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _codigoController,
                      label: 'Codigo sucursal',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre sucursal',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre de la sucursal';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _direccionController,
                      label: 'Direccion',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _rutaIdController,
                      label: 'Ruta ID',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _gpsController,
                      label: 'GPS (lat,lng)',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _telefonoController,
                      label: 'Telefono',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _correoController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (vm.saveErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: palette.dangerContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vm.saveErrorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: (!canWrite || vm.isSaving)
                            ? null
                            : () => _save(context),
                        icon: vm.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          vm.isSaving
                              ? 'Guardando...'
                              : (_isEdit ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ClientBranchesViewModel>();
    final branch = widget.branch;
    final result = branch == null
        ? await vm.createBranch(
            nombre: _nombreController.text,
            codigo: _codigoController.text,
            direccion: _direccionController.text,
            rutaId: int.tryParse(_rutaIdController.text.trim()),
            gpsUbicacion: _gpsController.text,
            telefono: _telefonoController.text,
            correo: _correoController.text,
          )
        : await vm.updateBranch(
            branchId: branch.id,
            nombre: _nombreController.text,
            codigo: _codigoController.text,
            direccion: _direccionController.text,
            rutaId: int.tryParse(_rutaIdController.text.trim()),
            gpsUbicacion: _gpsController.text,
            telefono: _telefonoController.text,
            correo: _correoController.text,
          );

    if (!context.mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEdit
              ? 'Sucursal "${result.nombre}" actualizada.'
              : 'Sucursal "${result.nombre}" creada.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }
}
