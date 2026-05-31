import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppIcons {
  AppIcons._();

  // Navigation Icons
  static IconData get arrowLeft => PhosphorIconsBold.caretLeft;
  static IconData get arrowRight => PhosphorIconsBold.caretRight;
  static IconData get close => PhosphorIconsBold.x;

  // Feedback & Status Icons
  static IconData get checkCircleFill => PhosphorIconsFill.checkCircle;
  static IconData get checkCircleRegular => PhosphorIconsRegular.checkCircle;
  static IconData get info => PhosphorIconsRegular.info;

  // Toast Status Icons
  static IconData get toastSuccess => PhosphorIconsBold.checkCircle;
  static IconData get toastError => PhosphorIconsBold.warningCircle;
  static IconData get toastInfo => PhosphorIconsBold.info;

  // Gender Icons
  static IconData get genderFemale => PhosphorIconsBold.genderFemale;
  static IconData get genderMale => PhosphorIconsBold.genderMale;
  static IconData get genderNeuter => PhosphorIconsBold.user;
  static IconData get sparkle => PhosphorIconsBold.sparkle;
  static IconData get textSize => PhosphorIconsBold.textT;

  // Audio Player Icons
  static IconData get play => PhosphorIconsBold.play;
  static IconData get pause => PhosphorIconsBold.pause;
  static IconData get skipBack => PhosphorIconsBold.skipBack;
  static IconData get skipForward => PhosphorIconsBold.skipForward;
  static IconData get rewind => PhosphorIconsBold.rewind;
  static IconData get fastForward => PhosphorIconsBold.fastForward;
}
