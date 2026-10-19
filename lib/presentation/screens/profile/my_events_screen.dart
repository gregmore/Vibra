import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_event_card.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';

enum _EventFilter { upcoming, saved, past }

class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen> {
  final _searchController = TextEditingController();
  _EventFilter _filter = _EventFilter.upcoming;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final myEvents = ref.watch(myEventsProvider);
    // One event can be both saved and confirmed: show it once in the agenda.
    final unique = {
      for (final event in [...myEvents.saved, ...myEvents.going])
        event.id: event,
    };
    final now = DateTime.now();
    final upcoming =
        unique.values.where((event) => !event.eventDate.isBefore(now)).toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final past =
        unique.values.where((event) => event.eventDate.isBefore(now)).toList()
          ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    final saved = {
      for (final event in myEvents.saved) event.id: event,
    }.values.toList()..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final groups = {
      _EventFilter.upcoming: upcoming,
      _EventFilter.saved: saved,
      _EventFilter.past: past,
    };
    final labels = {
      _EventFilter.upcoming: l10n.myEventsUpcoming,
      _EventFilter.saved: l10n.myEventsSaved,
      _EventFilter.past: l10n.myEventsPast,
    };
    final events = groups[_filter]!.where((event) {
      return [event.name, event.artistName, event.venueName, event.city]
          .whereType<String>()
          .any((value) => value.toLowerCase().contains(_query));
    }).toList();
    final subtitle = switch (_filter) {
      _EventFilter.upcoming => l10n.myEventsGoingSubtitle,
      _EventFilter.saved => l10n.myEventsSavedSubtitle,
      _EventFilter.past => l10n.myEventsPastSubtitle,
    };

    return VibraPageScaffold(
      useGradient: false,
      appBar: AppBar(title: Text(l10n.myEventsTitle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: VibraInput(
              controller: _searchController,
              hintText: l10n.myEventsSearchHint,
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              suffix: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.myEventsClearSearch,
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final filter in _EventFilter.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${labels[filter]} (${groups[filter]!.length})',
                      ),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              subtitle,
              style: VibraTextStyles.bodyMedium.copyWith(
                color: t.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(myEventsProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  if (events.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _emptyState(context, l10n),
                    )
                  else
                    SliverList.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) => VibraEventCard(
                        key: ValueKey(events[index].id),
                        event: events[index],
                        compact: true,
                        onTap: () =>
                            context.push('/event-detail', extra: events[index]),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    final searching = _query.isNotEmpty;
    final message = searching
        ? l10n.myEventsSearchEmpty
        : switch (_filter) {
            _EventFilter.upcoming => l10n.myEventsGoingEmpty,
            _EventFilter.saved => l10n.myEventsSavedEmpty,
            _EventFilter.past => l10n.myEventsPastEmpty,
          };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: VibraSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                searching ? Icons.search_off_rounded : Icons.event_note_rounded,
                size: 36,
                color: context.vibraTokens.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                message.replaceAll(r'\n', '\n'),
                textAlign: TextAlign.center,
                style: VibraTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              VibraButton(
                label: searching
                    ? l10n.myEventsClearSearch
                    : l10n.myEventsExplore,
                leadingIcon: searching
                    ? Icons.close_rounded
                    : Icons.explore_outlined,
                onPressed: searching
                    ? _clearSearch
                    : () => context.go('/explore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
