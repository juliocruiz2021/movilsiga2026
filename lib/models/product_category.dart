class ProductCategory {
  const ProductCategory({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}
