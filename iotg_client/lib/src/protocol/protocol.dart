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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'anomaly_entry.dart' as _i2;
import 'capability_registry.dart' as _i3;
import 'chat_message.dart' as _i4;
import 'dataset_registry.dart' as _i5;
import 'field_registry.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'metric_dictionary.dart' as _i8;
import 'observability_query.dart' as _i9;
import 'observability_result.dart' as _i10;
import 'package:iotg_client/src/protocol/observability_query.dart' as _i11;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i12;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i13;
export 'anomaly_entry.dart';
export 'capability_registry.dart';
export 'chat_message.dart';
export 'dataset_registry.dart';
export 'field_registry.dart';
export 'greetings/greeting.dart';
export 'metric_dictionary.dart';
export 'observability_query.dart';
export 'observability_result.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.AnomalyEntry) {
      return _i2.AnomalyEntry.fromJson(data) as T;
    }
    if (t == _i3.CapabilityRegistry) {
      return _i3.CapabilityRegistry.fromJson(data) as T;
    }
    if (t == _i4.ChatResponse) {
      return _i4.ChatResponse.fromJson(data) as T;
    }
    if (t == _i5.DatasetRegistry) {
      return _i5.DatasetRegistry.fromJson(data) as T;
    }
    if (t == _i6.FieldRegistry) {
      return _i6.FieldRegistry.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.MetricDictionary) {
      return _i8.MetricDictionary.fromJson(data) as T;
    }
    if (t == _i9.ObservabilityQuery) {
      return _i9.ObservabilityQuery.fromJson(data) as T;
    }
    if (t == _i10.ObservabilityResult) {
      return _i10.ObservabilityResult.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnomalyEntry?>()) {
      return (data != null ? _i2.AnomalyEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CapabilityRegistry?>()) {
      return (data != null ? _i3.CapabilityRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatResponse?>()) {
      return (data != null ? _i4.ChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DatasetRegistry?>()) {
      return (data != null ? _i5.DatasetRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FieldRegistry?>()) {
      return (data != null ? _i6.FieldRegistry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MetricDictionary?>()) {
      return (data != null ? _i8.MetricDictionary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ObservabilityQuery?>()) {
      return (data != null ? _i9.ObservabilityQuery.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ObservabilityResult?>()) {
      return (data != null ? _i10.ObservabilityResult.fromJson(data) : null)
          as T;
    }
    if (t == List<_i11.ObservabilityQuery>) {
      return (data as List)
              .map((e) => deserialize<_i11.ObservabilityQuery>(e))
              .toList()
          as T;
    }
    try {
      return _i12.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i13.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnomalyEntry => 'AnomalyEntry',
      _i3.CapabilityRegistry => 'CapabilityRegistry',
      _i4.ChatResponse => 'ChatResponse',
      _i5.DatasetRegistry => 'DatasetRegistry',
      _i6.FieldRegistry => 'FieldRegistry',
      _i7.Greeting => 'Greeting',
      _i8.MetricDictionary => 'MetricDictionary',
      _i9.ObservabilityQuery => 'ObservabilityQuery',
      _i10.ObservabilityResult => 'ObservabilityResult',
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
      case _i2.AnomalyEntry():
        return 'AnomalyEntry';
      case _i3.CapabilityRegistry():
        return 'CapabilityRegistry';
      case _i4.ChatResponse():
        return 'ChatResponse';
      case _i5.DatasetRegistry():
        return 'DatasetRegistry';
      case _i6.FieldRegistry():
        return 'FieldRegistry';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.MetricDictionary():
        return 'MetricDictionary';
      case _i9.ObservabilityQuery():
        return 'ObservabilityQuery';
      case _i10.ObservabilityResult():
        return 'ObservabilityResult';
    }
    className = _i12.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i13.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.AnomalyEntry>(data['data']);
    }
    if (dataClassName == 'CapabilityRegistry') {
      return deserialize<_i3.CapabilityRegistry>(data['data']);
    }
    if (dataClassName == 'ChatResponse') {
      return deserialize<_i4.ChatResponse>(data['data']);
    }
    if (dataClassName == 'DatasetRegistry') {
      return deserialize<_i5.DatasetRegistry>(data['data']);
    }
    if (dataClassName == 'FieldRegistry') {
      return deserialize<_i6.FieldRegistry>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'MetricDictionary') {
      return deserialize<_i8.MetricDictionary>(data['data']);
    }
    if (dataClassName == 'ObservabilityQuery') {
      return deserialize<_i9.ObservabilityQuery>(data['data']);
    }
    if (dataClassName == 'ObservabilityResult') {
      return deserialize<_i10.ObservabilityResult>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i12.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i13.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i12.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i13.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
