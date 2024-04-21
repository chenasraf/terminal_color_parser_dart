import 'package:terminal_color_parser/terminal_color_parser.dart';
import 'package:test/test.dart';

const inputs = [
  '\x1B[32mYou are standing in a small clearing.\x1B[0m',
  'You are standing in a small clearing.',
  '\x1B[0m\x1B[1m\x1B[0m\x1B[1m\x1B[31mWelcome to SimpleMUD\x1B[0m\x1B[1m\x1B[0m',
  '\x1B[0m\x1B[37m\x1B[0m\x1B[37m\x1B[1m[\x1B[0m\x1B[37m\x1B[1m\x1B[32m10\x1B[0m\x1B[37m\x1B[1m/10]\x1B[0m\x1B[37m\x1B[0m',
  '\x1B[0m"If you are ready to advance, young fellow, you may \x1B[1m\x1B[33mtrain\x1B[0m here."\x1B[0m\x1B[1m\x1B[0m',
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
          styles: {},
          // styles: {TermStyle.reset},
        ),
        ColorToken.emptyReset(),
      ]);
    });
    test('parse colors - simple colors 2', () {
      final input = inputs[4];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: '"If you are ready to advance, young fellow, you may ',
          fgColor: 0,
          bgColor: 0,
          styles: {TermStyle.reset},
        ),
        ColorToken(
          text: 'train',
          fgColor: 33,
          bgColor: 0,
          styles: {TermStyle.bold},
        ),
        ColorToken(
          text: ' here."',
          fgColor: 0,
          bgColor: 0,
          styles: {TermStyle.reset},
        ),
        ColorToken(
          text: '',
          fgColor: 0,
          bgColor: 0,
          styles: {TermStyle.reset, TermStyle.bold},
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
      expect(output[0].formatted,
          inputs[0].substring(0, inputs[0].indexOf('\x1B[0m')));
    });
  });
}
