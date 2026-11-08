/// VIBRA component library.
///
/// Import this single file to access every design-system component. All
/// components read colours, type, spacing and motion from the centralized
/// tokens in `lib/core/theme/`.
///
/// | Spec name               | Implementation                         |
/// |-------------------------|----------------------------------------|
/// | VibraPrimaryButton      | common/vibra_button.dart               |
/// | VibraSecondaryButton    | common/vibra_button.dart               |
/// | VibraTextField          | common/vibra_input.dart                |
/// | VibraEventCard          | common/vibra_event_card.dart           |
/// | VibraUserCard           | common/vibra_user_match_card.dart      |
/// | VibraMatchIndicator     | common/vibra_match_indicator.dart      |
/// | VibraBottomNavigation   | common/vibra_bottom_navigation.dart    |
/// | VibraSectionHeader      | common/vibra_section_header.dart       |
/// | VibraAvatar             | common/vibra_avatar.dart               |
/// | VibraBadge              | common/vibra_badge.dart                |
/// | VibraLoadingIndicator   | common/vibra_state_views.dart          |
/// | VibraEmptyState         | common/vibra_state_views.dart          |
/// | VibraErrorState         | common/vibra_state_views.dart          |
/// | VibraBottomSheet        | common/vibra_bottom_sheet.dart         |
library;

export '../../core/theme/vibra_motion.dart';
export '../../core/theme/vibra_spacing.dart';
export '../../core/theme/vibra_text_styles.dart';
export '../../core/theme/vibra_theme_tokens.dart';
export 'common/vibra_avatar.dart';
export 'common/vibra_badge.dart';
export 'common/vibra_bottom_navigation.dart';
export 'common/vibra_bottom_sheet.dart';
export 'common/vibra_button.dart';
export 'common/vibra_editorial_event.dart';
export 'common/vibra_event_card.dart';
export 'common/vibra_event_meta.dart';
export 'common/vibra_image.dart';
export 'common/vibra_input.dart';
export 'common/vibra_logo.dart';
export 'common/vibra_match_indicator.dart';
export 'common/vibra_page_scaffold.dart';
export 'common/vibra_section_header.dart';
export 'common/vibra_state_views.dart';
export 'common/vibra_surface.dart';
export 'common/vibra_user_match_card.dart';
