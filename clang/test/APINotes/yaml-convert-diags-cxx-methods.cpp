// RUN: rm -rf %t
// RUN: not %clang_cc1 -fsyntax-only -fapinotes %s -I %S/Inputs/BrokenHeaders3 2>&1 | FileCheck %s

#include "SomeBrokenLib.h"

// CHECK: error: duplicate definition of C++ method note 'DuplicateMethods::legacy'
// CHECK: error: duplicate definition of C++ method note 'DuplicateMethods::typed(int)'
// CHECK-NOT: duplicate definition of C++ method note 'DuplicateMethods::mixed'
// CHECK-NOT: duplicate definition of C++ method note 'DuplicateMethods::typed(double)'
