import '../agents/metric_resolver.dart';

/// Result Validator — checks for data quality issues before post-processing.
class ResultValidator {
  /// Validates raw ES|QL rows for a given set of metrics.
  /// Returns a [ValidationResult].
  ValidationResult validate(
    List<Map<String, dynamic>> rows,
    List<ResolvedMetric> metrics,
  ) {
    if (rows.isEmpty) {
      return ValidationResult.failed(
        'No data found. The entity may not exist, '
        'or there is no data in the requested time window.',
      );
    }

    final issues = <String>[];

    for (final metric in metrics) {
      final values = rows
          .map((r) => r[metric.fieldPath])
          .where((v) => v != null)
          .toList();

      if (values.isEmpty) {
        issues.add('No data for metric "${metric.displayName}"');
        continue;
      }

      // Check for constant series (all identical values)
      final numValues = values
          .whereType<num>()
          .map((v) => v.toDouble())
          .toList();
      if (numValues.length > 1) {
        final allSame = numValues.every((v) => v == numValues.first);
        if (allSame) {
          issues.add(
            '"${metric.displayName}" appears to be constant (${numValues.first}). '
            'This may indicate a reporting issue.',
          );
        }
      }
    }

    if (issues.isNotEmpty) {
      return ValidationResult.warning(issues.join(' | '));
    }

    return ValidationResult.ok();
  }
}

class ValidationResult {
  final bool ok;
  final bool isWarning;
  final String? message;

  const ValidationResult._({
    required this.ok,
    required this.isWarning,
    this.message,
  });

  factory ValidationResult.ok() =>
      const ValidationResult._(ok: true, isWarning: false);

  factory ValidationResult.warning(String message) =>
      ValidationResult._(ok: true, isWarning: true, message: message);

  factory ValidationResult.failed(String message) =>
      ValidationResult._(ok: false, isWarning: false, message: message);
}
