import 'package:decimal/decimal.dart';

/// Converts a dynamic value (from JSON) to minor units (int).
/// E.g., 10.5 -> 1050
int toMinorUnitsFromJson(dynamic v) {
  final s = v?.toString() ?? '0';
  final d = Decimal.tryParse(s) ?? Decimal.zero;
  return (d * Decimal.fromInt(100)).round().toBigInt().toInt();
}

/// Converts a major units string (from UI input) to minor units (int).
int stringToMinorUnits(String v) {
  final clean = v.replaceAll(',', '');
  final d = Decimal.tryParse(clean) ?? Decimal.zero;
  return (d * Decimal.fromInt(100)).round().toBigInt().toInt();
}

/// Formats a minor units (int) to a double representing major units.
/// E.g., 1050 -> 10.5
double minorUnitsToDouble(int amount) {
  return amount / 100.0;
}

/// Formats a minor units (int) to a string representing major units for display.
String formatMinorUnits(int amount) {
  final d = amount / 100.0;
  if (d.truncateToDouble() == d) {
    return d.toInt().toString();
  }
  return d.toStringAsFixed(2);
}
