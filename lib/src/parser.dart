import 'color.dart';
import 'interfaces.dart';
import 'reader.dart';
import 'consts.dart';
import 'token.dart';

/// A parser to parse a string with color codes.
class ColorParser implements IReader<StringTokenValue> {
  /// Reader for the text.
  /// Provides method to seek, peek, read and check if it's done.
  final IReader<String> reader;
  final _tokens = <StringTokenValue>[];

  ColorParser._(this.reader);

  factory ColorParser(String text) => ColorParser._(StringReader(text));

  /// Parse the text and return a list of [ColorToken]s.
  ///
  /// Each token represents a piece of text with color information. You can join all the text
  /// together (without separators) to get the original text, uncolored.
  ///
  /// To get the colored text, use the [ColorToken.formatted] property of each token, or use the
  /// [ColorToken.fgColor], [ColorToken.bgColor] and [ColorToken.styles] properties to create
  /// your desired output format.
  List<ColorToken> parse() {
    final lexed = <ColorToken>[];
    while (!reader.isDone) {
      var cur = _getToken();
      if (cur != null) {
        lexed.add(cur);
      }
    }
    return lexed;
  }

  ColorToken? _getToken() {
    var token = ColorToken.empty();
    final char = reader.peek();
    // print('char: ${_debugString(char ?? '<null>')}');

    switch (char) {
      case null:
        return null;
      case Consts.esc:
        return _consumeEscSequence(token);
    }

    return _consumeText(token);
  }

  ColorToken _consumeEscSequence(ColorToken token) {
    // print('Consuming escape sequence for $token');
    reader.read();
    var next = reader.read();
    switch (next) {
      case '[':
        token = _consumeStyleToken(token);
    }
    return _consumeText(token);
  }

  ColorToken _consumeStyleToken(ColorToken token) {
    // print('Consuming style token for $token');
    final args = _consumeUntil('m');
    reader.read();
    token = _parseStyleToken(token, args.split(';'));
    return token;
  }

  ColorToken _parseStyleToken(ColorToken token, List<String> colors) {
    if (colors.isEmpty) {
      return token;
    }

    final colorNums = colors.map((n) => int.parse(n)).toList();
    final first = colorNums.first;

    final isRgb = _checkPair(colorNums, 38, 2) || _checkPair(colorNums, 48, 2);
    final isXterm256 =
        _checkPair(colorNums, 38, 5) || _checkPair(colorNums, 48, 5);
    final isAnsiFg =
        _checkBetween(first, 30, 37) || _checkBetween(first, 90, 97);
    final isAnsiBg =
        _checkBetween(first, 40, 47) || _checkBetween(first, 100, 107);

    // Special cases
    if (isRgb) {
      // RGB format is 38;2;R;G;B or 48;2;R;G;B
      token = _consumeRgbToken(token, colors);
      colors.removeRange(0, 5);
    } else if (isXterm256) {
      // Xterm256 format is 38;5;N or 48;5;N
      token = _consumeXterm256Token(token, colors);
      colors.removeRange(0, 3);
    } else if (isAnsiFg) {
      token.fgColor = ANSIColor.fg(first);
      colors.removeAt(0);
    } else if (isAnsiBg) {
      token.bgColor = ANSIColor.bg(first);
      colors.removeAt(0);
    } else {
      // Other style codes
      for (var color in colorNums) {
        token.setStyle(color);
        colors.removeAt(0);
      }
    }

    if (reader.peek() == Consts.esc) {
      return _consumeEscSequence(token);
    }

    if (colors.isNotEmpty) {
      token = _parseStyleToken(token, colors);
    }
    return token;
  }

  ColorToken _consumeRgbToken(ColorToken token, List<String> colors) {
    if (colors.length < 5) {
      return token;
    }
    final r = int.parse(colors[2]);
    final g = int.parse(colors[3]);
    final b = int.parse(colors[4]);
    if (colors[0] == '38') {
      token.fgColor = RGBColor.fg(r, g, b);
    } else if (colors[0] == '48') {
      token.bgColor = RGBColor.bg(r, g, b);
    }
    return token;
  }

  ColorToken _consumeXterm256Token(ColorToken token, List<String> colors) {
    if (colors.length < 3) {
      return token;
    }
    final color = int.parse(colors[2]);
    if (colors[0] == '38') {
      token.fgColor = ANSIColor.fg(color);
    } else if (colors[0] == '48') {
      token.bgColor = ANSIColor.bg(color);
    }
    return token;
  }

  bool _checkPair<T>(List<T> arr, T v1, T v2) {
    return arr.length > 1 && arr[0] == v1 && arr[1] == v2;
  }

  bool _checkBetween<T extends num>(T value, T min, T max) {
    return min <= value && value <= max;
  }

  ColorToken _consumeText(ColorToken token) {
    // print('Consuming text for $token');
    token.text += _consumeUntil(Consts.esc);
    return token;
  }

  String _consumeUntil(String char) {
    String? next = reader.peek();
    if (next == null) {
      return '';
    }
    var result = '';
    while (!reader.isDone) {
      if (next == char) {
        break;
      }
      next = reader.peek();
      if (next == null) {
        break;
      }
      result += reader.read()!;
      next = reader.peek();
    }
    return result;
  }

  // ignore: unused_element
  String _peekUntil(String char) {
    String? next = reader.peek();
    if (next == null) {
      return '';
    }
    var result = '';
    final prevPos = reader.index;
    while (!reader.isDone) {
      if (next == char) {
        break;
      }
      next = reader.peek();
      if (next == null) {
        break;
      }
      result += reader.read()!;
      next = reader.peek();
    }
    reader.setPosition(prevPos);
    return result;
  }

  // ignore: unused_element
  _debugString(String string) => string.replaceAll('\x1B', '\\x1B');

  @override
  int index = 0;

  @override
  bool get isDone => index >= reader.length;

  @override
  peek() => _tokens[index];

  @override
  read() => _tokens[index++];

  @override
  int get length => _tokens.length;

  @override
  setPosition(int position) => index = position;
}

