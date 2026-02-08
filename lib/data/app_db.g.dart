// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<int> tipo = GeneratedColumn<int>(
    'tipo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
    'precio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoUrlMeta = const VerificationMeta(
    'fotoUrl',
  );
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
    'foto_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoUrlWebMeta = const VerificationMeta(
    'fotoUrlWeb',
  );
  @override
  late final GeneratedColumn<String> fotoUrlWeb = GeneratedColumn<String>(
    'foto_url_web',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoThumbUrlMeta = const VerificationMeta(
    'fotoThumbUrl',
  );
  @override
  late final GeneratedColumn<String> fotoThumbUrl = GeneratedColumn<String>(
    'foto_thumb_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNombreMeta = const VerificationMeta(
    'categoryNombre',
  );
  @override
  late final GeneratedColumn<String> categoryNombre = GeneratedColumn<String>(
    'category_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandIdMeta = const VerificationMeta(
    'brandId',
  );
  @override
  late final GeneratedColumn<int> brandId = GeneratedColumn<int>(
    'brand_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandNombreMeta = const VerificationMeta(
    'brandNombre',
  );
  @override
  late final GeneratedColumn<String> brandNombre = GeneratedColumn<String>(
    'brand_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    tipo,
    precio,
    stock,
    activo,
    descripcion,
    fotoUrl,
    fotoUrlWeb,
    fotoThumbUrl,
    categoryId,
    categoryNombre,
    brandId,
    brandNombre,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    if (data.containsKey('precio')) {
      context.handle(
        _precioMeta,
        precio.isAcceptableOrUnknown(data['precio']!, _precioMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('foto_url')) {
      context.handle(
        _fotoUrlMeta,
        fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta),
      );
    }
    if (data.containsKey('foto_url_web')) {
      context.handle(
        _fotoUrlWebMeta,
        fotoUrlWeb.isAcceptableOrUnknown(
          data['foto_url_web']!,
          _fotoUrlWebMeta,
        ),
      );
    }
    if (data.containsKey('foto_thumb_url')) {
      context.handle(
        _fotoThumbUrlMeta,
        fotoThumbUrl.isAcceptableOrUnknown(
          data['foto_thumb_url']!,
          _fotoThumbUrlMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_nombre')) {
      context.handle(
        _categoryNombreMeta,
        categoryNombre.isAcceptableOrUnknown(
          data['category_nombre']!,
          _categoryNombreMeta,
        ),
      );
    }
    if (data.containsKey('brand_id')) {
      context.handle(
        _brandIdMeta,
        brandId.isAcceptableOrUnknown(data['brand_id']!, _brandIdMeta),
      );
    }
    if (data.containsKey('brand_nombre')) {
      context.handle(
        _brandNombreMeta,
        brandNombre.isAcceptableOrUnknown(
          data['brand_nombre']!,
          _brandNombreMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tipo'],
      ),
      precio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      fotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url'],
      ),
      fotoUrlWeb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url_web'],
      ),
      fotoThumbUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_thumb_url'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      categoryNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_nombre'],
      ),
      brandId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}brand_id'],
      ),
      brandNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_nombre'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final int id;
  final String codigo;
  final String nombre;
  final int? tipo;
  final double precio;
  final double stock;
  final bool activo;
  final String? descripcion;
  final String? fotoUrl;
  final String? fotoUrlWeb;
  final String? fotoThumbUrl;
  final int? categoryId;
  final String? categoryNombre;
  final int? brandId;
  final String? brandNombre;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const ProductRow({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.tipo,
    required this.precio,
    required this.stock,
    required this.activo,
    this.descripcion,
    this.fotoUrl,
    this.fotoUrlWeb,
    this.fotoThumbUrl,
    this.categoryId,
    this.categoryNombre,
    this.brandId,
    this.brandNombre,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || tipo != null) {
      map['tipo'] = Variable<int>(tipo);
    }
    map['precio'] = Variable<double>(precio);
    map['stock'] = Variable<double>(stock);
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    if (!nullToAbsent || fotoUrlWeb != null) {
      map['foto_url_web'] = Variable<String>(fotoUrlWeb);
    }
    if (!nullToAbsent || fotoThumbUrl != null) {
      map['foto_thumb_url'] = Variable<String>(fotoThumbUrl);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || categoryNombre != null) {
      map['category_nombre'] = Variable<String>(categoryNombre);
    }
    if (!nullToAbsent || brandId != null) {
      map['brand_id'] = Variable<int>(brandId);
    }
    if (!nullToAbsent || brandNombre != null) {
      map['brand_nombre'] = Variable<String>(brandNombre);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      tipo: tipo == null && nullToAbsent ? const Value.absent() : Value(tipo),
      precio: Value(precio),
      stock: Value(stock),
      activo: Value(activo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      fotoUrlWeb: fotoUrlWeb == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrlWeb),
      fotoThumbUrl: fotoThumbUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoThumbUrl),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryNombre: categoryNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryNombre),
      brandId: brandId == null && nullToAbsent
          ? const Value.absent()
          : Value(brandId),
      brandNombre: brandNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(brandNombre),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: serializer.fromJson<int?>(json['tipo']),
      precio: serializer.fromJson<double>(json['precio']),
      stock: serializer.fromJson<double>(json['stock']),
      activo: serializer.fromJson<bool>(json['activo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      fotoUrlWeb: serializer.fromJson<String?>(json['fotoUrlWeb']),
      fotoThumbUrl: serializer.fromJson<String?>(json['fotoThumbUrl']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      categoryNombre: serializer.fromJson<String?>(json['categoryNombre']),
      brandId: serializer.fromJson<int?>(json['brandId']),
      brandNombre: serializer.fromJson<String?>(json['brandNombre']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<int?>(tipo),
      'precio': serializer.toJson<double>(precio),
      'stock': serializer.toJson<double>(stock),
      'activo': serializer.toJson<bool>(activo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'fotoUrlWeb': serializer.toJson<String?>(fotoUrlWeb),
      'fotoThumbUrl': serializer.toJson<String?>(fotoThumbUrl),
      'categoryId': serializer.toJson<int?>(categoryId),
      'categoryNombre': serializer.toJson<String?>(categoryNombre),
      'brandId': serializer.toJson<int?>(brandId),
      'brandNombre': serializer.toJson<String?>(brandNombre),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ProductRow copyWith({
    int? id,
    String? codigo,
    String? nombre,
    Value<int?> tipo = const Value.absent(),
    double? precio,
    double? stock,
    bool? activo,
    Value<String?> descripcion = const Value.absent(),
    Value<String?> fotoUrl = const Value.absent(),
    Value<String?> fotoUrlWeb = const Value.absent(),
    Value<String?> fotoThumbUrl = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<String?> categoryNombre = const Value.absent(),
    Value<int?> brandId = const Value.absent(),
    Value<String?> brandNombre = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    tipo: tipo.present ? tipo.value : this.tipo,
    precio: precio ?? this.precio,
    stock: stock ?? this.stock,
    activo: activo ?? this.activo,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
    fotoUrlWeb: fotoUrlWeb.present ? fotoUrlWeb.value : this.fotoUrlWeb,
    fotoThumbUrl: fotoThumbUrl.present ? fotoThumbUrl.value : this.fotoThumbUrl,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryNombre: categoryNombre.present
        ? categoryNombre.value
        : this.categoryNombre,
    brandId: brandId.present ? brandId.value : this.brandId,
    brandNombre: brandNombre.present ? brandNombre.value : this.brandNombre,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      precio: data.precio.present ? data.precio.value : this.precio,
      stock: data.stock.present ? data.stock.value : this.stock,
      activo: data.activo.present ? data.activo.value : this.activo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      fotoUrlWeb: data.fotoUrlWeb.present
          ? data.fotoUrlWeb.value
          : this.fotoUrlWeb,
      fotoThumbUrl: data.fotoThumbUrl.present
          ? data.fotoThumbUrl.value
          : this.fotoThumbUrl,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryNombre: data.categoryNombre.present
          ? data.categoryNombre.value
          : this.categoryNombre,
      brandId: data.brandId.present ? data.brandId.value : this.brandId,
      brandNombre: data.brandNombre.present
          ? data.brandNombre.value
          : this.brandNombre,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('precio: $precio, ')
          ..write('stock: $stock, ')
          ..write('activo: $activo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('fotoUrlWeb: $fotoUrlWeb, ')
          ..write('fotoThumbUrl: $fotoThumbUrl, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryNombre: $categoryNombre, ')
          ..write('brandId: $brandId, ')
          ..write('brandNombre: $brandNombre, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    nombre,
    tipo,
    precio,
    stock,
    activo,
    descripcion,
    fotoUrl,
    fotoUrlWeb,
    fotoThumbUrl,
    categoryId,
    categoryNombre,
    brandId,
    brandNombre,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.precio == this.precio &&
          other.stock == this.stock &&
          other.activo == this.activo &&
          other.descripcion == this.descripcion &&
          other.fotoUrl == this.fotoUrl &&
          other.fotoUrlWeb == this.fotoUrlWeb &&
          other.fotoThumbUrl == this.fotoThumbUrl &&
          other.categoryId == this.categoryId &&
          other.categoryNombre == this.categoryNombre &&
          other.brandId == this.brandId &&
          other.brandNombre == this.brandNombre &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<int?> tipo;
  final Value<double> precio;
  final Value<double> stock;
  final Value<bool> activo;
  final Value<String?> descripcion;
  final Value<String?> fotoUrl;
  final Value<String?> fotoUrlWeb;
  final Value<String?> fotoThumbUrl;
  final Value<int?> categoryId;
  final Value<String?> categoryNombre;
  final Value<int?> brandId;
  final Value<String?> brandNombre;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.precio = const Value.absent(),
    this.stock = const Value.absent(),
    this.activo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.fotoUrlWeb = const Value.absent(),
    this.fotoThumbUrl = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryNombre = const Value.absent(),
    this.brandId = const Value.absent(),
    this.brandNombre = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    this.tipo = const Value.absent(),
    this.precio = const Value.absent(),
    this.stock = const Value.absent(),
    this.activo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.fotoUrlWeb = const Value.absent(),
    this.fotoThumbUrl = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryNombre = const Value.absent(),
    this.brandId = const Value.absent(),
    this.brandNombre = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre);
  static Insertable<ProductRow> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<int>? tipo,
    Expression<double>? precio,
    Expression<double>? stock,
    Expression<bool>? activo,
    Expression<String>? descripcion,
    Expression<String>? fotoUrl,
    Expression<String>? fotoUrlWeb,
    Expression<String>? fotoThumbUrl,
    Expression<int>? categoryId,
    Expression<String>? categoryNombre,
    Expression<int>? brandId,
    Expression<String>? brandNombre,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (precio != null) 'precio': precio,
      if (stock != null) 'stock': stock,
      if (activo != null) 'activo': activo,
      if (descripcion != null) 'descripcion': descripcion,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (fotoUrlWeb != null) 'foto_url_web': fotoUrlWeb,
      if (fotoThumbUrl != null) 'foto_thumb_url': fotoThumbUrl,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryNombre != null) 'category_nombre': categoryNombre,
      if (brandId != null) 'brand_id': brandId,
      if (brandNombre != null) 'brand_nombre': brandNombre,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<int?>? tipo,
    Value<double>? precio,
    Value<double>? stock,
    Value<bool>? activo,
    Value<String?>? descripcion,
    Value<String?>? fotoUrl,
    Value<String?>? fotoUrlWeb,
    Value<String?>? fotoThumbUrl,
    Value<int?>? categoryId,
    Value<String?>? categoryNombre,
    Value<int?>? brandId,
    Value<String?>? brandNombre,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      activo: activo ?? this.activo,
      descripcion: descripcion ?? this.descripcion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fotoUrlWeb: fotoUrlWeb ?? this.fotoUrlWeb,
      fotoThumbUrl: fotoThumbUrl ?? this.fotoThumbUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryNombre: categoryNombre ?? this.categoryNombre,
      brandId: brandId ?? this.brandId,
      brandNombre: brandNombre ?? this.brandNombre,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(tipo.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (fotoUrlWeb.present) {
      map['foto_url_web'] = Variable<String>(fotoUrlWeb.value);
    }
    if (fotoThumbUrl.present) {
      map['foto_thumb_url'] = Variable<String>(fotoThumbUrl.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryNombre.present) {
      map['category_nombre'] = Variable<String>(categoryNombre.value);
    }
    if (brandId.present) {
      map['brand_id'] = Variable<int>(brandId.value);
    }
    if (brandNombre.present) {
      map['brand_nombre'] = Variable<String>(brandNombre.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('precio: $precio, ')
          ..write('stock: $stock, ')
          ..write('activo: $activo, ')
          ..write('descripcion: $descripcion, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('fotoUrlWeb: $fotoUrlWeb, ')
          ..write('fotoThumbUrl: $fotoThumbUrl, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryNombre: $categoryNombre, ')
          ..write('brandId: $brandId, ')
          ..write('brandNombre: $brandNombre, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductCategoriesTable extends ProductCategories
    with TableInfo<$ProductCategoriesTable, ProductCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    descripcion,
    activo,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ProductCategoriesTable createAlias(String alias) {
    return $ProductCategoriesTable(attachedDatabase, alias);
  }
}

class ProductCategoryRow extends DataClass
    implements Insertable<ProductCategoryRow> {
  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const ProductCategoryRow({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ProductCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProductCategoriesCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      activo: Value(activo),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ProductCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCategoryRow(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      activo: serializer.fromJson<bool>(json['activo']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'activo': serializer.toJson<bool>(activo),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ProductCategoryRow copyWith({
    int? id,
    String? codigo,
    String? nombre,
    Value<String?> descripcion = const Value.absent(),
    bool? activo,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ProductCategoryRow(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    activo: activo ?? this.activo,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ProductCategoryRow copyWithCompanion(ProductCategoriesCompanion data) {
    return ProductCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      activo: data.activo.present ? data.activo.value : this.activo,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoryRow(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    nombre,
    descripcion,
    activo,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCategoryRow &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.activo == this.activo &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ProductCategoriesCompanion extends UpdateCompanion<ProductCategoryRow> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<bool> activo;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ProductCategoriesCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ProductCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    this.descripcion = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre);
  static Insertable<ProductCategoryRow> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<bool>? activo,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (activo != null) 'activo': activo,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ProductCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<String?>? descripcion,
    Value<bool>? activo,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ProductCategoriesCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $BrandsTable extends Brands with TableInfo<$BrandsTable, BrandRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    descripcion,
    activo,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brands';
  @override
  VerificationContext validateIntegrity(
    Insertable<BrandRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BrandRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrandRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BrandsTable createAlias(String alias) {
    return $BrandsTable(attachedDatabase, alias);
  }
}

class BrandRow extends DataClass implements Insertable<BrandRow> {
  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const BrandRow({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  BrandsCompanion toCompanion(bool nullToAbsent) {
    return BrandsCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      activo: Value(activo),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory BrandRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrandRow(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      activo: serializer.fromJson<bool>(json['activo']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'activo': serializer.toJson<bool>(activo),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  BrandRow copyWith({
    int? id,
    String? codigo,
    String? nombre,
    Value<String?> descripcion = const Value.absent(),
    bool? activo,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => BrandRow(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    activo: activo ?? this.activo,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  BrandRow copyWithCompanion(BrandsCompanion data) {
    return BrandRow(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      activo: data.activo.present ? data.activo.value : this.activo,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrandRow(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    nombre,
    descripcion,
    activo,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrandRow &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.activo == this.activo &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BrandsCompanion extends UpdateCompanion<BrandRow> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<bool> activo;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const BrandsCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  BrandsCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    this.descripcion = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre);
  static Insertable<BrandRow> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<bool>? activo,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (activo != null) 'activo': activo,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  BrandsCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<String?>? descripcion,
    Value<bool>? activo,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return BrandsCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrandsCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SucursalesTable extends Sucursales
    with TableInfo<$SucursalesTable, SucursalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SucursalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    activo,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sucursales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SucursalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SucursalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SucursalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SucursalesTable createAlias(String alias) {
    return $SucursalesTable(attachedDatabase, alias);
  }
}

class SucursalRow extends DataClass implements Insertable<SucursalRow> {
  final int id;
  final String codigo;
  final String nombre;
  final bool activo;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const SucursalRow({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.activo,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SucursalesCompanion toCompanion(bool nullToAbsent) {
    return SucursalesCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      activo: Value(activo),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SucursalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SucursalRow(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      activo: serializer.fromJson<bool>(json['activo']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'activo': serializer.toJson<bool>(activo),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SucursalRow copyWith({
    int? id,
    String? codigo,
    String? nombre,
    bool? activo,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SucursalRow(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    activo: activo ?? this.activo,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SucursalRow copyWithCompanion(SucursalesCompanion data) {
    return SucursalRow(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activo: data.activo.present ? data.activo.value : this.activo,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SucursalRow(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, codigo, nombre, activo, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SucursalRow &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.activo == this.activo &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SucursalesCompanion extends UpdateCompanion<SucursalRow> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<bool> activo;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const SucursalesCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SucursalesCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre);
  static Insertable<SucursalRow> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<bool>? activo,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (activo != null) 'activo': activo,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SucursalesCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<bool>? activo,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return SucursalesCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SucursalesCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $BodegasTable extends Bodegas with TableInfo<$BodegasTable, BodegaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodegasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sucursalIdMeta = const VerificationMeta(
    'sucursalId',
  );
  @override
  late final GeneratedColumn<int> sucursalId = GeneratedColumn<int>(
    'sucursal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sucursalId,
    codigo,
    nombre,
    activo,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bodegas';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodegaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sucursal_id')) {
      context.handle(
        _sucursalIdMeta,
        sucursalId.isAcceptableOrUnknown(data['sucursal_id']!, _sucursalIdMeta),
      );
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodegaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodegaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sucursalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sucursal_id'],
      ),
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BodegasTable createAlias(String alias) {
    return $BodegasTable(attachedDatabase, alias);
  }
}

class BodegaRow extends DataClass implements Insertable<BodegaRow> {
  final int id;
  final int? sucursalId;
  final String codigo;
  final String nombre;
  final bool activo;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const BodegaRow({
    required this.id,
    this.sucursalId,
    required this.codigo,
    required this.nombre,
    required this.activo,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sucursalId != null) {
      map['sucursal_id'] = Variable<int>(sucursalId);
    }
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  BodegasCompanion toCompanion(bool nullToAbsent) {
    return BodegasCompanion(
      id: Value(id),
      sucursalId: sucursalId == null && nullToAbsent
          ? const Value.absent()
          : Value(sucursalId),
      codigo: Value(codigo),
      nombre: Value(nombre),
      activo: Value(activo),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory BodegaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodegaRow(
      id: serializer.fromJson<int>(json['id']),
      sucursalId: serializer.fromJson<int?>(json['sucursalId']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      activo: serializer.fromJson<bool>(json['activo']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sucursalId': serializer.toJson<int?>(sucursalId),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'activo': serializer.toJson<bool>(activo),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  BodegaRow copyWith({
    int? id,
    Value<int?> sucursalId = const Value.absent(),
    String? codigo,
    String? nombre,
    bool? activo,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => BodegaRow(
    id: id ?? this.id,
    sucursalId: sucursalId.present ? sucursalId.value : this.sucursalId,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    activo: activo ?? this.activo,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  BodegaRow copyWithCompanion(BodegasCompanion data) {
    return BodegaRow(
      id: data.id.present ? data.id.value : this.id,
      sucursalId: data.sucursalId.present
          ? data.sucursalId.value
          : this.sucursalId,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activo: data.activo.present ? data.activo.value : this.activo,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodegaRow(')
          ..write('id: $id, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sucursalId, codigo, nombre, activo, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodegaRow &&
          other.id == this.id &&
          other.sucursalId == this.sucursalId &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.activo == this.activo &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BodegasCompanion extends UpdateCompanion<BodegaRow> {
  final Value<int> id;
  final Value<int?> sucursalId;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<bool> activo;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const BodegasCompanion({
    this.id = const Value.absent(),
    this.sucursalId = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  BodegasCompanion.insert({
    this.id = const Value.absent(),
    this.sucursalId = const Value.absent(),
    required String codigo,
    required String nombre,
    this.activo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre);
  static Insertable<BodegaRow> custom({
    Expression<int>? id,
    Expression<int>? sucursalId,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<bool>? activo,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sucursalId != null) 'sucursal_id': sucursalId,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (activo != null) 'activo': activo,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  BodegasCompanion copyWith({
    Value<int>? id,
    Value<int?>? sucursalId,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<bool>? activo,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return BodegasCompanion(
      id: id ?? this.id,
      sucursalId: sucursalId ?? this.sucursalId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sucursalId.present) {
      map['sucursal_id'] = Variable<int>(sucursalId.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodegasCompanion(')
          ..write('id: $id, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ExistenciasTable extends Existencias
    with TableInfo<$ExistenciasTable, ExistenciaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExistenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodegaIdMeta = const VerificationMeta(
    'bodegaId',
  );
  @override
  late final GeneratedColumn<int> bodegaId = GeneratedColumn<int>(
    'bodega_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bodegaId,
    productId,
    stock,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'existencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExistenciaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bodega_id')) {
      context.handle(
        _bodegaIdMeta,
        bodegaId.isAcceptableOrUnknown(data['bodega_id']!, _bodegaIdMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExistenciaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExistenciaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bodegaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bodega_id'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ExistenciasTable createAlias(String alias) {
    return $ExistenciasTable(attachedDatabase, alias);
  }
}

class ExistenciaRow extends DataClass implements Insertable<ExistenciaRow> {
  final int id;
  final int? bodegaId;
  final int? productId;
  final double stock;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const ExistenciaRow({
    required this.id,
    this.bodegaId,
    this.productId,
    required this.stock,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bodegaId != null) {
      map['bodega_id'] = Variable<int>(bodegaId);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['stock'] = Variable<double>(stock);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExistenciasCompanion toCompanion(bool nullToAbsent) {
    return ExistenciasCompanion(
      id: Value(id),
      bodegaId: bodegaId == null && nullToAbsent
          ? const Value.absent()
          : Value(bodegaId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      stock: Value(stock),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ExistenciaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExistenciaRow(
      id: serializer.fromJson<int>(json['id']),
      bodegaId: serializer.fromJson<int?>(json['bodegaId']),
      productId: serializer.fromJson<int?>(json['productId']),
      stock: serializer.fromJson<double>(json['stock']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bodegaId': serializer.toJson<int?>(bodegaId),
      'productId': serializer.toJson<int?>(productId),
      'stock': serializer.toJson<double>(stock),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ExistenciaRow copyWith({
    int? id,
    Value<int?> bodegaId = const Value.absent(),
    Value<int?> productId = const Value.absent(),
    double? stock,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ExistenciaRow(
    id: id ?? this.id,
    bodegaId: bodegaId.present ? bodegaId.value : this.bodegaId,
    productId: productId.present ? productId.value : this.productId,
    stock: stock ?? this.stock,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ExistenciaRow copyWithCompanion(ExistenciasCompanion data) {
    return ExistenciaRow(
      id: data.id.present ? data.id.value : this.id,
      bodegaId: data.bodegaId.present ? data.bodegaId.value : this.bodegaId,
      productId: data.productId.present ? data.productId.value : this.productId,
      stock: data.stock.present ? data.stock.value : this.stock,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExistenciaRow(')
          ..write('id: $id, ')
          ..write('bodegaId: $bodegaId, ')
          ..write('productId: $productId, ')
          ..write('stock: $stock, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bodegaId, productId, stock, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExistenciaRow &&
          other.id == this.id &&
          other.bodegaId == this.bodegaId &&
          other.productId == this.productId &&
          other.stock == this.stock &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExistenciasCompanion extends UpdateCompanion<ExistenciaRow> {
  final Value<int> id;
  final Value<int?> bodegaId;
  final Value<int?> productId;
  final Value<double> stock;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ExistenciasCompanion({
    this.id = const Value.absent(),
    this.bodegaId = const Value.absent(),
    this.productId = const Value.absent(),
    this.stock = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ExistenciasCompanion.insert({
    this.id = const Value.absent(),
    this.bodegaId = const Value.absent(),
    this.productId = const Value.absent(),
    this.stock = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  static Insertable<ExistenciaRow> custom({
    Expression<int>? id,
    Expression<int>? bodegaId,
    Expression<int>? productId,
    Expression<double>? stock,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bodegaId != null) 'bodega_id': bodegaId,
      if (productId != null) 'product_id': productId,
      if (stock != null) 'stock': stock,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ExistenciasCompanion copyWith({
    Value<int>? id,
    Value<int?>? bodegaId,
    Value<int?>? productId,
    Value<double>? stock,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ExistenciasCompanion(
      id: id ?? this.id,
      bodegaId: bodegaId ?? this.bodegaId,
      productId: productId ?? this.productId,
      stock: stock ?? this.stock,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bodegaId.present) {
      map['bodega_id'] = Variable<int>(bodegaId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExistenciasCompanion(')
          ..write('id: $id, ')
          ..write('bodegaId: $bodegaId, ')
          ..write('productId: $productId, ')
          ..write('stock: $stock, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductSucursalStocksTable extends ProductSucursalStocks
    with TableInfo<$ProductSucursalStocksTable, ProductSucursalStockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductSucursalStocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sucursalIdMeta = const VerificationMeta(
    'sucursalId',
  );
  @override
  late final GeneratedColumn<int> sucursalId = GeneratedColumn<int>(
    'sucursal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sucursalCodigoMeta = const VerificationMeta(
    'sucursalCodigo',
  );
  @override
  late final GeneratedColumn<String> sucursalCodigo = GeneratedColumn<String>(
    'sucursal_codigo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sucursalNombreMeta = const VerificationMeta(
    'sucursalNombre',
  );
  @override
  late final GeneratedColumn<String> sucursalNombre = GeneratedColumn<String>(
    'sucursal_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockTotalMeta = const VerificationMeta(
    'stockTotal',
  );
  @override
  late final GeneratedColumn<double> stockTotal = GeneratedColumn<double>(
    'stock_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    sucursalId,
    sucursalCodigo,
    sucursalNombre,
    stockTotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_sucursal_stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductSucursalStockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('sucursal_id')) {
      context.handle(
        _sucursalIdMeta,
        sucursalId.isAcceptableOrUnknown(data['sucursal_id']!, _sucursalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sucursalIdMeta);
    }
    if (data.containsKey('sucursal_codigo')) {
      context.handle(
        _sucursalCodigoMeta,
        sucursalCodigo.isAcceptableOrUnknown(
          data['sucursal_codigo']!,
          _sucursalCodigoMeta,
        ),
      );
    }
    if (data.containsKey('sucursal_nombre')) {
      context.handle(
        _sucursalNombreMeta,
        sucursalNombre.isAcceptableOrUnknown(
          data['sucursal_nombre']!,
          _sucursalNombreMeta,
        ),
      );
    }
    if (data.containsKey('stock_total')) {
      context.handle(
        _stockTotalMeta,
        stockTotal.isAcceptableOrUnknown(data['stock_total']!, _stockTotalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId, sucursalId};
  @override
  ProductSucursalStockRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductSucursalStockRow(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      sucursalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sucursal_id'],
      )!,
      sucursalCodigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sucursal_codigo'],
      ),
      sucursalNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sucursal_nombre'],
      ),
      stockTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_total'],
      )!,
    );
  }

  @override
  $ProductSucursalStocksTable createAlias(String alias) {
    return $ProductSucursalStocksTable(attachedDatabase, alias);
  }
}

class ProductSucursalStockRow extends DataClass
    implements Insertable<ProductSucursalStockRow> {
  final int productId;
  final int sucursalId;
  final String? sucursalCodigo;
  final String? sucursalNombre;
  final double stockTotal;
  const ProductSucursalStockRow({
    required this.productId,
    required this.sucursalId,
    this.sucursalCodigo,
    this.sucursalNombre,
    required this.stockTotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<int>(productId);
    map['sucursal_id'] = Variable<int>(sucursalId);
    if (!nullToAbsent || sucursalCodigo != null) {
      map['sucursal_codigo'] = Variable<String>(sucursalCodigo);
    }
    if (!nullToAbsent || sucursalNombre != null) {
      map['sucursal_nombre'] = Variable<String>(sucursalNombre);
    }
    map['stock_total'] = Variable<double>(stockTotal);
    return map;
  }

  ProductSucursalStocksCompanion toCompanion(bool nullToAbsent) {
    return ProductSucursalStocksCompanion(
      productId: Value(productId),
      sucursalId: Value(sucursalId),
      sucursalCodigo: sucursalCodigo == null && nullToAbsent
          ? const Value.absent()
          : Value(sucursalCodigo),
      sucursalNombre: sucursalNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(sucursalNombre),
      stockTotal: Value(stockTotal),
    );
  }

  factory ProductSucursalStockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductSucursalStockRow(
      productId: serializer.fromJson<int>(json['productId']),
      sucursalId: serializer.fromJson<int>(json['sucursalId']),
      sucursalCodigo: serializer.fromJson<String?>(json['sucursalCodigo']),
      sucursalNombre: serializer.fromJson<String?>(json['sucursalNombre']),
      stockTotal: serializer.fromJson<double>(json['stockTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<int>(productId),
      'sucursalId': serializer.toJson<int>(sucursalId),
      'sucursalCodigo': serializer.toJson<String?>(sucursalCodigo),
      'sucursalNombre': serializer.toJson<String?>(sucursalNombre),
      'stockTotal': serializer.toJson<double>(stockTotal),
    };
  }

  ProductSucursalStockRow copyWith({
    int? productId,
    int? sucursalId,
    Value<String?> sucursalCodigo = const Value.absent(),
    Value<String?> sucursalNombre = const Value.absent(),
    double? stockTotal,
  }) => ProductSucursalStockRow(
    productId: productId ?? this.productId,
    sucursalId: sucursalId ?? this.sucursalId,
    sucursalCodigo: sucursalCodigo.present
        ? sucursalCodigo.value
        : this.sucursalCodigo,
    sucursalNombre: sucursalNombre.present
        ? sucursalNombre.value
        : this.sucursalNombre,
    stockTotal: stockTotal ?? this.stockTotal,
  );
  ProductSucursalStockRow copyWithCompanion(
    ProductSucursalStocksCompanion data,
  ) {
    return ProductSucursalStockRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      sucursalId: data.sucursalId.present
          ? data.sucursalId.value
          : this.sucursalId,
      sucursalCodigo: data.sucursalCodigo.present
          ? data.sucursalCodigo.value
          : this.sucursalCodigo,
      sucursalNombre: data.sucursalNombre.present
          ? data.sucursalNombre.value
          : this.sucursalNombre,
      stockTotal: data.stockTotal.present
          ? data.stockTotal.value
          : this.stockTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductSucursalStockRow(')
          ..write('productId: $productId, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('sucursalCodigo: $sucursalCodigo, ')
          ..write('sucursalNombre: $sucursalNombre, ')
          ..write('stockTotal: $stockTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productId,
    sucursalId,
    sucursalCodigo,
    sucursalNombre,
    stockTotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductSucursalStockRow &&
          other.productId == this.productId &&
          other.sucursalId == this.sucursalId &&
          other.sucursalCodigo == this.sucursalCodigo &&
          other.sucursalNombre == this.sucursalNombre &&
          other.stockTotal == this.stockTotal);
}

class ProductSucursalStocksCompanion
    extends UpdateCompanion<ProductSucursalStockRow> {
  final Value<int> productId;
  final Value<int> sucursalId;
  final Value<String?> sucursalCodigo;
  final Value<String?> sucursalNombre;
  final Value<double> stockTotal;
  final Value<int> rowid;
  const ProductSucursalStocksCompanion({
    this.productId = const Value.absent(),
    this.sucursalId = const Value.absent(),
    this.sucursalCodigo = const Value.absent(),
    this.sucursalNombre = const Value.absent(),
    this.stockTotal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductSucursalStocksCompanion.insert({
    required int productId,
    required int sucursalId,
    this.sucursalCodigo = const Value.absent(),
    this.sucursalNombre = const Value.absent(),
    this.stockTotal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       sucursalId = Value(sucursalId);
  static Insertable<ProductSucursalStockRow> custom({
    Expression<int>? productId,
    Expression<int>? sucursalId,
    Expression<String>? sucursalCodigo,
    Expression<String>? sucursalNombre,
    Expression<double>? stockTotal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (sucursalId != null) 'sucursal_id': sucursalId,
      if (sucursalCodigo != null) 'sucursal_codigo': sucursalCodigo,
      if (sucursalNombre != null) 'sucursal_nombre': sucursalNombre,
      if (stockTotal != null) 'stock_total': stockTotal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductSucursalStocksCompanion copyWith({
    Value<int>? productId,
    Value<int>? sucursalId,
    Value<String?>? sucursalCodigo,
    Value<String?>? sucursalNombre,
    Value<double>? stockTotal,
    Value<int>? rowid,
  }) {
    return ProductSucursalStocksCompanion(
      productId: productId ?? this.productId,
      sucursalId: sucursalId ?? this.sucursalId,
      sucursalCodigo: sucursalCodigo ?? this.sucursalCodigo,
      sucursalNombre: sucursalNombre ?? this.sucursalNombre,
      stockTotal: stockTotal ?? this.stockTotal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (sucursalId.present) {
      map['sucursal_id'] = Variable<int>(sucursalId.value);
    }
    if (sucursalCodigo.present) {
      map['sucursal_codigo'] = Variable<String>(sucursalCodigo.value);
    }
    if (sucursalNombre.present) {
      map['sucursal_nombre'] = Variable<String>(sucursalNombre.value);
    }
    if (stockTotal.present) {
      map['stock_total'] = Variable<double>(stockTotal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductSucursalStocksCompanion(')
          ..write('productId: $productId, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('sucursalCodigo: $sucursalCodigo, ')
          ..write('sucursalNombre: $sucursalNombre, ')
          ..write('stockTotal: $stockTotal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductCategoriesTable productCategories =
      $ProductCategoriesTable(this);
  late final $BrandsTable brands = $BrandsTable(this);
  late final $SucursalesTable sucursales = $SucursalesTable(this);
  late final $BodegasTable bodegas = $BodegasTable(this);
  late final $ExistenciasTable existencias = $ExistenciasTable(this);
  late final $ProductSucursalStocksTable productSucursalStocks =
      $ProductSucursalStocksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    productCategories,
    brands,
    sucursales,
    bodegas,
    existencias,
    productSucursalStocks,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      Value<int?> tipo,
      Value<double> precio,
      Value<double> stock,
      Value<bool> activo,
      Value<String?> descripcion,
      Value<String?> fotoUrl,
      Value<String?> fotoUrlWeb,
      Value<String?> fotoThumbUrl,
      Value<int?> categoryId,
      Value<String?> categoryNombre,
      Value<int?> brandId,
      Value<String?> brandNombre,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<int?> tipo,
      Value<double> precio,
      Value<double> stock,
      Value<bool> activo,
      Value<String?> descripcion,
      Value<String?> fotoUrl,
      Value<String?> fotoUrlWeb,
      Value<String?> fotoThumbUrl,
      Value<int?> categoryId,
      Value<String?> categoryNombre,
      Value<int?> brandId,
      Value<String?> brandNombre,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$ProductsTableFilterComposer extends Composer<_$AppDb, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrlWeb => $composableBuilder(
    column: $table.fotoUrlWeb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoThumbUrl => $composableBuilder(
    column: $table.fotoThumbUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryNombre => $composableBuilder(
    column: $table.categoryNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brandId => $composableBuilder(
    column: $table.brandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandNombre => $composableBuilder(
    column: $table.brandNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDb, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrlWeb => $composableBuilder(
    column: $table.fotoUrlWeb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoThumbUrl => $composableBuilder(
    column: $table.fotoThumbUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryNombre => $composableBuilder(
    column: $table.categoryNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brandId => $composableBuilder(
    column: $table.brandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandNombre => $composableBuilder(
    column: $table.brandNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDb, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<String> get fotoUrlWeb => $composableBuilder(
    column: $table.fotoUrlWeb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoThumbUrl => $composableBuilder(
    column: $table.fotoThumbUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryNombre => $composableBuilder(
    column: $table.categoryNombre,
    builder: (column) => column,
  );

  GeneratedColumn<int> get brandId =>
      $composableBuilder(column: $table.brandId, builder: (column) => column);

  GeneratedColumn<String> get brandNombre => $composableBuilder(
    column: $table.brandNombre,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, BaseReferences<_$AppDb, $ProductsTable, ProductRow>),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDb db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int?> tipo = const Value.absent(),
                Value<double> precio = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String?> fotoUrlWeb = const Value.absent(),
                Value<String?> fotoThumbUrl = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryNombre = const Value.absent(),
                Value<int?> brandId = const Value.absent(),
                Value<String?> brandNombre = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                tipo: tipo,
                precio: precio,
                stock: stock,
                activo: activo,
                descripcion: descripcion,
                fotoUrl: fotoUrl,
                fotoUrlWeb: fotoUrlWeb,
                fotoThumbUrl: fotoThumbUrl,
                categoryId: categoryId,
                categoryNombre: categoryNombre,
                brandId: brandId,
                brandNombre: brandNombre,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<int?> tipo = const Value.absent(),
                Value<double> precio = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String?> fotoUrlWeb = const Value.absent(),
                Value<String?> fotoThumbUrl = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryNombre = const Value.absent(),
                Value<int?> brandId = const Value.absent(),
                Value<String?> brandNombre = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                tipo: tipo,
                precio: precio,
                stock: stock,
                activo: activo,
                descripcion: descripcion,
                fotoUrl: fotoUrl,
                fotoUrlWeb: fotoUrlWeb,
                fotoThumbUrl: fotoThumbUrl,
                categoryId: categoryId,
                categoryNombre: categoryNombre,
                brandId: brandId,
                brandNombre: brandNombre,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDb, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$ProductCategoriesTableCreateCompanionBuilder =
    ProductCategoriesCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      Value<String?> descripcion,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ProductCategoriesTableUpdateCompanionBuilder =
    ProductCategoriesCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<String?> descripcion,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$ProductCategoriesTableFilterComposer
    extends Composer<_$AppDb, $ProductCategoriesTable> {
  $$ProductCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductCategoriesTableOrderingComposer
    extends Composer<_$AppDb, $ProductCategoriesTable> {
  $$ProductCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductCategoriesTableAnnotationComposer
    extends Composer<_$AppDb, $ProductCategoriesTable> {
  $$ProductCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ProductCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProductCategoriesTable,
          ProductCategoryRow,
          $$ProductCategoriesTableFilterComposer,
          $$ProductCategoriesTableOrderingComposer,
          $$ProductCategoriesTableAnnotationComposer,
          $$ProductCategoriesTableCreateCompanionBuilder,
          $$ProductCategoriesTableUpdateCompanionBuilder,
          (
            ProductCategoryRow,
            BaseReferences<
              _$AppDb,
              $ProductCategoriesTable,
              ProductCategoryRow
            >,
          ),
          ProductCategoryRow,
          PrefetchHooks Function()
        > {
  $$ProductCategoriesTableTableManager(
    _$AppDb db,
    $ProductCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductCategoriesCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<String?> descripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductCategoriesCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProductCategoriesTable,
      ProductCategoryRow,
      $$ProductCategoriesTableFilterComposer,
      $$ProductCategoriesTableOrderingComposer,
      $$ProductCategoriesTableAnnotationComposer,
      $$ProductCategoriesTableCreateCompanionBuilder,
      $$ProductCategoriesTableUpdateCompanionBuilder,
      (
        ProductCategoryRow,
        BaseReferences<_$AppDb, $ProductCategoriesTable, ProductCategoryRow>,
      ),
      ProductCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$BrandsTableCreateCompanionBuilder =
    BrandsCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      Value<String?> descripcion,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$BrandsTableUpdateCompanionBuilder =
    BrandsCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<String?> descripcion,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$BrandsTableFilterComposer extends Composer<_$AppDb, $BrandsTable> {
  $$BrandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrandsTableOrderingComposer extends Composer<_$AppDb, $BrandsTable> {
  $$BrandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrandsTableAnnotationComposer extends Composer<_$AppDb, $BrandsTable> {
  $$BrandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$BrandsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BrandsTable,
          BrandRow,
          $$BrandsTableFilterComposer,
          $$BrandsTableOrderingComposer,
          $$BrandsTableAnnotationComposer,
          $$BrandsTableCreateCompanionBuilder,
          $$BrandsTableUpdateCompanionBuilder,
          (BrandRow, BaseReferences<_$AppDb, $BrandsTable, BrandRow>),
          BrandRow,
          PrefetchHooks Function()
        > {
  $$BrandsTableTableManager(_$AppDb db, $BrandsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BrandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BrandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BrandsCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<String?> descripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BrandsCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BrandsTable,
      BrandRow,
      $$BrandsTableFilterComposer,
      $$BrandsTableOrderingComposer,
      $$BrandsTableAnnotationComposer,
      $$BrandsTableCreateCompanionBuilder,
      $$BrandsTableUpdateCompanionBuilder,
      (BrandRow, BaseReferences<_$AppDb, $BrandsTable, BrandRow>),
      BrandRow,
      PrefetchHooks Function()
    >;
typedef $$SucursalesTableCreateCompanionBuilder =
    SucursalesCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$SucursalesTableUpdateCompanionBuilder =
    SucursalesCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$SucursalesTableFilterComposer
    extends Composer<_$AppDb, $SucursalesTable> {
  $$SucursalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SucursalesTableOrderingComposer
    extends Composer<_$AppDb, $SucursalesTable> {
  $$SucursalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SucursalesTableAnnotationComposer
    extends Composer<_$AppDb, $SucursalesTable> {
  $$SucursalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SucursalesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SucursalesTable,
          SucursalRow,
          $$SucursalesTableFilterComposer,
          $$SucursalesTableOrderingComposer,
          $$SucursalesTableAnnotationComposer,
          $$SucursalesTableCreateCompanionBuilder,
          $$SucursalesTableUpdateCompanionBuilder,
          (SucursalRow, BaseReferences<_$AppDb, $SucursalesTable, SucursalRow>),
          SucursalRow,
          PrefetchHooks Function()
        > {
  $$SucursalesTableTableManager(_$AppDb db, $SucursalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SucursalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SucursalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SucursalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SucursalesCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SucursalesCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SucursalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SucursalesTable,
      SucursalRow,
      $$SucursalesTableFilterComposer,
      $$SucursalesTableOrderingComposer,
      $$SucursalesTableAnnotationComposer,
      $$SucursalesTableCreateCompanionBuilder,
      $$SucursalesTableUpdateCompanionBuilder,
      (SucursalRow, BaseReferences<_$AppDb, $SucursalesTable, SucursalRow>),
      SucursalRow,
      PrefetchHooks Function()
    >;
typedef $$BodegasTableCreateCompanionBuilder =
    BodegasCompanion Function({
      Value<int> id,
      Value<int?> sucursalId,
      required String codigo,
      required String nombre,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$BodegasTableUpdateCompanionBuilder =
    BodegasCompanion Function({
      Value<int> id,
      Value<int?> sucursalId,
      Value<String> codigo,
      Value<String> nombre,
      Value<bool> activo,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$BodegasTableFilterComposer extends Composer<_$AppDb, $BodegasTable> {
  $$BodegasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodegasTableOrderingComposer extends Composer<_$AppDb, $BodegasTable> {
  $$BodegasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodegasTableAnnotationComposer
    extends Composer<_$AppDb, $BodegasTable> {
  $$BodegasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$BodegasTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BodegasTable,
          BodegaRow,
          $$BodegasTableFilterComposer,
          $$BodegasTableOrderingComposer,
          $$BodegasTableAnnotationComposer,
          $$BodegasTableCreateCompanionBuilder,
          $$BodegasTableUpdateCompanionBuilder,
          (BodegaRow, BaseReferences<_$AppDb, $BodegasTable, BodegaRow>),
          BodegaRow,
          PrefetchHooks Function()
        > {
  $$BodegasTableTableManager(_$AppDb db, $BodegasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodegasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodegasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodegasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sucursalId = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BodegasCompanion(
                id: id,
                sucursalId: sucursalId,
                codigo: codigo,
                nombre: nombre,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sucursalId = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<bool> activo = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BodegasCompanion.insert(
                id: id,
                sucursalId: sucursalId,
                codigo: codigo,
                nombre: nombre,
                activo: activo,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodegasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BodegasTable,
      BodegaRow,
      $$BodegasTableFilterComposer,
      $$BodegasTableOrderingComposer,
      $$BodegasTableAnnotationComposer,
      $$BodegasTableCreateCompanionBuilder,
      $$BodegasTableUpdateCompanionBuilder,
      (BodegaRow, BaseReferences<_$AppDb, $BodegasTable, BodegaRow>),
      BodegaRow,
      PrefetchHooks Function()
    >;
typedef $$ExistenciasTableCreateCompanionBuilder =
    ExistenciasCompanion Function({
      Value<int> id,
      Value<int?> bodegaId,
      Value<int?> productId,
      Value<double> stock,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ExistenciasTableUpdateCompanionBuilder =
    ExistenciasCompanion Function({
      Value<int> id,
      Value<int?> bodegaId,
      Value<int?> productId,
      Value<double> stock,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$ExistenciasTableFilterComposer
    extends Composer<_$AppDb, $ExistenciasTable> {
  $$ExistenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bodegaId => $composableBuilder(
    column: $table.bodegaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExistenciasTableOrderingComposer
    extends Composer<_$AppDb, $ExistenciasTable> {
  $$ExistenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bodegaId => $composableBuilder(
    column: $table.bodegaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExistenciasTableAnnotationComposer
    extends Composer<_$AppDb, $ExistenciasTable> {
  $$ExistenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bodegaId =>
      $composableBuilder(column: $table.bodegaId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ExistenciasTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExistenciasTable,
          ExistenciaRow,
          $$ExistenciasTableFilterComposer,
          $$ExistenciasTableOrderingComposer,
          $$ExistenciasTableAnnotationComposer,
          $$ExistenciasTableCreateCompanionBuilder,
          $$ExistenciasTableUpdateCompanionBuilder,
          (
            ExistenciaRow,
            BaseReferences<_$AppDb, $ExistenciasTable, ExistenciaRow>,
          ),
          ExistenciaRow,
          PrefetchHooks Function()
        > {
  $$ExistenciasTableTableManager(_$AppDb db, $ExistenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExistenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExistenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExistenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bodegaId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExistenciasCompanion(
                id: id,
                bodegaId: bodegaId,
                productId: productId,
                stock: stock,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bodegaId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExistenciasCompanion.insert(
                id: id,
                bodegaId: bodegaId,
                productId: productId,
                stock: stock,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExistenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExistenciasTable,
      ExistenciaRow,
      $$ExistenciasTableFilterComposer,
      $$ExistenciasTableOrderingComposer,
      $$ExistenciasTableAnnotationComposer,
      $$ExistenciasTableCreateCompanionBuilder,
      $$ExistenciasTableUpdateCompanionBuilder,
      (
        ExistenciaRow,
        BaseReferences<_$AppDb, $ExistenciasTable, ExistenciaRow>,
      ),
      ExistenciaRow,
      PrefetchHooks Function()
    >;
typedef $$ProductSucursalStocksTableCreateCompanionBuilder =
    ProductSucursalStocksCompanion Function({
      required int productId,
      required int sucursalId,
      Value<String?> sucursalCodigo,
      Value<String?> sucursalNombre,
      Value<double> stockTotal,
      Value<int> rowid,
    });
typedef $$ProductSucursalStocksTableUpdateCompanionBuilder =
    ProductSucursalStocksCompanion Function({
      Value<int> productId,
      Value<int> sucursalId,
      Value<String?> sucursalCodigo,
      Value<String?> sucursalNombre,
      Value<double> stockTotal,
      Value<int> rowid,
    });

class $$ProductSucursalStocksTableFilterComposer
    extends Composer<_$AppDb, $ProductSucursalStocksTable> {
  $$ProductSucursalStocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sucursalCodigo => $composableBuilder(
    column: $table.sucursalCodigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sucursalNombre => $composableBuilder(
    column: $table.sucursalNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockTotal => $composableBuilder(
    column: $table.stockTotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductSucursalStocksTableOrderingComposer
    extends Composer<_$AppDb, $ProductSucursalStocksTable> {
  $$ProductSucursalStocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sucursalCodigo => $composableBuilder(
    column: $table.sucursalCodigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sucursalNombre => $composableBuilder(
    column: $table.sucursalNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockTotal => $composableBuilder(
    column: $table.stockTotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductSucursalStocksTableAnnotationComposer
    extends Composer<_$AppDb, $ProductSucursalStocksTable> {
  $$ProductSucursalStocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sucursalCodigo => $composableBuilder(
    column: $table.sucursalCodigo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sucursalNombre => $composableBuilder(
    column: $table.sucursalNombre,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockTotal => $composableBuilder(
    column: $table.stockTotal,
    builder: (column) => column,
  );
}

class $$ProductSucursalStocksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProductSucursalStocksTable,
          ProductSucursalStockRow,
          $$ProductSucursalStocksTableFilterComposer,
          $$ProductSucursalStocksTableOrderingComposer,
          $$ProductSucursalStocksTableAnnotationComposer,
          $$ProductSucursalStocksTableCreateCompanionBuilder,
          $$ProductSucursalStocksTableUpdateCompanionBuilder,
          (
            ProductSucursalStockRow,
            BaseReferences<
              _$AppDb,
              $ProductSucursalStocksTable,
              ProductSucursalStockRow
            >,
          ),
          ProductSucursalStockRow,
          PrefetchHooks Function()
        > {
  $$ProductSucursalStocksTableTableManager(
    _$AppDb db,
    $ProductSucursalStocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductSucursalStocksTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductSucursalStocksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductSucursalStocksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> productId = const Value.absent(),
                Value<int> sucursalId = const Value.absent(),
                Value<String?> sucursalCodigo = const Value.absent(),
                Value<String?> sucursalNombre = const Value.absent(),
                Value<double> stockTotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSucursalStocksCompanion(
                productId: productId,
                sucursalId: sucursalId,
                sucursalCodigo: sucursalCodigo,
                sucursalNombre: sucursalNombre,
                stockTotal: stockTotal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int productId,
                required int sucursalId,
                Value<String?> sucursalCodigo = const Value.absent(),
                Value<String?> sucursalNombre = const Value.absent(),
                Value<double> stockTotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSucursalStocksCompanion.insert(
                productId: productId,
                sucursalId: sucursalId,
                sucursalCodigo: sucursalCodigo,
                sucursalNombre: sucursalNombre,
                stockTotal: stockTotal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductSucursalStocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProductSucursalStocksTable,
      ProductSucursalStockRow,
      $$ProductSucursalStocksTableFilterComposer,
      $$ProductSucursalStocksTableOrderingComposer,
      $$ProductSucursalStocksTableAnnotationComposer,
      $$ProductSucursalStocksTableCreateCompanionBuilder,
      $$ProductSucursalStocksTableUpdateCompanionBuilder,
      (
        ProductSucursalStockRow,
        BaseReferences<
          _$AppDb,
          $ProductSucursalStocksTable,
          ProductSucursalStockRow
        >,
      ),
      ProductSucursalStockRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductCategoriesTableTableManager get productCategories =>
      $$ProductCategoriesTableTableManager(_db, _db.productCategories);
  $$BrandsTableTableManager get brands =>
      $$BrandsTableTableManager(_db, _db.brands);
  $$SucursalesTableTableManager get sucursales =>
      $$SucursalesTableTableManager(_db, _db.sucursales);
  $$BodegasTableTableManager get bodegas =>
      $$BodegasTableTableManager(_db, _db.bodegas);
  $$ExistenciasTableTableManager get existencias =>
      $$ExistenciasTableTableManager(_db, _db.existencias);
  $$ProductSucursalStocksTableTableManager get productSucursalStocks =>
      $$ProductSucursalStocksTableTableManager(_db, _db.productSucursalStocks);
}
