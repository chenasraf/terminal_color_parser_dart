import 'package:terminal_color_parser/terminal_color_parser.dart';
import 'package:test/test.dart';

const inputs = [
  '\x1B[32mYou are standing in a small clearing.\x1B[0m',
  'You are standing in a small clearing.',
  '\x1B[0m\x1B[1m\x1B[0m\x1B[1m\x1B[31mWelcome to SimpleMUD\x1B[0m\x1B[1m\x1B[0m',
  '\x1B[0m\x1B[37m\x1B[0m\x1B[37m\x1B[1m[\x1B[0m\x1B[37m\x1B[1m\x1B[32m10\x1B[0m\x1B[37m\x1B[1m/10]\x1B[0m\x1B[37m\x1B[0m'
];

void main() {
  group('ColorParser', () {
    test('parse colors - simple colors', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: 'You are standing in a small clearing.',
          fgColor: 32,
          bgColor: 0,
          styles: {TermStyle.reset},
        ),
      ]);
    });

    test('parse colors - no colors', () {
      final input = inputs[1];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: 'You are standing in a small clearing.',
          fgColor: 0,
          bgColor: 0,
          styles: {},
        ),
      ]);
    });

    test('formatted', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output[0].formatted, inputs[0]);
    });
  });
}
