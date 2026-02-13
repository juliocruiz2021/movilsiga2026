class RouteOption {
  const RouteOption({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.activo = true,
  });

  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool activo;

  String get label {
    final code = codigo.trim();
    final name = nombre.trim();
    if (code.isEmpty) return name;
    if (name.isEmpty) return code;
    return '$code - $name';
  }

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString().trim() ?? '',
      nombre: json['nombre']?.toString().trim() ?? '',
      descripcion: _toStringOrNull(json['descripcion']),
      activo: _toBool(json['activo']) ?? true,
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
}
