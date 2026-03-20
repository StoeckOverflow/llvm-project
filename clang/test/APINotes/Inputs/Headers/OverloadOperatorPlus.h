struct OverloadOperatorPlus {
  OverloadOperatorPlus operator+(int) const { return {}; }
  OverloadOperatorPlus operator+(double) const { return {}; }
};
