import 'package:flutter/material.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Campo sobrio con focus echo: sostituisce search/input pill e glass.
class VibraInput extends StatefulWidget {
  const VibraInput({
    required this.hintText,
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool autofocus;

  @override
  State<VibraInput> createState() => _VibraInputState();
}

class _VibraInputState extends State<VibraInput> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
          bottom: BorderSide(
            color: _focused ? t.accentPrimary : t.borderDefault,
            width: _focused ? 2 : 1,
          ),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        style: VibraTextStyles.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: widget.hintText,
          hintStyle: VibraTextStyles.bodyMedium.copyWith(
            color: t.textSecondary,
          ),
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: t.textPrimary, size: 20),
          suffixIcon: widget.suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
