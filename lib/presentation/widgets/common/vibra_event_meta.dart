import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../domain/entities/event.dart';
import 'vibra_badge.dart';

/// Presentation-level lifecycle of an event, derived only from data the
/// backend already returns (status + date). No business rule changes.
enum VibraEventStatus {
  upcoming,
  today,
  offSale,
  soldOut,
  cancelled,
  postponed,
  past,
}

VibraEventStatus vibraEventStatus(Event event, {DateTime? now}) {
  final status = event.status?.toLowerCase().trim();
  if (status == 'cancelled' || status == 'canceled') {
    return VibraEventStatus.cancelled;
  }
  if (status == 'postponed' || status == 'rescheduled') {
    return VibraEventStatus.postponed;
  }
  final current = (now ?? DateTime.now()).toLocal();
  final date = event.eventDate.toLocal();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day.isBefore(today)) return VibraEventStatus.past;
  if (status == 'soldout' || status == 'sold_out') {
    return VibraEventStatus.soldOut;
  }
  if (status == 'offsale') return VibraEventStatus.offSale;
  if (day == today) return VibraEventStatus.today;
  return VibraEventStatus.upcoming;
}

extension VibraEventStatusX on VibraEventStatus {
  /// Whether the event is no longer attendable (dims artwork).
  bool get isInactive =>
      this == VibraEventStatus.cancelled || this == VibraEventStatus.past;

  String label(AppLocalizations l10n) => switch (this) {
    VibraEventStatus.upcoming => l10n.eventStatusUpcoming,
    VibraEventStatus.today => l10n.eventStatusToday,
    VibraEventStatus.offSale => l10n.eventTicketsOffsale,
    VibraEventStatus.soldOut => l10n.eventStatusSoldOut,
    VibraEventStatus.cancelled => l10n.eventStatusCancelled,
    VibraEventStatus.postponed => l10n.eventStatusPostponed,
    VibraEventStatus.past => l10n.eventStatusPast,
  };

  VibraBadgeTone get tone => switch (this) {
    VibraEventStatus.upcoming => VibraBadgeTone.neutral,
    VibraEventStatus.today => VibraBadgeTone.accent,
    VibraEventStatus.offSale => VibraBadgeTone.warning,
    VibraEventStatus.soldOut => VibraBadgeTone.warning,
    VibraEventStatus.cancelled => VibraBadgeTone.error,
    VibraEventStatus.postponed => VibraBadgeTone.warning,
    VibraEventStatus.past => VibraBadgeTone.neutral,
  };
}

/// Status pill; [showUpcoming] hides the default state to reduce noise.
class VibraEventStatusBadge extends StatelessWidget {
  const VibraEventStatusBadge({
    required this.status,
    super.key,
    this.showUpcoming = false,
  });

  final VibraEventStatus status;
  final bool showUpcoming;

  @override
  Widget build(BuildContext context) {
    if (status == VibraEventStatus.upcoming && !showUpcoming) {
      return const SizedBox.shrink();
    }
    return VibraBadge(
      label: status.label(AppLocalizations.of(context)!),
      tone: status.tone,
      dot: true,
    );
  }
}

/// Formats a published price in its own currency. Without a known currency
/// there is no price to show (never assume one).
String? vibraFormatPrice(BuildContext context, Event event, double? value) {
  final currency = event.priceCurrency;
  if (value == null || currency == null) return null;
  return NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(context).toString(),
    name: currency,
  ).format(value);
}

/// "From €35": the lowest published face-value price, never availability.
String? vibraEventPriceLabel(BuildContext context, Event event) {
  final min = vibraFormatPrice(context, event, event.priceMin);
  if (min == null) return null;
  return AppLocalizations.of(context)!.eventPriceFrom(min);
}

/// Date helpers shared by every event surface.
class VibraEventDate {
  VibraEventDate(BuildContext context, DateTime date)
    : _locale = Localizations.localeOf(context).toString(),
      _date = date.toLocal();

  final String _locale;
  final DateTime _date;

  String get day => _date.day.toString().padLeft(2, '0');
  String get month => DateFormat.MMM(_locale).format(_date).toUpperCase();
  String get weekday => DateFormat.E(_locale).format(_date);
  String get time => DateFormat.Hm(_locale).format(_date);
  String get medium => DateFormat.yMMMd(_locale).format(_date);
  String get short => DateFormat.MMMd(_locale).format(_date);

  /// "Fri · 21:00"
  String get weekdayTime => '$weekday · $time';
}
