import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_event_card.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../../domain/entities/event.dart';

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEvents = [...ref.watch(myEventsProvider).going, ...ref.watch(savedEventsProvider)];
    
    // Rimuovi duplicati (se un evento è sia going che saved per qualche motivo)
    final uniqueEvents = <String, Event>{};
    for (final e in allEvents) {
      uniqueEvents[e.id] = e;
    }
    
    final now = DateTime.now();
    final upcoming = uniqueEvents.values.where((e) => e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now)).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
      
    final past = uniqueEvents.values.where((e) => e.eventDate.isBefore(now)).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate)); // Più recenti prima

    final l10n = AppLocalizations.of(context)!;

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.myEventsTitle)),
      child: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 8, bottom: 24)),
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: 'In Arrivo', // Sarebbe ideale estrarlo in l10n, hardcoded temporaneamente
              subtitle: l10n.myEventsGoingSubtitle,
            ),
          ),
          if (upcoming.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(
                context,
                icon: Icons.calendar_today_rounded,
                message: l10n.myEventsGoingEmpty,
              ),
            )
          else
            SliverList.builder(
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                return VibraEventCard(
                  event: upcoming[index],
                  compact: true,
                  onTap: () => context.push('/event-detail', extra: upcoming[index]),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: 'Passati',
              subtitle: 'Il tuo storico eventi',
            ),
          ),
          if (past.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(
                context,
                icon: Icons.history_rounded,
                message: 'Non hai ancora eventi passati.',
              ),
            )
          else
            SliverList.builder(
              itemCount: past.length,
              itemBuilder: (context, index) {
                return VibraEventCard(
                  event: past[index],
                  compact: true,
                  onTap: () => context.push('/event-detail', extra: past[index]),
                );
              },
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
