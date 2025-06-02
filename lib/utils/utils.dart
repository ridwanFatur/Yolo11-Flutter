class Utils {
  static List<List<List<List<double>>>> createInputPlaceholder() {
    return List.generate(
      1,
      (_) => List.generate(
        640,
        (_) => List.generate(640, (_) => List.generate(3, (_) => 0.0)),
      ),
    );
  }

  static List<List<List<double>>> createOutputPlaceholder() {
    return List.generate(
      1,
      (_) => List.generate(84, (_) => List.generate(8400, (_) => 0.0)),
    );
  }
}
