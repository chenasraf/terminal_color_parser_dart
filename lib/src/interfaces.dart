/// An interface for reading data of type T.
abstract class IReader<T> {
  /// Reads the next element of type T from the data source, and advances the position by one
  /// element.
  /// Returns the element read, or null if the end of the data source is reached.
  T? read();

  /// Peeks at the next element of type T from the data source without advancing the position.
  /// Returns the element peeked at, or null if the end of the data source is reached.
  T? peek();

  /// Returns the total length of the data source.
  int get length;

  /// Returns the current index position in the data source.
  int get index;

  /// Returns true if the end of the data source has been reached, false otherwise.
  bool get isDone;

  /// Sets the current index position in the data source to the specified value.
  ///
  /// @param originalIndex The index position to set.
  void setPosition(int originalIndex);
}
