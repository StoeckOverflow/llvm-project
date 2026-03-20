struct TypedVsLegacy {
  void mix(int) {}
  void mix(double) {}

  void ping() {}
  void ping(int) {}

  void selfOnly() {}
  void selfOnly(int) {}
  void selfOnly(double) {}

  void rewrite(char *) {}

  void partial(int, int *) {}
  void partial(int, double *) {}

  void singleZeroTyped() {}
  void singleZeroTyped(int) {}
};
