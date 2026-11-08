import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Compact filled field for search and inline composition.
///
/// Rounded surface, no underline; focus is shown by a violet hairline and a
/// violet prefix icon so the state never relies on colour alone.
class VibraInput extends StatefulWidget {
  const VibraInput({
    required this.hintText,
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;

  @override
  State<VibraInput> createState() => _VibraInputState();
}

class _VibraInputState extends State<VibraInput> {
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant VibraInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
      _focused = _focusNode.hasFocus;
    }
  }

  void _onFocusChanged() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final radius = BorderRadius.circular(VibraSpacing.radiusMedium);
    return AnimatedContainer(
      duration: VibraMotion.durationFor(context, VibraMotion.fast),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? t.surface
            : t.surfaceElevated,
        borderRadius: radius,
        border: Border.all(
          color: _focused ? t.accentPrimary : t.borderDefault,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        // The limit is still enforced; a live counter is noise in search
        // and chat fields.
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        style: VibraTextStyles.bodyLarge.copyWith(color: t.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          isDense: true,
          hintText: widget.hintText,
          hintStyle: VibraTextStyles.bodyMedium.copyWith(
            color: t.textSecondary,
          ),
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(
                  widget.prefixIcon,
                  color: _focused ? t.accentPrimary : t.textSecondary,
                  size: VibraSpacing.iconMd,
                ),
          suffixIcon: widget.suffix,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.prefixIcon == null ? VibraSpacing.lg : 0,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

/// Form field with a label above the input, inline validation and an
/// optional visibility toggle for secrets.
class VibraTextField extends StatefulWidget {
  const VibraTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorText,
    this.helperText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.showVisibilityToggle,
    this.visibilityToggleLabel,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? errorText;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Defaults to true when [obscureText] is set.
  final bool? showVisibilityToggle;

  /// Accessible label for the visibility toggle.
  final String? visibilityToggleLabel;

  @override
  State<VibraTextField> createState() => _VibraTextFieldState();
}

class _VibraTextFieldState extends State<VibraTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final showToggle = widget.showVisibilityToggle ?? widget.obscureText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              widget.label!,
              style: VibraTextStyles.labelMedium.copyWith(
                color: t.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: _obscured,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          style: VibraTextStyles.bodyLarge.copyWith(color: t.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: VibraSpacing.iconMd),
            suffixIcon:
                widget.suffix ??
                (showToggle
                    ? IconButton(
                        tooltip: widget.visibilityToggleLabel,
                        onPressed: () => setState(() => _obscured = !_obscured),
                        icon: Icon(
                          _obscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: VibraSpacing.iconMd,
                        ),
                      )
                    : null),
          ),
        ),
      ],
    );
  }
}
