import 'interfaces.dart';

/// A class that implements the IReader interface for reading strings.
class StringReader implements IReader<String> {
  /// The input string to be read.
  final String input;

  @override
  int index = 0;

  StringReader(this.input);

  @override
  int get length => input.length;

  @override
  bool get isDone => index >= length;

  @override
  String? peek() {
    if (isDone) {
      return null;
    }
    return input[index];
  }

  @override
  String? read() {
    if (isDone) {
      return null;
    }
    return input[index++];
  }

  @override
  void setPosition(int position) {
    index = position;
  }
}
