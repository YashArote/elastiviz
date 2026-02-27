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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'anomaly_entry.dart' as _i5;
import 'capability_registry.dart' as _i6;
import 'chat_message.dart' as _i7;
import 'dataset_registry.dart' as _i8;
import 'field_registry.dart' as _i9;
import 'greetings/greeting.dart' as _i10;
import 'metric_dictionary.dart' as _i11;
import 'observability_query.dart' as _i12;
import 'observability_result.dart' as _i13;
import 'package:iotg_server/src/generated/observability_query.dart' as _i14;
export 'anomaly_entry.dart';
export 'capability_registry.dart';
export 'chat_message.dart';
export 'dataset_registry.dart';
export 'field_registry.dart';
export 'greetings/greeting.dart';
export 'metric_dictionary.dart';
export 'observability_query.dart';
export 'observability_result.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'capability_registry',
      dartName: 'CapabilityRegistry',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'capability_registry_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'registryJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'refreshedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'capability_registry_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'dataset_registry',
      dartName: 'DatasetRegistry',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'dataset_registry_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'indexPattern',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'dataType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'lastSeen',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'dataset_registry_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'dataset_registry_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'field_registry',
      dartName: 'FieldRegistry',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'field_registry_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'dataset',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fieldPath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fieldType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isNumeric',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'isTimeseries',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'field_registry_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'field_registry_path_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'dataset',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'fieldPath',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'metric_dictionary',
      dartName: 'MetricDictionary',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'metric_dictionary_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'entityType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'dataset',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fieldPath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'unit',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'metric_dictionary_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'metric_dict_category_entity_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'category',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'entityType',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'observability_query',
      dartName: 'ObservabilityQuery',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'observability_query_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userQuery',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'intentJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'planJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'esqlQuery',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'observability_query_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'observability_result',
      dartName: 'ObservabilityResult',
      schema: 'public',
      module: 'iotg',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'observability_result_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'queryId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'chartJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'explanation',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'hasAnomalies',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'observability_result_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AnomalyEntry) {
      return _i5.AnomalyEntry.fromJson(data) as T;
    }
    if (t == _i6.CapabilityRegistry) {
      return _i6.CapabilityRegistry.fromJson(data) as T;
    }
    if (t == _i7.ChatResponse) {
      return _i7.ChatResponse.fromJson(data) as T;
    }
    if (t == _i8.DatasetRegistry) {
      return _i8.DatasetRegistry.fromJson(data) as T;
    }
    if (t == _i9.FieldRegistry) {
      return _i9.FieldRegistry.fromJson(data) as T;
    }
    if (t == _i10.Greeting) {
      return _i10.Greeting.fromJson(data) as T;
    }
    if (t == _i11.MetricDictionary) {
      return _i11.MetricDictionary.fromJson(data) as T;
    }
    if (t == _i12.ObservabilityQuery) {
      return _i12.ObservabilityQuery.fromJson(data) as T;
    }
    if (t == _i13.ObservabilityResult) {
      return _i13.ObservabilityResult.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AnomalyEntry?>()) {
      return (data != null ? _i5.AnomalyEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CapabilityRegistry?>()) {
      return (data != null ? _i6.CapabilityRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatResponse?>()) {
      return (data != null ? _i7.ChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DatasetRegistry?>()) {
      return (data != null ? _i8.DatasetRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.FieldRegistry?>()) {
      return (data != null ? _i9.FieldRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Greeting?>()) {
      return (data != null ? _i10.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MetricDictionary?>()) {
      return (data != null ? _i11.MetricDictionary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ObservabilityQuery?>()) {
      return (data != null ? _i12.ObservabilityQuery.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.ObservabilityResult?>()) {
      return (data != null ? _i13.ObservabilityResult.fromJson(data) : null)
          as T;
    }
    if (t == List<_i14.ObservabilityQuery>) {
      return (data as List)
              .map((e) => deserialize<_i14.ObservabilityQuery>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AnomalyEntry => 'AnomalyEntry',
      _i6.CapabilityRegistry => 'CapabilityRegistry',
      _i7.ChatResponse => 'ChatResponse',
      _i8.DatasetRegistry => 'DatasetRegistry',
      _i9.FieldRegistry => 'FieldRegistry',
      _i10.Greeting => 'Greeting',
      _i11.MetricDictionary => 'MetricDictionary',
      _i12.ObservabilityQuery => 'ObservabilityQuery',
      _i13.ObservabilityResult => 'ObservabilityResult',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('iotg.', '');
    }

    switch (data) {
      case _i5.AnomalyEntry():
        return 'AnomalyEntry';
      case _i6.CapabilityRegistry():
        return 'CapabilityRegistry';
      case _i7.ChatResponse():
        return 'ChatResponse';
      case _i8.DatasetRegistry():
        return 'DatasetRegistry';
      case _i9.FieldRegistry():
        return 'FieldRegistry';
      case _i10.Greeting():
        return 'Greeting';
      case _i11.MetricDictionary():
        return 'MetricDictionary';
      case _i12.ObservabilityQuery():
        return 'ObservabilityQuery';
      case _i13.ObservabilityResult():
        return 'ObservabilityResult';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnomalyEntry') {
      return deserialize<_i5.AnomalyEntry>(data['data']);
    }
    if (dataClassName == 'CapabilityRegistry') {
      return deserialize<_i6.CapabilityRegistry>(data['data']);
    }
    if (dataClassName == 'ChatResponse') {
      return deserialize<_i7.ChatResponse>(data['data']);
    }
    if (dataClassName == 'DatasetRegistry') {
      return deserialize<_i8.DatasetRegistry>(data['data']);
    }
    if (dataClassName == 'FieldRegistry') {
      return deserialize<_i9.FieldRegistry>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i10.Greeting>(data['data']);
    }
    if (dataClassName == 'MetricDictionary') {
      return deserialize<_i11.MetricDictionary>(data['data']);
    }
    if (dataClassName == 'ObservabilityQuery') {
      return deserialize<_i12.ObservabilityQuery>(data['data']);
    }
    if (dataClassName == 'ObservabilityResult') {
      return deserialize<_i13.ObservabilityResult>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.CapabilityRegistry:
        return _i6.CapabilityRegistry.t;
      case _i8.DatasetRegistry:
        return _i8.DatasetRegistry.t;
      case _i9.FieldRegistry:
        return _i9.FieldRegistry.t;
      case _i11.MetricDictionary:
        return _i11.MetricDictionary.t;
      case _i12.ObservabilityQuery:
        return _i12.ObservabilityQuery.t;
      case _i13.ObservabilityResult:
        return _i13.ObservabilityResult.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'iotg';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
