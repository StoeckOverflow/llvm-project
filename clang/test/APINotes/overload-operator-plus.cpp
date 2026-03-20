// RUN: rm -rf %t && mkdir -p %t
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadOperatorPlus -fdisable-module-hash -fapinotes-modules -fsyntax-only -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -x c++
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadOperatorPlus -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter OverloadOperatorPlus::operator+ -x c++ | FileCheck --check-prefix=CHECK %s

#include "OverloadOperatorPlus.h"

// CHECK: Dumping OverloadOperatorPlus::operator+:
// CHECK-NEXT: CXXMethodDecl {{.+}} operator+ 'OverloadOperatorPlus (int) const'
// CHECK-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK: UnavailableAttr {{.+}} <<invalid sloc>> "int operator+ unavailable"
// CHECK-NOT: "double operator+ unavailable"
// CHECK: Dumping OverloadOperatorPlus::operator+:
// CHECK-NEXT: CXXMethodDecl {{.+}} operator+ 'OverloadOperatorPlus (double) const'
// CHECK-NEXT: ParmVarDecl {{.+}} 'double'
// CHECK: UnavailableAttr {{.+}} <<invalid sloc>> "double operator+ unavailable"
// CHECK-NOT: "int operator+ unavailable"
