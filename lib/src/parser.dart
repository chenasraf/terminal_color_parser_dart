import 'interfaces.dart';
import 'reader.dart';
import 'consts.dart';
import 'token.dart';

/// A parser to parse a string with color codes.
class ColorParser implements IReader<StringTokenValue> {
  final IReader<String> reader;
  final _tokens = <StringTokenValue>[];

  ColorParser._(this.reader);

  factory ColorParser(String text) => ColorParser._(StringReader(text));

  /// Parse the text and return a list of [ColorToken]s.
  ///
  /// Each token represents a piece of text with color information. You can join all the text
  /// together (without separators) to get the original text, uncolored.
  ///
  /// To get the colored text, use the [ColorToken.formatted] property of each token.
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
    // print('');
    // print('char: ${_debugString(char ?? '<null>')}');
    // print('');

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
    final color = _consumeUntil('m');
    reader.read();
    int first, second, third = 0;

    if (color.contains(';')) { //ignore codes like [40m for now
      final colors = color.split(';');
      first = int.parse(colors[0]);
      second = colors.length > 1 ? int.tryParse(colors[1]) ?? 0 : 0;
      third = colors.length > 2 ? int.tryParse(colors[2]) ?? 0 : 0;

    // print('first: $first, second: $second, third: $third');
    int fg;
    int bg;
    if (first < 30) {
      token.setStyle(first);
      fg = second;
      bg = third;
    } else {
      if (first == 38 && second == 5) {
        token.xterm256 = true;
        fg = third;
        bg = 0;
      } else {
        fg = first;
        bg = second;
      }
    }
    token.fgColor = token.hasFgColor ? token.fgColor : fg;
    token.bgColor = token.hasBgColor ? token.bgColor : bg;
    if (reader.peek() == Consts.esc) {
      return _consumeEscSequence(token);
    }
  }
    return token;
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
