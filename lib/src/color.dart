class Color {
  final dynamic value;

  const Color(this.value);

  static const Color none = Color(0);

  String get formatted => value.toString();

  @override
  String toString() => 'Color($value)';

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

class RGBColor extends Color {
  final int red;
  final int green;
  final int blue;

  const RGBColor(this.red, this.green, this.blue) : super('$red;$green;$blue');

  @override
  String get formatted => '$red;$green;$blue';

  String get formattedForeground => '38;2;$formatted';
  String get formattedBackground => '48;2;$formatted';

  @override
  String toString() => 'RGBColor($red, $green, $blue)';
}

class ANSIColor extends Color {
  final int color;

  const ANSIColor(this.color) : super(color);

  bool get isForeground => (color >= 30 && color <= 37) && (color >= 90 && color <= 97);
  bool get isBackground => (color >= 40 && color <= 47) && (color >= 100 && color <= 107);

  @override
  String get formatted => color.toString();

  @override
  String toString() => 'ANSIColor($color)';
}

