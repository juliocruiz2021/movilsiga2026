import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/giro_option.dart';
import '../models/municipio_option.dart';
import '../models/route_option.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/clients_viewmodel.dart';
import 'location_picker_view.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/offline_cloud_icon.dart';

class ClientFormView extends StatefulWidget {
  const ClientFormView({super.key, this.client});

  final Client? client;

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
  final _gpsController = TextEditingController();

  bool _esProveedor = false;
  bool _isResolvingGps = false;
  bool _isAutoSavingGps = false;
  int? _selectedGiroId;
  String? _selectedGiroLabel;
  int? _selectedMunicipioId;
  String? _selectedMunicipioLabel;
  int? _selectedRutaId;
  String? _selectedRutaLabel;
  String? _lastSyncedGps;
  bool get _isEdit => widget.client != null;
  bool get _hasPendingGpsSync =>
      _isEdit &&
      _normalizeGps(_gpsController.text) != _lastSyncedGps &&
      !_isAutoSavingGps;

  @override
  void initState() {
    super.initState();
    _gpsController.addListener(_onGpsChanged);
    final client = widget.client;
    if (client == null) return;
    _codigoController.text = client.codigo;
    _nombreController.text = client.nombre;
    _nombreComercialController.text = client.nombreComercial ?? '';
    _nitController.text = client.nit ?? '';
    _duiController.text = client.dui ?? '';
    _pasaporteController.text = client.pasaporte ?? '';
    _telefonoController.text = client.telefono ?? '';
    _celularController.text = client.celular ?? '';
    _correoController.text = client.correo ?? '';
    _direccionController.text = client.direccion ?? '';
    _selectedGiroId = client.giroId;
    _selectedGiroLabel = _composeGiroLabel(
      id: client.giroId,
      codigo: client.codigoGiro,
      descripcion: client.giroDescripcion,
    );
    _selectedMunicipioId = client.municipioId;
    _selectedMunicipioLabel = _composeMunicipioLabel(
      id: client.municipioId,
      codigo: client.municipioCodigo,
      descripcion: client.municipioDescripcion,
    );
    _selectedRutaId = client.rutaId;
    _selectedRutaLabel = _composeRouteLabel(
      id: client.rutaId,
      codigo: client.rutaCodigo,
      nombre: client.rutaNombre,
    );
    _gpsController.text = client.gpsUbicacion ?? '';
    _lastSyncedGps = _normalizeGps(client.gpsUbicacion);
    _esProveedor = client.esProveedor;
  }

  @override
  void dispose() {
    _gpsController.removeListener(_onGpsChanged);
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
    _gpsController.dispose();
    super.dispose();
  }

  void _onGpsChanged() {
    if (!mounted) return;
    setState(() {});
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
    final canUpdate = context.select<AuthViewModel, bool>(
      (auth) =>
          auth.hasPermission('socios.update') ||
          auth.hasPermission('clientes.update'),
    );
    final canSave = _isEdit ? canUpdate : canCreate;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar cliente' : 'Nuevo cliente'),
        actions: [
          Consumer<ClientsViewModel>(
            builder: (context, vm, _) {
              final enabled = canSave && !vm.isSaving;
              final saveColor = enabled
                  ? palette.primary
                  : palette.textMuted.withValues(alpha: 0.45);
              return IconButton(
                tooltip: _isEdit ? 'Actualizar cliente' : 'Guardar cliente',
                onPressed: enabled ? () => _save(context) : null,
                icon: vm.isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.primary,
                        ),
                      )
                    : Icon(Icons.save_outlined, color: saveColor),
              );
            },
          ),
          const OfflineCloudIcon(),
        ],
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Consumer<ClientsViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!canSave)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.dangerContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isEdit
                              ? 'No tienes permiso para editar clientes.'
                              : 'No tienes permiso para crear clientes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (!canSave) const SizedBox(height: 12),
                    Opacity(
                      opacity: canSave ? 1 : 0.72,
                      child: IgnorePointer(
                        ignoring: !canSave,
                        child: Column(
                          children: [
                            _buildSectionCard(
                              context,
                              title: 'Identificacion',
                              icon: Icons.badge_outlined,
                              children: [
                                _buildTextField(
                                  controller: _codigoController,
                                  label: 'Codigo',
                                  hint: _isEdit
                                      ? null
                                      : 'Opcional, se genera automatico si va vacio',
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: _isEdit
                                      ? (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Ingresa el codigo del cliente';
                                          }
                                          return null;
                                        }
                                      : null,
                                ),
                                _buildTextField(
                                  controller: _nombreController,
                                  label: 'Nombre',
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa el nombre del cliente';
                                    }
                                    return null;
                                  },
                                ),
                                _buildTextField(
                                  controller: _nombreComercialController,
                                  label: 'Nombre comercial',
                                  textCapitalization: TextCapitalization.words,
                                ),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  value: _esProveedor,
                                  onChanged: (value) =>
                                      setState(() => _esProveedor = value),
                                  title: const Text('Tambien es proveedor'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSectionCard(
                              context,
                              title: 'Informacion fiscal',
                              icon: Icons.receipt_long_outlined,
                              children: [
                                _buildTextField(
                                  controller: _nitController,
                                  label: 'NIT',
                                ),
                                _buildTextField(
                                  controller: _duiController,
                                  label: 'DUI',
                                ),
                                _buildTextField(
                                  controller: _pasaporteController,
                                  label: 'Pasaporte',
                                ),
                                _buildGiroPicker(context),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSectionCard(
                              context,
                              title: 'Contacto',
                              icon: Icons.contact_phone_outlined,
                              children: [
                                _buildTextField(
                                  controller: _telefonoController,
                                  label: 'Telefono',
                                  keyboardType: TextInputType.phone,
                                ),
                                _buildTextField(
                                  controller: _celularController,
                                  label: 'Celular',
                                  keyboardType: TextInputType.phone,
                                ),
                                _buildTextField(
                                  controller: _correoController,
                                  label: 'Correo',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSectionCard(
                              context,
                              title: 'Ubicacion y ruta',
                              icon: Icons.location_on_outlined,
                              children: [
                                _buildTextField(
                                  controller: _direccionController,
                                  label: 'Direccion',
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 2,
                                ),
                                _buildMunicipioPicker(context),
                                _buildRoutePicker(context),
                                _buildTextField(
                                  controller: _gpsController,
                                  label: 'GPS (lat,lng)',
                                  hint: 'Ejemplo: 13.692900,-89.218200',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                  validator: _validateGps,
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _isResolvingGps
                                          ? null
                                          : _setGpsFromDevice,
                                      icon: _isResolvingGps
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.my_location_outlined,
                                            ),
                                      label: const Text(
                                        'Ubicacion del dispositivo',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _pickGpsOnMap,
                                      icon: const Icon(Icons.map_outlined),
                                      label: const Text('Seleccionar en mapa'),
                                    ),
                                    if (_isAutoSavingGps)
                                      const Chip(
                                        avatar: SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        label: Text('Guardando GPS...'),
                                      ),
                                    if (_hasPendingGpsSync)
                                      const Chip(
                                        label: Text('GPS pendiente de guardar'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                    const SizedBox(height: 18),
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _buildGiroPicker(BuildContext context) {
    final palette = context.palette;
    final label = _selectedGiroLabel ?? 'Sin giro';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openGiroPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Giro',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedGiroId != null)
                IconButton(
                  tooltip: 'Quitar giro',
                  onPressed: () {
                    setState(() {
                      _selectedGiroId = null;
                      _selectedGiroLabel = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              const Icon(Icons.search),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _selectedGiroId == null ? palette.textMuted : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMunicipioPicker(BuildContext context) {
    final palette = context.palette;
    final label = _selectedMunicipioLabel ?? 'Sin municipio';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openMunicipioPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Municipio',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedMunicipioId != null)
                IconButton(
                  tooltip: 'Quitar municipio',
                  onPressed: () {
                    setState(() {
                      _selectedMunicipioId = null;
                      _selectedMunicipioLabel = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              const Icon(Icons.search),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _selectedMunicipioId == null ? palette.textMuted : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePicker(BuildContext context) {
    final palette = context.palette;
    final label = _selectedRutaLabel ?? 'Sin ruta';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openRoutePicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ruta',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedRutaId != null)
                IconButton(
                  tooltip: 'Quitar ruta',
                  onPressed: () {
                    setState(() {
                      _selectedRutaId = null;
                      _selectedRutaLabel = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              const Icon(Icons.search),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _selectedRutaId == null ? palette.textMuted : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final palette = context.palette;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      ),
    );
  }

  String? _composeRouteLabel({int? id, String? codigo, String? nombre}) {
    final code = (codigo ?? '').trim();
    final name = (nombre ?? '').trim();
    if (code.isNotEmpty && name.isNotEmpty) {
      return '$code - $name';
    }
    if (name.isNotEmpty) return name;
    if (code.isNotEmpty) return code;
    if (id != null) return 'Ruta #$id';
    return null;
  }

  String? _composeGiroLabel({int? id, String? codigo, String? descripcion}) {
    final code = (codigo ?? '').trim();
    final desc = (descripcion ?? '').trim();
    if (code.isNotEmpty && desc.isNotEmpty) {
      return '$code / $desc';
    }
    if (desc.isNotEmpty) return desc;
    if (code.isNotEmpty) return code;
    if (id != null) return 'Giro #$id';
    return null;
  }

  String? _composeMunicipioLabel({
    int? id,
    String? codigo,
    String? descripcion,
  }) {
    final code = (codigo ?? '').trim();
    final desc = (descripcion ?? '').trim();
    if (code.isNotEmpty && desc.isNotEmpty) {
      return '$code / $desc';
    }
    if (desc.isNotEmpty) return desc;
    if (code.isNotEmpty) return code;
    if (id != null) return 'Municipio #$id';
    return null;
  }

  Future<void> _openGiroPicker() async {
    final vm = context.read<ClientsViewModel>();
    final selected = await showModalBottomSheet<GiroOption?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _GiroPickerSheet(
          selectedGiroId: _selectedGiroId,
          onSearch: (query) => vm.searchGiros(query: query),
        );
      },
    );

    if (!mounted || selected == null) return;

    if (selected.id <= 0) {
      setState(() {
        _selectedGiroId = null;
        _selectedGiroLabel = null;
      });
      return;
    }

    setState(() {
      _selectedGiroId = selected.id;
      _selectedGiroLabel = selected.label;
    });
  }

  Future<void> _openMunicipioPicker() async {
    final vm = context.read<ClientsViewModel>();
    final selected = await showModalBottomSheet<MunicipioOption?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _MunicipioPickerSheet(
          selectedMunicipioId: _selectedMunicipioId,
          onSearch: (query) => vm.searchMunicipios(query: query),
        );
      },
    );

    if (!mounted || selected == null) return;

    if (selected.id <= 0) {
      setState(() {
        _selectedMunicipioId = null;
        _selectedMunicipioLabel = null;
      });
      return;
    }

    setState(() {
      _selectedMunicipioId = selected.id;
      _selectedMunicipioLabel = selected.label;
    });
  }

  Future<void> _openRoutePicker() async {
    final vm = context.read<ClientsViewModel>();
    final selected = await showModalBottomSheet<RouteOption?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _RoutePickerSheet(
          selectedRouteId: _selectedRutaId,
          onSearch: (query) => vm.searchRoutes(query: query),
        );
      },
    );

    if (!mounted || selected == null) return;

    if (selected.id <= 0) {
      setState(() {
        _selectedRutaId = null;
        _selectedRutaLabel = null;
      });
      return;
    }

    setState(() {
      _selectedRutaId = selected.id;
      _selectedRutaLabel = selected.label;
    });
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(text)) {
      return 'Correo invalido';
    }
    return null;
  }

  String? _validateGps(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final parts = text.split(',');
    if (parts.length != 2) {
      return 'Formato requerido: lat,lng';
    }

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      return 'Coordenadas invalidas';
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return 'Lat/Lng fuera de rango';
    }
    return null;
  }

  Future<void> _setGpsFromDevice() async {
    setState(() => _isResolvingGps = true);
    try {
      final position = await _resolveCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicacion.')),
        );
        return;
      }
      _gpsController.text =
          '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
      await _autoSaveGpsIfNeeded();
    } finally {
      if (mounted) {
        setState(() => _isResolvingGps = false);
      }
    }
  }

  Future<void> _pickGpsOnMap() async {
    final gps = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => LocationPickerView(initialGps: _gpsController.text),
      ),
    );
    if (!mounted || gps == null || gps.trim().isEmpty) return;
    _gpsController.text = _normalizeGps(gps.trim()) ?? gps.trim();
    await _autoSaveGpsIfNeeded();
  }

  Future<Position?> _resolveCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ClientsViewModel>();
    final client = widget.client;
    final normalizedGps = _normalizeGps(_gpsController.text);
    final result = client == null
        ? await vm.createClient(
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
            gpsUbicacion: normalizedGps,
            giroId: _selectedGiroId,
            municipioId: _selectedMunicipioId,
            rutaId: _selectedRutaId,
            esProveedor: _esProveedor,
          )
        : await vm.updateClient(
            clientId: client.id,
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
            gpsUbicacion: normalizedGps,
            giroId: _selectedGiroId,
            municipioId: _selectedMunicipioId,
            rutaId: _selectedRutaId,
            esProveedor: _esProveedor,
          );

    if (!context.mounted) return;
    if (result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEdit
              ? 'Cliente "${result.nombre}" actualizado.'
              : 'Cliente "${result.nombre}" creado.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _autoSaveGpsIfNeeded() async {
    final client = widget.client;
    if (client == null) return;

    final gps = _normalizeGps(_gpsController.text);
    if (gps == _lastSyncedGps) return;
    if (_isAutoSavingGps) return;

    setState(() => _isAutoSavingGps = true);
    try {
      final vm = context.read<ClientsViewModel>();
      final ok = await vm.updateClientGps(
        clientId: client.id,
        gpsUbicacion: gps,
      );
      if (!mounted) return;

      if (ok) {
        _lastSyncedGps = gps;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicacion GPS actualizada en servidor.'),
          ),
        );
        return;
      }

      final message =
          vm.saveErrorMessage ?? 'No se pudo actualizar GPS en servidor.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isAutoSavingGps = false);
      }
    }
  }

  String? _normalizeGps(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final parts = value.split(',');
    if (parts.length != 2) return value;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return value;
    return '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
  }
}

class _GiroPickerSheet extends StatefulWidget {
  const _GiroPickerSheet({
    required this.onSearch,
    required this.selectedGiroId,
  });

  final Future<List<GiroOption>> Function(String query) onSearch;
  final int? selectedGiroId;

  @override
  State<_GiroPickerSheet> createState() => _GiroPickerSheetState();
}

class _GiroPickerSheetState extends State<_GiroPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<GiroOption> _giros = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGiros();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _loadGiros(query: value);
    });
  }

  Future<void> _loadGiros({String query = ''}) async {
    setState(() => _isLoading = true);
    final found = await widget.onSearch(query.trim());
    if (!mounted) return;
    setState(() {
      _giros = found;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.74,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar giro',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Escribe codigo o descripcion',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Sin giro'),
                onTap: () => Navigator.of(
                  context,
                ).pop(const GiroOption(id: 0, codigo: '', descripcion: '')),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading && _giros.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _giros.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron giros.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _giros.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final giro = _giros[index];
                          final selected = giro.id == widget.selectedGiroId;
                          return ListTile(
                            title: Text(giro.label),
                            trailing: selected
                                ? Icon(Icons.check, color: palette.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(giro),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MunicipioPickerSheet extends StatefulWidget {
  const _MunicipioPickerSheet({
    required this.onSearch,
    required this.selectedMunicipioId,
  });

  final Future<List<MunicipioOption>> Function(String query) onSearch;
  final int? selectedMunicipioId;

  @override
  State<_MunicipioPickerSheet> createState() => _MunicipioPickerSheetState();
}

class _MunicipioPickerSheetState extends State<_MunicipioPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<MunicipioOption> _municipios = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _loadMunicipios(query: value);
    });
  }

  Future<void> _loadMunicipios({String query = ''}) async {
    setState(() => _isLoading = true);
    final found = await widget.onSearch(query.trim());
    if (!mounted) return;
    setState(() {
      _municipios = found;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.74,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar municipio',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Escribe codigo o municipio',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Sin municipio'),
                onTap: () => Navigator.of(
                  context,
                ).pop(const MunicipioOption(id: 0, codigo: '', municipio: '')),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading && _municipios.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _municipios.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron municipios.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _municipios.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final municipio = _municipios[index];
                          final selected =
                              municipio.id == widget.selectedMunicipioId;
                          return ListTile(
                            title: Text(municipio.label),
                            trailing: selected
                                ? Icon(Icons.check, color: palette.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(municipio),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePickerSheet extends StatefulWidget {
  const _RoutePickerSheet({
    required this.onSearch,
    required this.selectedRouteId,
  });

  final Future<List<RouteOption>> Function(String query) onSearch;
  final int? selectedRouteId;

  @override
  State<_RoutePickerSheet> createState() => _RoutePickerSheetState();
}

class _RoutePickerSheetState extends State<_RoutePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<RouteOption> _routes = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _loadRoutes(query: value);
    });
  }

  Future<void> _loadRoutes({String query = ''}) async {
    setState(() => _isLoading = true);
    final found = await widget.onSearch(query.trim());
    if (!mounted) return;
    setState(() {
      _routes = found;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.74,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar ruta',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Escribe codigo o nombre de ruta',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Sin ruta'),
                onTap: () => Navigator.of(
                  context,
                ).pop(const RouteOption(id: 0, codigo: '', nombre: 'Sin ruta')),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading && _routes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _routes.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron rutas.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _routes.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final route = _routes[index];
                          final selected = route.id == widget.selectedRouteId;
                          return ListTile(
                            title: Text(route.label),
                            subtitle:
                                (route.descripcion ?? '').trim().isNotEmpty
                                ? Text(route.descripcion!.trim())
                                : null,
                            trailing: selected
                                ? Icon(Icons.check, color: palette.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(route),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
