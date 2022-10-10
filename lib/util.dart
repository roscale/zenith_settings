extension InterleaveExt<T> on Iterable<T> {
  Iterable<T> interleave(T element) sync* {
    final it = iterator;
    if (it.moveNext()) {
      yield it.current;
    }
    while (it.moveNext()) {
      yield element;
      yield it.current;
    }
  }
}
