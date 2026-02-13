class MunicipioOption {
  const MunicipioOption({
    required this.id,
    required this.codigo,
    required this.municipio,
  });

  final int id;
  final String codigo;
  final String municipio;

  String get label {
    final code = codigo.trim();
    final name = municipio.trim();
    if (code.isEmpty) return name;
    if (name.isEmpty) return code;
    return '$code / $name';
  }

  factory MunicipioOption.fromJson(Map<String, dynamic> json) {
    return MunicipioOption(
      id: _toInt(json['id']) ?? 0,
      codigo: json['codigo']?.toString().trim() ?? '',
      municipio: json['municipio']?.toString().trim() ?? '',
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
