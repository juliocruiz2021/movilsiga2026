import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OrderConfirmationView extends StatefulWidget {
  const OrderConfirmationView({
    super.key,
    required this.clienteLabel,
    required this.fecha,
    required this.noPidio,
    required this.total,
    required this.cantidad,
    required this.lineasCount,
    required this.gps,
    required this.initialNote,
    this.motivoNoPedido,
  });

  final String clienteLabel;
  final DateTime fecha;
  final bool noPidio;
  final String? motivoNoPedido;
  final double total;
  final double cantidad;
  final int lineasCount;
  final String gps;
  final String initialNote;

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  late final TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface,
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
                _InfoRow(label: 'Cliente', value: widget.clienteLabel),
                _InfoRow(label: 'Fecha', value: _formatDate(widget.fecha)),
                _InfoRow(
                  label: 'Estado',
                  value: widget.noPidio ? 'No pidió' : 'Con pedido',
                ),
                if (widget.noPidio)
                  _InfoRow(
                    label: 'Motivo',
                    value: (widget.motivoNoPedido ?? '').trim().isEmpty
                        ? '-'
                        : widget.motivoNoPedido!,
                  ),
                _InfoRow(
                  label: 'Items',
                  value:
                      '${widget.lineasCount} lineas • ${widget.cantidad.toStringAsFixed(0)} unidades',
                ),
                _InfoRow(
                  label: 'Total',
                  value: '\$${widget.total.toStringAsFixed(2)}',
                ),
                _InfoRow(
                  label: 'GPS',
                  value: widget.gps.trim().isEmpty ? '-' : widget.gps,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nota',
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notaController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Observaciones del pedido...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop(_notaController.text.trim());
            },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(widget.noPidio ? 'Guardar no pidió' : 'Guardar pedido'),
          ),
        ],
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
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: TextStyle(
                color: palette.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}
