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

/// Persisted result for a saved observability query.
abstract class ObservabilityResult
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ObservabilityResult._({
    this.id,
    required this.queryId,
    required this.chartJson,
    required this.explanation,
    required this.hasAnomalies,
    required this.createdAt,
  });

  factory ObservabilityResult({
    int? id,
    required int queryId,
    required String chartJson,
    required String explanation,
    required bool hasAnomalies,
    required DateTime createdAt,
  }) = _ObservabilityResultImpl;

  factory ObservabilityResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservabilityResult(
      id: jsonSerialization['id'] as int?,
      queryId: jsonSerialization['queryId'] as int,
      chartJson: jsonSerialization['chartJson'] as String,
      explanation: jsonSerialization['explanation'] as String,
      hasAnomalies: jsonSerialization['hasAnomalies'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ObservabilityResultTable();

  static const db = ObservabilityResultRepository._();

  @override
  int? id;

  /// FK to the ObservabilityQuery that produced this result
  int queryId;

  /// Full chart response JSON (series, anomalies)
  String chartJson;

  /// Plain text explanation from the Explanation Agent
  String explanation;

  /// Whether anomalies were detected
  bool hasAnomalies;

  /// When this result was stored
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ObservabilityResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ObservabilityResult copyWith({
    int? id,
    int? queryId,
    String? chartJson,
    String? explanation,
    bool? hasAnomalies,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservabilityResult',
      if (id != null) 'id': id,
      'queryId': queryId,
      'chartJson': chartJson,
      'explanation': explanation,
      'hasAnomalies': hasAnomalies,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ObservabilityResult',
      if (id != null) 'id': id,
      'queryId': queryId,
      'chartJson': chartJson,
      'explanation': explanation,
      'hasAnomalies': hasAnomalies,
      'createdAt': createdAt.toJson(),
    };
  }

  static ObservabilityResultInclude include() {
    return ObservabilityResultInclude._();
  }

  static ObservabilityResultIncludeList includeList({
    _i1.WhereExpressionBuilder<ObservabilityResultTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityResultTable>? orderByList,
    ObservabilityResultInclude? include,
  }) {
    return ObservabilityResultIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ObservabilityResult.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ObservabilityResult.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservabilityResultImpl extends ObservabilityResult {
  _ObservabilityResultImpl({
    int? id,
    required int queryId,
    required String chartJson,
    required String explanation,
    required bool hasAnomalies,
    required DateTime createdAt,
  }) : super._(
         id: id,
         queryId: queryId,
         chartJson: chartJson,
         explanation: explanation,
         hasAnomalies: hasAnomalies,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ObservabilityResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ObservabilityResult copyWith({
    Object? id = _Undefined,
    int? queryId,
    String? chartJson,
    String? explanation,
    bool? hasAnomalies,
    DateTime? createdAt,
  }) {
    return ObservabilityResult(
      id: id is int? ? id : this.id,
      queryId: queryId ?? this.queryId,
      chartJson: chartJson ?? this.chartJson,
      explanation: explanation ?? this.explanation,
      hasAnomalies: hasAnomalies ?? this.hasAnomalies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ObservabilityResultUpdateTable
    extends _i1.UpdateTable<ObservabilityResultTable> {
  ObservabilityResultUpdateTable(super.table);

  _i1.ColumnValue<int, int> queryId(int value) => _i1.ColumnValue(
    table.queryId,
    value,
  );

  _i1.ColumnValue<String, String> chartJson(String value) => _i1.ColumnValue(
    table.chartJson,
    value,
  );

  _i1.ColumnValue<String, String> explanation(String value) => _i1.ColumnValue(
    table.explanation,
    value,
  );

  _i1.ColumnValue<bool, bool> hasAnomalies(bool value) => _i1.ColumnValue(
    table.hasAnomalies,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ObservabilityResultTable extends _i1.Table<int?> {
  ObservabilityResultTable({super.tableRelation})
    : super(tableName: 'observability_result') {
    updateTable = ObservabilityResultUpdateTable(this);
    queryId = _i1.ColumnInt(
      'queryId',
      this,
    );
    chartJson = _i1.ColumnString(
      'chartJson',
      this,
    );
    explanation = _i1.ColumnString(
      'explanation',
      this,
    );
    hasAnomalies = _i1.ColumnBool(
      'hasAnomalies',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ObservabilityResultUpdateTable updateTable;

  /// FK to the ObservabilityQuery that produced this result
  late final _i1.ColumnInt queryId;

  /// Full chart response JSON (series, anomalies)
  late final _i1.ColumnString chartJson;

  /// Plain text explanation from the Explanation Agent
  late final _i1.ColumnString explanation;

  /// Whether anomalies were detected
  late final _i1.ColumnBool hasAnomalies;

  /// When this result was stored
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    queryId,
    chartJson,
    explanation,
    hasAnomalies,
    createdAt,
  ];
}

class ObservabilityResultInclude extends _i1.IncludeObject {
  ObservabilityResultInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ObservabilityResult.t;
}

class ObservabilityResultIncludeList extends _i1.IncludeList {
  ObservabilityResultIncludeList._({
    _i1.WhereExpressionBuilder<ObservabilityResultTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ObservabilityResult.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ObservabilityResult.t;
}

class ObservabilityResultRepository {
  const ObservabilityResultRepository._();

  /// Returns a list of [ObservabilityResult]s matching the given query parameters.
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
  Future<List<ObservabilityResult>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityResultTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityResultTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ObservabilityResult>(
      where: where?.call(ObservabilityResult.t),
      orderBy: orderBy?.call(ObservabilityResult.t),
      orderByList: orderByList?.call(ObservabilityResult.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ObservabilityResult] matching the given query parameters.
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
  Future<ObservabilityResult?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityResultTable>? where,
    int? offset,
    _i1.OrderByBuilder<ObservabilityResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityResultTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ObservabilityResult>(
      where: where?.call(ObservabilityResult.t),
      orderBy: orderBy?.call(ObservabilityResult.t),
      orderByList: orderByList?.call(ObservabilityResult.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ObservabilityResult] by its [id] or null if no such row exists.
  Future<ObservabilityResult?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ObservabilityResult>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ObservabilityResult]s in the list and returns the inserted rows.
  ///
  /// The returned [ObservabilityResult]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ObservabilityResult>> insert(
    _i1.Session session,
    List<ObservabilityResult> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ObservabilityResult>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ObservabilityResult] and returns the inserted row.
  ///
  /// The returned [ObservabilityResult] will have its `id` field set.
  Future<ObservabilityResult> insertRow(
    _i1.Session session,
    ObservabilityResult row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ObservabilityResult>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ObservabilityResult]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ObservabilityResult>> update(
    _i1.Session session,
    List<ObservabilityResult> rows, {
    _i1.ColumnSelections<ObservabilityResultTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ObservabilityResult>(
      rows,
      columns: columns?.call(ObservabilityResult.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ObservabilityResult]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ObservabilityResult> updateRow(
    _i1.Session session,
    ObservabilityResult row, {
    _i1.ColumnSelections<ObservabilityResultTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ObservabilityResult>(
      row,
      columns: columns?.call(ObservabilityResult.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ObservabilityResult] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ObservabilityResult?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ObservabilityResultUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ObservabilityResult>(
      id,
      columnValues: columnValues(ObservabilityResult.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ObservabilityResult]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ObservabilityResult>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ObservabilityResultUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ObservabilityResultTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityResultTable>? orderBy,
    _i1.OrderByListBuilder<ObservabilityResultTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ObservabilityResult>(
      columnValues: columnValues(ObservabilityResult.t.updateTable),
      where: where(ObservabilityResult.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ObservabilityResult.t),
      orderByList: orderByList?.call(ObservabilityResult.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ObservabilityResult]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ObservabilityResult>> delete(
    _i1.Session session,
    List<ObservabilityResult> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ObservabilityResult>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ObservabilityResult].
  Future<ObservabilityResult> deleteRow(
    _i1.Session session,
    ObservabilityResult row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ObservabilityResult>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ObservabilityResult>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ObservabilityResultTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ObservabilityResult>(
      where: where(ObservabilityResult.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityResultTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ObservabilityResult>(
      where: where?.call(ObservabilityResult.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
