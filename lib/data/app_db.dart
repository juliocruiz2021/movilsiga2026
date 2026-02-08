import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

@DataClassName('ProductRow')
class Products extends Table {
  IntColumn get id => integer()();
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  IntColumn get tipo => integer().nullable()();
  RealColumn get precio => real().withDefault(const Constant(0))();
  RealColumn get stock => real().withDefault(const Constant(0))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  TextColumn get descripcion => text().nullable()();
  TextColumn get fotoUrl => text().nullable()();
  TextColumn get fotoUrlWeb => text().nullable()();
  TextColumn get fotoThumbUrl => text().nullable()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get categoryNombre => text().nullable()();
  IntColumn get brandId => integer().nullable()();
  TextColumn get brandNombre => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductCategoryRow')
class ProductCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BrandRow')
class Brands extends Table {
  IntColumn get id => integer()();
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SucursalRow')
class Sucursales extends Table {
  IntColumn get id => integer()();
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BodegaRow')
class Bodegas extends Table {
  IntColumn get id => integer()();
  IntColumn get sucursalId => integer().nullable()();
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExistenciaRow')
class Existencias extends Table {
  IntColumn get id => integer()();
  IntColumn get bodegaId => integer().nullable()();
  IntColumn get productId => integer().nullable()();
  RealColumn get stock => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductSucursalStockRow')
class ProductSucursalStocks extends Table {
  IntColumn get productId => integer()();
  IntColumn get sucursalId => integer()();
  TextColumn get sucursalCodigo => text().nullable()();
  TextColumn get sucursalNombre => text().nullable()();
  RealColumn get stockTotal => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {productId, sucursalId};
}

@DriftDatabase(
  tables: [
    Products,
    ProductCategories,
    Brands,
    Sucursales,
    Bodegas,
    Existencias,
    ProductSucursalStocks,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'movilsiga.sqlite',
      native: const DriftNativeOptions(
        databaseDirectory: AppDatabaseDirectory.documents,
      ),
    );
  }

  Future<void> upsertProducts(List<ProductsCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(products, items);
    });
  }

  Future<void> upsertCategories(List<ProductCategoriesCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(productCategories, items);
    });
  }

  Future<void> upsertBrands(List<BrandsCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(brands, items);
    });
  }

  Future<void> upsertSucursales(List<SucursalesCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(sucursales, items);
    });
  }

  Future<void> upsertBodegas(List<BodegasCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(bodegas, items);
    });
  }

  Future<void> upsertExistencias(List<ExistenciasCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(existencias, items);
    });
  }

  Future<void> replaceProductSucursalStocks(
    int productId,
    List<ProductSucursalStocksCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(productSucursalStocks)
            ..where((tbl) => tbl.productId.equals(productId)))
          .go();
      if (items.isNotEmpty) {
        await batch((b) {
          b.insertAllOnConflictUpdate(productSucursalStocks, items);
        });
      }
    });
  }

  Future<List<ProductCategoryRow>> fetchCategories() {
    return (select(productCategories)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .get();
  }

  Future<List<Producto>> fetchProductsPage({
    required int page,
    required int perPage,
    String? search,
    int? categoryId,
    int? brandId,
    int? tipo,
    bool? onlyActive,
  }) async {
    final query = select(products)
      ..where((tbl) => tbl.deletedAt.isNull());

    if (search != null && search.isNotEmpty) {
      final term = '%${search.replaceAll('%', '\\%')}%';
      query.where((tbl) =>
          tbl.nombre.like(term) | tbl.codigo.like(term));
    }
    if (categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }
    if (brandId != null) {
      query.where((tbl) => tbl.brandId.equals(brandId));
    }
    if (tipo != null) {
      query.where((tbl) => tbl.tipo.equals(tipo));
    }
    if (onlyActive != null) {
      query.where((tbl) => tbl.activo.equals(onlyActive));
    }

    final total = await query.get().then((rows) => rows.length);
    final offset = (page - 1) * perPage;
    final rows = await (query
          ..orderBy([(t) => OrderingTerm(expression: t.id)])
          ..limit(perPage, offset: offset))
        .get();
    return rows
        .map((row) => Producto(row: row, total: total))
        .toList();
  }

  Future<List<ProductSucursalStockRow>> fetchProductStocks(int productId) {
    return (select(productSucursalStocks)
          ..where((tbl) => tbl.productId.equals(productId)))
        .get();
  }
}

class Producto {
  const Producto({required this.row, required this.total});

  final ProductRow row;
  final int total;
}
