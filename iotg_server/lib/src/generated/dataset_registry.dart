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

/// Represents a discovered Elasticsearch data stream / dataset.
abstract class DatasetRegistry
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DatasetRegistry._({
    this.id,
    required this.name,
    required this.indexPattern,
    required this.dataType,
    required this.lastSeen,
  });

  factory DatasetRegistry({
    int? id,
    required String name,
    required String indexPattern,
    required String dataType,
    required DateTime lastSeen,
  }) = _DatasetRegistryImpl;

  factory DatasetRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatasetRegistry(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      indexPattern: jsonSerialization['indexPattern'] as String,
      dataType: jsonSerialization['dataType'] as String,
      lastSeen: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeen'],
      ),
    );
  }

  static final t = DatasetRegistryTable();

  static const db = DatasetRegistryRepository._();

  @override
  int? id;

  /// The dataset name, e.g. "kubernetes.container"
  String name;

  /// The index pattern used to query, e.g. "metrics-kubernetes.container*"
  String indexPattern;

  /// Either "metrics" or "logs"
  String dataType;

  /// Timestamp of the last successful discovery
  DateTime lastSeen;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DatasetRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatasetRegistry copyWith({
    int? id,
    String? name,
    String? indexPattern,
    String? dataType,
    DateTime? lastSeen,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatasetRegistry',
      if (id != null) 'id': id,
      'name': name,
      'indexPattern': indexPattern,
      'dataType': dataType,
      'lastSeen': lastSeen.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatasetRegistry',
      if (id != null) 'id': id,
      'name': name,
      'indexPattern': indexPattern,
      'dataType': dataType,
      'lastSeen': lastSeen.toJson(),
    };
  }

  static DatasetRegistryInclude include() {
    return DatasetRegistryInclude._();
  }

  static DatasetRegistryIncludeList includeList({
    _i1.WhereExpressionBuilder<DatasetRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DatasetRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DatasetRegistryTable>? orderByList,
    DatasetRegistryInclude? include,
  }) {
    return DatasetRegistryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DatasetRegistry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DatasetRegistry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatasetRegistryImpl extends DatasetRegistry {
  _DatasetRegistryImpl({
    int? id,
    required String name,
    required String indexPattern,
    required String dataType,
    required DateTime lastSeen,
  }) : super._(
         id: id,
         name: name,
         indexPattern: indexPattern,
         dataType: dataType,
         lastSeen: lastSeen,
       );

  /// Returns a shallow copy of this [DatasetRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatasetRegistry copyWith({
    Object? id = _Undefined,
    String? name,
    String? indexPattern,
    String? dataType,
    DateTime? lastSeen,
  }) {
    return DatasetRegistry(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      indexPattern: indexPattern ?? this.indexPattern,
      dataType: dataType ?? this.dataType,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class DatasetRegistryUpdateTable extends _i1.UpdateTable<DatasetRegistryTable> {
  DatasetRegistryUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> indexPattern(String value) => _i1.ColumnValue(
    table.indexPattern,
    value,
  );

  _i1.ColumnValue<String, String> dataType(String value) => _i1.ColumnValue(
    table.dataType,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastSeen(DateTime value) =>
      _i1.ColumnValue(
        table.lastSeen,
        value,
      );
}

class DatasetRegistryTable extends _i1.Table<int?> {
  DatasetRegistryTable({super.tableRelation})
    : super(tableName: 'dataset_registry') {
    updateTable = DatasetRegistryUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    indexPattern = _i1.ColumnString(
      'indexPattern',
      this,
    );
    dataType = _i1.ColumnString(
      'dataType',
      this,
    );
    lastSeen = _i1.ColumnDateTime(
      'lastSeen',
      this,
    );
  }

  late final DatasetRegistryUpdateTable updateTable;

  /// The dataset name, e.g. "kubernetes.container"
  late final _i1.ColumnString name;

  /// The index pattern used to query, e.g. "metrics-kubernetes.container*"
  late final _i1.ColumnString indexPattern;

  /// Either "metrics" or "logs"
  late final _i1.ColumnString dataType;

  /// Timestamp of the last successful discovery
  late final _i1.ColumnDateTime lastSeen;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    indexPattern,
    dataType,
    lastSeen,
  ];
}

class DatasetRegistryInclude extends _i1.IncludeObject {
  DatasetRegistryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DatasetRegistry.t;
}

class DatasetRegistryIncludeList extends _i1.IncludeList {
  DatasetRegistryIncludeList._({
    _i1.WhereExpressionBuilder<DatasetRegistryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DatasetRegistry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DatasetRegistry.t;
}

class DatasetRegistryRepository {
  const DatasetRegistryRepository._();

  /// Returns a list of [DatasetRegistry]s matching the given query parameters.
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
  Future<List<DatasetRegistry>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DatasetRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DatasetRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DatasetRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DatasetRegistry>(
      where: where?.call(DatasetRegistry.t),
      orderBy: orderBy?.call(DatasetRegistry.t),
      orderByList: orderByList?.call(DatasetRegistry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DatasetRegistry] matching the given query parameters.
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
  Future<DatasetRegistry?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DatasetRegistryTable>? where,
    int? offset,
    _i1.OrderByBuilder<DatasetRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DatasetRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DatasetRegistry>(
      where: where?.call(DatasetRegistry.t),
      orderBy: orderBy?.call(DatasetRegistry.t),
      orderByList: orderByList?.call(DatasetRegistry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DatasetRegistry] by its [id] or null if no such row exists.
  Future<DatasetRegistry?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DatasetRegistry>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DatasetRegistry]s in the list and returns the inserted rows.
  ///
  /// The returned [DatasetRegistry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DatasetRegistry>> insert(
    _i1.Session session,
    List<DatasetRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DatasetRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DatasetRegistry] and returns the inserted row.
  ///
  /// The returned [DatasetRegistry] will have its `id` field set.
  Future<DatasetRegistry> insertRow(
    _i1.Session session,
    DatasetRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DatasetRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DatasetRegistry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DatasetRegistry>> update(
    _i1.Session session,
    List<DatasetRegistry> rows, {
    _i1.ColumnSelections<DatasetRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DatasetRegistry>(
      rows,
      columns: columns?.call(DatasetRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DatasetRegistry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DatasetRegistry> updateRow(
    _i1.Session session,
    DatasetRegistry row, {
    _i1.ColumnSelections<DatasetRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DatasetRegistry>(
      row,
      columns: columns?.call(DatasetRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DatasetRegistry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DatasetRegistry?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<DatasetRegistryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DatasetRegistry>(
      id,
      columnValues: columnValues(DatasetRegistry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DatasetRegistry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DatasetRegistry>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DatasetRegistryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DatasetRegistryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DatasetRegistryTable>? orderBy,
    _i1.OrderByListBuilder<DatasetRegistryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DatasetRegistry>(
      columnValues: columnValues(DatasetRegistry.t.updateTable),
      where: where(DatasetRegistry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DatasetRegistry.t),
      orderByList: orderByList?.call(DatasetRegistry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DatasetRegistry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DatasetRegistry>> delete(
    _i1.Session session,
    List<DatasetRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DatasetRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DatasetRegistry].
  Future<DatasetRegistry> deleteRow(
    _i1.Session session,
    DatasetRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DatasetRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DatasetRegistry>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DatasetRegistryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DatasetRegistry>(
      where: where(DatasetRegistry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DatasetRegistryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DatasetRegistry>(
      where: where?.call(DatasetRegistry.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
