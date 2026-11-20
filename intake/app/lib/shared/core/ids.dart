/// Creates stable IDs once, when a thing is first made, so retries can reuse
/// them. Injected so tests get predictable IDs.
class IdGenerator {
  IdGenerator();

  int _counter = 0;

  String next(String prefix) {
    _counter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}$_counter';
  }
}
