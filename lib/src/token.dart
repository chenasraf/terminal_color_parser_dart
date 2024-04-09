import 'consts.dart';

/// Represents a string value with color information.
///
/// Can be used to store the text and color information for a single token.
///
/// Use [ColorToken.formatted] to get the ANSI formatted text, which you can output to the console.
class ColorToken {
  /// The raw, uncoded text.
  String text;

  /// The foreground color code.
  int fgColor;

  /// The background color code.
  int bgColor;

  /// Whether the text is bold.
  bool get bold => styles.contains(TermStyle.bold);

  /// Whether the text is italic.
  bool get italic => styles.contains(TermStyle.italic);

  /// Whether the text is underlined.
  bool get underline => styles.contains(TermStyle.underline);

  /// Whether the text is dim.
  bool get dim => styles.contains(TermStyle.dim);

  /// Whether the text is slow blinking.
  bool get slowBlink => styles.contains(TermStyle.slowBlink);

  /// Whether the text is rapid blinking.
  bool get rapidBlink => styles.contains(TermStyle.rapidBlink);

  /// Whether the text's colors should be inverse.
  bool get inverse => styles.contains(TermStyle.inverse);

  /// Whether the text is concealed.
  bool get conceal => styles.contains(TermStyle.conceal);

  /// Whether the text is struck out.
  bool get strikeout => styles.contains(TermStyle.strikeout);

  /// Whether the text is an xterm256 color code. Otherwise, it is a standard color code.
  bool xterm256;

  /// The styles applied to the text.
  late Set<TermStyle> styles;

  ColorToken({
    required this.text,
    required this.fgColor,
    required this.bgColor,
    this.xterm256 = false,
    Set<TermStyle>? styles,
  }) : styles = styles ?? {};

  /// Create an empty token.
  factory ColorToken.empty() => ColorToken(text: '', fgColor: 0, bgColor: 0);

  /// Create a token with default color and the given text.
  factory ColorToken.defaultColor(String text) =>
      ColorToken(text: text, fgColor: 0, bgColor: 0);

  /// Returns true if the text is empty.
  bool get isEmpty => text.isEmpty;

  /// Returns true if the text is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Get the formatted text as ANSI formatted text.
  ///
  /// Outputting this value to a terminal will display the text with the correct colors.
  ///
  /// To format the text in other ways, use the properties to get the [fgColor] and [bgColor],
  /// and construct it to whatever format you need.
  String get formatted {
    var colorCodes = '';
    if (xterm256) {
      colorCodes = '38;5;$fgColor';
      if (bgColor != 0) {
        colorCodes += ';48;5;$bgColor';
      }
    } else {
      colorCodes = fgColor == 0 ? '' : '$fgColor';
      if (bgColor != 0) {
        colorCodes += ';$bgColor';
      }
    }
    final styleCodes = styles.isNotEmpty ? styles.map((s) => Consts.codeMap[s]).join(';') : '';

    final tokens = _tokenString([colorCodes, styleCodes].where((s) => s.isNotEmpty).join(';'));
    final reset = _tokenString(Consts.resetByte.toString());

    return '$tokens$text$reset';
  }

  @override
  String toString() {
    final x = xterm256 ? 'x' : '';
    return 'ColoredText("$text", $fgColor:$bgColor, $x, ${styles.map((s) => s.name)})';
  }

  String _tokenString(String content) => '\x1B[${content}m';

  @override
  int get hashCode => text.hashCode ^ fgColor.hashCode ^ bgColor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorToken &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          fgColor == other.fgColor &&
          bgColor == other.bgColor;

  /// Set the style based on the given code.
  void setStyle(int code) {
    if (code == Consts.resetByte) {
      styles.clear();
    } else {
      for (final style in Consts.codeMap.entries) {
        if (code == style.value) {
          styles.add(style.key);
          return;
        }
      }
    }
  }
}

/// An enum that represents the different types of string tokens that can be read.
enum StringToken {
  /// An escape character.
  ///
  /// `\x1B`
  esc,

  /// A color start token.
  ///
  /// `[`
  colorStart,

  /// A color terminator token.
  ///
  /// `m`
  colorTerm,

  /// A color separator token.
  ///
  /// `;`
  colorSeparator,

  /// A literal token.
  ///
  /// (any other character)
  literal,
}

/// A class that represents a string token and contains its raw value.
class StringTokenValue {
  /// The token type.
  final StringToken token;

  /// The raw value of the token.
  final String raw;

  const StringTokenValue(this.token, this.raw);

  /// A token representing an escape character.
  static const esc = StringTokenValue(StringToken.esc, Consts.esc);

  /// A token representing a color start character.
  static const colorStart = StringTokenValue(StringToken.colorStart, '[');

  /// A token representing a color separator character.
  static const colorSeparator =
      StringTokenValue(StringToken.colorSeparator, ';');

  /// A token representing a color terminator character.
  static const colorTerm = StringTokenValue(StringToken.colorTerm, 'm');

  /// A token representing an empty literal.
  static const empty = StringTokenValue(StringToken.literal, '');

  /// A token representing a literal value.
  StringTokenValue.literal(String raw) : this(StringToken.literal, raw);

  @override
  int get hashCode => raw.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringTokenValue &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          raw == other.raw;

  @override
  String toString() =>
      token != StringToken.esc ? '${token.name}($raw)' : token.name;
}
