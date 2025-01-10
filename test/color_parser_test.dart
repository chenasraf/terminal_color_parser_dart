import 'package:terminal_color_parser/src/color.dart';
import 'package:terminal_color_parser/terminal_color_parser.dart';
import 'package:test/test.dart';

const inputs = [
  '\x1B[32mYou are standing in a small clearing.\x1B[0m',
  'You are standing in a small clearing.',
  '\x1B[0m\x1B[1m\x1B[0m\x1B[1m\x1B[31mWelcome to SimpleMUD\x1B[0m\x1B[1m\x1B[0m',
  '\x1B[0m\x1B[37m\x1B[0m\x1B[37m\x1B[1m[\x1B[0m\x1B[37m\x1B[1m\x1B[32m10\x1B[0m\x1B[37m\x1B[1m/10]\x1B[0m\x1B[37m\x1B[0m',
  '\x1B[0m"If you are ready to advance, young fellow, you may \x1B[1m\x1B[33mtrain\x1B[0m here."\x1B[0m\x1B[1m\x1B[0m',
  '\x1B[38;2;255;0;0mRed\x1B[0m',
];

void main() {
  group('ColorParser', () {
    test('parse colors - simple colors', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: 'You are standing in a small clearing.',
          fgColor: ANSIColor(32),
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
          styles: {TermStyle.reset},
        ),
        ColorToken(
          text: 'train',
          fgColor: ANSIColor(33),
          styles: {TermStyle.bold},
        ),
        ColorToken(
          text: ' here."',
          styles: {TermStyle.reset},
        ),
        ColorToken(
          text: '',
          styles: {TermStyle.reset, TermStyle.bold},
        ),
      ]);
    });

    test('parse colors - rgb', () {
      final input = inputs[5];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: 'Red',
          styles: {},
          fgColor: RGBColor(255, 0, 0),
        ),
        ColorToken.emptyReset(),
      ]);
    });

    test('parse colors - no colors', () {
      final input = inputs[1];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(
          text: 'You are standing in a small clearing.',
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

