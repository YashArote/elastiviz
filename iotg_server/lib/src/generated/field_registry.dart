/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// Raw ECS field discovered in a specific dataset.
abstract class FieldRegistry
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FieldRegistry._({
    this.id,
    required this.dataset,
    required this.fieldPath,
    required this.fieldType,
    required this.isNumeric,
    required this.isTimeseries,
  });

  factory FieldRegistry({
    int? id,
    required String dataset,
    required String fieldPath,
    required String fieldType,
    required bool isNumeric,
    required bool isTimeseries,
  }) = _FieldRegistryImpl;

  factory FieldRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FieldRegistry(
      id: jsonSerialization['id'] as int?,
      dataset: jsonSerialization['dataset'] as String,
      fieldPath: jsonSerialization['fieldPath'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      isNumeric: jsonSerialization['isNumeric'] as bool,
      isTimeseries: jsonSerialization['isTimeseries'] as bool,
    );
  }

  static final t = FieldRegistryTable();

  static const db = FieldRegistryRepository._();

  @override
  int? id;

  /// The dataset this field belongs to (e.g. "kubernetes.container")
  String dataset;

  /// The full ECS field path (e.g. "kubernetes.container.cpu.usage.node.pct")
  String fieldPath;

  /// Elasticsearch data type (double, long, keyword, date, etc.)
  String fieldType;

  /// Whether this field is numeric (double / long / float)
  bool isNumeric;

  /// Whether this field is suitable for timeseries charting
  bool isTimeseries;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FieldRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FieldRegistry copyWith({
    int? id,
    String? dataset,
    String? fieldPath,
    String? fieldType,
    bool? isNumeric,
    bool? isTimeseries,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldRegistry',
      if (id != null) 'id': id,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'fieldType': fieldType,
      'isNumeric': isNumeric,
      'isTimeseries': isTimeseries,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FieldRegistry',
      if (id != null) 'id': id,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'fieldType': fieldType,
      'isNumeric': isNumeric,
      'isTimeseries': isTimeseries,
    };
  }

  static FieldRegistryInclude include() {
    return FieldRegistryInclude._();
  }

  static FieldRegistryIncludeList includeList({
    _i1.WhereExpressionBuilder<FieldRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldRegistryTable>? orderByList,
    FieldRegistryInclude? include,
  }) {
    return FieldRegistryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldRegistry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FieldRegistry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FieldRegistryImpl extends FieldRegistry {
  _FieldRegistryImpl({
    int? id,
    required String dataset,
    required String fieldPath,
    required String fieldType,
    required bool isNumeric,
    required bool isTimeseries,
  }) : super._(
         id: id,
         dataset: dataset,
         fieldPath: fieldPath,
         fieldType: fieldType,
         isNumeric: isNumeric,
         isTimeseries: isTimeseries,
       );

  /// Returns a shallow copy of this [FieldRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FieldRegistry copyWith({
    Object? id = _Undefined,
    String? dataset,
    String? fieldPath,
    String? fieldType,
    bool? isNumeric,
    bool? isTimeseries,
  }) {
    return FieldRegistry(
      id: id is int? ? id : this.id,
      dataset: dataset ?? this.dataset,
      fieldPath: fieldPath ?? this.fieldPath,
      fieldType: fieldType ?? this.fieldType,
      isNumeric: isNumeric ?? this.isNumeric,
      isTimeseries: isTimeseries ?? this.isTimeseries,
    );
  }
}

class FieldRegistryUpdateTable extends _i1.UpdateTable<FieldRegistryTable> {
  FieldRegistryUpdateTable(super.table);

  _i1.ColumnValue<String, String> dataset(String value) => _i1.ColumnValue(
    table.dataset,
    value,
  );

  _i1.ColumnValue<String, String> fieldPath(String value) => _i1.ColumnValue(
    table.fieldPath,
    value,
  );

  _i1.ColumnValue<String, String> fieldType(String value) => _i1.ColumnValue(
    table.fieldType,
    value,
  );

  _i1.ColumnValue<bool, bool> isNumeric(bool value) => _i1.ColumnValue(
    table.isNumeric,
    value,
  );

  _i1.ColumnValue<bool, bool> isTimeseries(bool value) => _i1.ColumnValue(
    table.isTimeseries,
    value,
  );
}

class FieldRegistryTable extends _i1.Table<int?> {
  FieldRegistryTable({super.tableRelation})
    : super(tableName: 'field_registry') {
    updateTable = FieldRegistryUpdateTable(this);
    dataset = _i1.ColumnString(
      'dataset',
      this,
    );
    fieldPath = _i1.ColumnString(
      'fieldPath',
      this,
    );
    fieldType = _i1.ColumnString(
      'fieldType',
      this,
    );
    isNumeric = _i1.ColumnBool(
      'isNumeric',
      this,
    );
    isTimeseries = _i1.ColumnBool(
      'isTimeseries',
      this,
    );
  }

  late final FieldRegistryUpdateTable updateTable;

  /// The dataset this field belongs to (e.g. "kubernetes.container")
  late final _i1.ColumnString dataset;

  /// The full ECS field path (e.g. "kubernetes.container.cpu.usage.node.pct")
  late final _i1.ColumnString fieldPath;

  /// Elasticsearch data type (double, long, keyword, date, etc.)
  late final _i1.ColumnString fieldType;

  /// Whether this field is numeric (double / long / float)
  late final _i1.ColumnBool isNumeric;

  /// Whether this field is suitable for timeseries charting
  late final _i1.ColumnBool isTimeseries;

  @override
  List<_i1.Column> get columns => [
    id,
    dataset,
    fieldPath,
    fieldType,
    isNumeric,
    isTimeseries,
  ];
}

class FieldRegistryInclude extends _i1.IncludeObject {
  FieldRegistryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FieldRegistry.t;
}

class FieldRegistryIncludeList extends _i1.IncludeList {
  FieldRegistryIncludeList._({
    _i1.WhereExpressionBuilder<FieldRegistryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FieldRegistry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FieldRegistry.t;
}

class FieldRegistryRepository {
  const FieldRegistryRepository._();

  /// Returns a list of [FieldRegistry]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<FieldRegistry>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FieldRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<FieldRegistry>(
      where: where?.call(FieldRegistry.t),
      orderBy: orderBy?.call(FieldRegistry.t),
      orderByList: orderByList?.call(FieldRegistry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [FieldRegistry] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<FieldRegistry?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FieldRegistryTable>? where,
    int? offset,
    _i1.OrderByBuilder<FieldRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<FieldRegistry>(
      where: where?.call(FieldRegistry.t),
      orderBy: orderBy?.call(FieldRegistry.t),
      orderByList: orderByList?.call(FieldRegistry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [FieldRegistry] by its [id] or null if no such row exists.
  Future<FieldRegistry?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<FieldRegistry>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [FieldRegistry]s in the list and returns the inserted rows.
  ///
  /// The returned [FieldRegistry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FieldRegistry>> insert(
    _i1.Session session,
    List<FieldRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FieldRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FieldRegistry] and returns the inserted row.
  ///
  /// The returned [FieldRegistry] will have its `id` field set.
  Future<FieldRegistry> insertRow(
    _i1.Session session,
    FieldRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FieldRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FieldRegistry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FieldRegistry>> update(
    _i1.Session session,
    List<FieldRegistry> rows, {
    _i1.ColumnSelections<FieldRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FieldRegistry>(
      rows,
      columns: columns?.call(FieldRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FieldRegistry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FieldRegistry> updateRow(
    _i1.Session session,
    FieldRegistry row, {
    _i1.ColumnSelections<FieldRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FieldRegistry>(
      row,
      columns: columns?.call(FieldRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FieldRegistry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FieldRegistry?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<FieldRegistryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FieldRegistry>(
      id,
      columnValues: columnValues(FieldRegistry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FieldRegistry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FieldRegistry>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<FieldRegistryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FieldRegistryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldRegistryTable>? orderBy,
    _i1.OrderByListBuilder<FieldRegistryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FieldRegistry>(
      columnValues: columnValues(FieldRegistry.t.updateTable),
      where: where(FieldRegistry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldRegistry.t),
      orderByList: orderByList?.call(FieldRegistry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FieldRegistry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FieldRegistry>> delete(
    _i1.Session session,
    List<FieldRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FieldRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FieldRegistry].
  Future<FieldRegistry> deleteRow(
    _i1.Session session,
    FieldRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FieldRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FieldRegistry>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FieldRegistryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FieldRegistry>(
      where: where(FieldRegistry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FieldRegistryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FieldRegistry>(
      where: where?.call(FieldRegistry.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
