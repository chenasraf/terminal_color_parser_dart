class Consts {
  /// A newline character.
  static const newline = '\n';

  /// A carriage return character.
  static const cr = '\r';

  /// A form feed character.
  static const lf = '\n';

  /// An escape character.
  static const esc = '\x1B';

  /// The pattern to match color codes.
  static const colorPatternRaw = r'\[\d*m';

  /// The byte to indicate reset text.
  static const resetByte = 0;

  /// The byte to indicate bold text.
  static const boldByte = 1;

  /// The byte to indicate dim text.
  static const dimByte = 2;

  /// The byte to indicate italic text.
  static const italicByte = 3;

  /// The byte to indicate underlined text.
  static const underlineByte = 4;

  /// The byte to indicate slow blinking text.
  static const slowBlinkByte = 5;

  /// The byte to indicate rapid blinking text.
  static const rapidBlinkByte = 6;

  /// The byte to indicate inverse text.
  static const inverseByte = 7;

  /// The byte to indicate concealed text.
  static const concealByte = 8;

  /// The byte to indicate strikethrough text.
  static const strikeoutByte = 9;

  /// The byte to indicate a font change.
  static const fontByte = 10;

  /// Map of style bytes to their corresponding integer values.
  static final codeMap = <TermStyle, int>{
    TermStyle.reset: resetByte,
    TermStyle.bold: boldByte,
    TermStyle.dim: dimByte,
    TermStyle.italic: italicByte,
    TermStyle.underline: underlineByte,
    TermStyle.slowBlink: slowBlinkByte,
    TermStyle.rapidBlink: rapidBlinkByte,
    TermStyle.inverse: inverseByte,
    TermStyle.conceal: concealByte,
    TermStyle.strikeout: strikeoutByte,
    TermStyle.font: fontByte,
  };
}

/// Enum representing the different style bytes.
/// This is an incomplete, but representative list.
enum TermStyle {
  /// Reset all styles.
  reset,

  /// Bold text.
  bold,

  /// Dim/low intensity text.
  dim,

  /// Italic text.
  italic,

  /// Underlined text.
  underline,

  /// Slow blinking text.
  slowBlink,

  /// Rapid blinking text.
  rapidBlink,

  /// Inverse text colors (swap foreground and background colors).
  inverse,

  /// Concealed text (hidden).
  conceal,

  /// Strikethrough text.
  strikeout,

  /// Change font.
  font,
}

