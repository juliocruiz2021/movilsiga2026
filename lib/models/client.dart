class Client {
  const Client({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.activo,
    required this.esCliente,
    required this.esProveedor,
    this.nombreComercial,
    this.nit,
    this.dui,
    this.pasaporte,
    this.telefono,
    this.celular,
    this.correo,
    this.direccion,
    this.codigoGiro,
    this.giroDescripcion,
    this.giroId,
    this.municipioId,
    this.municipioCodigo,
    this.municipioDescripcion,
    this.gpsUbicacion,
    this.rutaId,
    this.rutaCodigo,
    this.rutaNombre,
    this.updatedAt,
  });

  final int id;
  final String codigo;
  final String nombre;
  final bool activo;
  final bool esCliente;
  final bool esProveedor;
  final String? nombreComercial;
  final String? nit;
  final String? dui;
  final String? pasaporte;
  final String? telefono;
  final String? celular;
  final String? correo;
  final String? direccion;
  final String? codigoGiro;
  final String? giroDescripcion;
  final int? giroId;
  final int? municipioId;
  final String? municipioCodigo;
  final String? municipioDescripcion;
  final String? gpsUbicacion;
  final int? rutaId;
  final String? rutaCodigo;
  final String? rutaNombre;
  final DateTime? updatedAt;

  String get primaryContact {
    if ((celular ?? '').trim().isNotEmpty) return celular!.trim();
    if ((telefono ?? '').trim().isNotEmpty) return telefono!.trim();
    if ((correo ?? '').trim().isNotEmpty) return correo!.trim();
    return '';
  }

  String get routeLabel {
    if ((rutaNombre ?? '').trim().isNotEmpty) return rutaNombre!.trim();
    if ((rutaCodigo ?? '').trim().isNotEmpty) return rutaCodigo!.trim();
    return 'Sin Ruta';
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    final rutaRaw = json['ruta'];
    final ruta = rutaRaw is Map<String, dynamic>
        ? rutaRaw
        : (rutaRaw is Map ? rutaRaw.map((k, v) => MapEntry('$k', v)) : null);
    final giroRaw = json['giro'];
    final giro = giroRaw is Map<String, dynamic>
        ? giroRaw
        : (giroRaw is Map ? giroRaw.map((k, v) => MapEntry('$k', v)) : null);
    final municipioRaw = json['municipio'];
    final municipio = municipioRaw is Map<String, dynamic>
        ? municipioRaw
        : (municipioRaw is Map
              ? municipioRaw.map((k, v) => MapEntry('$k', v))
              : null);

    return Client(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      activo: _toBool(json['activo']) ?? true,
      esCliente: _toBool(json['es_cliente']) ?? true,
      esProveedor: _toBool(json['es_proveedor']) ?? false,
      nombreComercial: _toStringOrNull(json['nombre_comercial']),
      nit: _toStringOrNull(json['nit']),
      dui: _toStringOrNull(json['dui']),
      pasaporte: _toStringOrNull(json['pasaporte']),
      telefono: _toStringOrNull(json['telefono']),
      celular: _toStringOrNull(json['celular']),
      correo: _toStringOrNull(json['correo']),
      direccion: _toStringOrNull(json['direccion']),
      codigoGiro:
          _toStringOrNull(json['codigo_giro']) ??
          _toStringOrNull(giro?['codigo']),
      giroDescripcion: _toStringOrNull(giro?['descripcion']),
      giroId: _toInt(json['giro_id']),
      municipioId: _toInt(json['municipio_id']),
      municipioCodigo: _toStringOrNull(municipio?['codigo']),
      municipioDescripcion:
          _toStringOrNull(municipio?['descripcion']) ??
          _toStringOrNull(municipio?['municipio']),
      gpsUbicacion: _toStringOrNull(json['gps_ubicacion']),
      rutaId: _toInt(json['ruta_id']),
      rutaCodigo: _toStringOrNull(ruta?['codigo']),
      rutaNombre: _toStringOrNull(ruta?['nombre']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  static String? _toStringOrNull(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == '1' || normalized == 'true') return true;
      if (normalized == '0' || normalized == 'false') return false;
    }
    return null;
  }

  static DateTime? _toDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
