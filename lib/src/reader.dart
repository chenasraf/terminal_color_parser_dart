import 'interfaces.dart';

/// A class that implements the IReader interface for reading strings.
class StringReader implements IReader<String> {
  /// The input string to be read.
  final String input;

  /// The current index of the reader.
  @override
  int index = 0;

  StringReader(this.input);

  /// The length of the input string.
  @override
  int get length => input.length;

  /// Returns true if the reader has reached the end of the input string.
  @override
  bool get isDone => index >= length;

  /// Returns the next character in the input string without advancing the index.
  @override
  String? peek() {
    if (isDone) {
      return null;
    }
    return input[index];
  }

  /// Returns the next character in the input string and advances the index.
  @override
  String? read() {
    if (isDone) {
      return null;
    }
    return input[index++];
  }

  /// Sets the current index of the reader.
  @override
  void setPosition(int position) {
    index = position;
  }
}
