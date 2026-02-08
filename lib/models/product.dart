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
    this.brandId,
    this.brandNombre,
    this.fotoUrl,
    this.fotoUrlWeb,
    this.fotoThumbUrl,
    this.descripcion,
    this.stockBySucursal = const [],
  });

  final int id;
  final String codigo;
  final String nombre;
  final double precio;
  final double stock;
  final int colorHex;
  final int? categoryId;
  final String? categoryNombre;
  final int? brandId;
  final String? brandNombre;
  final String? fotoUrl;
  final String? fotoUrlWeb;
  final String? fotoThumbUrl;
  final String? descripcion;
  final List<SucursalStock> stockBySucursal;

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['precio'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;
    final stockRaw = json['stock'];
    final stock = stockRaw is num
        ? stockRaw.toDouble()
        : double.tryParse(stockRaw?.toString() ?? '') ?? 0;
    final descripcionRaw = json['descripcion'] ??
        json['description'] ??
        json['descripcion_corta'];
    final sucursalesRaw = json['existencias_sucursales'];
    final sucursales = <SucursalStock>[];
    if (sucursalesRaw is List) {
      for (final item in sucursalesRaw) {
        if (item is Map) {
          final mapped = item.map((k, v) => MapEntry(k.toString(), v));
          sucursales.add(SucursalStock.fromJson(mapped));
        }
      }
    }
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      precio: price,
      stock: stock,
      colorHex: _colorFromId((json['id'] as num?)?.toInt() ?? 0),
      categoryId: (category?['id'] as num?)?.toInt(),
      categoryNombre: category?['nombre']?.toString(),
      brandId: (brand?['id'] as num?)?.toInt(),
      brandNombre: brand?['nombre']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      fotoUrlWeb: json['foto_url_web']?.toString(),
      fotoThumbUrl: json['foto_thumb_url']?.toString(),
      descripcion: descripcionRaw?.toString(),
      stockBySucursal: sucursales,
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

  Product mergeFallback(Product fallback) {
    String? pickText(String? value) {
      return (value != null && value.trim().isNotEmpty) ? value : null;
    }

    return Product(
      id: id != 0 ? id : fallback.id,
      codigo: codigo.isNotEmpty ? codigo : fallback.codigo,
      nombre: nombre.isNotEmpty ? nombre : fallback.nombre,
      precio: precio != 0 ? precio : fallback.precio,
      stock: stock != 0 ? stock : fallback.stock,
      colorHex: colorHex,
      categoryId: categoryId ?? fallback.categoryId,
      categoryNombre: pickText(categoryNombre) ?? fallback.categoryNombre,
      brandId: brandId ?? fallback.brandId,
      brandNombre: pickText(brandNombre) ?? fallback.brandNombre,
      fotoUrl: pickText(fotoUrl) ?? fallback.fotoUrl,
      fotoUrlWeb: pickText(fotoUrlWeb) ?? fallback.fotoUrlWeb,
      fotoThumbUrl: pickText(fotoThumbUrl) ?? fallback.fotoThumbUrl,
      descripcion: pickText(descripcion) ?? fallback.descripcion,
      stockBySucursal:
          stockBySucursal.isNotEmpty ? stockBySucursal : fallback.stockBySucursal,
    );
  }

  static int colorFromId(int id) => _colorFromId(id);
}

class SucursalStock {
  const SucursalStock({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.stockTotal,
  });

  final int id;
  final String codigo;
  final String nombre;
  final double stockTotal;

  factory SucursalStock.fromJson(Map<String, dynamic> json) {
    final sucursal = json['sucursal'];
    final sucursalMap = sucursal is Map
        ? sucursal.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    final stockRaw = json['stock_total'];
    final stockTotal = stockRaw is num
        ? stockRaw.toDouble()
        : double.tryParse(stockRaw?.toString() ?? '') ?? 0;
    return SucursalStock(
      id: (sucursalMap['id'] as num?)?.toInt() ?? 0,
      codigo: sucursalMap['codigo']?.toString() ?? '',
      nombre: sucursalMap['nombre']?.toString() ?? '',
      stockTotal: stockTotal,
    );
  }
}
