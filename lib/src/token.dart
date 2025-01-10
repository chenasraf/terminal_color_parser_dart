import 'color.dart';
import 'consts.dart';

/// Represents a string value with color information.
///
/// Can be used to store the text and color information for a single token.
///
/// Use [ColorToken.formatted] to get the ANSI formatted text, which you can output to the console.
class ColorToken {
  /// The text content.
  String text;

  /// The foreground color code.
  Color fgColor;

  /// The background color code.
  Color bgColor;

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

  /// Whether the text is reset at the end.
  bool get reset => styles.contains(TermStyle.reset);

  /// Whether the text has a foreground color.
  bool get hasFgColor => fgColor != Color.none;

  /// Whether the text has a background color.
  bool get hasBgColor => bgColor != Color.none;

  /// The styles applied to the text.
  late Set<TermStyle> styles;

  ColorToken({
    required this.text,
    this.fgColor = Color.none,
    this.bgColor = Color.none,
    Set<TermStyle>? styles,
  }) : styles = styles ?? {};

  /// Create an empty token.
  factory ColorToken.empty() => ColorToken(text: '');

  /// Create an empty token with a reset style.
  factory ColorToken.emptyReset() => ColorToken(
        text: '',
        styles: {TermStyle.reset},
      );

  /// Create a token with default color and the given text.
  factory ColorToken.fromText(String text) =>
      ColorToken(text: text, fgColor: Color.none, bgColor: Color.none);

  /// Returns true if the text is empty.
  bool get isEmpty => text.isEmpty;

  /// Returns true if the text is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Get the formatted text as ANSI formatted text.
  ///
  /// Outputting this value to a terminal will display the text with the correct colors.
  ///
  /// To format the text in other ways, use the properties to get the [fgColor], [bgColor],
  /// and other [styles], and construct it to the desired output format.
  String get formatted {
    final parts = <String>[];
    var post = '';

    // foreground
    if (fgColor is RGBColor) {
      parts.add('38;2;${fgColor.formatted}');
    } else if (fgColor.isNotNone) {
      parts.add(fgColor.formatted);
    }

    // background
    if (bgColor is RGBColor) {
      parts.add('48;2;${bgColor.formatted}');
    } else if (bgColor.isNotNone) {
      parts.add(bgColor.formatted);
    }

    // other styles
    final styleParts = styles
        .where((s) => s != TermStyle.reset)
        .map((s) => Consts.codeMap[s]?.toString())
        .whereType<String>();
    parts.addAll(styleParts);

    if (reset) {
      post = _tokenString(Consts.codeMap[TermStyle.reset].toString());
    }

    // collct all tokens
    final tokens = _tokenString(parts.where((s) => s.isNotEmpty).join(';'));

    return '$tokens$text$post';
  }

  @override
  String toString() => 'ColorToken(${debugProperties().join(', ')})';

  /// Returns a list of debug properties.
  List<String> debugProperties() => [
        'text: "${_debugString(text)}"',
        'fgColor: $fgColor',
        'bgColor: $bgColor',
        'styles: ${styles.map((s) => s.name)}',
      ];

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
          bgColor == other.bgColor &&
          styles.length == other.styles.length &&
          styles.containsAll(other.styles);

  /// Set the style based on the given code.
  void setStyle(int code) {
    for (final style in Consts.codeMap.entries) {
      if (code == style.value) {
        styles.add(style.key);
        return;
      }
    }
  }

  _debugString(String string) => string.replaceAll('\x1B', '\\x1B');
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

