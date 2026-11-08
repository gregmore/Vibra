import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Shared by onboarding and profile editing; injectable for gallery QA.
final profileImagePickerProvider = Provider<ImagePicker>(
  (ref) => ImagePicker(),
);
