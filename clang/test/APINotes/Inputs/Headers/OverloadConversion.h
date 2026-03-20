struct OverloadConversion {
  operator int() const { return 0; }
  operator double() const { return 0.0; }
};
