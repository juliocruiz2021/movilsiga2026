import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

@DataClassName('PendingOrderRow')
class PendingOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientRequestId => text().nullable().unique()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get remoteOrderId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
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
    PendingOrders,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(pendingOrders);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'movilsiga.sqlite',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
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

  Future<int> enqueuePendingOrder({
    String? clientRequestId,
    required String payloadJson,
  }) {
    final now = DateTime.now();
    return into(pendingOrders).insert(
      PendingOrdersCompanion.insert(
        clientRequestId: Value(clientRequestId),
        payloadJson: payloadJson,
        status: const Value('pending'),
        attempts: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<PendingOrderRow>> fetchPendingOrders({int limit = 100}) {
    return (select(pendingOrders)
          ..where((tbl) => tbl.status.isNotValue('synced'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)])
          ..limit(limit))
        .get();
  }

  Future<void> markPendingOrderSending(int id) async {
    final row = await (select(pendingOrders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;

    await (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        status: const Value('sending'),
        attempts: Value(row.attempts + 1),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markPendingOrderFailed(int id, String error) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        status: const Value('failed'),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markPendingOrderSynced(int id, {int? remoteOrderId}) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        status: const Value('synced'),
        remoteOrderId: Value(remoteOrderId),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetSendingPendingOrders() {
    return (update(pendingOrders)..where((t) => t.status.equals('sending')))
        .write(
          PendingOrdersCompanion(
            status: const Value('pending'),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<int> countUnsyncedPendingOrders() async {
    final countExpr = pendingOrders.id.count();
    final row = await (selectOnly(pendingOrders)
          ..addColumns([countExpr])
          ..where(pendingOrders.status.isNotValue('synced')))
        .getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> countProducts() async {
    final count = products.id.count();
    final row = await (selectOnly(products)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<SyncStats> fetchSyncStats() async {
    final productsStats = await _tableStats(
      table: products,
      id: products.id,
      updatedAt: products.updatedAt,
    );
    final categoriesStats = await _tableStats(
      table: productCategories,
      id: productCategories.id,
      updatedAt: productCategories.updatedAt,
    );
    final brandsStats = await _tableStats(
      table: brands,
      id: brands.id,
      updatedAt: brands.updatedAt,
    );
    final sucursalesStats = await _tableStats(
      table: sucursales,
      id: sucursales.id,
      updatedAt: sucursales.updatedAt,
    );
    final bodegasStats = await _tableStats(
      table: bodegas,
      id: bodegas.id,
      updatedAt: bodegas.updatedAt,
    );
    final existenciasStats = await _tableStats(
      table: existencias,
      id: existencias.id,
      updatedAt: existencias.updatedAt,
    );

    return SyncStats(
      products: productsStats,
      categories: categoriesStats,
      brands: brandsStats,
      sucursales: sucursalesStats,
      bodegas: bodegasStats,
      existencias: existenciasStats,
    );
  }

  Future<TableSyncStats> _tableStats({
    required TableInfo<Table, Object?> table,
    required IntColumn id,
    required DateTimeColumn updatedAt,
  }) async {
    final countExpr = id.count();
    final maxExpr = updatedAt.max();
    final row = await (selectOnly(table)
          ..addColumns([countExpr, maxExpr]))
        .getSingle();
    final count = row.read(countExpr) ?? 0;
    final maxDate = row.read(maxExpr);
    return TableSyncStats(count: count, lastUpdatedAt: maxDate);
  }
}

class Producto {
  const Producto({required this.row, required this.total});

  final ProductRow row;
  final int total;
}

class SyncStats {
  const SyncStats({
    required this.products,
    required this.categories,
    required this.brands,
    required this.sucursales,
    required this.bodegas,
    required this.existencias,
  });

  final TableSyncStats products;
  final TableSyncStats categories;
  final TableSyncStats brands;
  final TableSyncStats sucursales;
  final TableSyncStats bodegas;
  final TableSyncStats existencias;
}

class TableSyncStats {
  const TableSyncStats({
    required this.count,
    required this.lastUpdatedAt,
  });

  final int count;
  final DateTime? lastUpdatedAt;
}
