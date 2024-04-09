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
      final token = reader.read()!;
      var cur = _getToken(token);
      lexed.add(cur);
    }
    return lexed;
  }

  ColorToken _getToken(String char) {
    final token = ColorToken.empty();
    switch (char) {
      case Consts.esc:
        String? next;
        // keep reading until we hit the end of the escape sequence or the end of the string
        while (!reader.isDone) {
          next = reader.peek();
          if (next == Consts.esc) {
            break;
          }
          reader.read();
          if (next == '[') {
            final color = _consumeUntil('m');
            reader.read();
            final colors = color.split(';');
            final first = int.tryParse(colors[0]) ?? 0;
            final second = colors.length > 1 ? int.tryParse(colors[1]) ?? 0 : 0;
            final third = colors.length > 2 ? int.tryParse(colors[2]) ?? 0 : 0;
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
            token.fgColor = fg;
            token.bgColor = bg;
            token.text = _consumeUntil(Consts.esc);
            return token;
          }
          if (next == null) {
            break;
          }
          token.text += next;
        }
        return token;
      default:
        token.text += char;
        token.text += _consumeUntil(Consts.esc);
        return token;
    }
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

