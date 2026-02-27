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

/// The capability registry — the only schema the agent runtime can see.
/// Stored as a JSON snapshot updated on every ingestion cycle.
abstract class CapabilityRegistry
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CapabilityRegistry._({
    this.id,
    required this.registryJson,
    required this.refreshedAt,
  });

  factory CapabilityRegistry({
    int? id,
    required String registryJson,
    required DateTime refreshedAt,
  }) = _CapabilityRegistryImpl;

  factory CapabilityRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapabilityRegistry(
      id: jsonSerialization['id'] as int?,
      registryJson: jsonSerialization['registryJson'] as String,
      refreshedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['refreshedAt'],
      ),
    );
  }

  static final t = CapabilityRegistryTable();

  static const db = CapabilityRegistryRepository._();

  @override
  int? id;

  /// JSON string: {entities: {pod: {metrics:[], logs:bool, anomaly_detection:bool}}}
  String registryJson;

  /// Timestamp of when this snapshot was last refreshed
  DateTime refreshedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CapabilityRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapabilityRegistry copyWith({
    int? id,
    String? registryJson,
    DateTime? refreshedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapabilityRegistry',
      if (id != null) 'id': id,
      'registryJson': registryJson,
      'refreshedAt': refreshedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CapabilityRegistry',
      if (id != null) 'id': id,
      'registryJson': registryJson,
      'refreshedAt': refreshedAt.toJson(),
    };
  }

  static CapabilityRegistryInclude include() {
    return CapabilityRegistryInclude._();
  }

  static CapabilityRegistryIncludeList includeList({
    _i1.WhereExpressionBuilder<CapabilityRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CapabilityRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CapabilityRegistryTable>? orderByList,
    CapabilityRegistryInclude? include,
  }) {
    return CapabilityRegistryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CapabilityRegistry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CapabilityRegistry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapabilityRegistryImpl extends CapabilityRegistry {
  _CapabilityRegistryImpl({
    int? id,
    required String registryJson,
    required DateTime refreshedAt,
  }) : super._(
         id: id,
         registryJson: registryJson,
         refreshedAt: refreshedAt,
       );

  /// Returns a shallow copy of this [CapabilityRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapabilityRegistry copyWith({
    Object? id = _Undefined,
    String? registryJson,
    DateTime? refreshedAt,
  }) {
    return CapabilityRegistry(
      id: id is int? ? id : this.id,
      registryJson: registryJson ?? this.registryJson,
      refreshedAt: refreshedAt ?? this.refreshedAt,
    );
  }
}

class CapabilityRegistryUpdateTable
    extends _i1.UpdateTable<CapabilityRegistryTable> {
  CapabilityRegistryUpdateTable(super.table);

  _i1.ColumnValue<String, String> registryJson(String value) => _i1.ColumnValue(
    table.registryJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> refreshedAt(DateTime value) =>
      _i1.ColumnValue(
        table.refreshedAt,
        value,
      );
}

class CapabilityRegistryTable extends _i1.Table<int?> {
  CapabilityRegistryTable({super.tableRelation})
    : super(tableName: 'capability_registry') {
    updateTable = CapabilityRegistryUpdateTable(this);
    registryJson = _i1.ColumnString(
      'registryJson',
      this,
    );
    refreshedAt = _i1.ColumnDateTime(
      'refreshedAt',
      this,
    );
  }

  late final CapabilityRegistryUpdateTable updateTable;

  /// JSON string: {entities: {pod: {metrics:[], logs:bool, anomaly_detection:bool}}}
  late final _i1.ColumnString registryJson;

  /// Timestamp of when this snapshot was last refreshed
  late final _i1.ColumnDateTime refreshedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    registryJson,
    refreshedAt,
  ];
}

class CapabilityRegistryInclude extends _i1.IncludeObject {
  CapabilityRegistryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CapabilityRegistry.t;
}

class CapabilityRegistryIncludeList extends _i1.IncludeList {
  CapabilityRegistryIncludeList._({
    _i1.WhereExpressionBuilder<CapabilityRegistryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CapabilityRegistry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CapabilityRegistry.t;
}

class CapabilityRegistryRepository {
  const CapabilityRegistryRepository._();

  /// Returns a list of [CapabilityRegistry]s matching the given query parameters.
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
  Future<List<CapabilityRegistry>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CapabilityRegistryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CapabilityRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CapabilityRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CapabilityRegistry>(
      where: where?.call(CapabilityRegistry.t),
      orderBy: orderBy?.call(CapabilityRegistry.t),
      orderByList: orderByList?.call(CapabilityRegistry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [CapabilityRegistry] matching the given query parameters.
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
  Future<CapabilityRegistry?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CapabilityRegistryTable>? where,
    int? offset,
    _i1.OrderByBuilder<CapabilityRegistryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CapabilityRegistryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CapabilityRegistry>(
      where: where?.call(CapabilityRegistry.t),
      orderBy: orderBy?.call(CapabilityRegistry.t),
      orderByList: orderByList?.call(CapabilityRegistry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CapabilityRegistry] by its [id] or null if no such row exists.
  Future<CapabilityRegistry?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CapabilityRegistry>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CapabilityRegistry]s in the list and returns the inserted rows.
  ///
  /// The returned [CapabilityRegistry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CapabilityRegistry>> insert(
    _i1.Session session,
    List<CapabilityRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CapabilityRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CapabilityRegistry] and returns the inserted row.
  ///
  /// The returned [CapabilityRegistry] will have its `id` field set.
  Future<CapabilityRegistry> insertRow(
    _i1.Session session,
    CapabilityRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CapabilityRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CapabilityRegistry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CapabilityRegistry>> update(
    _i1.Session session,
    List<CapabilityRegistry> rows, {
    _i1.ColumnSelections<CapabilityRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CapabilityRegistry>(
      rows,
      columns: columns?.call(CapabilityRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CapabilityRegistry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CapabilityRegistry> updateRow(
    _i1.Session session,
    CapabilityRegistry row, {
    _i1.ColumnSelections<CapabilityRegistryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CapabilityRegistry>(
      row,
      columns: columns?.call(CapabilityRegistry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CapabilityRegistry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CapabilityRegistry?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CapabilityRegistryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CapabilityRegistry>(
      id,
      columnValues: columnValues(CapabilityRegistry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CapabilityRegistry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CapabilityRegistry>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CapabilityRegistryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CapabilityRegistryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CapabilityRegistryTable>? orderBy,
    _i1.OrderByListBuilder<CapabilityRegistryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CapabilityRegistry>(
      columnValues: columnValues(CapabilityRegistry.t.updateTable),
      where: where(CapabilityRegistry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CapabilityRegistry.t),
      orderByList: orderByList?.call(CapabilityRegistry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CapabilityRegistry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CapabilityRegistry>> delete(
    _i1.Session session,
    List<CapabilityRegistry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CapabilityRegistry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CapabilityRegistry].
  Future<CapabilityRegistry> deleteRow(
    _i1.Session session,
    CapabilityRegistry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CapabilityRegistry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CapabilityRegistry>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CapabilityRegistryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CapabilityRegistry>(
      where: where(CapabilityRegistry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CapabilityRegistryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CapabilityRegistry>(
      where: where?.call(CapabilityRegistry.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
