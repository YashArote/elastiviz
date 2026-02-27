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

/// A single entry in the generated metric dictionary.
/// Maps an abstract metric concept (e.g. "cpu") to an ECS field path.
abstract class MetricDictionary
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MetricDictionary._({
    this.id,
    required this.category,
    required this.entityType,
    required this.dataset,
    required this.fieldPath,
    required this.unit,
  });

  factory MetricDictionary({
    int? id,
    required String category,
    required String entityType,
    required String dataset,
    required String fieldPath,
    required String unit,
  }) = _MetricDictionaryImpl;

  factory MetricDictionary.fromJson(Map<String, dynamic> jsonSerialization) {
    return MetricDictionary(
      id: jsonSerialization['id'] as int?,
      category: jsonSerialization['category'] as String,
      entityType: jsonSerialization['entityType'] as String,
      dataset: jsonSerialization['dataset'] as String,
      fieldPath: jsonSerialization['fieldPath'] as String,
      unit: jsonSerialization['unit'] as String,
    );
  }

  static final t = MetricDictionaryTable();

  static const db = MetricDictionaryRepository._();

  @override
  int? id;

  /// Abstract metric category: cpu, memory, network, disk, etc.
  String category;

  /// Entity type this metric applies to: pod, node, service
  String entityType;

  /// The source dataset (e.g. "kubernetes.container")
  String dataset;

  /// The full ECS field path
  String fieldPath;

  /// Measurement unit: %, bytes, cores, etc.
  String unit;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MetricDictionary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MetricDictionary copyWith({
    int? id,
    String? category,
    String? entityType,
    String? dataset,
    String? fieldPath,
    String? unit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MetricDictionary',
      if (id != null) 'id': id,
      'category': category,
      'entityType': entityType,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'unit': unit,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MetricDictionary',
      if (id != null) 'id': id,
      'category': category,
      'entityType': entityType,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'unit': unit,
    };
  }

  static MetricDictionaryInclude include() {
    return MetricDictionaryInclude._();
  }

  static MetricDictionaryIncludeList includeList({
    _i1.WhereExpressionBuilder<MetricDictionaryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MetricDictionaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MetricDictionaryTable>? orderByList,
    MetricDictionaryInclude? include,
  }) {
    return MetricDictionaryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MetricDictionary.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MetricDictionary.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MetricDictionaryImpl extends MetricDictionary {
  _MetricDictionaryImpl({
    int? id,
    required String category,
    required String entityType,
    required String dataset,
    required String fieldPath,
    required String unit,
  }) : super._(
         id: id,
         category: category,
         entityType: entityType,
         dataset: dataset,
         fieldPath: fieldPath,
         unit: unit,
       );

  /// Returns a shallow copy of this [MetricDictionary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MetricDictionary copyWith({
    Object? id = _Undefined,
    String? category,
    String? entityType,
    String? dataset,
    String? fieldPath,
    String? unit,
  }) {
    return MetricDictionary(
      id: id is int? ? id : this.id,
      category: category ?? this.category,
      entityType: entityType ?? this.entityType,
      dataset: dataset ?? this.dataset,
      fieldPath: fieldPath ?? this.fieldPath,
      unit: unit ?? this.unit,
    );
  }
}

class MetricDictionaryUpdateTable
    extends _i1.UpdateTable<MetricDictionaryTable> {
  MetricDictionaryUpdateTable(super.table);

  _i1.ColumnValue<String, String> category(String value) => _i1.ColumnValue(
    table.category,
    value,
  );

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<String, String> dataset(String value) => _i1.ColumnValue(
    table.dataset,
    value,
  );

  _i1.ColumnValue<String, String> fieldPath(String value) => _i1.ColumnValue(
    table.fieldPath,
    value,
  );

  _i1.ColumnValue<String, String> unit(String value) => _i1.ColumnValue(
    table.unit,
    value,
  );
}

class MetricDictionaryTable extends _i1.Table<int?> {
  MetricDictionaryTable({super.tableRelation})
    : super(tableName: 'metric_dictionary') {
    updateTable = MetricDictionaryUpdateTable(this);
    category = _i1.ColumnString(
      'category',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    dataset = _i1.ColumnString(
      'dataset',
      this,
    );
    fieldPath = _i1.ColumnString(
      'fieldPath',
      this,
    );
    unit = _i1.ColumnString(
      'unit',
      this,
    );
  }

  late final MetricDictionaryUpdateTable updateTable;

  /// Abstract metric category: cpu, memory, network, disk, etc.
  late final _i1.ColumnString category;

  /// Entity type this metric applies to: pod, node, service
  late final _i1.ColumnString entityType;

  /// The source dataset (e.g. "kubernetes.container")
  late final _i1.ColumnString dataset;

  /// The full ECS field path
  late final _i1.ColumnString fieldPath;

  /// Measurement unit: %, bytes, cores, etc.
  late final _i1.ColumnString unit;

  @override
  List<_i1.Column> get columns => [
    id,
    category,
    entityType,
    dataset,
    fieldPath,
    unit,
  ];
}

class MetricDictionaryInclude extends _i1.IncludeObject {
  MetricDictionaryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MetricDictionary.t;
}

class MetricDictionaryIncludeList extends _i1.IncludeList {
  MetricDictionaryIncludeList._({
    _i1.WhereExpressionBuilder<MetricDictionaryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MetricDictionary.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MetricDictionary.t;
}

class MetricDictionaryRepository {
  const MetricDictionaryRepository._();

  /// Returns a list of [MetricDictionary]s matching the given query parameters.
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
  Future<List<MetricDictionary>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MetricDictionaryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MetricDictionaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MetricDictionaryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<MetricDictionary>(
      where: where?.call(MetricDictionary.t),
      orderBy: orderBy?.call(MetricDictionary.t),
      orderByList: orderByList?.call(MetricDictionary.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [MetricDictionary] matching the given query parameters.
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
  Future<MetricDictionary?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MetricDictionaryTable>? where,
    int? offset,
    _i1.OrderByBuilder<MetricDictionaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MetricDictionaryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<MetricDictionary>(
      where: where?.call(MetricDictionary.t),
      orderBy: orderBy?.call(MetricDictionary.t),
      orderByList: orderByList?.call(MetricDictionary.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [MetricDictionary] by its [id] or null if no such row exists.
  Future<MetricDictionary?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<MetricDictionary>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [MetricDictionary]s in the list and returns the inserted rows.
  ///
  /// The returned [MetricDictionary]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<MetricDictionary>> insert(
    _i1.Session session,
    List<MetricDictionary> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<MetricDictionary>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [MetricDictionary] and returns the inserted row.
  ///
  /// The returned [MetricDictionary] will have its `id` field set.
  Future<MetricDictionary> insertRow(
    _i1.Session session,
    MetricDictionary row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MetricDictionary>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MetricDictionary]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MetricDictionary>> update(
    _i1.Session session,
    List<MetricDictionary> rows, {
    _i1.ColumnSelections<MetricDictionaryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MetricDictionary>(
      rows,
      columns: columns?.call(MetricDictionary.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MetricDictionary]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MetricDictionary> updateRow(
    _i1.Session session,
    MetricDictionary row, {
    _i1.ColumnSelections<MetricDictionaryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MetricDictionary>(
      row,
      columns: columns?.call(MetricDictionary.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MetricDictionary] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MetricDictionary?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<MetricDictionaryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MetricDictionary>(
      id,
      columnValues: columnValues(MetricDictionary.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MetricDictionary]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MetricDictionary>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<MetricDictionaryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MetricDictionaryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MetricDictionaryTable>? orderBy,
    _i1.OrderByListBuilder<MetricDictionaryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MetricDictionary>(
      columnValues: columnValues(MetricDictionary.t.updateTable),
      where: where(MetricDictionary.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MetricDictionary.t),
      orderByList: orderByList?.call(MetricDictionary.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MetricDictionary]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MetricDictionary>> delete(
    _i1.Session session,
    List<MetricDictionary> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MetricDictionary>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MetricDictionary].
  Future<MetricDictionary> deleteRow(
    _i1.Session session,
    MetricDictionary row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MetricDictionary>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MetricDictionary>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<MetricDictionaryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MetricDictionary>(
      where: where(MetricDictionary.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MetricDictionaryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MetricDictionary>(
      where: where?.call(MetricDictionary.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
