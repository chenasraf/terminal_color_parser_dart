/// The color mode, either foreground or background.
enum ColorMode { foreground, background }

/// Represents a color in the terminal.
/// This is a base class for all color types.
class Color {
  /// The value of the color
  final dynamic value;

  /// The mode of the color, either foreground or background.
  final ColorMode mode;

  /// Creates a new color with the given value and mode.
  const Color(this.value, this.mode);

  /// Creates a new foreground color with the given value.
  const Color.fg(this.value) : mode = ColorMode.foreground;

  /// Creates a new background color with the given value.
  const Color.bg(this.value) : mode = ColorMode.background;

  /// This color should be ignored for rendering.
  static const Color none = Color.fg(0);

  /// Returns true if the color is the default color.
  bool get isNone => value == 0;

  /// Returns true is the color is not the default color.
  bool get isNotNone => !isNone;

  /// The formatted value of the color, used in ANSI escape codes.
  String get formatted => value.toString();

  /// The string representation of the color mode.
  String get modeString => mode.toString().split('.').last;

  @override
  String toString() => isNone ? 'Color.none' : 'Color($value, $modeString)';

  @override
  operator ==(Object other) {
    if (other is Color) {
      return value == other.value;
    }
    return value == other;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents an RGB color in the terminal.
class RGBColor extends Color {
  /// The red value of the color.
  final int red;

  /// The green value of the color.
  final int green;

  /// The blue value of the color.
  final int blue;

  /// Creates a new RGB color with the given red, green, and blue values.
  const RGBColor(
    this.red,
    this.green,
    this.blue, [
    ColorMode mode = ColorMode.foreground,
  ]) : super('$red;$green;$blue', mode);

  /// Creates a new RGB foreground color with the given red, green, and blue values.
  const RGBColor.fg(
    this.red,
    this.green,
    this.blue,
  ) : super('$red;$green;$blue', ColorMode.foreground);

  /// Creates a new RGB background color with the given red, green, and blue values.
  const RGBColor.bg(
    this.red,
    this.green,
    this.blue,
  ) : super('$red;$green;$blue', ColorMode.background);

  @override
  String get formatted => '$formattedMode;$red;$green;$blue';

  /// The formatted mode of the color, used in ANSI escape codes.
  /// It is usually followed by the r;g;b components of the color.
  String get formattedMode => mode == ColorMode.foreground ? '38;2' : '48;2';

  @override
  String toString() => isNone ? 'RGBColor.none' : 'RGBColor($red, $green, $blue)';
}

class ANSIColor extends Color {
  final int color;

  /// Creates a new ANSI color with the given value.
  ANSIColor(this.color)
      : super(
            color,
            isForegroundColor(color)
                ? ColorMode.foreground
                : ColorMode.background);

  /// Creates a new ANSI foreground color with the given value.
  const ANSIColor.fg(this.color) : super.fg(color);

  /// Creates a new ANSI background color with the given value.
  const ANSIColor.bg(this.color) : super.bg(color);

  /// Returns true if the color is a foreground color.
  bool get isForeground => mode == ColorMode.foreground;

  /// Returns true if the color is a background color.
  bool get isBackground => mode == ColorMode.background;

  /// Returns true if the color is a foreground color.
  static bool isForegroundColor(int color) =>
      ((color >= 30 && color <= 37) || (color >= 90 && color <= 97));

  /// Returns true if the color is a background color.
  static bool isBackgroundColor(int color) =>
      ((color >= 40 && color <= 47) || (color >= 100 && color <= 107));

  @override
  String get formatted => color.toString();

  @override
  String toString() => isNone ? 'ANSIColor.none' : 'ANSIColor($color)';
}

