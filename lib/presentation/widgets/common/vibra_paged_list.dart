import 'package:flutter/material.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../l10n/app_localizations.dart';
import 'vibra_state_views.dart';

/// A lazily built list that loads the next page as it nears its end
/// (docs/performance.md). The first page comes from a provider, so pull to
/// refresh and invalidation keep working: a new [first] list starts over.
///
/// [loadMore] receives the last item shown and returns the following page;
/// a page shorter than [pageSize] is the last one.
class VibraPagedList<T> extends StatefulWidget {
  const VibraPagedList({
    required this.first,
    required this.pageSize,
    required this.loadMore,
    required this.itemKey,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(VibraSpacing.pagePadding),
    this.onRefresh,
    super.key,
  });

  final List<T> first;
  final int pageSize;
  final Future<List<T>> Function(T last) loadMore;
  final Object Function(T item) itemKey;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;

  @override
  State<VibraPagedList<T>> createState() => _VibraPagedListState<T>();
}

class _VibraPagedListState<T> extends State<VibraPagedList<T>> {
  late List<T> _items;
  late bool _done;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant VibraPagedList<T> old) {
    super.didUpdateWidget(old);
    if (!identical(old.first, widget.first)) _reset();
  }

  void _reset() {
    _items = List.of(widget.first);
    _done = widget.first.length < widget.pageSize;
    _loading = false;
    _failed = false;
  }

  Future<void> _more() async {
    if (_loading || _done || _failed || _items.isEmpty) return;
    final first = widget.first;
    setState(() => _loading = true);
    try {
      final page = await widget.loadMore(_items.last);
      if (!mounted || !identical(first, widget.first)) return;
      final known = {for (final x in _items) widget.itemKey(x)};
      setState(() {
        _items.addAll(page.where((x) => !known.contains(widget.itemKey(x))));
        _done = page.length < widget.pageSize;
        _loading = false;
      });
    } catch (_) {
      // Keep what is shown; scrolling again retries.
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 600) _more();
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        itemCount: _items.length + (_done ? 0 : 1),
        itemBuilder: (context, i) {
          if (i == _items.length) {
            if (_failed) {
              return Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _failed = false);
                    _more();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppLocalizations.of(context)!.commonRetry),
                ),
              );
            }
            // Short first screens never scroll: ask for the next page here.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _more();
            });
            return const Padding(
              padding: EdgeInsets.all(VibraSpacing.md),
              child: VibraLoadingIndicator(),
            );
          }
          final item = _items[i];
          return KeyedSubtree(
            key: ValueKey(widget.itemKey(item)),
            child: widget.itemBuilder(context, item),
          );
        },
      ),
    );
    final refresh = widget.onRefresh;
    return refresh == null
        ? list
        : RefreshIndicator(onRefresh: refresh, child: list);
  }
}
