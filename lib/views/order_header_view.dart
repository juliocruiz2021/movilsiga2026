import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../viewmodels/order_editor_viewmodel.dart';

class OrderHeaderView extends StatefulWidget {
  const OrderHeaderView({super.key, required this.vm});

  final OrderEditorViewModel vm;

  @override
  State<OrderHeaderView> createState() => _OrderHeaderViewState();
}

class _OrderHeaderViewState extends State<OrderHeaderView> {
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  final TextEditingController _numeroManualController = TextEditingController();

  OrderEditorViewModel get _vm => widget.vm;

  @override
  void dispose() {
    _gpsController.dispose();
    _notaController.dispose();
    _numeroManualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encabezado del pedido')),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          _syncControllers();
          final palette = context.palette;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_vm.selectedClient != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: palette.shadow.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: palette.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _vm.selectedClient!.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.textStrong,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text('Fecha: ${_formatDate(_vm.fecha)}'),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Serie',
                      value: _safeSelected(_vm.selectedSerieId, _vm.series),
                      items: _vm.series,
                      onChanged: (value) {
                        if (value == null) return;
                        _vm.setSerie(value);
                      },
                    ),
                    if (!_vm.serieAutomatica) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _numeroManualController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Numero manual',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _vm.setNumeroManual,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _gpsController,
                            decoration: const InputDecoration(
                              labelText: 'GPS ubicacion',
                              hintText: 'lat,lng',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _vm.setGpsUbicacion,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _vm.isResolvingGps ? null : _captureGps,
                          tooltip: 'Tomar GPS',
                          icon: _vm.isResolvingGps
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No va pedir',
                            style: TextStyle(
                              color: palette.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Switch(
                          value: _vm.noPidio,
                          onChanged: (value) async {
                            _vm.setNoPidio(value);
                            if (value && _vm.gpsUbicacion.trim().isEmpty) {
                              await _captureGps();
                            }
                          },
                        ),
                      ],
                    ),
                    if (_vm.noPidio) ...[
                      _buildDropdown(
                        label: 'Motivo no pidio',
                        value: _safeSelected(
                          _vm.selectedMotivoNoPedidoId,
                          _vm.motivosNoPedido,
                        ),
                        items: _vm.motivosNoPedido,
                        onChanged: (value) {
                          if (value == null) return;
                          _vm.setMotivoNoPedido(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _vm.isLoadingReasons
                            ? null
                            : _openCreateReasonDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Agregar motivo nuevo'),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'En no pidio se guarda el punteo sin detalle y con GPS.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notaController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Nota / observaciones',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _vm.setObservaciones,
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: _onContinue,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuar a confirmar'),
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
    required List<OrderLookupOption> items,
    required ValueChanged<int?>? onChanged,
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

  int? _safeSelected(int? selected, List<OrderLookupOption> items) {
    if (selected == null) return null;
    return items.any((item) => item.id == selected) ? selected : null;
  }

  void _syncControllers() {
    final gps = _vm.gpsUbicacion;
    if (_gpsController.text != gps) {
      _gpsController.text = gps;
      _gpsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _gpsController.text.length),
      );
    }

    final note = _vm.observaciones;
    if (_notaController.text != note) {
      _notaController.text = note;
      _notaController.selection = TextSelection.fromPosition(
        TextPosition(offset: _notaController.text.length),
      );
    }

    final manual = _vm.numeroManual?.toString() ?? '';
    if (_numeroManualController.text != manual) {
      _numeroManualController.text = manual;
      _numeroManualController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numeroManualController.text.length),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _vm.fecha,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null) return;
    _vm.setFecha(picked);
  }

  Future<void> _captureGps() async {
    final ok = await _vm.captureGpsFromDevice();
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo obtener el GPS del dispositivo.'),
      ),
    );
  }

  Future<void> _openCreateReasonDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nuevo motivo de no pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del motivo',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Codigo (opcional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (!mounted || result != true) {
      nameController.dispose();
      codeController.dispose();
      return;
    }

    final created = await _vm.createMotivoNoPedido(
      nombre: nameController.text,
      codigo: codeController.text,
    );

    nameController.dispose();
    codeController.dispose();

    if (!mounted) return;

    if (created != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Motivo "${created.nombre}" creado.')),
      );
      return;
    }

    final message = _vm.saveErrorMessage ?? 'No se pudo crear el motivo.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _onContinue() {
    final messenger = ScaffoldMessenger.of(context);

    if (_vm.selectedClient == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente.')),
      );
      return;
    }
    if (_vm.selectedSucursalId == null ||
        _vm.selectedPuntoVentaId == null ||
        _vm.selectedVendedorId == null ||
        _vm.selectedCentroCostoId == null ||
        _vm.selectedTipoDocumentoId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Faltan parámetros por defecto del usuario para crear pedidos.',
          ),
        ),
      );
      return;
    }
    if (_vm.selectedSerieId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecciona una serie.')),
      );
      return;
    }
    if (!_vm.serieAutomatica &&
        (_vm.numeroManual == null || _vm.numeroManual! <= 0)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ingresa numero manual valido.')),
      );
      return;
    }
    if (_vm.noPidio) {
      if (_vm.selectedMotivoNoPedidoId == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Selecciona un motivo de no pedido.')),
        );
        return;
      }
      if (_vm.gpsUbicacion.trim().isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Captura el GPS para no pedido.')),
        );
        return;
      }
    } else {
      if (_vm.selectedBodegaId == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No hay bodega por defecto para este usuario.'),
          ),
        );
        return;
      }
      if (_vm.lineas.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Agrega productos al pedido.')),
        );
        return;
      }
    }

    Navigator.of(context).pop(true);
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}
