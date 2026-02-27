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

/// A persisted record of a user observability query.
/// Used for save/replay functionality.
abstract class ObservabilityQuery
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ObservabilityQuery._({
    this.id,
    required this.userQuery,
    required this.intentJson,
    required this.planJson,
    required this.esqlQuery,
    required this.createdAt,
  });

  factory ObservabilityQuery({
    int? id,
    required String userQuery,
    required String intentJson,
    required String planJson,
    required String esqlQuery,
    required DateTime createdAt,
  }) = _ObservabilityQueryImpl;

  factory ObservabilityQuery.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservabilityQuery(
      id: jsonSerialization['id'] as int?,
      userQuery: jsonSerialization['userQuery'] as String,
      intentJson: jsonSerialization['intentJson'] as String,
      planJson: jsonSerialization['planJson'] as String,
      esqlQuery: jsonSerialization['esqlQuery'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ObservabilityQueryTable();

  static const db = ObservabilityQueryRepository._();

  @override
  int? id;

  /// The raw natural-language query from the user
  String userQuery;

  /// JSON of the IntentResult from the Intent Agent
  String intentJson;

  /// JSON of the ExecutionPlan from the Planning Agent
  String planJson;

  /// The compiled ES|QL query string
  String esqlQuery;

  /// When this query was created
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ObservabilityQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ObservabilityQuery copyWith({
    int? id,
    String? userQuery,
    String? intentJson,
    String? planJson,
    String? esqlQuery,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservabilityQuery',
      if (id != null) 'id': id,
      'userQuery': userQuery,
      'intentJson': intentJson,
      'planJson': planJson,
      'esqlQuery': esqlQuery,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ObservabilityQuery',
      if (id != null) 'id': id,
      'userQuery': userQuery,
      'intentJson': intentJson,
      'planJson': planJson,
      'esqlQuery': esqlQuery,
      'createdAt': createdAt.toJson(),
    };
  }

  static ObservabilityQueryInclude include() {
    return ObservabilityQueryInclude._();
  }

  static ObservabilityQueryIncludeList includeList({
    _i1.WhereExpressionBuilder<ObservabilityQueryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityQueryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityQueryTable>? orderByList,
    ObservabilityQueryInclude? include,
  }) {
    return ObservabilityQueryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ObservabilityQuery.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ObservabilityQuery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservabilityQueryImpl extends ObservabilityQuery {
  _ObservabilityQueryImpl({
    int? id,
    required String userQuery,
    required String intentJson,
    required String planJson,
    required String esqlQuery,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userQuery: userQuery,
         intentJson: intentJson,
         planJson: planJson,
         esqlQuery: esqlQuery,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ObservabilityQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ObservabilityQuery copyWith({
    Object? id = _Undefined,
    String? userQuery,
    String? intentJson,
    String? planJson,
    String? esqlQuery,
    DateTime? createdAt,
  }) {
    return ObservabilityQuery(
      id: id is int? ? id : this.id,
      userQuery: userQuery ?? this.userQuery,
      intentJson: intentJson ?? this.intentJson,
      planJson: planJson ?? this.planJson,
      esqlQuery: esqlQuery ?? this.esqlQuery,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ObservabilityQueryUpdateTable
    extends _i1.UpdateTable<ObservabilityQueryTable> {
  ObservabilityQueryUpdateTable(super.table);

  _i1.ColumnValue<String, String> userQuery(String value) => _i1.ColumnValue(
    table.userQuery,
    value,
  );

  _i1.ColumnValue<String, String> intentJson(String value) => _i1.ColumnValue(
    table.intentJson,
    value,
  );

  _i1.ColumnValue<String, String> planJson(String value) => _i1.ColumnValue(
    table.planJson,
    value,
  );

  _i1.ColumnValue<String, String> esqlQuery(String value) => _i1.ColumnValue(
    table.esqlQuery,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ObservabilityQueryTable extends _i1.Table<int?> {
  ObservabilityQueryTable({super.tableRelation})
    : super(tableName: 'observability_query') {
    updateTable = ObservabilityQueryUpdateTable(this);
    userQuery = _i1.ColumnString(
      'userQuery',
      this,
    );
    intentJson = _i1.ColumnString(
      'intentJson',
      this,
    );
    planJson = _i1.ColumnString(
      'planJson',
      this,
    );
    esqlQuery = _i1.ColumnString(
      'esqlQuery',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ObservabilityQueryUpdateTable updateTable;

  /// The raw natural-language query from the user
  late final _i1.ColumnString userQuery;

  /// JSON of the IntentResult from the Intent Agent
  late final _i1.ColumnString intentJson;

  /// JSON of the ExecutionPlan from the Planning Agent
  late final _i1.ColumnString planJson;

  /// The compiled ES|QL query string
  late final _i1.ColumnString esqlQuery;

  /// When this query was created
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userQuery,
    intentJson,
    planJson,
    esqlQuery,
    createdAt,
  ];
}

class ObservabilityQueryInclude extends _i1.IncludeObject {
  ObservabilityQueryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ObservabilityQuery.t;
}

class ObservabilityQueryIncludeList extends _i1.IncludeList {
  ObservabilityQueryIncludeList._({
    _i1.WhereExpressionBuilder<ObservabilityQueryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ObservabilityQuery.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ObservabilityQuery.t;
}

class ObservabilityQueryRepository {
  const ObservabilityQueryRepository._();

  /// Returns a list of [ObservabilityQuery]s matching the given query parameters.
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
  Future<List<ObservabilityQuery>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityQueryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityQueryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityQueryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ObservabilityQuery>(
      where: where?.call(ObservabilityQuery.t),
      orderBy: orderBy?.call(ObservabilityQuery.t),
      orderByList: orderByList?.call(ObservabilityQuery.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ObservabilityQuery] matching the given query parameters.
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
  Future<ObservabilityQuery?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityQueryTable>? where,
    int? offset,
    _i1.OrderByBuilder<ObservabilityQueryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ObservabilityQueryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ObservabilityQuery>(
      where: where?.call(ObservabilityQuery.t),
      orderBy: orderBy?.call(ObservabilityQuery.t),
      orderByList: orderByList?.call(ObservabilityQuery.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ObservabilityQuery] by its [id] or null if no such row exists.
  Future<ObservabilityQuery?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ObservabilityQuery>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ObservabilityQuery]s in the list and returns the inserted rows.
  ///
  /// The returned [ObservabilityQuery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ObservabilityQuery>> insert(
    _i1.Session session,
    List<ObservabilityQuery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ObservabilityQuery>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ObservabilityQuery] and returns the inserted row.
  ///
  /// The returned [ObservabilityQuery] will have its `id` field set.
  Future<ObservabilityQuery> insertRow(
    _i1.Session session,
    ObservabilityQuery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ObservabilityQuery>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ObservabilityQuery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ObservabilityQuery>> update(
    _i1.Session session,
    List<ObservabilityQuery> rows, {
    _i1.ColumnSelections<ObservabilityQueryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ObservabilityQuery>(
      rows,
      columns: columns?.call(ObservabilityQuery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ObservabilityQuery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ObservabilityQuery> updateRow(
    _i1.Session session,
    ObservabilityQuery row, {
    _i1.ColumnSelections<ObservabilityQueryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ObservabilityQuery>(
      row,
      columns: columns?.call(ObservabilityQuery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ObservabilityQuery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ObservabilityQuery?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ObservabilityQueryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ObservabilityQuery>(
      id,
      columnValues: columnValues(ObservabilityQuery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ObservabilityQuery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ObservabilityQuery>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ObservabilityQueryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ObservabilityQueryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ObservabilityQueryTable>? orderBy,
    _i1.OrderByListBuilder<ObservabilityQueryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ObservabilityQuery>(
      columnValues: columnValues(ObservabilityQuery.t.updateTable),
      where: where(ObservabilityQuery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ObservabilityQuery.t),
      orderByList: orderByList?.call(ObservabilityQuery.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ObservabilityQuery]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ObservabilityQuery>> delete(
    _i1.Session session,
    List<ObservabilityQuery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ObservabilityQuery>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ObservabilityQuery].
  Future<ObservabilityQuery> deleteRow(
    _i1.Session session,
    ObservabilityQuery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ObservabilityQuery>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ObservabilityQuery>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ObservabilityQueryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ObservabilityQuery>(
      where: where(ObservabilityQuery.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ObservabilityQueryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ObservabilityQuery>(
      where: where?.call(ObservabilityQuery.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
