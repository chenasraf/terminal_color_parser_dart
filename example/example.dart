import 'package:terminal_color_parser/terminal_color_parser.dart';

void main(List<String> args) async {
  final coloredText = ColorParser('Hello, \x1B[32mworld\x1B[0m!').parse();

  print(coloredText);
  // ==> ColoredText("Hello, ", 0:0, , ()), ColoredText("world", 32:0, , ()), ColoredText("!", 0:0, , ())]

  var i = 0;
  for (final token in coloredText) {
    dbg(i, token);
    i++;
  }

  print('');
  print('');

  // Construct your own colored text
  final tokens = [
    ColorToken(text: 'Hello, ', fgColor: 0, bgColor: 0),
    ColorToken(
      text: 'world',
      fgColor: 32,
      bgColor: 0,
      styles: {TermStyle.underline},
    ),
    ColorToken(text: '!', fgColor: 0, bgColor: 0),
  ];

  i = 0;
  for (final token in tokens) {
    dbg(i, token);
    i++;
  }

  print('');
  print(tokens.map((t) => t.formatted).join(''));
}

void dbg(int i, ColorToken token) {
  print('Token #$i: ${token.formatted}');
  print('  - Text: ${token.text}');
  print('  - Foreground: ${token.fgColor}');
  print('  - Background: ${token.bgColor}');
  print('  - Bold: ${token.bold}');
  print('  - Italic: ${token.italic}');
  print('  - Underline: ${token.underline}');
  print('  - Styles: ${token.styles}');
}

