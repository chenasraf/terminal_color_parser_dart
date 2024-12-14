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

    if (!color.contains(';')) {
      //single number color [30-37] / [40-47]
      // or [90-97] / [100-107], fg / bg
      // e.g. ^[40m
      // or just style ? e.g. ^[1m

      // TODO: this seems to crash on ^[40m, don't understand exactly why
      // doesn't seem to be the 40m, that one gets interpreted well (black bg)

      int colorValue = -1;
      try {
        colorValue = int.parse(color);
      } on FormatException {
        // ignore, then??
        // print("failing color= " + color);
        // TODO: it keeps logging thousands of empty "failing colors" ?
      }
      if (colorValue > -1) { // init safely, ignore if nothing ?
        if ((30 <= colorValue) && (colorValue <= 37) ||
            (90 <= colorValue) && (colorValue <= 97)) {
          token.fgColor = colorValue;
        } else if ((40 <= colorValue) && (colorValue <= 47) ||
            (100 <= colorValue) && (colorValue <= 107)) {
          token.bgColor = colorValue;
        } else if (colorValue < 30) { // style ?
          token.setStyle(colorValue);
        }
      }
    }
    // things like  ^[1;38;2;114;150;50;48;2;125;70;22m TEXT ^[0m
    else { // multi number madness, trying recursive parser ?
      final colors = color.split(';');
      processTokenStyle(colors, token); //really hope this works by reference
    }
    if (reader.peek() == Consts.esc) {
      return _consumeEscSequence(token);
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

  processTokenStyle(List<String> colors, ColorToken token){
    if (colors.isNotEmpty) { //if it's already empty, do nothing more
      int first = int.parse(colors[0]);
      if (first < 30) { // bold, underline, etc?
        token.setStyle(first);
        colors.removeAt(0);
      } else if((30 <= first) && (first <= 37) || (90 <= first) && (first <= 97) ||
          (40 <= first) && (first <= 47) || (100 <= first) && (first <= 107)){
        if((30 <= first) && (first <= 37) || (90 <= first) && (first <= 97)) {
          token.fgColor = first ;
          colors.removeAt(0);
        }else if((40 <= first) && (first <= 47) || (100 <= first) && (first <= 107)) {
          token.bgColor = first;
          colors.removeAt(0);
        }
      }else {
        int second = int.parse(colors[1]);
        if (first == 38 && second == 5) {
          token.xterm256 = true;
          int third = int.parse(colors[2]);
          token.fgColor = third;
          colors.removeRange(0, 3);
          // bg = 0;
        } else if (first == 48 && second == 5) {
          token.xterm256 = true;
          int third = int.parse(colors[2]);
          token.bgColor = third;
          colors.removeRange(0, 3);
          // bg = 0;
        } else  {
          if (first == 38 && second == 2) { //rgb
            String red = colors[2];
            String green = colors[3];
            String blue = colors[4];
            token.rgbFg = true;
            token.rgbFgColor = "$red;$green;$blue";
            colors.removeRange(0, 5);
          } else if (first == 48 && second == 2) { //rgb
            String red = colors[2];
            String green = colors[3];
            String blue = colors[4];
            token.rgbBg = true;
            token.rgbBgColor = "$red;$green;$blue";
            colors.removeRange(0, 5);
          }
          else {
            return;
          }
        }
      }
      //pass the rest of the color codes, hope for the best
      if(colors.isNotEmpty) {
        processTokenStyle(colors, token); // really really hoping these go by reference
      }
    }
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

