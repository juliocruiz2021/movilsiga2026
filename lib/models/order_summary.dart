class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.estado,
    required this.tipoRegistro,
    required this.tipoOperacion,
    required this.total,
    required this.subtotal,
    required this.descuento,
    required this.socioCodigo,
    required this.socioNombre,
    this.fecha,
    this.serie,
    this.numero,
    this.observaciones,
    this.socioId,
    this.socioNombreComercial,
    this.socioTelefono,
    this.socioCelular,
  });

  final int id;
  final DateTime? fecha;
  final String estado;
  final String tipoRegistro;
  final String tipoOperacion;
  final String? serie;
  final int? numero;
  final double total;
  final double subtotal;
  final double descuento;
  final String? observaciones;
  final int? socioId;
  final String socioCodigo;
  final String socioNombre;
  final String? socioNombreComercial;
  final String? socioTelefono;
  final String? socioCelular;

  String get documentNumber {
    final serieText = (serie ?? '').trim();
    final numeroText = numero?.toString() ?? '';
    if (serieText.isEmpty && numeroText.isEmpty) return 'Sin correlativo';
    if (serieText.isEmpty) return numeroText;
    if (numeroText.isEmpty) return serieText;
    return '$serieText-$numeroText';
  }

  String get bestPhone {
    final celular = socioCelular?.trim() ?? '';
    if (celular.isNotEmpty) return celular;
    final telefono = socioTelefono?.trim() ?? '';
    if (telefono.isNotEmpty) return telefono;
    return '';
  }

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final socio = _asMap(json['socio']);

    return OrderSummary(
      id: _toInt(json['id']) ?? 0,
      fecha: _toDate(json['fecha']),
      estado: _toText(json['estado']) ?? '',
      tipoRegistro: _toText(json['tipo_registro']) ?? '',
      tipoOperacion: _toText(json['tipo_operacion']) ?? '',
      serie: _toText(json['serie']),
      numero: _toInt(json['numero']),
      total: _toDouble(json['total']),
      subtotal: _toDouble(json['subtotal']),
      descuento: _toDouble(json['descuento']),
      observaciones: _toText(json['observaciones']),
      socioId: _toInt(json['socio_id']) ?? _toInt(socio?['id']),
      socioCodigo: _toText(socio?['codigo']) ?? '',
      socioNombre: _toText(socio?['nombre']) ?? '',
      socioNombreComercial: _toText(socio?['nombre_comercial']),
      socioTelefono: _toText(socio?['telefono']),
      socioCelular: _toText(socio?['celular']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  static String? _toText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
