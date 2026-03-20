#ifndef SOME_BROKEN_LIB_H
#define SOME_BROKEN_LIB_H

struct DuplicateMethods {
  void legacy();
  void mixed(int);
  void mixed(double);
  void typed(int);
  void typed(double);
};

#endif // SOME_BROKEN_LIB_H
