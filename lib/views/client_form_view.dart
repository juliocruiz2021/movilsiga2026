import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/clients_viewmodel.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/offline_cloud_icon.dart';

class ClientFormView extends StatefulWidget {
  const ClientFormView({super.key});

  @override
  State<ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<ClientFormView> {
  final _formKey = GlobalKey<FormState>();

  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _nombreComercialController = TextEditingController();
  final _nitController = TextEditingController();
  final _duiController = TextEditingController();
  final _pasaporteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _celularController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _codigoGiroController = TextEditingController();
  final _giroIdController = TextEditingController();
  final _municipioIdController = TextEditingController();
  final _gpsController = TextEditingController();

  bool _esProveedor = false;

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _nombreComercialController.dispose();
    _nitController.dispose();
    _duiController.dispose();
    _pasaporteController.dispose();
    _telefonoController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _codigoGiroController.dispose();
    _giroIdController.dispose();
    _municipioIdController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final canCreate = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.create') ||
          auth.hasPermission('clientes.create'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo cliente'),
        actions: const [OfflineCloudIcon()],
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Consumer<ClientsViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!canCreate)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.dangerContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No tienes permiso para crear clientes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (!canCreate) const SizedBox(height: 12),
                    _buildTextField(
                      controller: _codigoController,
                      label: 'Codigo',
                      hint: 'Opcional, se genera automatico si va vacio',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre del cliente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _nombreComercialController,
                      label: 'Nombre comercial',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(controller: _nitController, label: 'NIT'),
                    const SizedBox(height: 10),
                    _buildTextField(controller: _duiController, label: 'DUI'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _pasaporteController,
                      label: 'Pasaporte',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _telefonoController,
                      label: 'Telefono',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _celularController,
                      label: 'Celular',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _correoController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _direccionController,
                      label: 'Direccion',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _codigoGiroController,
                      label: 'Codigo giro',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _giroIdController,
                      label: 'Giro ID',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _municipioIdController,
                      label: 'Municipio ID',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _gpsController,
                      label: 'GPS (lat,lng)',
                      hint: 'Ejemplo: 13.6929,-89.2182',
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: _esProveedor,
                      onChanged: canCreate
                          ? (value) => setState(() => _esProveedor = value)
                          : null,
                      title: const Text('Tambien es proveedor'),
                    ),
                    if (vm.saveErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
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
                        onPressed: (!canCreate || vm.isSaving)
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
                        label: Text(vm.isSaving ? 'Guardando...' : 'Guardar'),
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
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ClientsViewModel>();
    final created = await vm.createClient(
      codigo: _codigoController.text,
      nombre: _nombreController.text,
      nombreComercial: _nombreComercialController.text,
      nit: _nitController.text,
      dui: _duiController.text,
      pasaporte: _pasaporteController.text,
      telefono: _telefonoController.text,
      celular: _celularController.text,
      correo: _correoController.text,
      direccion: _direccionController.text,
      gpsUbicacion: _gpsController.text,
      codigoGiro: _codigoGiroController.text,
      giroId: int.tryParse(_giroIdController.text.trim()),
      municipioId: int.tryParse(_municipioIdController.text.trim()),
      esProveedor: _esProveedor,
    );

    if (!context.mounted) return;
    if (created == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cliente "${created.nombre}" creado.')),
    );
    Navigator.of(context).pop(true);
  }
}
