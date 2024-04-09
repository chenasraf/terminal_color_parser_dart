# Terminal Color Parser

This package is an ANSI/xterm256 color parser. You can get the list of colored segments by creating
a `ColorParser` instance and calling `parse()` method.

```dart
import 'package:terminal_color_parser/terminal_color_parser.dart';

final coloredText = ColorParser('Hello, \x1B[32mworld\x1B[0m!').parse();

print(coloredText);
// ==> ColoredText("Hello, ", 0:0, , ()), ColoredText("world", 32:0, , ()), ColoredText("!", 0:0, , ())]

var i = 0;
for (final token in coloredText) {
  print('Token #$i: ${token.formatted}');
  print('  - Text: ${token.text}');
  print('  - Foreground: ${token.fgColor}');
  print('  - Background: ${token.bgColor}');
  print('  - Bold: ${token.bold}');
  print('  - Italic: ${token.italic}');
  print('  - Underline: ${token.underline}');
  print('  - Styles: ${token.styles}');
  i++;
}
```

You can also re-format the ANSI codes by using the `formatted` property on each token.

```dart
final tokens = [
  ColorToken(text: 'Hello, ', fgColor: 0, bgColor: 0),
  ColorToken(
    text: 'world',
    fgColor: 32,
    bgColor: 0,
    styles: {StyleByte.underline},
  ),
  ColorToken(text: '!', fgColor: 0, bgColor: 0),
];

var i = 0;
for (final token in coloredText) {
  print('Token #$i: ${token.formatted}');
  print('  - Text: ${token.text}');
  print('  - Foreground: ${token.fgColor}');
  print('  - Background: ${token.bgColor}');
  print('  - Bold: ${token.bold}');
  print('  - Italic: ${token.italic}');
  print('  - Underline: ${token.underline}');
  print('  - Styles: ${token.styles}');
  i++;
}
```

## Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.
