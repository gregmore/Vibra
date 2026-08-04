import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension su [DateTime] per formattazione date in italiano.
extension DateTimeExtensions on DateTime {
  /// Formatta come "12 luglio 2025".
  String toReadableDate() => DateFormat('d MMMM yyyy', 'it_IT').format(this);

  /// Formatta come "12 lug".
  String toShortDate() => DateFormat('d MMM', 'it_IT').format(this);

  /// Formatta come "12 lug 2025, 21:00".
  String toFullDateTime() =>
      DateFormat('d MMM yyyy, HH:mm', 'it_IT').format(this);

  /// Formatta solo l'ora come "21:00".
  String toTimeOnly() => DateFormat('HH:mm').format(this);

  /// Restituisce true se la data è oggi.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Restituisce true se la data è in futuro.
  bool get isFuture => isAfter(DateTime.now());
}

/// Extension su [String] per validazione e formattazione.
extension StringExtensions on String {
  /// Capitalizza la prima lettera.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Tronca la stringa a [maxLength] caratteri aggiungendo "...".
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Restituisce true se la stringa è un'email valida.
  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);
}

/// Extension su [BuildContext] per accesso rapido a tema e dimensioni.
extension BuildContextExtensions on BuildContext {
  /// Accesso rapido al [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Accesso rapido al [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Accesso rapido al [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Larghezza dello schermo.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Altezza dello schermo.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Padding sicuro (notch, navigation bar).
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  /// Mostra uno SnackBar con stile Vibra.
  void showVibraSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Extension su [double] per formattazione distanze e score.
extension DoubleExtensions on double {
  /// Formatta la distanza in km (es: "2.3 km" o "850 m").
  String toDistanceString() {
    if (this < 1) {
      return '${(this * 1000).round()} m';
    }
    return '${toStringAsFixed(1)} km';
  }

  /// Formatta come percentuale (es: "94%").
  String toPercentString() => '${round()}%';
}
