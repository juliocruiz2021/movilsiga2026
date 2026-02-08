class Product {
  const Product({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.colorHex,
    this.categoryId,
    this.categoryNombre,
    this.fotoUrl,
    this.fotoThumbUrl,
  });

  final int id;
  final String codigo;
  final String nombre;
  final double precio;
  final double stock;
  final int colorHex;
  final int? categoryId;
  final String? categoryNombre;
  final String? fotoUrl;
  final String? fotoThumbUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['precio'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
    final category = json['category'] as Map<String, dynamic>?;
    final stockRaw = json['stock'];
    final stock = stockRaw is num
        ? stockRaw.toDouble()
        : double.tryParse(stockRaw?.toString() ?? '') ?? 0;
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      precio: price,
      stock: stock,
      colorHex: _colorFromId((json['id'] as num?)?.toInt() ?? 0),
      categoryId: (category?['id'] as num?)?.toInt(),
      categoryNombre: category?['nombre']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      fotoThumbUrl: json['foto_thumb_url']?.toString(),
    );
  }

  static int _colorFromId(int id) {
    const palette = [
      0xFF8ED1FF,
      0xFFFFC857,
      0xFF8FE3C1,
      0xFFFF9FB1,
      0xFFB5A2FF,
      0xFF93D9D9,
      0xFFFFD166,
      0xFF7BDFF2,
      0xFF96F2D7,
      0xFFA5B4FC,
      0xFFFCA5A5,
      0xFF99F6E4,
    ];
    return palette[id % palette.length];
  }
}
