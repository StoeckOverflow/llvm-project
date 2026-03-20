struct OverloadConstQual {
  int pick() { return 0; }
  int pick() const { return 1; }
};
