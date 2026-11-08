import 'package:flutter/material.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../domain/entities/event.dart';
import 'vibra_editorial_event.dart';

/// Canonical event card for lists and grids.
///
/// * default: a poster card ([VibraEventFeature]) — artwork, date stamp,
///   name, venue, time, price, status and match.
/// * [compact]: a list row ([VibraEventRow]) with the same information
///   density reduced to one line of metadata.
///
/// Both variants log the same `view` interaction as before.
class VibraEventCard extends StatelessWidget {
  const VibraEventCard({
    required this.event,
    this.compact = false,
    this.matchScore,
    this.onTap,
    this.height = 300,
    super.key,
  });

  final Event event;
  final bool compact;
  final int? matchScore;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.pagePadding,
        ),
        child: VibraEventRow(
          event: event,
          matchScore: matchScore,
          onTap: onTap ?? () {},
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: VibraSpacing.sm,
      ),
      child: VibraEventFeature(
        event: event,
        matchScore: matchScore,
        height: height,
        onTap: onTap ?? () {},
      ),
    );
  }
}
