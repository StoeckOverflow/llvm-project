// XFAIL: *
// Position: -1 notes remain legacy-only in this implementation, so APINotes
// still cannot distinguish cv-qualified overloads by the implicit object type.
// RUN: rm -rf %t && mkdir -p %t
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadConstQual -fdisable-module-hash -fapinotes-modules -fsyntax-only -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -x c++
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadConstQual -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter OverloadConstQual::pick -x c++ | FileCheck --check-prefix=CHECK %s

#include "OverloadConstQual.h"

// CHECK: Dumping OverloadConstQual::pick:
// CHECK-NEXT: CXXMethodDecl {{.+}} pick 'int ()'
// CHECK-NEXT: UnavailableAttr {{.+}} <<invalid sloc>> "non-const pick unavailable"
// CHECK-NOT: "const pick unavailable"
// CHECK: Dumping OverloadConstQual::pick:
// CHECK-NEXT: CXXMethodDecl {{.+}} pick 'int () const'
// CHECK-NEXT: UnavailableAttr {{.+}} <<invalid sloc>> "const pick unavailable"
// CHECK-NOT: "non-const pick unavailable"
