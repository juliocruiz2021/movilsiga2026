class GiroOption {
  const GiroOption({
    required this.id,
    required this.codigo,
    required this.descripcion,
  });

  final int id;
  final String codigo;
  final String descripcion;

  String get label {
    final code = codigo.trim();
    final desc = descripcion.trim();
    if (code.isEmpty) return desc;
    if (desc.isEmpty) return code;
    return '$code / $desc';
  }

  factory GiroOption.fromJson(Map<String, dynamic> json) {
    return GiroOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim() ?? '',
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
