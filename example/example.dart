import 'package:terminal_color_parser/src/color.dart';
import 'package:terminal_color_parser/terminal_color_parser.dart';

void main(List<String> args) async {
  final coloredText = ColorParser('Hello, \x1B[32mworld\x1B[0m!').parse();

  print(coloredText);
  // ==> ColorToken("Hello, ", 0:0, , ()), ColorToken("world", 32:0, , ()), ColorToken("!", 0:0, , ())]

  var i = 0;
  for (final token in coloredText) {
    dbg(i, token);
    i++;
  }

  print('');
  print('');

  // Construct your own colored text
  final tokens = [
    ColorToken(text: 'Hello, '),
    ColorToken(
      text: 'world',
      fgColor: Color.fg(32),
      styles: {TermStyle.underline,TermStyle.reset},
    ),
    ColorToken(text: '!', styles: {TermStyle.bold}),
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
  print('Token #$i: ${token.formatted}\x1B[0m');
  print('  - Text: ${token.text}');
  print('  - Foreground: ${token.fgColor}');
  print('  - Background: ${token.bgColor}');
  print('  - Bold: ${token.bold}');
  print('  - Italic: ${token.italic}');
  print('  - Underline: ${token.underline}');
  print('  - Styles: ${token.styles}');
}
