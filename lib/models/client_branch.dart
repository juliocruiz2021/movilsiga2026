class ClientBranch {
  const ClientBranch({
    required this.id,
    required this.socioId,
    required this.nombre,
    required this.activo,
    this.rutaId,
    this.codigo,
    this.direccion,
    this.gpsUbicacion,
    this.telefono,
    this.correo,
    this.rutaCodigo,
    this.rutaNombre,
    this.updatedAt,
  });

  final int id;
  final int socioId;
  final int? rutaId;
  final String? codigo;
  final String nombre;
  final String? direccion;
  final String? gpsUbicacion;
  final String? telefono;
  final String? correo;
  final bool activo;
  final String? rutaCodigo;
  final String? rutaNombre;
  final DateTime? updatedAt;

  String get primaryContact {
    if ((telefono ?? '').trim().isNotEmpty) return telefono!.trim();
    if ((correo ?? '').trim().isNotEmpty) return correo!.trim();
    return '';
  }

  factory ClientBranch.fromJson(Map<String, dynamic> json) {
    final rutaMap = json['ruta'];
    final ruta = rutaMap is Map<String, dynamic>
        ? rutaMap
        : (rutaMap is Map ? rutaMap.map((k, v) => MapEntry('$k', v)) : null);

    return ClientBranch(
      id: _toInt(json['id']) ?? 0,
      socioId: _toInt(json['socio_id']) ?? 0,
      rutaId: _toInt(json['ruta_id']),
      codigo: _toStringOrNull(json['codigo']),
      nombre: _toStringOrNull(json['nombre']) ?? '',
      direccion: _toStringOrNull(json['direccion']),
      gpsUbicacion: _toStringOrNull(json['gps_ubicacion']),
      telefono: _toStringOrNull(json['telefono']),
      correo: _toStringOrNull(json['correo']),
      activo: _toBool(json['activo']) ?? true,
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
